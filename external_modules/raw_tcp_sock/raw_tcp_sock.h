#ifndef RAW_TCP_SOCK_H
#define RAW_TCP_SOCK_H
#include <stdio.h>
#include <string.h>

#include "net/gnrc/ipv6.h"
#include "net/gnrc/pkt.h"
#include "net/ipv6.h"
#include "net/sock/ip.h"

#include "msg.h"
#include "sched.h"

#include "../ocaml_event_sig/ocaml_event_sig.h"

#define TCP_EVENTLOOP_PRIO (THREAD_PRIORITY_MAIN - 2)

extern sock_ip_ep_t tcp_local;
extern sock_ip_ep_t tcp_remote;
extern sock_ip_t tcp_sock;
extern ssize_t tcp_hdr_size;

// Add sock_buffer_queue
// extern glb_tcp_queue_buf;

extern uint8_t tcpbuf[128];

void *raw_tcp_sock_thread(void *args);
void get_addrs(void *buf);
unsigned int get_ips(void *buf);

#endif