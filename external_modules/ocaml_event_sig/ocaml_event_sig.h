#ifndef EVENT_QUEUE_H
#define EVENT_QUEUE_H
#include "event.h"
#include "shared.h"

#define NET_EV 01
extern uint16_t event_flags;

extern event_queue_t QUEUE;

void add_net_event(void *args);

#endif