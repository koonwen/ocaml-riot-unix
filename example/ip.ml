open Cstruct
open Map
open Lwt

type origin = Src | Dst

let of_origin = function Src -> 0 | Dst -> 1

external riot_get_packet : Cstruct.buffer -> int = "caml_mirage_riot_get_packet"
external riot_get_ips : Cstruct.buffer -> int = "caml_mirage_riot_get_ips"
external riot_get_mtu : unit -> int = "caml_mirage_riot_get_mtu"
external riot_write : Cstruct.buffer -> int -> int = "caml_mirage_riot_write"

external riot_get_addrs : Cstruct.buffer -> int -> int
  = "caml_mirage_riot_get_addr"

module IpUtils = struct
  let ip_of_cs ?(off = 0) cs =
    let pre = Cstruct.BE.get_uint64 cs ((8 * off) + 0) in
    let mul = Cstruct.BE.get_uint64 cs ((8 * off) + 8) in
    Ipaddr.V6.of_int64 (pre, mul)
end

let cs = ref (Cstruct.create 128)
let con = Lwt_condition.create ()

module type S = sig
  include Tcpip.Ip.S

  (* Connect only to TCPIP stack, UDP not yet implemented *)
  val connect : unit -> t Lwt.t
  val listen : t -> tcp:callback -> unit Lwt.t
end

module RIOT_IP : S = struct
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

  let input t ~(tcp : callback) ~(udp : callback)
      ~(default : proto:int -> callback) (buf : Cstruct.t) : unit Lwt.t =
    failwith "Not implemented"

  let write (t : t) ?(fragment : bool = false) ?(ttl : int = 1)
      ?(src : ipaddr = List.hd t.ip_lst) (ipaddr : ipaddr)
      (proto : Tcpip.Ip.proto) ?(size : int = default_payload_size)
      (headerf : Cstruct.t -> int) (payloads : Cstruct.t list) =
    if size > default_payload_size then Lwt.return_error `Would_fragment
    else
      let cs = Cstruct.create size in
      let cs_buf = Cstruct.to_bigarray cs in
      match proto with
      | `TCP ->
          if riot_write cs_buf size > 0 then Lwt.return_ok ()
          else Lwt.return_error `Unimplemented
      | _ -> Lwt.return_error `Unimplemented

  let pseudoheader (t : t) ?(src : ipaddr = List.hd t.ip_lst) (ipaddr : ipaddr)
      (proto : Tcpip.Ip.proto) (i : int) : Cstruct.t =
    failwith "pseudoheader Not implemented"

  let src (t : t) ~(dst : ipaddr) : ipaddr = List.hd t.ip_lst
  let get_ip (t : t) : ipaddr list = t.ip_lst
  let mtu (t : t) ~(dst : ipaddr) : int = riot_get_mtu ()

  let connect () =
    Lwt.return
      {
        ipv6_only = true;
        icmp = true;
        tcp = true;
        udp = false;
        ip_lst =
          (let cs = Cstruct.create 32 in
           match riot_get_ips (Cstruct.to_bigarray cs) with
           | 0 -> failwith "Error occured getting ips"
           | n ->
               let ipaddr_lst = ref [] in
               for off = 0 to n - 1 do
                 let ip = IpUtils.ip_of_cs ~off cs in
                 (* Printf.printf "IP = %s\n%!" @@ Ipaddr.V6.to_string ip; *)
                 ipaddr_lst := !ipaddr_lst @ [ ip ]
               done;
               !ipaddr_lst);
      }

  let listen t ~(tcp : callback) =
    let src_cs = Cstruct.create 16 in
    let dst_cs = Cstruct.create 16 in
    let payload_cs = Cstruct.create 128 in
    let open Lwt.Syntax in
    let rec aux () =
      Printf.printf "Looping\n%!";
      let* _ = Lwt_condition.wait con in
      assert (riot_get_addrs (Cstruct.to_bigarray src_cs) (of_origin Src) = 0);
      assert (riot_get_addrs (Cstruct.to_bigarray dst_cs) (of_origin Dst) = 0);
      assert (riot_get_packet (Cstruct.to_bigarray payload_cs) = 0);
      let src = IpUtils.ip_of_cs src_cs in
      let dst = IpUtils.ip_of_cs dst_cs in
      tcp ~src ~dst payload_cs >>= aux
    in
    aux ()
end

(* let reg_net_event () =
   let res, w = Lwt.wait () in
   glb_w := Some w;
   res *)

let resolve () =
  let get_data () = riot_get_packet (Cstruct.to_bigarray !cs) in
  (match get_data () with
  | 0 -> print_endline "successfully got data"
  | _ -> raise Not_found);
  Lwt_condition.signal con 1
(* Lwt_mvar.put mbox !cs; *)
(* let w = Queue.pop !netq in
   let w = Option.get !glb_w in
      glb_w := None;
      Lwt.wakeup w !cs *)
