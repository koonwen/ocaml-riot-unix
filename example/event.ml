open Lwt_result
open Cstruct

external getbyte : unit -> byte = "mirage_riot_getbyte"

let byte_buffer = ref (Buffer.create 16)

(* Right now the only flow we will use is from STDIO over UART *)
type flow = [ `UART ]
type error = Disconnect | Failed | Unknown
type 'a or_eof = [ `Data of 'a | `Eof ]

let my_data = `Data (Cstruct.string "hello")

(* Flow uses CStructs, try to follow the interface file*)
type thread =
  | CharResolver of byte Lwt.u
  | LineResolver of string Lwt.u
  | StreamResolver of (Cstruct.t or_eof, error) result Lwt.u

let ioq = ref (Queue.create ())

let read (t : flow) =
  let res, w = Lwt.wait () in
  Queue.push (StreamResolver w) !ioq;
  res

let readchar () =
  let res, w = Lwt.wait () in
  Queue.push (CharResolver w) !ioq;
  res

let readline () =
  let res, w = Lwt.wait () in
  Queue.push (LineResolver w) !ioq;
  res

let resolve () =
  match Queue.peek_opt !ioq with
  | None -> Printf.printf "No waiting thread, ignoring...\n\r%!"
  | Some (CharResolver w) ->
      let _ = Queue.pop !ioq in
      Lwt.wakeup w @@ getbyte ()
  | Some (LineResolver w) ->
      let open Buffer in
      let c = getbyte () in
      if Char.(c = chr 13 || c = chr 10) then (
        let _ = Queue.pop !ioq in
        add_utf_8_uchar !byte_buffer (Uchar.of_char '\n');
        Lwt.wakeup w (contents !byte_buffer);
        clear !byte_buffer)
      else add_utf_8_uchar !byte_buffer (Uchar.of_char c)
  | Some (StreamResolver w) ->
      let c = getbyte () in
      if c = byte 4 then (
        let b = `Data (Buffer.to_bytes !byte_buffer |> of_bytes) in
        Lwt.wakeup w (Ok b);
        Buffer.clear !byte_buffer)
      else if Char.(c = chr 13 || c = chr 10) then
        Buffer.add_utf_8_uchar !byte_buffer (Uchar.of_char '\n')
      else Buffer.add_utf_8_uchar !byte_buffer (Uchar.of_char c)
