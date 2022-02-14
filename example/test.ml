(* Lwt test program *)
let p : unit Lwt.t =
  let open Lwt.Syntax in
  let open Lwt in
  let rec timer ~(name : string) ~(time : int) : unit Lwt.t =
    Time.sleep_ns 2_000_000_000L >>= fun _ ->
    if time > 0 then (
      Printf.printf "%s: %d\n%!" name time;
      timer ~name ~time:(time - 1))
    else (
      print_endline "TIMER DONE";
      return ())
  in
  let me = timer ~name:"foo" ~time:5 in
  let you = timer ~name:"bar" ~time:5 in
  Lwt.join [ me; you ]

(* Test program for adding events *)
(* let q =
   let event_queue = init_event_queue () in
   post_event event_queue;
   let result = riot_yield event_queue 2_000_000L in
   post_event event_queue;
   let result2 = riot_yield event_queue 2_000_000L in
   (* let _ = riot_yield event_queue 2_000_000L in *)
   print_endline "IM FINISHED" *)