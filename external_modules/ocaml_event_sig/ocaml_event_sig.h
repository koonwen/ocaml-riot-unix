#ifndef EVENT_QUEUE_H
#define EVENT_QUEUE_H
#include "event.h"

#include "debug.h"
#define ENABLE_DEBUG (1)

extern event_queue_t QUEUE;

// TODO Change this to a simple event set on individual bits
// extern union event_set
// {
//     /* data */
// };
extern uint16_t event_set;

void add_net_event(void *args);
void net_handler(void *arg);

#endif