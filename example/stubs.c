#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/bigarray.h>

// ======================== time.ml stubs ======================
#include "xtimer.h"
// Get monotonic time in microseconds since timer started
CAMLprim value
caml_get_monotonic_time(value v_unit)
{
    CAMLparam1(v_unit);

    uint64_t time = xtimer_now_usec64();

    CAMLreturn(caml_copy_int64(time));
}

// ======================== event_loop.ml stubs ======================
#include "../ocaml_event_sig/ocaml_event_sig.h"

CAMLprim value
riot_event_timeout(value v_timeout)
{
    CAMLparam1(v_timeout);
    uint64_t timeout = Int64_val(v_timeout);

    event_t *new_event;
    printf("Waiting for event for %lld microseconds\n\r", timeout);
    if (new_event = event_wait_timeout64(&QUEUE, timeout))
        new_event->handler(new_event);
    else
        printf("No event triggered, timeout expired\n\r");
    CAMLreturn(caml_copy_int64(new_event));
}

// ======================== riot_ip.ml stubs ======================
#include "../raw_tcp_sock/raw_tcp_sock.h"
#define MTU (IPV6_MIN_MTU)

CAMLprim value
caml_mirage_riot_get_packet(value v_bigarray)
{
    CAMLparam1(v_bigarray);
    uint8_t *ptr = (uint8_t *)Caml_ba_data_val(v_bigarray);
    memcpy(ptr, tcpbuf, sizeof(tcpbuf));
    CAMLreturn(0);
}

CAMLprim value
caml_mirage_riot_get_tcp_hdr_size(value v_unit)
{
    CAMLparam0();
    // printf("(netstubs): tcp_hdr_size = %lu\n", tcp_hdr_size);

    CAMLreturn(Val_int(tcp_hdr_size));
}

CAMLprim value
caml_mirage_riot_write(value v_bigarray, value v_protnum, value v_len)
{
    CAMLparam3(v_bigarray, v_protnum, v_len);
    void *data_ptr = Caml_ba_data_val(v_bigarray);
    ssize_t bytes_written =
        sock_ip_send(&tcp_sock, data_ptr, Int_val(v_len), v_protnum, &tcp_remote);
    if (bytes_written == Int_val(v_len))
    {
        CAMLreturn(Val_int(1));
    }
    CAMLreturn(Val_int(-1));
}

CAMLprim value
caml_mirage_riot_get_mtu(value v_unit)
{
    CAMLparam0();
    CAMLreturn(Val_int(MTU));
}

// deprecated
CAMLprim value
caml_mirage_riot_event_set(value v_unit)
{
    CAMLparam0();
    CAMLreturn(Val_int(event_set));
}

CAMLprim value
caml_mirage_riot_get_ips(value v_bigarray)
{
    CAMLparam0();
    void *data_ptr = Caml_ba_data_val(v_bigarray);
    unsigned int n = get_ips(data_ptr);
    CAMLreturn(Val_int(n));
}

CAMLprim value
caml_mirage_riot_get_addr(value v_bigarray, value v_mode)
{
    CAMLparam2(v_bigarray, v_mode);
    void *buf_ptr = Caml_ba_data_val(v_bigarray);
    int res = get_addr(buf_ptr, Int_val(v_mode));
    CAMLreturn(Val_int(res));
}