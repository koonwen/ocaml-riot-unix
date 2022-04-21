# TODO #
1. Clean up the example section `DONE`
2. Clean up the toplevel `DONE`
3. Write instructional on how to build including compiler download
4. Implement an event set for the event loop `DONE`
5. Change to ztimer
6. Test on chip
7. Move headers to a common include directory `Done`
8. Fuzzing
9. Document stubs
10. Investigate double ACK
11. Add random module
12. Change ipaddr to type Ipaddr.V4V6
13. Make GNRC branch
14. Write some unit tests
15. Write script to output memory usage

original runtime.o ~ 700Kb
change caml_code to `const`

513K Apr 21 00:43 runtime.o
Need to figure out if this can be dumped onto readonly memory