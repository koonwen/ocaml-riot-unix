/* runtime/caml/s.h.  Generated from s.h.in by configure.  */
/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

/* Operating system and standard library configuration. */

/* 0. Operating system type string. */

#define OCAML_OS_TYPE "Unix"
/* #define OCAML_OS_TYPE "Unix" */
/* #define OCAML_OS_TYPE "Win32" */
/* #define OCAML_OS_TYPE "MacOS" */

/* 1. For the runtime system. */

/* #undef POSIX_SIGNALS */

/* Define POSIX_SIGNALS if signal handling is POSIX-compliant.
   In particular, sigaction(), sigprocmask() and the operations on
   sigset_t are provided. */

/* #undef BSD_SIGNALS */

/* Define BSD_SIGNALS if signal handlers have the BSD semantics: the handler
   remains attached to the signal when the signal is received. Leave it
   undefined if signal handlers have the System V semantics: the signal
   resets the behavior to default. */

/* #undef SUPPORT_DYNAMIC_LINKING */

/* Define SUPPORT_DYNAMIC_LINKING if dynamic loading of C stub code
   via dlopen() is available. */

#define HAS_C99_FLOAT_OPS 1

/* Define HAS_C99_FLOAT_OPS if <math.h> conforms to ISO C99.
   In particular, it should provide expm1(), log1p(), hypot(), copysign(). */

#define HAS_WORKING_FMA 1

/* Define HAS_WORKING_FMA if the fma function is correctly implemented. The
   newlib library (intentionally) just has return x * y + z. */

/* #undef HAS_GETRUSAGE */

/* #undef HAS_TIMES */

/* #undef HAS_SECURE_GETENV */

/* #undef HAS___SECURE_GETENV */

/* #undef HAS_ISSETUGID */

/* 2. For the Unix library. */

#define HAS_SOCKETS 1

/* Define HAS_SOCKETS if you have BSD sockets. */

/* #undef HAS_SOCKLEN_T */

/* Define HAS_SOCKLEN_T if the type socklen_t is defined in
   /usr/include/sys/socket.h. */

/* #undef HAS_INET_ATON */

/* #undef HAS_IPV6 */

#define HAS_STDINT_H 1

#define HAS_UNISTD 1

/* Define HAS_UNISTD if you have /usr/include/unistd.h. */

/* #undef HAS_DIRENT */

/* Define HAS_DIRENT if you have /usr/include/dirent.h and the result of
   readdir() is of type struct dirent *.
   Otherwise, we'll load /usr/include/sys/dir.h, and readdir() is expected to
   return a struct direct *. */

/* #undef HAS_REWINDDIR */

/* Define HAS_REWINDDIR if you have rewinddir(). */

/* #undef HAS_LOCKF */

/* Define HAS_LOCKF if the library provides the lockf() function. */

/* #undef HAS_MKFIFO */

/* Define HAS_MKFIFO if the library provides the mkfifo() function. */

/* #undef HAS_GETCWD */

/* Define HAS_GETCWD if the library provides the getcwd() function. */

#define HAS_SYSTEM 1

/* Define HAS_SYSTEM if the library provides the system() function. */

/* #undef HAS_UTIME */
/* #undef HAS_UTIMES */

/* Define HAS_UTIME if you have /usr/include/utime.h and the library
   provides utime(). Define HAS_UTIMES if the library provides utimes(). */

/* #undef HAS_FCHMOD */

/* Define HAS_FCHMOD if you have fchmod() and fchown(). */

/* #undef HAS_TRUNCATE */

/* Define HAS_TRUNCATE if you have truncate() and
   ftruncate(). */

/* #undef HAS_SELECT */

/* Define HAS_SELECT if you have select(). */

#define HAS_SYS_SELECT_H 1

/* Define HAS_SYS_SELECT_H if /usr/include/sys/select.h exists
   and should be included before using select(). */

/* #undef HAS_NANOSLEEP */
/* Define HAS_NANOSLEEP if you have nanosleep(). */

/* #undef HAS_SYMLINK */

/* Define HAS_SYMLINK if you have symlink() and readlink() and lstat(). */

/* #undef HAS_WAIT4 */
/* #undef HAS_WAITPID */

/* Define HAS_WAIT4 if you have wait4().
   Define HAS_WAITPID if you have waitpid(). */

/* #undef HAS_GETGROUPS */

/* Define HAS_GETGROUPS if you have getgroups(). */

/* #undef HAS_SETGROUPS */

/* Define HAS_SETGROUPS if you have setgroups(). */

/* #undef HAS_INITGROUPS */

/* Define HAS_INITGROUPS if you have initgroups(). */

/* #undef HAS_TERMIOS */

/* Define HAS_TERMIOS if you have /usr/include/termios.h and it is
   Posix-compliant. */

/* #undef HAS_SETITIMER */

/* Define HAS_SETITIMER if you have setitimer(). */

/* #undef HAS_GETHOSTNAME */

/* Define HAS_GETHOSTNAME if you have gethostname(). */

/* #undef HAS_UNAME */

/* Define HAS_UNAME if you have uname(). */

/* #undef HAS_GETTIMEOFDAY */

/* Define HAS_GETTIMEOFDAY if you have gettimeofday(). */

/* #undef HAS_MKTIME */

/* Define HAS_MKTIME if you have mktime(). */

/* #undef HAS_SETSID */

/* Define HAS_SETSID if you have setsid(). */

/* #undef HAS_PUTENV */

/* Define HAS_PUTENV if you have putenv(). */

/* #undef HAS_SETENV_UNSETENV */

/* Define HAS_SETENV_UNSETENV if you have setenv() and unsetenv(). */

#define HAS_LOCALE_H 1

/* Define HAS_LOCALE_H if you have the include file <locale.h> and the
   uselocale() function. */

#define HAS_XLOCALE_H 1

/* Define HAS_XLOCALE_H if you have the include file <xlocale.h> and the
   uselocale() function. */

/* #undef HAS_STRTOD_L */

/* Define HAS_STRTOD_L if you have strtod_l */

/* #undef HAS_MMAP */

/* Define HAS_MMAP if you have the include file <sys/mman.h> and the
   functions mmap() and munmap(). */

/* #undef HAS_PWRITE */

/* #undef HAS_NANOSECOND_STAT */

/* #undef HAS_GETHOSTBYNAME_R */

/* Define HAS_GETHOSTBYNAME_R if gethostbyname_r() is available.
   The value of this symbol is the number of arguments of
   gethostbyname_r(): either 5 or 6 depending on prototype.
   (5 is the Solaris version, 6 is the Linux version). */

/* #undef HAS_GETHOSTBYADDR_R */

/* Define HAS_GETHOSTBYADDR_R if gethostbyname_r() is available.
   The value of this symbol is the number of arguments of
   gethostbyaddr_r(): either 7 or 8 depending on prototype.
   (7 is the Solaris version, 8 is the Linux version). */

/* #undef HAS_MKSTEMP */

/* #undef HAS_NICE */

/* Define HAS_NICE if you have nice(). */

/* #undef HAS_DUP3 */

/* #undef HAS_PIPE2 */

/* #undef HAS_ACCEPT4 */

/* #undef HAS_GETAUXVAL */

/* #undef HAS_SYS_SHM_H */

/* #undef HAS_SHMAT */

/* #undef HAS_EXECVPE */

/* #undef HAS_POSIX_SPAWN */

#define HAS_FFS 1
/* #undef HAS_BITSCANFORWARD */

#define HAS_STACK_OVERFLOW_DETECTION 1

/* #undef HAS_SIGWAIT */

/* #undef HAS_HUGE_PAGES */

/* #undef HUGE_PAGE_SIZE */

/* #undef HAS_BROKEN_PRINTF */

/* #undef HAS_STRERROR */

/* #undef HAS_POSIX_MONOTONIC_CLOCK */

/* #undef HAS_MACH_ABSOLUTE_TIME */
#undef HAS_SOCKETS
