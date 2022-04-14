#ifndef EVENT_QUEUE_H
#define EVENT_QUEUE_H
#include "event.h"
#include "shared.h"

#define UART_EV 01
#define NET_EV 02
extern uint16_t event_flags;

extern event_queue_t QUEUE;

void add_net_event(void *args);
void net_handler(void *arg);

#endif