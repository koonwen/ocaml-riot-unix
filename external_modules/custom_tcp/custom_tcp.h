#ifndef CUSTOM_IPV6_H
#define CUSTOM_IPV6_H
#include <stdio.h>
#include <string.h>

#include "net/gnrc.h"
// #include "net/gnrc/ipv6.h"
#include "net/gnrc/tcp.h"

#include "msg.h"
#include "sched.h"

#include "ocaml_event_sig.h"
#include "shared.h"

#define TCP_EVENTLOOP_PRIO (THREAD_PRIORITY_MAIN - 2U)
#define TCP_EVENTLOOP_STACK_SIZE (THREAD_STACKSIZE_DEFAULT)
kernel_pid_t custom_gnrc_tcp_init(void);

#endif
