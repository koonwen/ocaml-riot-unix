module MCLOCK : Mirage_clock.MCLOCK = struct
  external time : unit -> int64 = "caml_get_monotonic_time"

  let elapsed_ns () = Int64.mul (time ()) 1000L
  let period_ns () = failwith "[period_ns] unimplemented\n"
end
