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
	dune exec gofr