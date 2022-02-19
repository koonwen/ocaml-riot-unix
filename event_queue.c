#include "event_queue.h"

void myhandler(void *arg)
{
    printf("\nUART event called\n");
}

void uart_cb(void *arg, uint8_t data)
{
    event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
    event->handler = myhandler;
    event_post(&QUEUE, event);
}
