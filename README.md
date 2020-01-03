# nlopt-ocaml

nlopt-ocaml implements OCaml bindings to the [NLOpt](http://ab-initio.mit.edu/wiki/index.php/NLopt) optimization library. 

[![Build Status](https://travis-ci.org/mkur/nlopt-ocaml.svg?branch=master)](https://travis-ci.org/mkur/nlopt-ocaml)

## Dependencies

* ocaml
* dune
* NLopt 

## Installation

### Mac OS X

Use [homebrew](https://brew.sh/) to install nlopt:

	brew install nlopt
	
Use [OPAM](https://opam.ocaml.org/) to install the OCaml interface:

	opam install nlopt-ocaml

### Ubuntu (12.10)

Install nlopt:

	sudo apt-get install libnlopt0 libnlopt-dev
	
Use [OPAM](https://opam.ocaml.org/) to install the OCaml interface:

	opam install nlopt-ocaml

### Generic installation instructions

Use git to get the newest sources:

	git clone https://github.com/mkur/nlopt-ocaml

In the main directory type

	make 
		
to build and install nlopt-ocaml using dune.

## Example

The interface closely matches the object-oriented [API](http://ab-initio.mit.edu/wiki/index.php/NLopt_Reference) of NLopt. 

	open Nlopt;;
	
	let opt = create lbfgs 2;;
	
	let f a grad = 					
	  let x = a.(0) in
	  let y = a.(1) in
	  let () =
	    match grad with
		None -> ()
	      | Some g ->
		  begin  
		    g.(0) <- 2. *. (x -. 1.);
		    g.(1) <- 2. *. y;
		  end in
	    (x -. 1.) ** 2. +. y ** 2.;;
	
	set_min_objective opt f;;
	set_xtol_rel opt 1e-06;;
	
	let x0 = [| 5.;  5.|];;
	
	let (res, xopt, fopt) = optimize opt x0;;
	
To run this optimization problem type

	dune exec examples/tutorial.exe

A more advanced example is included in the distribution.

## Documentation




