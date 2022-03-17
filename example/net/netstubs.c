// #define CAML_NAME_SPACE
// #include <caml/mlvalues.h>
// #include <caml/memory.h>
// #include <caml/alloc.h>
// #include <caml/custom.h>
// #include "net/sock/ip.h"

// sock_ip_ep_t local;
// sock_ip_ep_t remote;
// sock_ip_t sock;
// char buf[BUFSIZ];

// CAMLprim value
// caml_get_mtu(value v_unit)
// {
//     CAMLparam1(v_unit);
//     CAMLreturn(caml_copy_int64(IPV6_MIN_MTU));
// }

// CAMLprim value
// caml_sock_ip_create(value unit)
// {
//     CAMLparam0();
//     local = SOCK_IPV6_EP_ANY;
//     if (sock_ip_create(&sock, &local, NULL, PROTNUM_IPV6_NONXT, 0) < 0)
//     {
//         puts("Error creating raw IP sock");
//         CAMLreturn(caml_copy_int64(1));
//     }
//     CAMLreturn(caml_copy_int64(&sock));
// }

// CAMLprim value
// caml_sock_ip_recv_aux(value unit)
// {
//     CAMLparam0();
//     ssize_t res = sock_ip_recv_aux(&local, buf, BUFSIZ, SOCK_NO_TIMEOUT, &remote, NULL);
//     CAMLreturn(caml_copy_int64(res));
// }