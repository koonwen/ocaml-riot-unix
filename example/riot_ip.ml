open Cstruct
open Map
open Lwt
open Netutils

let protocol_to_int = function `ICMP -> 58 | `TCP -> 6 | `UDP -> 17
let of_origin = function `Src -> 0 | `Dst -> 1
let cs = ref (Cstruct.create 128)
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

  let default_payload_size = 128

  type error = [ Tcpip.Ip.error | `Unimplemented ]

  let pp_error ppf = function
    | `Unimplemented -> Fmt.pf ppf "Unimplemented"
    | (`No_route _ | `Would_fragment) as v -> Tcpip.Ip.pp_error ppf v

  let disconnect t = Lwt.return_unit

  type callback = src:ipaddr -> dst:ipaddr -> Cstruct.t -> unit Lwt.t

  let input t ~tcp ~udp ~default buf = failwith "Not required for RIOT stack"

  let write t ?(fragment = false) ?(ttl = 1) ?(src = List.hd t.ip_lst) ipaddr
      proto ?(size = default_payload_size) headerf payloads =
    if size > default_payload_size then Lwt.return_error `Would_fragment
    else
      let cs = Cstruct.create size in
      let i = headerf cs in
      let cs = Cstruct.sub cs 0 i in
      let pkt = cs :: payloads in
      let buf = Cstruct.concat pkt in
      match proto with
      | `TCP ->
          if TcpUtils.riot_write (buf |> Cstruct.to_bigarray) i > 0 then
            Lwt.return_ok ()
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
                 (* Printf.printf "IP = %s\n%!" @@ Ipaddr.V6.to_string ip; *)
                 ipaddr_lst := !ipaddr_lst @ [ ip ]
               done;
               !ipaddr_lst);
      }

  let listen t ~(tcp : callback) =
    let ip_cs = Cstruct.create 16 in
    let ip_buf = Cstruct.to_bigarray ip_cs in
    let payload_cs = Cstruct.create 128 in
    let payload_buf = Cstruct.to_bigarray payload_cs in
    let open Lwt.Syntax in
    let rec aux () =
      Printf.printf "Looping\n%!";
      let* _ = Lwt_condition.wait con in
      assert (IpUtils.riot_get_pkt_ips ip_buf = 0);
      assert (IpUtils.riot_get_pkt payload_buf = 0);
      (* Tcp_riot.print_pkt payload_cs; *)
      Printf.printf "\nResizing packet to %d\n%!"
        (IpUtils.riot_get_tp_hdr_size ());
      let new_cs = Cstruct.sub payload_cs 0 (IpUtils.riot_get_tp_hdr_size ()) in
      let src = t.ip_lst |> List.hd in
      let dst = IpUtils.ipv6_of_cs ip_cs in
      Lwt.async (fun () -> tcp ~src ~dst new_cs);
      aux ()
    in
    aux ()
end

let resolve () =
  let get_data () = IpUtils.riot_get_pkt (Cstruct.to_bigarray !cs) in
  (match get_data () with 0 -> () | _ -> raise Not_found);
  Lwt_condition.signal con 1