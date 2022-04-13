#ifndef EVENT_QUEUE_H
#define EVENT_QUEUE_H

#include "string.h"

#include "xtimer.h"
#include "event.h"
#include "periph/uart.h"
#include "event/callback.h"
#include "stdio_uart.h"
#include "tty_uart.h"

extern event_queue_t QUEUE;
extern uint8_t BYTE_CONTAINER;

// TODO Change this to a simple event set on individual bits
// extern union event_set
// {
//     /* data */
// };
extern uint16_t event_set;

void send_tcp_packet(void);
void uart_cb(void *arg, uint8_t data);
void handler(void *args);

void add_net_event(void *args);
void net_handler(void *arg);

#endif