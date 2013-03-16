
open Nlopt;;

let rosenbrock a grad = 
  let x = a.(0) in
  let y = a.(1) in
  let () = 
    match grad with
	None -> ()
      | Some g -> 
	  g.(0) <- -400. *. (y -. x *. x) -. 2. *. (1. -. x);
	  g.(1) <- 200. *. (y -. x *. x)
  in
    (1. -. x) ** 2. +. 100. *. (y -. x *. x) ** 2.;;

let f = rosenbrock;;

let opt = create mma 2;; 

let () = 
  begin
    set_min_objective opt f;
    set_xtol_rel opt 1e-06;
    set_maxeval opt 10000
  end
;;


let tol = get_xtol_rel opt;;
let maxeval = get_maxeval opt;;

Printf.printf "XTOL_REL: %f\n" tol;;
Printf.printf "MAXEVAL: %d\n" maxeval;;

(* Starting point *)

let x0 = [|1.2 ; 2.|];;

(* Unconstrained problem *)

let (res, xopt, fopt) = optimize opt x0;;

Printf.printf "Optimization status %s\n" (string_of_result res);;
Printf.printf "Unconstrained optimum x=%f y=%f f=%f\n" (xopt.(0)) (xopt.(1)) fopt;;

(* Constrained problem *)

(* Unit disk *)

let unit_disk a grad = 
  let x = a.(0) in
  let y = a.(1) in
  let () = 
    match grad with
	None -> ()
      | Some g -> 
	  g.(0) <- 2. *. x;
	  g.(1) <- 2. *. y
  in
    x *. x +. y *. y -. 1.;;

let f_cons = unit_disk;;

let () = add_inequality_constraint opt f_cons 1e-03;;

let (res, xopt, fopt) = optimize opt x0;;

Printf.printf "Optimization status %s\n" (string_of_result res);;
Printf.printf "Constrained optimum x=%f y=%f f=%f\n" (xopt.(0)) (xopt.(1)) fopt;;


