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

open Lwt

module Abstract : sig
  type nanoseconds
  type event_queue_ptr
  type event_ptr

  val to_microseconds : int64 -> nanoseconds
  val to_event_queue_ptr : int64 -> event_queue_ptr
  val to_event_ptr : int64 -> event_ptr
  val of_event_ptr : event_ptr -> int64
end = struct
  type nanoseconds = int64
  type event_queue_ptr = int64
  type event_ptr = int64

  let to_microseconds v = v
  let to_event_queue_ptr v = v
  let to_event_ptr v = v
  let of_event_ptr v = v
end

open Abstract

external init_event_queue : unit -> event_queue_ptr
  = "mirage_initialize_event_queue"

external get_event_queue : unit -> event_queue_ptr = "mirage_get_event_queue"

external riot_yield : event_queue_ptr -> nanoseconds -> event_ptr
  = "mirage_riot_yield"

external sleep : nanoseconds -> unit = "mirage_riot_sleep"
external post_event : event_queue_ptr -> unit = "mirage_riot_post_event"
external get_event_set : unit -> int = "caml_mirage_riot_event_set"
(* A Map from Int64 (solo5_handle_t) to an Lwt_condition. *)
(* module HandleMap = Map.Make (Int64)

   let work = ref HandleMap.empty *)

(* Wait for work on handle [h]. The Lwt_condition and HandleMap binding are
 * created lazily the first time [h] is waited on. *)
(* let wait_for_work_on_handle h =
   match HandleMap.find h !work with
   | exception Not_found ->
       let cond = Lwt_condition.create () in
       work := HandleMap.add h cond !work;
       Lwt_condition.wait cond
   | cond -> Lwt_condition.wait cond *)

(* Execute one iteration and register a callback function *)

(* let run t =
   let rec aux () =
     Lwt.wakeup_paused ();
     Time.restart_threads Time.time;
     match Lwt.poll t with
     | Some () -> ()
     | None ->
         (* Call enter hooks. *)
         Mirage_runtime.run_enter_iter_hooks ();
         let timeout =
           match Time.select_next () with
           | None -> Int64.add (Time.time ()) (Duration.of_day 1)
           | Some tm -> tm
         in
         let ready_set = riot_yield timeout in
         (if not (Int64.equal 0L ready_set) then
          (* Some I/O is possible, wake up threads and continue. *)
          let is_in_set set x =
            not Int64.(equal 0L (logand set (shift_left 1L (to_int x))))
          in
          HandleMap.iter
            (fun k v ->
              if is_in_set ready_set k then Lwt_condition.broadcast v ())
            !work);
         (* Call leave hooks. *)
         Mirage_runtime.run_leave_iter_hooks () ;
         aux ()
   in
   aux () *)

let ( / ) = Int64.div
let ( - ) = Int64.sub
let event_queue_ptr = get_event_queue ()

let run t =
  let rec aux () =
    Lwt.wakeup_paused ();
    Time.restart_threads Time.Monotonic.time;
    match Lwt.poll t with
    | Some () ->
        Printf.printf "main (): Program exitted\r\n%!";
        ()
    | None ->
        let timeout =
          (* Call enter hooks. *)
          Mirage_runtime.run_enter_iter_hooks ();
          match Time.select_next () with
          | None -> Int64.add (Time.Monotonic.time ()) (Duration.of_day 1)
          | Some tm -> tm
        in
        (* waits for events *)
        let remaining_time =
          timeout - Time.Monotonic.time () |> to_microseconds
        in
        (* sleep remaining_time; *)
        let event = riot_yield event_queue_ptr remaining_time in
        (* NEED TO DEFINE READY SET EVENTS *)
        (if of_event_ptr event > 0L then
         match get_event_set () with
         | 0 -> (*Uart.resolve*) failwith "got 0"
         | 1 -> Ip.resolve ()
         | _ -> raise Not_found);
        (* Call leave hooks. *)
        Mirage_runtime.run_leave_iter_hooks ();
        aux ()
  in
  aux ()

let print_callback ~src ~dst cs =
  Format.printf "\nsrc ip: %a | dst ip: %a\n%!" Ip.RIOT_IP.pp_ipaddr src
    Ip.RIOT_IP.pp_ipaddr dst;
  Tcp_riot.print_pkt cs;
  Lwt.return_unit

(* let () =
   at_exit (fun () ->
     Lwt.abandon_wakeups () ;
     run (Mirage_runtime.run_exit_hooks ())) *)

let () =
  (* let q = init_event_queue () in *)
  let open Ip.RIOT_IP in
  let open Lwt.Syntax in
  run
    (let* internal_state = connect () in
     listen internal_state ~tcp:print_callback)

(* set up 32bit ocaml *)
(* Use 64bit integers *)
(* Change to yield *)
(* wait for console events *)
(* Unix doesn't use UART, therefore the API for
   checking for a stdio event's are not available to be tested on
   Linux, hence the alternative is to spawn a separate thread
   that busy waits to check if there's an available IO and puts it
    on the event queue *)
(* Take note that for interrupt lines, these are at the hardware
   level that just turns on and off an interrupt line to signal that there
   is something waiting or not. *)

(* Add in Mirage hooks *)
(* Move events into OCaml code *)
(* Reimplement Handle Map to respond to events *)
(* Responding to network events *)
(* See if RIOT has console writing APIs with carridge return moving pointer to beginning *)