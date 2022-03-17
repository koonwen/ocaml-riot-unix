(* open Tcpip.Ip

   module RIOT_IP : Tcpip.Ip.S = struct
     type nonrec error = private [> error ]

     let pp_error : error Fmt.t = failwith ""

     type ipaddr

     let pp_ipaddr : ipaddr Fmt.t = failwith ""

     type t

     let disconnect : t -> unit Lwt.t = failwith ""

     type callback = src:ipaddr -> dst:ipaddr -> Cstruct.t -> unit Lwt.t

     let input :
         t ->
         tcp:callback ->
         udp:callback ->
         default:(proto:int -> callback) ->
         Cstruct.t ->
         unit Lwt.t =
       failwith ""

     let write :
         t ->
         ?fragment:bool ->
         ?ttl:int ->
         ?src:ipaddr ->
         ipaddr ->
         proto ->
         ?size:int ->
         (Cstruct.t -> int) ->
         Cstruct.t list ->
         (unit, error) result Lwt.t =
       failwith ""

     let pseudoheader : t -> ?src:ipaddr -> ipaddr -> proto -> int -> Cstruct.t =
       failwith ""

     let src : t -> dst:ipaddr -> ipaddr = failwith ""
     let get_ip : t -> ipaddr list = failwith ""
     let mtu : t -> dst:ipaddr -> int = failwith ""
   end *)
