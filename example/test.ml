(* module Make (TCP : Tcpip.Tcp.S) (Ipv6 : Ip.S) = struct
        type t = { ipv6 : Ipv6.t; tcpv6 : TCP.t }

        let connect ipv6 tcpv6 =
          let t = { ipv6; tcpv6 } in
          Lwt.return t

        let listen t = Ipv6.listen t.ipv6 ~tcp:(TCP.input t.tcpv6)
      end *)

module TCP = Tcp.Flow.Make (Ip.RIOT_IP) (Time) (Mclock) (Mirage_random_stdlib)
open Lwt.Syntax
open Lwt

let cb flow = return_unit
let listen ip tcp = Ip.RIOT_IP.listen ip ~tcp:(TCP.input tcp)

let () =
  Main.run
    (let* ip = Ip.RIOT_IP.connect () in
     let* tcp = TCP.connect ip in
     TCP.listen tcp ~port:8000 cb;
     listen ip tcp >>= fun _ -> return_unit)
