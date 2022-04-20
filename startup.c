#include "stdio.h"
#include "string.h"
#include "xtimer.h"

extern void caml_startup(char **argv);
char *argv[] = {"mirage", NULL};

int main(void)
{

    puts("RIOT init network stack");

    xtimer_msleep(10);

    printf("main (): Starting OCaml\n");
    caml_startup(argv);

    /* should be never reached */
    return 0;
}