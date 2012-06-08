
type t
type algorithm =
    NLOPT_GN_DIRECT
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

type result =
    NLOPT_FAILURE
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

exception Failure
exception Invalid_args
exception Out_of_memory
exception Roundoff_limited
exception Forced_stop

val create : algorithm -> int -> t

val set_min_objective : t -> (float array -> (float array option) -> float) -> unit
val set_max_objective : t -> (float array -> (float array option) -> float) -> unit
val optimize : t -> float array -> (result * float array * float) 

val get_dimension : t -> int

val set_lower_bounds : t -> float array -> unit
val get_lower_bounds : t -> float array 
val set_upper_bounds : t -> float array -> unit
val get_upper_bounds : t -> float array 

val add_inequality_constraint: t -> (float array -> (float array) option -> float) -> float -> unit
  
val set_stopval: t -> float -> unit
val get_stopval: t -> float 

val set_ftol_rel: t -> float -> unit
val get_ftol_rel: t -> float 

val set_ftol_abs: t -> float -> unit
val get_ftol_abs: t -> float
  
val set_xtol_rel: t -> float -> unit
val get_xtol_rel: t -> float 
  
val set_xtol_abs: t -> float array -> unit
val get_xtol_abs: t -> float array 

val set_maxeval: t -> int -> unit
val get_maxeval: t -> int 
  
val set_maxtime: t -> float -> unit
val get_maxtime: t -> float 

val force_stop: t -> unit

val set_local_optimizer: t -> t -> unit

val set_initial_step: t -> float array -> unit
val get_initial_step: t -> float array -> float array

val set_population: t -> int -> unit

val set_vector_storage: t -> int -> unit
val get_vector_storage: t -> int

val version: unit -> int * int * int

val string_of_result : result -> string

