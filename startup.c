#include <string.h>

#include "stdio_uart.h"
#include "event_queue.h"

extern void caml_startup(char **argv);
char *argv[] = {"mirage", NULL};
event_queue_t QUEUE;

int main(void)
{
    event_queue_init(&QUEUE);

    kernel_pid_t main_pid = thread_getpid();
    uart_init(STDIO_UART_DEV, STDIO_UART_BAUDRATE, uart_cb, &main_pid);

    printf("main (): Starting OCaml\n");
    caml_startup(argv);
    return 0;
}