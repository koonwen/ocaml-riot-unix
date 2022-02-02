all : main.o runtime.o
	cc -o prog $(^) -L`ocamlc -where` -lcamlrun -lm

main.o : main.c
	cc -c main.c

runtime.o : runtime.ml
	ocamlc -output-obj -o runtime.o runtime.ml

clean :
	rm *.cmi *.cmo *.o prog
