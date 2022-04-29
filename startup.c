#include "ocaml_event_sig.h"
#include "raw_tcp_sock.h"
// #include "shell.h"

extern void caml_startup(char **argv);
char *argv[] = {"mirage", NULL};

char tcp_thread_stack[THREAD_STACKSIZE_DEFAULT];
event_queue_t QUEUE;
uint16_t event_set = 0;

int main(void)
{

    puts("RIOT init network stack");

    xtimer_msleep(10);

    // char line_buf[SHELL_DEFAULT_BUFSIZE];
    // shell_run(NULL, line_buf, SHELL_DEFAULT_BUFSIZE);

    printf("main (): Starting OCaml\n");
    caml_startup(argv);

    /* should be never reached */
    return 0;
}