#include "ocaml_event_sig.h"
#include "../raw_tcp_sock/raw_tcp_sock.h"

void savebyte(void *arg);
uint8_t BYTE_CONTAINER;

// =============================UART==================================
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