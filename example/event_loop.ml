open Lwt

external riot_event_timeout : int64 -> int = "caml_riot_event_timeout"

let net_ev = 01
let ( & ) = Int.logand

let run t =
  let rec aux () =
    Lwt.wakeup_paused ();
    Riot_time.restart_threads Riot_time.Monotonic.time;
    match Lwt.poll t with
    | Some () -> Printf.printf "main () exitted"
    | None ->
        let timeout =
          (* Call enter hooks. *)
          Mirage_runtime.run_enter_iter_hooks ();
          match Riot_time.select_next () with
          | None -> Int64.add (Riot_time.Monotonic.time ()) (Duration.of_day 1)
          | Some tm -> Int64.sub tm (Riot_time.Monotonic.time ())
        in
        (* sleep remaining_time; *)
        let event_flags = riot_event_timeout timeout in
        if (event_flags & net_ev) > 0 then Riot_ip.resolve ();
        (* Call leave hooks. *)
        Mirage_runtime.run_leave_iter_hooks ();
        aux ()
  in
  aux ()