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
open Cohttp

let () =
  Logs.set_level (Some Debug);
  Logs.set_reporter (Logs_fmt.reporter ())

module RIOT_stack = struct
  module IP = Riot_ip.S

  module TCP =
    Tcp.Flow.Make (Riot_ip.S) (Riot_time.S) (Riot_clock.MCLOCK)
      (Mirage_random_stdlib)

  module Http_server = struct
    include Cohttp_mirage.Server.Flow (TCP)

    let create ip tcp ~port http =
      TCP.listen tcp ~port (callback http);
      IP.listen ip ~tcp:(TCP.input tcp)
  end
end

let server =
  let callback _conn req body =
    let uri = req |> Request.uri |> Uri.to_string in
    let meth = req |> Request.meth |> Code.string_of_method in
    let headers = req |> Request.headers |> Header.to_string in
    ( body |> Cohttp_lwt.Body.to_string >|= fun body ->
      Printf.sprintf "Uri: %s\nMethod: %s\nHeaders\nHeaders: %s\nBody: %s\n" uri
        meth headers body )
    >>= fun body -> RIOT_stack.Http_server.respond_string ~status:`OK ~body ()
  in
  RIOT_stack.Http_server.make ?conn_closed:None ~callback ()

let () =
  Event_loop.run
    (let* ip = RIOT_stack.IP.connect () in
     let* tcp = RIOT_stack.TCP.connect ip in
     RIOT_stack.Http_server.create ip tcp ~port:8000 server)

(* let () =
   at_exit (fun () ->
     Lwt.abandon_wakeups () ;
     run (Mirage_runtime.run_exit_hooks ())) *)
