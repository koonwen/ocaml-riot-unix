(* Lightweight thread library for Objective Caml
* http://www.ocsigen.org/lwt
* Module Lwt_main
* Copyright (C) 2009 Jérémie Dimino
 * Copyright (C) 2010 Anil Madhavapeddy <anil@recoil.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, with linking exceptions;
 * either version 2.1 of the License, or (at your option) any later
 * version. See COPYING file for details.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 * 02111-1307, USA.
 *)
open Lwt.Syntax
open Lwt

let () =
  Logs.set_level (Some Debug);
  Logs.set_reporter (Logs_fmt.reporter ())

module RIOT_stack = struct
  module IP = Riot_ip.S

  module TCP =
    Tcp.Flow.Make (Riot_ip.S) (Riot_time.S) (Riot_clock.MCLOCK)
      (Mirage_random_stdlib)

  let listen ip tcp = Riot_ip.S.listen ip ~tcp:(TCP.input tcp)
end

let echo_cb (flow : RIOT_stack.TCP.flow) =
  let rec aux flow =
    let* res = RIOT_stack.TCP.read flow in
    let data_in =
      match res with Ok v -> v | Error e -> failwith "Failed to read data"
    in
    let* write_out =
      match data_in with
      | `Data d -> RIOT_stack.TCP.write_nodelay flow d
      | `Eof -> return_ok ()
    in
    match write_out with Ok _ -> aux flow | _ -> failwith "Write Error!"
  in
  aux flow

let () =
  Event_loop.run
    (let* ip = RIOT_stack.IP.connect () in
     let* tcp = RIOT_stack.TCP.connect ip in
     RIOT_stack.TCP.listen tcp ~port:8000 echo_cb;
     RIOT_stack.listen ip tcp >>= fun _ -> return_unit)

(* let () =
   at_exit (fun () ->
     Lwt.abandon_wakeups () ;
     run (Mirage_runtime.run_exit_hooks ())) *)
