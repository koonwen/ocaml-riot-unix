#include <stdio.h>
#include <string.h>

#include "xtimer.h"
#include "event.h"

extern void caml_startup(char **argv);

char *argv[] = {"mirage", NULL};

// #include "thread.h"

// static void handler(event_t *event)
// {
//     printf("triggered 0x%08x\n", (unsigned)event);
// }

// static event_t event = {.handler = handler};
// static event_queue_t queue;

// char rcv_thread_stack[THREAD_STACKSIZE_MAIN];

// void *rcv_thread(void *arg)
// {
//     (void)arg;

//     while (1)
//     {
//         xtimer_sleep(1);
//         event_post(&queue, &event);
//     }

//     return NULL;
// }

// int main(void)
// {
//     event_queue_init(&queue);
//     thread_create(rcv_thread_stack, sizeof(rcv_thread_stack),
//                   THREAD_PRIORITY_MAIN - 1, THREAD_CREATE_STACKTEST,
//                   rcv_thread, NULL, "rcv_thread");
//     // event_loop(&queue);
//     event_t *event;
//     event = event_wait_timeout(&queue, 0);
//     if (event)
//     {
//         event->handler(event);
//     }
//     printf("event is %x\n", event);
//     return 0;
// }

int main(void)
{
    printf("main (): ");
    printf("Hello %s\n", *argv);
    caml_startup(argv);
    return 0;
}