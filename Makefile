.PHONY: default build install uninstall test clean fmt
.IGNORE: fmt

default: build

build:
	dune build

test:
	dune runtest -f

install:
	dune install

uninstall:
	dune uninstall

clean:
	dune clean
	git clean -dfXq

fmt:
	dune build @fmt
	dune promote

run: build fmt
	rm -f capture_nums.txt
	dune exec gofr

debug: build fmt
	ocamldebug _build/default/gofr/main.bc
