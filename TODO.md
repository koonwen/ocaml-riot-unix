# TODO #
1. Write instructional on how to build including compiler download
2. Test on chip
3. Change to ztimer
4. Fuzzing
5. Document stubs
6. Investigate double ACK
7. Add random module
8. Change ipaddr to type Ipaddr.V4V6
9. Make GNRC branch
10. Write some unit tests
11. Write script to output memory usage (memory usage)
12. GNRC implementation

original runtime.o ~ 700Kb
change caml_code to `const`

513K Apr 21 00:43 runtime.o
Need to figure out if this can be dumped onto readonly memory