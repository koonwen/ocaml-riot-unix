open Lwt

module Abstract : sig
  type event_ptr

  val is_valid : event_ptr -> bool
end = struct
  type event_ptr = int64

  let is_valid = function _ -> true
end

open Abstract

external riot_yield : int64 -> event_ptr = "riot_event_timeout"

let run t =
  let rec aux () =
    Lwt.wakeup_paused ();
    Time.restart_threads Time.Monotonic.time;
    match Lwt.poll t with
    | Some () -> Printf.printf "main () exitted"
    | None ->
        let timeout =
          (* Call enter hooks. *)
          Mirage_runtime.run_enter_iter_hooks ();
          match Time.select_next () with
          | None -> Int64.add (Time.Monotonic.time ()) (Duration.of_day 1)
          | Some tm -> Int64.sub tm (Time.Monotonic.time ())
        in
        (* sleep remaining_time; *)
        let event = riot_yield timeout in
        (* NEED TO DEFINE READY SET EVENTS *)
        if is_valid event then Riot_ip.resolve ()
        else failwith "event_ptr error";
        (* Call leave hooks. *)
        Mirage_runtime.run_leave_iter_hooks ();
        aux ()
  in
  aux ()