#!/bin/bash

PID=`ps a | grep ocaml.elf |grep -o -E '[0-9]+' | head -n 1`
kill $PID