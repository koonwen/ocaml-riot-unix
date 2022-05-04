open Cstruct
open Map
open Lwt
open Netutils

let protocol_to_int = function `ICMP -> 58 | `TCP -> 6 | `UDP -> 17
let of_origin = function `Src -> 0 | `Dst -> 1
let con = Lwt_condition.create ()

module S : sig
  include Tcpip.Ip.S

  (* Connect only to TCPIP stack, UDP not yet implemented *)
  val connect : unit -> t Lwt.t
  val listen : t -> tcp:callback -> unit Lwt.t
end = struct
  type ipaddr = Ipaddr.V6.t

  let pp_ipaddr = Ipaddr.V6.pp

  (* Witness of the interface *)
  type t = {
    ipv6_only : bool;
    icmp : bool;
    tcp : bool;
    udp : bool;
    ip_lst : ipaddr list;
  }

  type error = [ Tcpip.Ip.error | `Unimplemented | `Exceeded_MTU ]

  let pp_error ppf = function
    | `Exceeded_MTU -> Fmt.pf ppf "Exceeded MTU"
    | `Unimplemented -> Fmt.pf ppf "Unimplemented"
    | (`No_route _ | `Would_fragment) as v -> Tcpip.Ip.pp_error ppf v

  let disconnect t = fail_with "Not implemented"

  type callback = src:ipaddr -> dst:ipaddr -> Cstruct.t -> unit Lwt.t

  let input t ~tcp ~udp ~default buf = failwith "Not required for RIOT stack"
  let maximum_transfer_unit = Netutils.IpUtils.riot_get_mtu ()

  let write t ?(fragment = true) ?(ttl = 1) ?(src = List.hd t.ip_lst) ipaddr
      proto ?(size = 0) headerf payloads =
    let cs = Cstruct.create size in
    let ip_hdr_len = headerf cs in
    if size + ip_hdr_len > maximum_transfer_unit then
      Lwt.return_error `Exceeded_MTU
    else
      let cs = Cstruct.sub cs 0 ip_hdr_len in
      let pkt = cs :: payloads in
      let buf = Cstruct.concat pkt in
      match proto with
      | `TCP ->
          if TcpUtils.riot_write (buf |> Cstruct.to_bigarray) ip_hdr_len > 0
          then Lwt.return_ok ()
          else Lwt.return_error `Unimplemented
      | _ -> Lwt.return_error `Unimplemented

  let pseudoheader t ?(src = List.hd t.ip_lst) dst proto len =
    let ph = Cstruct.create (16 + 16 + 8) in
    IpUtils.ipaddr_to_cstruct_raw src ph 0;
    IpUtils.ipaddr_to_cstruct_raw dst ph 16;
    Cstruct.BE.set_uint32 ph 32 (Int32.of_int len);
    Cstruct.set_uint8 ph 36 0;
    Cstruct.set_uint8 ph 37 0;
    Cstruct.set_uint8 ph 38 0;
    Cstruct.set_uint8 ph 39 (protocol_to_int `TCP);
    ph

  let src t ~(dst : ipaddr) = List.hd t.ip_lst
  let get_ip t = t.ip_lst
  let mtu t ~(dst : ipaddr) = IpUtils.riot_get_mtu ()

  let connect () =
    Lwt.return
      {
        ipv6_only = true;
        icmp = true;
        tcp = true;
        udp = false;
        ip_lst =
          (let cs = Cstruct.create 32 in
           match NetifUtils.riot_get_host_ips (Cstruct.to_bigarray cs) with
           | 0 -> failwith "Error occured getting ips"
           | n ->
               let ipaddr_lst = ref [] in
               for off = 0 to n - 1 do
                 let ip = IpUtils.ipv6_of_cs ~off cs in
                 Printf.printf "IP = %s\n%!" @@ Ipaddr.V6.to_string ip;
                 ipaddr_lst := !ipaddr_lst @ [ ip ]
               done;
               !ipaddr_lst);
      }

  let listen t ~(tcp : callback) =
    let open Lwt.Syntax in
    let rec aux () =
      let* _ = Lwt_condition.wait con in
      let payload = IpUtils.get_payload () in
      let _, dst = IpUtils.get_pkt_ips () in
      let src = List.hd t.ip_lst in
      Lwt.async (fun () -> tcp ~src ~dst payload);
      aux ()
    in
    aux ()
end

let resolve =
  let cs = ref (Cstruct.create IpUtils.bufsiz) in
  let resolve_helper () =
    let get_data () = IpUtils.riot_get_pkt (Cstruct.to_bigarray !cs) in
    (match get_data () with 0 -> () | _ -> raise Not_found);
    Lwt_condition.signal con 1
  in
  resolve_helper