#ifndef EVENT_QUEUE_H
#define EVENT_QUEUE_H

#include "xtimer.h"
#include "event.h"
#include "periph/uart.h"

extern event_queue_t QUEUE;

void uart_cb(void *arg, uint8_t data);

#endif