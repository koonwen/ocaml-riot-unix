#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include <stdio.h>
#include "thread.h"
#include "xtimer.h"
#include "event.h"

CAMLprim value
caml_get_monotonic_time(value v_unit)
{
    CAMLparam1(v_unit);

    xtimer_ticks64_t time = xtimer_now64();
    // Convert to nanoseconds
    time.ticks64 *= 1000;

    CAMLreturn(caml_copy_int64(time.ticks64));
}

CAMLprim value
mirage_riot_sleep(value v_seconds)
{
    CAMLparam1(v_seconds);

    uint32_t seconds = Int32_val(v_seconds);
    xtimer_sleep(seconds);

    CAMLreturn(Val_unit);
}

CAMLprim value
mirage_initialize_event_queue(value v_unit)
{
    CAMLparam1(v_unit);

    event_queue_t queue;
    event_queue_init(&queue);

    CAMLreturn(caml_copy_int64(&queue));
}

CAMLprim value
mirage_riot_yield(value v_queue, value v_timeout)
{
    CAMLparam2(v_queue, v_timeout);
    event_queue_t *queue = Nativeint_val(v_queue);
    uint64_t timeout = Int64_val(v_timeout);

    event_t *new_event;
    if (new_event = event_wait_timeout64(queue, timeout))
    {
        printf("in here\n");
        new_event->handler(new_event);
        CAMLreturn(caml_copy_int64(new_event));
    }
    CAMLreturn(caml_copy_int64(0));
}

static void handler(event_t *event)
{
    printf("triggered 0x%08x\n", (unsigned)event);
}

// Add an event to the event queue with a default callback handler which prints the address of the event
CAMLprim value
mirage_riot_post_event(value v_queue)
{
    CAMLparam1(v_queue);

    event_queue_t *queue = Nativeint_val(v_queue);
    event_t *event = (event_t *)calloc(sizeof(1), sizeof(event_t));
    event->handler = handler;
    event_post(queue, event);

    CAMLreturn(Val_unit);
}