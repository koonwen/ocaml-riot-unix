#include "event_queue.h"

extern void caml_startup(char **argv);
char *argv[] = {"mirage", NULL};
event_queue_t QUEUE;

int main(void)
{
    event_queue_init(&QUEUE);

    // Setup UART interrupt callback
    uart_init(STDIO_UART_DEV, STDIO_UART_BAUDRATE, uart_cb, NULL);

    printf("main (): Starting OCaml\r\n");
    caml_startup(argv);
    return 0;
}