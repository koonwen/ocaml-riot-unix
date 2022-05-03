#!/bin/bash
# Usage: ./mem_usage native
# Usage: ./mem_usage nrf52840-mdk

app_out=$1

function get_usage () {
	objects=`find ./bin/$app_out/ -type f -name *.o`
	size --totals $objects > obj_stats
	printf "\n\n\n" >> obj_stats
	size ./bin/$app_out/ocaml_runtime/runtime.o >> obj_stats
	printf "\n"
	size ./bin/$app_out/ocaml.elf >> obj_stats
}

get_usage
# BOARD=nrf52840-mdk make runtime
# sed -i 's/static int caml_code/const static int caml_code/g' ./external_modules/ocaml_runtime/runtime.c
# BOARD=nrf52840-mdk make all
# printf "Without Dead code elimination:\n" > results
# get_usage ()

# printf "\n\n\nWith Dead code elimination:\n" >> results
# BOARD=nrf52840-mdk make runtime optimize
# sed -i 's/static int caml_code/const static int caml_code/g' ./external_modules/ocaml_runtime/runtime.c
# BOARD=nrf52840-mdk make all
# get_usage ()

