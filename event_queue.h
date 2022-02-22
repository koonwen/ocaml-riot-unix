#ifndef EVENT_QUEUE_H
#define EVENT_QUEUE_H

#include "string.h"

#include "xtimer.h"
#include "event.h"
#include "periph/uart.h"
#include "event/callback.h"
#include "stdio_uart.h"

extern event_queue_t QUEUE;
extern uint8_t BYTE_CONTAINER;

void uart_cb(void *arg, uint8_t data);

#endif