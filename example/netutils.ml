module TcpUtils = struct
  [%%cstruct
  type tcp_hdr_t = {
    src_port : uint8_t; [@len 2]
    dst_port : uint8_t; [@len 2]
    sq_num : uint8_t; [@len 4]
    ack : uint8_t; [@len 4]
    do_rsv_flags : uint8_t; [@len 2]
    window : uint8_t; [@len 2]
    chksum : uint8_t; [@len 2]
    urg_ptr : uint8_t; [@len 2]
  }
  [@@big_endian]]

  let pp_port ppf i = Fmt.pf ppf "port: %u" i
  let pp_sq_num ppf i = Fmt.pf ppf "sq_num: %lu" i
  let pp_ack ppf i = Fmt.pf ppf "ack: %lu" i

  let pp_do_rsv_flags ppf i =
    let data_off = Int.shift_right_logical i 12 in
    (* let reserved = Int.shift_left i 4 |> Int.shift_right_logical 10 in *)
    let flags = Int.logand i 63 in
    Fmt.pf ppf "do: %d\nflags: 0x%x" data_off flags

  let pp_window ppf i = Fmt.pf ppf "window: %d" i
  let pp_checksum ppf i = Fmt.pf ppf "checksum: 0x%x" i
  let pp_urg_ptr ppf i = Fmt.pf ppf "urgent pointer: %d" i

  let pp_pkt ppf cs =
    Fmt.pf ppf "src %a | dst %a\n%a\n%a\n%a\n%a\n%a\n%a\n\n" pp_port
      (Cstruct.BE.get_uint16 cs 0)
      pp_port
      (Cstruct.BE.get_uint16 cs 2)
      pp_sq_num
      (Cstruct.BE.get_uint32 cs 4)
      pp_ack
      (Cstruct.BE.get_uint32 cs 8)
      pp_do_rsv_flags
      (Cstruct.BE.get_uint16 cs 12)
      pp_window
      (Cstruct.BE.get_uint16 cs 14)
      pp_checksum
      (Cstruct.BE.get_uint16 cs 16)
      pp_urg_ptr
      (Cstruct.BE.get_uint16 cs 18)

  let print_pkt tcp_pkt = Format.printf "%a" pp_pkt tcp_pkt
end

module IpUtils = struct
  let ip_of_cs ?(off = 0) cs =
    let pre = Cstruct.BE.get_uint64 cs ((8 * off) + 0) in
    let mul = Cstruct.BE.get_uint64 cs ((8 * off) + 8) in
    Ipaddr.V6.of_int64 (pre, mul)

  let ipaddr_to_cstruct_raw i cs off =
    let a, b, c, d = Ipaddr.V6.to_int32 i in
    Cstruct.BE.set_uint32 cs (0 + off) a;
    Cstruct.BE.set_uint32 cs (4 + off) b;
    Cstruct.BE.set_uint32 cs (8 + off) c;
    Cstruct.BE.set_uint32 cs (12 + off) d
end