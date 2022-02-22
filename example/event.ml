open Lwt
open Cstruct

external getbyte : unit -> byte = "mirage_riot_getbyte"

type thread = Cresolver of byte Lwt.u | Sresolver of string Lwt.u

let ioq = ref (Queue.create ())
let string_buffer = ref (Buffer.create 16)

(* Flow uses CStructs, try to follow the interface file
   let test_buf = Cstruct.create 16 *)

let readchar () =
  let res, w = Lwt.wait () in
  Queue.push (Cresolver w) !ioq;
  res

let readline () =
  let res, w = Lwt.wait () in
  Queue.add (Sresolver w) !ioq;
  res

let resolve () =
  match Queue.peek_opt !ioq with
  | None -> Printf.printf "No waiting thread, ignoring...\n\r%!"
  | Some (Cresolver w) ->
      let _ = Queue.pop !ioq in
      Lwt.wakeup w @@ getbyte ()
  | Some (Sresolver w) ->
      let open Buffer in
      let c = getbyte () in
      if Char.(c = chr 13 || c = chr 10) then (
        let _ = Queue.pop !ioq in
        add_utf_8_uchar !string_buffer (Uchar.of_char '\n');
        Lwt.wakeup w (contents !string_buffer);
        clear !string_buffer)
      else add_utf_8_uchar !string_buffer (Uchar.of_char c)
