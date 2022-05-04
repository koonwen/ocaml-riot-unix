# RIOT / OCaml build system

## Prequisites
GCC 32bit libraries: 
- on debian: `sudo apt install gcc-multilib`
- on fedora: `sudo dnf install glibc-devel.i686`

OCaml version: 4.12.1

## Build
1. Clone repository including submodules
```bash
$ git clone git@github.com:koonwen/ocaml-riot-unix.git --recurse-submodules
```

2. Install local opam switch with dependencies
```bash
$ cd ocaml-riot-unix
$ opam switch create . 4.12.1
```

3. This project doesn't rely on Unix syscalls because we want to be able to port it to differnt platforms. However, some of the libraries that we use depend on Unix although we don't use that part of the libraries functionality. For this reason, we manually made edits to these libraries (ocplib-endian, cohttp-mirage) to remove the dependency. (opam might complain about a package conflict but it should still work)
```bash
$ opam pin ocplib-endian git@github.com:koonwen/ocplib-endian.git
$ opam pin add http.5.0.0 git@github.com:koonwen/ocaml-cohttp.git
$ opam pin add git@github.com:koonwen/ocaml-cohttp.git -ny
$ opam install dune mirage-random-stdlib mirage-runtime mirage-clock mirage-time mirage-flow cohttp-mirage cstruct duration tcpip logs ipaddr lwt cohttp-mirage mirage-flow psq
$ eval $(opam env)
```
4. Now to build the application just run `make`. If you want to include deadcode elmination in the build, use `make optimize && make all`
5. If you're running linux, set up a tap interface using RIOT scripts
```
sudo RIOT/dist/tools/tapsetup/tapsetup -c 1
```

## Test
To send HTTP request to the server
```
$ curl -g -6 'http://[<Your tap0 ipv6 address>%tapbr0]:8000/' -d "Hello Mirage-tcpip-riot"
```