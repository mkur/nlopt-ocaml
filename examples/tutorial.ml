
(* OCaml version of the NLOPT tutorial example *)

open Nlopt

let myfunc x grad = 
  let v = sqrt x.(1) in
  let () = match grad with
    | None -> ()
    | Some g -> 
      g.(0) <- 0.;
      g.(1) <- 0.5 /. v in
  v
;;

let mycons a b x grad  = 
  let v = (a *. x.(0) +. b) ** 3. -. x.(1) in
  let () = match grad with
    | None -> ()
    | Some g -> 
      g.(0) <- 3. *. a *. (a *. x.(0) +. b) ** 2.;
      g.(1) <- -1. in
  v
;;
  
let opt = create mma 2;; 

let () = 
  begin
    set_min_objective opt myfunc;
    set_xtol_rel opt 1e-04;
    set_lower_bounds opt [| neg_infinity; 0. |];
    add_inequality_constraint opt (mycons 2. 0.) 1e-08;
    add_inequality_constraint opt (mycons ~-.1. 1.) 1e-08;
  end
;;

let x0 = [|1.234 ; 5.678|];;

let (res, xopt, fopt) = optimize opt x0;;

Printf.printf "Optimization status %s\n" (string_of_result res);;
Printf.printf "Constrained optimum x=%f y=%f f=%f\n" (xopt.(0)) (xopt.(1)) fopt;;


