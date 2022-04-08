// #include "event_queue.h"
// #include "unistd.h"
// #include "xtimer.h"
// #include "shell.h"
// #include "msg.h"
// #include "thread.h"

// extern void caml_startup(char **argv);
// char *argv[] = {"mirage", NULL};
// event_queue_t QUEUE;

// void *shell_thread(void *args);

// #define MAIN_QUEUE_SIZE (8)
// static msg_t _main_msg_queue[MAIN_QUEUE_SIZE];

// char thread_stack_default[THREAD_STACKSIZE_DEFAULT];

// int main(void)
// {
//     event_queue_init(&QUEUE);

//     // // Setup TTY
//     // tty_uart_setup(STDIO_UART_DEV, "/dev/tty");

//     // Setup UART interrupt callback
//     // uart_init(STDIO_UART_DEV, STDIO_UART_BAUDRATE, uart_cb, NULL);
//     // thread_create(thread_stack_default, THREAD_STACKSIZE_DEFAULT,
//     //               THREAD_PRIORITY_MAIN, THREAD_CREATE_STACKTEST,
//     //               shell_thread, NULL, "shell thread");
//     xtimer_msleep(10);

//     printf("main (): Starting OCaml\r\n");
//     // fflush(STDIN_FILENO);
//     caml_startup(argv);
//     return 0;
// }

// void *shell_thread(void *args)
// {
//     msg_init_queue(_main_msg_queue, MAIN_QUEUE_SIZE);
//     char line_buf[SHELL_DEFAULT_BUFSIZE];
//     puts("All up, running the shell now");
//     shell_run(NULL, line_buf, SHELL_DEFAULT_BUFSIZE);
// }

#include "external_modules/ocaml_event_sig/ocaml_event_sig.h"
#include "external_modules/raw_tcp_sock/raw_tcp_sock.h"

extern void caml_startup(char **argv);
char *argv[] = {"mirage", NULL};

char tcp_thread_stack[THREAD_STACKSIZE_DEFAULT];
event_queue_t QUEUE;
uint16_t event_set = 2;

// ipv6_mirage_t global_ipv6_state;

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