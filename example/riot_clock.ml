external time : unit -> int64 = "caml_get_monotonic_time"

let elapsed_ns () = Int64.mul (time ()) 1000L
let period_ns () = None
