
(** OCaml interface to the NLopt optimization library *)

type 'a algorithm
(** Represent an algorithm, the parameter giving some properties of the algorithm. *)

val direct : [`Global ] algorithm
val direct_l : [`Global | `Ineq] algorithm
val direct_l_rand : [`Global] algorithm
val direct_noscal : [`Global] algorithm
val direct_l_noscal : [`Global] algorithm
val direct_l_rand_noscal : [`Global] algorithm
val orig_direct : [`Global | `Ineq] algorithm
val orig_direct_l : [`Global] algorithm
val stogo : [`Global | `Grad] algorithm
val stogo_rand : [`Global | `Grad] algorithm
val lbfgs : [`Local | `Grad] algorithm
val praxis : [`Local] algorithm
val var1 : [`Local | `Grad] algorithm
val var2 : [`Local | `Grad] algorithm
val tnewton : [`Local | `Grad] algorithm
val tnewton_restart : [`Local | `Grad] algorithm
val tnewton_precond : [`Local | `Grad] algorithm
val tnewton_precond_restart : [`Local | `Grad] algorithm
val crs2_lm : [`Global] algorithm
val mma  : [`Local | `Grad | `Ineq] algorithm
val cobyla : [`Local | `Ineq | `Eq] algorithm
val newuoa : [`Local] algorithm
val newuoa_bound : [`Local] algorithm
val neldermead : [`Local] algorithm
val sbplx : [`Local] algorithm
val bobyqa : [`Local] algorithm
val isres : [`Global | `Ineq | `Eq] algorithm
val auglag : [`Subsidiary | `Ineq | `Eq] algorithm
val auglag_eq : [`Subsidiary | `Ineq | `Eq] algorithm
val mlsl : [`Subsidiary | `Global] algorithm
val mlsl_lds : [`Subsidiary | `Global] algorithm
val slsqp : [`Local | `Grad | `Ineq | `Eq] algorithm
val esch : [`Global] algorithm
val ccsaq : [`Local | `Grad] algorithm
val ags : [`Global] algorithm

type 'a t
(** A value containing the information about the optimization problem. *)

exception Roundoff_limited
exception Forced_stop

val create : 'a algorithm -> int -> 'a t
  
val set_min_objective : 'a t -> (float array -> (float array option) -> float) -> unit
val set_max_objective : 'a t -> (float array -> (float array option) -> float) -> unit

val optimize : 'a t -> float array -> ([> `Success | `Stopval_reached | `Stopval_reached | `Ftol_reached | `Xtol_reached | `Maxeval_reached | `Maxtime_reached ] * float array * float) 
(** [optimize opt x] performs the optimization using [x] as an initial guess (it must be of size get_dimension opt). Returns a triple [(result, xopt, fopt)] where [xopt] is the optimzed value and [fopt] is the function value at that optimum.

    @raise Invalid_argument [x] does not match the dimension of [opt] or NLopt returned NLOPT_INVALID_ARGS
    @raise Out_of_memory NLopt returned NLOPT_OUT_OF_MEMORY
    @raise Failure NLopt returned NLOPT_FAILURE
    @raise Roundoff_limited NLopt returned NLOPT_ROUNDOFF_LIMITED
 *)


val get_dimension : 'a t -> int

(** {2 Bound constraints} *)

val set_lower_bounds : 'a t -> float array -> unit
val get_lower_bounds : 'a t -> float array 
val set_upper_bounds : 'a t -> float array -> unit
val get_upper_bounds : 'a t -> float array 

(** {2 Nonlinear constraints} *)

val add_inequality_constraint: [>`Ineq] t -> (float array -> (float array) option -> float) -> float -> unit
val add_equality_constraint: [>`Eq] t -> (float array -> (float array) option -> float) -> float -> unit

(** {2 Stopping criteria} *)
  
val set_stopval: 'a t -> float -> unit
val get_stopval: 'a t -> float 

val set_ftol_rel: 'a t -> float -> unit
val get_ftol_rel: 'a t -> float 

val set_ftol_abs: 'a t -> float -> unit
val get_ftol_abs: 'a t -> float
  
val set_xtol_rel: 'a t -> float -> unit
val get_xtol_rel: 'a t -> float 
  
val set_xtol_abs: 'a t -> float array -> unit
val get_xtol_abs: 'a t -> float array 

val set_maxeval: 'a t -> int -> unit
val get_maxeval: 'a t -> int 
  
val set_maxtime: 'a t -> float -> unit
val get_maxtime: 'a t -> float 

(** {2 Force stop} *)

val force_stop: 'a t -> unit

(** {2 Local/subsidiary optimization algorithm} *)

val set_local_optimizer: [>`Subsidiary] t -> 'a t -> unit

(** {2 Initial step size} *)

val set_initial_step: 'a t -> float array -> unit
val get_initial_step: 'a t -> float array -> float array

(** {2 Stochastic population} *)

val set_population: 'a t -> int -> unit

(** {2 Vector storage for limited-memory quasi-Newton algorithms} *)

val set_vector_storage: 'a t -> int -> unit
val get_vector_storage: 'a t -> int

(** {2 Utility functions} *)

val version: unit -> int * int * int

val string_of_result :  [< `Success | `Stopval_reached | `Stopval_reached | `Ftol_reached | `Xtol_reached | `Maxeval_reached | `Maxtime_reached ] -> string
  

