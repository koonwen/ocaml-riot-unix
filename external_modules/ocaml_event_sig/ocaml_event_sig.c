#include "ocaml_event_sig.h"

// ===============================NET==================================
// Need to change this to copying information into a packet queue
void net_handler(void *arg)
{
    DEBUG("(Riot callback) triggered netevent handler in thread context\n", (unsigned)arg);
    event_set = 1;
    // Maybe add a lock on the event set
}

void add_net_event(void *args)
{
    event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
    event->handler = net_handler;
    event_post(&QUEUE, event);
}