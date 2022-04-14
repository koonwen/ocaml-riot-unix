#include "ocaml_event_sig.h"
#include "raw_tcp_sock.h"

extern void caml_startup(char **argv);
char *argv[] = {"mirage", NULL};

char tcp_thread_stack[THREAD_STACKSIZE_DEFAULT];
event_queue_t QUEUE;
uint16_t event_set = 2;

int main(void)
{

    event_queue_init(&QUEUE);

    // Raw IP socket thread
    thread_create(tcp_thread_stack, THREAD_STACKSIZE_DEFAULT,
                  TCP_EVENTLOOP_PRIO, THREAD_CREATE_STACKTEST,
                  raw_tcp_sock_thread, NULL, "raw tcp sock thread");

    puts("RIOT init network stack");

    xtimer_msleep(10);

    printf("main (): Starting OCaml\n");
    caml_startup(argv);

    /* should be never reached */
    return 0;
}