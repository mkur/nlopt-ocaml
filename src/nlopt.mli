
type 'a algorithm

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
val lbfgs_nocedal : [`Local | `Grad] algorithm
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

type 'a t

type result =
| Failure_res
| Invalid_args_res
| Out_of_memory_res
| Roundoff_limited_res
| Forced_stop_res
| Success
| Stopval_reached
| Ftol_reached
| Xtol_reached
| Maxeval_reached
| Maxtime_reached

exception Roundoff_limited
exception Forced_stop

val create : 'a algorithm -> int -> 'a t

val set_min_objective : 'a t -> (float array -> (float array option) -> float) -> unit
val set_max_objective : 'a t -> (float array -> (float array option) -> float) -> unit
val optimize : 'a t -> float array -> (result * float array * float) 

val get_dimension : 'a t -> int

val set_lower_bounds : 'a t -> float array -> unit
val get_lower_bounds : 'a t -> float array 
val set_upper_bounds : 'a t -> float array -> unit
val get_upper_bounds : 'a t -> float array 

val add_inequality_constraint: [>`Ineq] t -> (float array -> (float array) option -> float) -> float -> unit
val add_equality_constraint: [>`Eq] t -> (float array -> (float array) option -> float) -> float -> unit
  
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

val force_stop: 'a t -> unit

val set_local_optimizer: [>`Subsidiary] t -> 'a t -> unit

val set_initial_step: 'a t -> float array -> unit
val get_initial_step: 'a t -> float array -> float array

val set_population: 'a t -> int -> unit

val set_vector_storage: 'a t -> int -> unit
val get_vector_storage: 'a t -> int

val version: unit -> int * int * int

val string_of_result : result -> string

