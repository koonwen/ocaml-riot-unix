#include "ocaml_event_sig.h"
#include "custom_tcp.h"
#include "shell.h"

extern void caml_startup(char **argv);
char *argv[] = {"mirage", NULL};

event_queue_t QUEUE;
uint16_t event_set = 0;

int main(void)
{

    puts("RIOT init network stack");

    // Initialize event queue to signal into OCaml
    event_queue_init(&QUEUE);
    // GNRC TCP thread
    custom_gnrc_tcp_init();

    // char line_buf[SHELL_DEFAULT_BUFSIZE];
    // shell_run(NULL, line_buf, SHELL_DEFAULT_BUFSIZE);
    printf("main (): Starting OCaml\n");
    caml_startup(argv);

    /* should be never reached */
    return 0;
}