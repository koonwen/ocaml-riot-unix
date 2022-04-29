#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include "xtimer.h"
// Get monotonic time in microseconds since timer started
CAMLprim value
riot_sleep(value v_int32)
{
    CAMLparam1(v_int32);
    uint32_t t32 = Int32_val(v_int32);
    printf("Value to sleep is ld", t32);
    xtimer_sleep(t32);
    CAMLreturn(0);
}

CAMLprim value
wave(value v_unit)
{
    CAMLparam1(v_unit);
    while (1)
    {
        printf("WAVING HANDS");
        fflush(stdout);
    }
    CAMLreturn(0);
}

#include "unistd.h"

int chdir(const char *__path)
{
    return 1;
}
int mkdir(const char *_path, mode_t __mode)
{
    return 1;
}
int rmdir(const char *__path)
{
    return 1;
}
int getppid(void)
{
    return 1;
}
int _isatty(int fd)
{
    return 1;
}