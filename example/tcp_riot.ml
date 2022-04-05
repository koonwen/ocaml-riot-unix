[%%cstruct
type tcp_hdr_t = {
  src_port : uint8_t; [@len 2]
  dst_port : uint8_t; [@len 2]
  sq_num : uint8_t; [@len 4]
  ack : uint8_t; [@len 4]
  do_rsv : uint8_t; [@len 1]
  flags : uint8_t; [@len 1]
  window : uint8_t; [@len 2]
  chksum : uint8_t; [@len 2]
  urg_ptr : uint8_t; [@len 2]
}
[@@big_endian]]

let pp_port ppf i = Fmt.pf ppf "port: %u" i
let pp_sq_num ppf i = Fmt.pf ppf "sq_num: %lu" i
let pp_ack ppf i = Fmt.pf ppf "ack: %lu" i

let pp_do_rsv ppf i =
  let data_off = Int.shift_right_logical i 4 in
  let rsv = Int.logand i 23 in
  Fmt.pf ppf "do: %d\nrsc: %d" data_off rsv

let pp_flags ppf i = Fmt.pf ppf "flags: %u" i
let pp_window ppf i = Fmt.pf ppf "window: %d" i
let pp_checksum ppf i = Fmt.pf ppf "checksum: %d" i
let pp_urg_ptr ppf i = Fmt.pf ppf "urgent pointer: %d" i

let pp_pkt ppf cs =
  Fmt.pf ppf "src %a | dst %a\n%a\n%a\n%a\n%a\n%a\n%a\n%a\n\n" pp_port
    (Cstruct.BE.get_uint16 cs 0)
    pp_port
    (Cstruct.BE.get_uint16 cs 2)
    pp_sq_num
    (Cstruct.BE.get_uint32 cs 4)
    pp_ack
    (Cstruct.BE.get_uint32 cs 8)
    pp_do_rsv (Cstruct.get_uint8 cs 16) pp_flags (Cstruct.get_uint8 cs 17)
    pp_window
    (Cstruct.BE.get_uint16 cs 18)
    pp_checksum
    (Cstruct.BE.get_uint16 cs 20)
    pp_urg_ptr
    (Cstruct.BE.get_uint16 cs 22)

let print_pkt tcp_pkt = Format.printf "%a" pp_pkt tcp_pkt
