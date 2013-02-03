
type nlopt_algorithm = 
  | NLOPT_GN_DIRECT
  | NLOPT_GN_DIRECT_L
  | NLOPT_GN_DIRECT_L_RAND
  | NLOPT_GN_DIRECT_NOSCAL
  | NLOPT_GN_DIRECT_L_NOSCAL
  | NLOPT_GN_DIRECT_L_RAND_NOSCAL
  | NLOPT_GN_ORIG_DIRECT
  | NLOPT_GN_ORIG_DIRECT_L
  | NLOPT_GD_STOGO
  | NLOPT_GD_STOGO_RAND
  | NLOPT_LD_LBFGS_NOCEDAL
  | NLOPT_LD_LBFGS
  | NLOPT_LN_PRAXIS
  | NLOPT_LD_VAR1
  | NLOPT_LD_VAR2
  | NLOPT_LD_TNEWTON
  | NLOPT_LD_TNEWTON_RESTART
  | NLOPT_LD_TNEWTON_PRECOND
  | NLOPT_LD_TNEWTON_PRECOND_RESTART
  | NLOPT_GN_CRS2_LM
  | NLOPT_GN_MLSL
  | NLOPT_GD_MLSL
  | NLOPT_GN_MLSL_LDS
  | NLOPT_GD_MLSL_LDS
  | NLOPT_LD_MMA
  | NLOPT_LN_COBYLA
  | NLOPT_LN_NEWUOA
  | NLOPT_LN_NEWUOA_BOUND
  | NLOPT_LN_NELDERMEAD
  | NLOPT_LN_SBPLX
  | NLOPT_LN_AUGLAG
  | NLOPT_LD_AUGLAG
  | NLOPT_LN_AUGLAG_EQ
  | NLOPT_LD_AUGLAG_EQ
  | NLOPT_LN_BOBYQA
  | NLOPT_GN_ISRES
  | NLOPT_AUGLAG
  | NLOPT_AUGLAG_EQ
  | NLOPT_G_MLSL
  | NLOPT_G_MLSL_LDS
  | NLOPT_LD_SLSQP

type 'a algorithm = nlopt_algorithm

let direct = NLOPT_GN_DIRECT
let direct_l = NLOPT_GN_DIRECT_L
let direct_l_rand = NLOPT_GN_DIRECT_L_RAND
let direct_noscal = NLOPT_GN_DIRECT_NOSCAL
let direct_l_noscal =  NLOPT_GN_DIRECT_L_NOSCAL
let direct_l_rand_noscal = NLOPT_GN_DIRECT_L_RAND_NOSCAL
let orig_direct = NLOPT_GN_ORIG_DIRECT
let orig_direct_l = NLOPT_GN_ORIG_DIRECT_L
let stogo = NLOPT_GD_STOGO
let stogo_rand = NLOPT_GD_STOGO_RAND
let lbfgs_nocedal = NLOPT_LD_LBFGS_NOCEDAL
let lbfgs = NLOPT_LD_LBFGS
let praxis = NLOPT_LN_PRAXIS
let var1 = NLOPT_LD_VAR1
let var2 = NLOPT_LD_VAR2
let tnewton = NLOPT_LD_TNEWTON
let tnewton_restart = NLOPT_LD_TNEWTON_RESTART
let tnewton_precond = NLOPT_LD_TNEWTON_PRECOND
let tnewton_precond_restart = NLOPT_LD_TNEWTON_PRECOND_RESTART
let crs2_lm = NLOPT_GN_CRS2_LM
let mma = NLOPT_LD_MMA
let cobyla = NLOPT_LN_COBYLA
let newuoa = NLOPT_LN_NEWUOA
let newuoa_bound = NLOPT_LN_NEWUOA_BOUND
let neldermead = NLOPT_LN_NELDERMEAD
let sbplx = NLOPT_LN_SBPLX
let bobyqa = NLOPT_LN_BOBYQA
let isres = NLOPT_GN_ISRES
let auglag = NLOPT_AUGLAG
let auglag_eq = NLOPT_AUGLAG_EQ
let mlsl = NLOPT_G_MLSL
let mlsl_lds = NLOPT_G_MLSL_LDS
let slsqp = NLOPT_LD_SLSQP

type 'a t

type result = 
  | NLOPT_FAILURE
  | NLOPT_INVALID_ARGS
  | NLOPT_OUT_OF_MEMORY
  | NLOPT_ROUNDOFF_LIMITED
  | NLOPT_FORCED_STOP
  | NLOPT_SUCCESS
  | NLOPT_STOPVAL_REACHED
  | NLOPT_FTOL_REACHED
  | NLOPT_XTOL_REACHED 
  | NLOPT_MAXEVAL_REACHED 
  | NLOPT_MAXTIME_REACHED
      
exception Roundoff_limited
exception Forced_stop

let check_result = function
    NLOPT_FAILURE -> raise (Failure "NLOPT_FAILURE")
  | NLOPT_INVALID_ARGS -> raise (Invalid_argument "NLOPT_INVALID_ARGS")
  | NLOPT_OUT_OF_MEMORY -> raise Out_of_memory
  | NLOPT_ROUNDOFF_LIMITED -> raise Roundoff_limited
  | NLOPT_FORCED_STOP -> raise Forced_stop
  | x -> x
;;

let string_of_result = function 
    NLOPT_FAILURE -> "NLOPT_FAILURE"
  | NLOPT_INVALID_ARGS -> "NLOPT_INVALID_ARGS"
  | NLOPT_OUT_OF_MEMORY -> "NLOPT_OUT_OF_MEMORY"
  | NLOPT_ROUNDOFF_LIMITED -> "NLOPT_ROUNDOFF_LIMITED"
  | NLOPT_FORCED_STOP -> "NLOPT_FORCED_STOP"
  | NLOPT_SUCCESS -> "NLOPT_SUCCESS"
  | NLOPT_STOPVAL_REACHED -> "NLOPT_STOPVAL_REACHED"
  | NLOPT_FTOL_REACHED -> "NLOPT_FTOL_REACHED"
  | NLOPT_XTOL_REACHED -> "NLOPT_XTOL_REACHED"
  | NLOPT_MAXEVAL_REACHED -> "NLOPT_MAXEVAL_REACHED"
  | NLOPT_MAXTIME_REACHED -> "NLOPT_MAXTIME_REACHED"
;;

external create: 'a algorithm -> int -> 'a t = "ml_nlopt_create"
external get_dimension: 'a t -> int = "ml_nlopt_get_dimension"

external ml_set_min_objective : 'a t -> (float array -> (float array) option -> float) -> result = "ml_nlopt_set_min_objective"
let set_min_objective opt f =
  let _ = check_result (ml_set_min_objective opt f) in ()
;;

external ml_set_max_objective : 'a t -> (float array -> (float array) option -> float) -> result = "ml_nlopt_set_max_objective"
let set_max_objective opt f =
  let _ = check_result (ml_set_max_objective opt f) in ()
;;

external ml_optimize : 'a t -> float array -> (result * float array * float) = "ml_nlopt_optimize"

let optimize opt x =
  if get_dimension opt <> Array.length x then
    raise (Invalid_argument "Nlopt.optimize: dimension of initial guess different from algorithm dimension")
  else
    let (result, xopt, fopt) = ml_optimize opt x in
      (check_result result, xopt, fopt)
;;

(* Constraints *)

external ml_set_lower_bounds: 'a t -> float array -> result = "ml_nlopt_set_lower_bounds"
let set_lower_bounds opt lb = 
  if get_dimension opt <> Array.length lb then
    raise (Invalid_argument "Nlopt.set_lower_bounds: dimension of bounds different from algorithm dimension")
  else
    let _ = check_result (ml_set_lower_bounds opt lb) in ()

external ml_get_lower_bounds: 'a t-> float array -> result = "ml_nlopt_get_lower_bounds"
let get_lower_bounds opt = 
  let lb = Array.create (get_dimension opt) nan in
  let _ = check_result (ml_get_lower_bounds opt lb) in
    lb
;;

external ml_set_upper_bounds: 'a t -> float array -> result = "ml_nlopt_set_upper_bounds"
let set_upper_bounds opt ub = 
  if get_dimension opt <> Array.length ub then
    raise (Invalid_argument "Nlopt.set_upper_bounds: dimension of bounds different from algorithm dimension")
  else
    let _ = check_result (ml_set_upper_bounds opt ub) in ()

external ml_get_upper_bounds: 'a t-> float array -> result = "ml_nlopt_get_upper_bounds"
let get_upper_bounds opt = 
  let ub = Array.create (get_dimension opt) nan in
  let _ = check_result (ml_get_upper_bounds opt ub) in
    ub
;;

external ml_add_inequality_constraint: 'a t -> (float array -> (float array) option -> float) -> float -> result = "ml_nlopt_add_inequality_constraint"
let add_inequality_constraint opt fconstr tol =
  let _ = check_result (ml_add_inequality_constraint opt fconstr tol) in ()
;;

external ml_add_equality_constraint: 'a t -> (float array -> (float array) option -> float) -> float -> result = "ml_nlopt_add_equality_constraint"
let add_equality_constraint opt fconstr tol =
  let _ = check_result (ml_add_equality_constraint opt fconstr tol) in ()
;;

(* Stopping criteria *)

external ml_set_stopval: 'a t -> float -> result = "ml_nlopt_set_stopval"
let set_stopval opt x = let _ = check_result (ml_set_stopval opt x) in ();;
external get_stopval: 'a t -> float = "ml_nlopt_get_stopval"

external ml_set_ftol_rel: 'a t -> float -> result = "ml_nlopt_set_ftol_rel"
let set_ftol_rel opt tol = let _ = check_result (ml_set_ftol_rel opt tol) in ();;
external get_ftol_rel: 'a t -> float = "ml_nlopt_get_ftol_rel"

external ml_set_ftol_abs: 'a t -> float -> result = "ml_nlopt_set_ftol_abs"
let set_ftol_abs opt tol = let _ = check_result (ml_set_ftol_abs opt tol) in ();;
external get_ftol_abs: 'a t -> float = "ml_nlopt_get_ftol_abs"

external ml_set_xtol_rel: 'a t -> float -> result = "ml_nlopt_set_xtol_rel"
let set_xtol_rel opt tol = let _ = check_result (ml_set_xtol_rel opt tol) in ();;
external get_xtol_rel: 'a t -> float = "ml_nlopt_get_xtol_rel"

external ml_set_xtol_abs: 'a t -> float array -> result = "ml_nlopt_set_xtol_abs"
let set_xtol_abs opt tol = let _ = check_result (ml_set_xtol_abs opt tol) in ();;
external ml_get_xtol_abs: 'a t -> float array -> result = "ml_nlopt_get_xtol_abs"
let get_xtol_abs opt = 
  let tol = Array.create (get_dimension opt) nan in
  let _ = check_result (ml_get_xtol_abs opt tol) in tol
;;


external ml_set_maxeval: 'a t -> int -> result = "ml_nlopt_set_maxeval"
let set_maxeval opt n = let _ = check_result (ml_set_maxeval opt n) in ();;
external get_maxeval: 'a t -> int = "ml_nlopt_get_maxeval"

external ml_set_maxtime: 'a t -> float -> result = "ml_nlopt_set_maxtime"
let set_maxtime opt t = let _ = check_result (ml_set_maxtime opt t) in ();;
external get_maxtime: 'a t -> float = "ml_nlopt_get_maxtime"

external ml_force_stop: 'a t -> result = "ml_nlopt_force_stop"
let force_stop opt = let _ = check_result (ml_force_stop opt) in ();;



(* Local/subsidiary optimization algorithm *)

external ml_set_local_optimizer: [>`Subsidiary] t -> 'a t -> result = "ml_nlopt_set_local_optimizer"
let set_local_optimizer opt local_opt = 
  let _ = check_result (ml_set_local_optimizer opt local_opt) in ();;


(* Initial step size *)

external ml_set_initial_step: 'a t -> float array -> result = "ml_nlopt_set_initial_step" 
let set_initial_step opt dx = 
  if get_dimension opt <> Array.length dx then
    raise (Invalid_argument "Nlopt.set_initial_step: dimension of initial step different from algorithm dimension")
  else
    let _ = check_result (ml_set_initial_step opt dx) in ();;

external ml_get_initial_step: 'a t -> float array -> float array -> result = "ml_nlopt_get_initial_step"
let get_initial_step opt x = 
  if get_dimension opt <> Array.length x then
    raise (Invalid_argument "Nlopt.get_initial_step: dimension of initial step different from algorithm dimension") 
  else
    let dx = Array.create (get_dimension opt) nan in
    let _ = check_result (ml_get_initial_step opt x dx) in dx
;;

(* Stochastic population *)

external ml_set_population: 'a t -> int -> result = "ml_nlopt_set_population"
let set_population opt pop = 
  if pop < 0 then
    raise (Invalid_argument "Nlopt.set_population: population negative")
  else
    let _ = check_result (ml_set_population opt pop) in ()
;;

(* Vector storage for limited-memory quasi-Newton algorithms *)

external ml_set_vector_storage: 'a t -> int -> result = "ml_nlopt_set_vector_storage"
let set_vector_storage opt m = 
  if m < 0 then
    raise (Invalid_argument "Nlopt.set_vector_storage: number of stored vectors negative")
  else
    let _ = check_result (ml_set_vector_storage opt m) in ()
;;

external get_vector_storage: 'a t -> int = "ml_nlopt_get_vector_storage"

(* Version *)

external version: unit -> int * int * int = "ml_nlopt_version"





