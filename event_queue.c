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