#!/bin/bash

rm -f setup.date setup.log

oasis setup
ocaml setup.ml -configure --prefix `opam config var prefix`
ocaml setup.ml -build

ocamlfind remove nlopt
ocaml setup.ml -install
