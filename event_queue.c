#include "event_queue.h"

void savebyte(void *arg);
uint8_t BYTE_CONTAINER;

// Install interrupt logic upon UART event
void uart_cb(void *arg, uint8_t data)
{
    printf("ISR: (unsigned int) %u\n\r", data);
    event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
    event_callback_init(event, savebyte, data);
    event_post(&QUEUE, event);
}

// Callback fired on interrupt event
void savebyte(void *arg)
{
    BYTE_CONTAINER = (uint8_t)arg;
    printf("UART EVENT CALLED, got %c\n\r", BYTE_CONTAINER);
}

// =====================================================================

// Need to change this to copying information into a packet queue
void net_handler(void *arg)
{
    printf("triggered netevent in thread context\n", (unsigned)arg);
    event_set = 1;
    // Maybe add a lock on the event set
}

void add_net_event(void *args)
{
    event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
    event->handler = net_handler;
    event_post(&QUEUE, event);
}