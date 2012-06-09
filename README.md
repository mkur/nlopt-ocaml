# nlopt-ocaml

nlopt-ocaml implements OCaml binding to the [NLOpt](http://ab-initio.mit.edu/wiki/index.php/NLopt) optimization library. 

## Dependencies

* ocaml
* findlib
* NLopt 

## Installing

Use Mercurial to get the newest sources:

	hg clone https://mkur@bitbucket.org/mkur/nlopt-ocaml

Edit `Makefile.conf` to reflect your system settings. You need to provide paths to the NLopt library (`LIBDIRS`) and its include files (`INCDIRS`). Then type

	make install
	
to install nlopt-ocaml using findlib.

## Example

The interface closely matches the object-oriented [API](http://ab-initio.mit.edu/wiki/index.php/NLopt_Reference) of NLopt. 
	
	open Nlopt;;
	
	let opt = create NLOPT_LD_LBFGS 2;;
	
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
	
	let (res, xopt, xfopt) = optimize opt x0;;
	


A more advanced example is included in the distribution.

## Documentation

Please refer to the project [wiki](https://bitbucket.org/mkur/nlopt-ocaml/wiki/Home).


