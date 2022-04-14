#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/bigarray.h>

// ======================== riot_time.ml stubs ======================
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
caml_riot_event_timeout(value v_timeout)
{
    CAMLparam1(v_timeout);
    uint64_t timeout = Int64_val(v_timeout);

    event_t *new_event;
    printf("Waiting for event for %lld microseconds\n\r", timeout);
    if (new_event = event_wait_timeout64(&QUEUE, timeout))
    {
        new_event->handler(new_event);
        uint16_t copy = event_flags;
        event_flags &= 0;
        CAMLreturn(Val_int(copy));
    }
    else
        printf("No event triggered, timeout expired\n\r");

    CAMLreturn(Val_int(0));
}

// ======================== netutils.ml stubs ======================
#include "../raw_tcp_sock/raw_tcp_sock.h"

CAMLprim value
caml_riot_write(value v_bigarray, value v_protnum, value v_len)
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
caml_riot_get_pkt(value v_bigarray)
{
    CAMLparam1(v_bigarray);
    uint8_t *ptr = (uint8_t *)Caml_ba_data_val(v_bigarray);
    memcpy(ptr, tcpbuf, sizeof(tcpbuf));
    CAMLreturn(0);
}

CAMLprim value
caml_riot_get_pkt_ips(value v_bigarray)
{
    CAMLparam1(v_bigarray);
    void *buf_ptr = Caml_ba_data_val(v_bigarray);
    get_addrs(buf_ptr);
    CAMLreturn0;
}

CAMLprim value
caml_riot_get_tp_hdr_size(value v_unit)
{
    CAMLparam0();
    // printf("(netstubs): tcp_hdr_size = %lu\n", tcp_hdr_size);

    CAMLreturn(Val_int(tcp_hdr_size));
}

CAMLprim value
caml_riot_get_mtu(value v_unit)
{
    CAMLparam0();
    CAMLreturn(Val_int(IPV6_MIN_MTU));
}

CAMLprim value
caml_riot_get_host_ips(value v_bigarray)
{
    CAMLparam0();
    void *data_ptr = Caml_ba_data_val(v_bigarray);
    unsigned int n = get_ips(data_ptr);
    CAMLreturn(Val_int(n));
}