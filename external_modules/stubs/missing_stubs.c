#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <unistd.h>

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