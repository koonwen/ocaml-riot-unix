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

#include "ocaml_event_sig.h"
#include "shared.h"

#define TCP_EVENTLOOP_PRIO (THREAD_PRIORITY_MAIN - 2)
#define TCPBUFSIZ 255

// The size of this buffer needs to match the size of the CStruct created in OCaml
extern uint8_t tcpbuf[TCPBUFSIZ];
extern sock_ip_ep_t tcp_local;
extern sock_ip_ep_t tcp_remote;
extern sock_ip_t tcp_sock;
extern ssize_t tcp_hdr_size;

void *raw_tcp_sock_thread(void *args);
void get_addrs(void *buf);
unsigned int get_ips(void *buf);

#endif