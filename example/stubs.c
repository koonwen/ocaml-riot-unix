#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include "event_queue.h"

// Get monotonic time in microseconds since timer started
CAMLprim value
caml_get_monotonic_time(value v_unit)
{
    CAMLparam1(v_unit);

    uint64_t time = xtimer_now_usec64();

    CAMLreturn(caml_copy_int64(time));
}

// Sleep for given time in microseconds
CAMLprim value
mirage_riot_sleep(value v_microseconds)
{
    CAMLparam1(v_microseconds);

    uint64_t microseconds = Int64_val(v_microseconds);
    printf("Sleeping for %ld microseconds\n", microseconds);
    xtimer_usleep64(microseconds);

    CAMLreturn(Val_unit);
}

CAMLprim value
mirage_initialize_event_queue(value v_unit)
{
    CAMLparam1(v_unit);

    event_queue_t *queue = (event_queue_t *)malloc(sizeof(event_queue_t));
    event_queue_init(queue);
    QUEUE = *queue;

    CAMLreturn(caml_copy_int64(queue));
}

CAMLprim value
mirage_get_event_queue(value v_unit)
{
    CAMLparam1(v_unit);
    CAMLreturn(caml_copy_int64(&QUEUE));
}

CAMLprim value
mirage_riot_yield(value v_queue, value v_timeout)
{
    CAMLparam2(v_queue, v_timeout);
    event_queue_t *queue = Int64_val(v_queue);
    uint64_t timeout = Int64_val(v_timeout);

    event_t *new_event;
    printf("Waiting for event for %ld microseconds\n", timeout);
    if (new_event = event_wait_timeout64(queue, timeout))
        new_event->handler(new_event);
    else
        printf("No event triggered, timeout expired\n");
    CAMLreturn(caml_copy_int64(new_event));
}

static void handler(event_t *event)
{
    printf("triggered 0x%08x before timeout expired\n", (unsigned)event);
}

// Add an event to the event queue with a default callback handler which prints the address of the event
CAMLprim value
mirage_riot_post_event(value v_queue)
{
    CAMLparam1(v_queue);

    event_queue_t *queue = Int64_val(v_queue);
    event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
    event->handler = handler;
    event_post(queue, event);

    CAMLreturn(Val_unit);
}

CAMLprim value
mirage_riot_console_event(value v_queue)
{
    CAMLparam1(v_queue);

    event_queue_t *queue = Int64_val(v_queue);
    event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
    event->handler = handler;
    event_post(queue, event);

    CAMLreturn(Val_unit);
}

// void myhandler(void *arg)
// {
//     printf("event called\n");
// }

// CAMLprim value
// mirage_riot_console_interrupt_handler(value v_queue)
// {
//     CAMLparam1(v_queue);

//     event_queue_t *queue = Int64_val(v_queue);
//     event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
//     event->handler = myhandler;
//     event_post(queue, event);

//     CAMLreturn(Val_unit);
// }