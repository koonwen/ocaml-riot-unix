#include "ocaml_event_sig.h"

uint16_t event_flags;
// ===============================NET==================================
// Need to change this to copying information into a packet queue
void net_handler(void *arg)
{
    DEBUG("(Riot callback) triggered netevent handler in thread context\n", (unsigned)arg);
    if ((event_flags & NET_EV) > 0)
    {
        printf("Overlapping net event, dropping...\n");
    }
    event_flags |= NET_EV;
    return;
}

void add_net_event(void *args)
{
    event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
    event->handler = net_handler;
    event_post(&QUEUE, event);
}