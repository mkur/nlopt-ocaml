
#include <math.h>
#include <nlopt.h>
#include <stdio.h>

#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/bigarray.h>
#include <caml/fail.h>

static const nlopt_algorithm map_algorithms[] = {
    NLOPT_GN_DIRECT, 
    NLOPT_GN_DIRECT_L,
    NLOPT_GN_DIRECT_L_RAND,
    NLOPT_GN_DIRECT_NOSCAL,
    NLOPT_GN_DIRECT_L_NOSCAL,
    NLOPT_GN_DIRECT_L_RAND_NOSCAL,
    
    NLOPT_GN_ORIG_DIRECT,
    NLOPT_GN_ORIG_DIRECT_L,
    
    NLOPT_GD_STOGO,
    NLOPT_GD_STOGO_RAND,

    NLOPT_LD_LBFGS_NOCEDAL,
    
    NLOPT_LD_LBFGS,
    
    NLOPT_LN_PRAXIS,
    
    NLOPT_LD_VAR1,
    NLOPT_LD_VAR2,
    
    NLOPT_LD_TNEWTON,
    NLOPT_LD_TNEWTON_RESTART,
    NLOPT_LD_TNEWTON_PRECOND,
    NLOPT_LD_TNEWTON_PRECOND_RESTART,
    
    NLOPT_GN_CRS2_LM,
    
    NLOPT_GN_MLSL,
    NLOPT_GD_MLSL,
    NLOPT_GN_MLSL_LDS,
    NLOPT_GD_MLSL_LDS,
    
    NLOPT_LD_MMA,
    
    NLOPT_LN_COBYLA,
    
    NLOPT_LN_NEWUOA,
    NLOPT_LN_NEWUOA_BOUND,
    
    NLOPT_LN_NELDERMEAD,
    NLOPT_LN_SBPLX,
    
    NLOPT_LN_AUGLAG,
    NLOPT_LD_AUGLAG,
    NLOPT_LN_AUGLAG_EQ,
    NLOPT_LD_AUGLAG_EQ,
    
    NLOPT_LN_BOBYQA,
    
    NLOPT_GN_ISRES,
    
    NLOPT_AUGLAG,
    NLOPT_AUGLAG_EQ,
    NLOPT_G_MLSL,
    NLOPT_G_MLSL_LDS,
    
    NLOPT_LD_SLSQP
};

static const nlopt_result map_results[] = {
    NLOPT_FAILURE,
    NLOPT_INVALID_ARGS,
    NLOPT_OUT_OF_MEMORY,
    NLOPT_ROUNDOFF_LIMITED,
    NLOPT_FORCED_STOP,
    NLOPT_SUCCESS,
    NLOPT_STOPVAL_REACHED,
    NLOPT_FTOL_REACHED,
    NLOPT_XTOL_REACHED,
    NLOPT_MAXEVAL_REACHED, 
    NLOPT_MAXTIME_REACHED
};

static int map_nlopt_result(nlopt_result result)
{
    int i;

    for(i=0; i < sizeof(map_results); i++)
	if(map_results[i] == result)
	    return(i);

    return(0); // Return NLOPT_FAILURE if no mapping found (ie. when wrapper code is not consistent with nlopt) 
}

struct constraint_list {
    value *cb;
    struct constraint_list *next;
};

struct ml_opt {
    nlopt_opt opt;
    value *cb;
    struct constraint_list *constraints;
};

#define MLOPT_VAL(v) (*((struct ml_opt *) Data_custom_val(v)))

static void ml_nlopt_finalize(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    value *cb = MLOPT_VAL(ml_opt).cb;

    // printf("Boom!\n");

    nlopt_destroy(opt);
    caml_remove_global_root(cb);
    free(cb);

    struct constraint_list *constraints = MLOPT_VAL(ml_opt).constraints;

    while (constraints)
    {
        struct constraint_list *prev;
	value *p = constraints->cb;
	
	// printf("Finalize %p\n", p);
	
	caml_remove_global_root(p);
	free(p);

        prev = constraints;
        constraints = constraints->next;
        free(prev);
    }
}


static struct custom_operations opt_ops = {
    "nlopt.opt",
    ml_nlopt_finalize,
    custom_finalize_default,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    custom_compare_ext_default,
};

value ml_nlopt_create (value algorithm, value n)
{
    CAMLparam2(algorithm, n);

    nlopt_algorithm alg = map_algorithms[Int_val(algorithm)];
    nlopt_opt opt = nlopt_create(alg, Int_val(n));

    value *cb = (value *) malloc(sizeof(value)); // callback container

    *cb = Val_unit;

    caml_register_global_root(cb);

    CAMLlocal1(ml_opt);

    ml_opt = caml_alloc_custom(&opt_ops, sizeof(struct ml_opt), 1, 100);
    MLOPT_VAL(ml_opt).opt = opt;
    MLOPT_VAL(ml_opt).cb = cb;
    MLOPT_VAL(ml_opt).constraints = NULL;

    CAMLreturn(ml_opt);
}

double ml_nlopt_callback_wrapper(unsigned n, const double *x,
				 double *gradient, /* NULL if not needed */
				 void *func_data)
{
    CAMLparam0();
    CAMLlocal4(ml_x, cb, ml_g, ml_g_option);

    cb = *(value*) func_data;
    ml_x = caml_alloc(n * Double_wosize, Double_array_tag);

    for(int i=0; i <n; i++)
	Store_double_field(ml_x, i, x[i]);

    if(gradient == NULL) 
    {
	ml_g_option = Val_int(0); /* None */
    }
    else
    {
	ml_g = caml_alloc(n * Double_wosize, Double_array_tag);

	for(int i=0; i <n; i++)
	    Store_double_field(ml_g, i, gradient[i]);

	ml_g_option = caml_alloc(1, 0);
	Store_field(ml_g_option, 0, ml_g); /* Some x */
    }

    value result = caml_callback2(cb, ml_x, ml_g_option);

    if(gradient != NULL)
    {
	for(int i=0; i <n; i++)
	    gradient[i] = Double_field(ml_g, i);
    }
    
    CAMLreturnT(double, Double_val(result));
}

value ml_nlopt_set_min_objective(value ml_opt, value ml_func)
{
    CAMLparam2(ml_opt, ml_func);

    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    value *cb = MLOPT_VAL(ml_opt).cb;
    *cb = ml_func;

    nlopt_result res = nlopt_set_min_objective(opt, &ml_nlopt_callback_wrapper, (void *) cb);
    
    CAMLreturn(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_set_max_objective(value ml_opt, value ml_func)
{
    CAMLparam2(ml_opt, ml_func);

    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    value *cb = MLOPT_VAL(ml_opt).cb;
    *cb = ml_func;

    nlopt_result res = nlopt_set_max_objective(opt, &ml_nlopt_callback_wrapper, (void *) cb);
    
    CAMLreturn(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_optimize(value ml_opt, value ml_x)
{
    CAMLparam2(ml_opt, ml_x);
    CAMLlocal2(ml_xopt, ml_rv);
    
    double fopt;
    
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    
    int len = Wosize_val(ml_x) / Double_wosize;
    
    double *x = (double *) malloc(len * sizeof(double));
    
    for(int i=0; i < len; i++)
	x[i] = Double_field(ml_x, i);
    
    nlopt_result res = nlopt_optimize(opt, x, &fopt);
    
    ml_xopt = caml_alloc(len * Double_wosize, Double_array_tag);

    for(int i=0; i < len; i++)
	Store_double_field(ml_xopt, i, x[i]);    
    
    ml_rv = caml_alloc(3, 0);
    
    Store_field(ml_rv, 0, Val_int(map_nlopt_result(res)));
    Store_field(ml_rv, 1, ml_xopt);
    Store_field(ml_rv, 2, caml_copy_double(fopt));

    CAMLreturn(ml_rv);
}

value ml_nlopt_get_dimension(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;

    return(Val_int(nlopt_get_dimension(opt)));
}

/* Constraints */

value ml_nlopt_set_lower_bounds (value ml_opt, value lb)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    int len = Wosize_val(lb) / Double_wosize;
    double *b = (double *) malloc(len * sizeof(double));
    
    for(int i=0; i<len; i++)
	b[i] = Double_field(lb, i);
    
    res = nlopt_set_lower_bounds(opt, b);

    free(b);
    
    return(Val_int(map_nlopt_result(res)));
}


value ml_nlopt_get_lower_bounds (value ml_opt, value ml_b)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;
    
    int n = nlopt_get_dimension(opt);
    
    double *b = (double *) malloc(n * sizeof(double));
    
    res = nlopt_get_lower_bounds(opt, b);
    
    if (res == NLOPT_SUCCESS)
    {
	for(int i=0; i<n; i++)
	    Store_double_field(ml_b, i, b[i]);
    }

    free(b);
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_set_upper_bounds (value ml_opt, value ub)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    int len = Wosize_val(ub) / Double_wosize;
    double *b = (double *) malloc(len * sizeof(double));
    
    for(int i=0; i<len; i++)
	b[i] = Double_field(ub, i);
    
    res = nlopt_set_upper_bounds(opt, b);

    free(b);
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_upper_bounds (value ml_opt, value ml_b)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;
    
    int n = nlopt_get_dimension(opt);
    
    double *b = (double *) malloc(n * sizeof(double));
    
    res = nlopt_get_upper_bounds(opt, b);
    
    if (res == NLOPT_SUCCESS)
    {
	for(int i=0; i<n; i++)
	    Store_double_field(ml_b, i, b[i]);
    }

    free(b);
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_add_inequality_constraint(value ml_opt, value ml_constr, value ml_tol)
{
    CAMLparam3(ml_opt, ml_constr, ml_tol);
    CAMLlocal1(cons);

    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    

    value *cb = (value *) malloc(sizeof(value)); // callback container

    *cb = ml_constr;

    nlopt_result res = nlopt_add_inequality_constraint(opt, &ml_nlopt_callback_wrapper, (void *) cb, Double_val(ml_tol));

    if (res == NLOPT_SUCCESS) 
    {
	caml_register_global_root(cb);

        struct constraint_list *constraints = malloc(sizeof(*constraints));
        constraints->cb = cb;
        constraints->next = MLOPT_VAL(ml_opt).constraints;

        MLOPT_VAL(ml_opt).constraints = constraints;
    }
    else
	free(cb);
    
    CAMLreturn(Val_int(map_nlopt_result(res)));
}


value ml_nlopt_add_equality_constraint(value ml_opt, value ml_constr, value ml_tol)
{
    CAMLparam3(ml_opt, ml_constr, ml_tol);
    CAMLlocal1(cons);

    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    
    value *cb = (value *) malloc(sizeof(value)); // callback container

    *cb = ml_constr;

    nlopt_result res = nlopt_add_equality_constraint(opt, &ml_nlopt_callback_wrapper, (void *) cb, Double_val(ml_tol));

    if (res == NLOPT_SUCCESS) 
    {
	caml_register_global_root(cb);

        struct constraint_list *constraints = malloc(sizeof(*constraints));
        constraints->cb = cb;
        constraints->next = MLOPT_VAL(ml_opt).constraints;

        MLOPT_VAL(ml_opt).constraints = constraints;
    }
    else
	free(cb);
    
    CAMLreturn(Val_int(map_nlopt_result(res)));
}

/* Stopping criteria */

value ml_nlopt_set_stopval(value ml_opt, value stopval)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_set_stopval(opt, Double_val(stopval));
    
    return(Val_int(map_nlopt_result(res)));
} 

value ml_nlopt_get_stopval(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;

    return(caml_copy_double(nlopt_get_stopval(opt)));
}


value ml_nlopt_set_ftol_rel(value ml_opt, value ml_tol)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_set_ftol_rel(opt, Double_val(ml_tol));
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_ftol_rel(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;

    return(caml_copy_double(nlopt_get_ftol_rel(opt)));
}


value ml_nlopt_set_ftol_abs(value ml_opt, value ml_tol)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_set_ftol_abs(opt, Double_val(ml_tol));
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_ftol_abs(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;

    return(caml_copy_double(nlopt_get_ftol_abs(opt)));
}

value ml_nlopt_set_xtol_rel(value ml_opt, value ml_tol)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_set_xtol_rel(opt, Double_val(ml_tol));
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_xtol_rel(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;

    return(caml_copy_double(nlopt_get_xtol_rel(opt)));
}

value ml_nlopt_set_xtol_abs(value ml_opt, value ml_tol)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    int n = Wosize_val(ml_tol) / Double_wosize;
    double *tol = (double *) malloc(n * sizeof(double));

    for(int i=0; i<n; i++)
	tol[i] = Double_field(ml_tol, i);    
    
    res = nlopt_set_xtol_abs(opt, tol);
    
    free(tol);

    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_xtol_abs(value ml_opt, value ml_tol)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    int n = Wosize_val(ml_tol) / Double_wosize;
    double *tol = (double *) malloc(n * sizeof(double));

    res = nlopt_get_xtol_abs(opt, tol);

    if (res == NLOPT_SUCCESS)
	for(int i=0; i<n; i++)
	    Store_double_field(ml_tol, i, tol[i]);
    
    free(tol);

    return(Val_int(map_nlopt_result(res)));
}


value ml_nlopt_set_maxeval(value ml_opt, value ml_maxeval)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_set_maxeval(opt, Int_val(ml_maxeval));
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_maxeval(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;

    return(Val_int(nlopt_get_maxeval(opt)));
}

value ml_nlopt_set_maxtime(value ml_opt, value ml_maxtime)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_set_maxtime(opt, Double_val(ml_maxtime));
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_maxtime(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;

    return(caml_copy_double(nlopt_get_maxtime(opt)));
}

value ml_nlopt_force_stop(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_force_stop(opt);
    
    return(Val_int(map_nlopt_result(res)));
}

/* Initial step size */

value ml_nlopt_set_initial_step(value ml_opt, value ml_dx)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    int n = Wosize_val(ml_dx) / Double_wosize;
    double *b = (double *) malloc(n * sizeof(double));
    
    for(int i=0; i<n; i++)
	b[i] = Double_field(ml_dx, i);
    
    res = nlopt_set_initial_step(opt, b);
    
    free(b);
    
    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_initial_step(value ml_opt, value ml_x, value ml_dx)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    int n = Wosize_val(ml_x) / Double_wosize;
    double *x = (double *) malloc(n * sizeof(double));
    double *dx = (double *) malloc(n * sizeof(double));

    for(int i=0; i<n; i++)
	x[i] = Double_field(ml_x, i);    

    res = nlopt_get_initial_step(opt, x, dx);

    if (res == NLOPT_SUCCESS)
    	for(int i=0; i<n; i++)
	    Store_double_field(ml_dx, i, dx[i]);
    
    free(x);
    free(dx);

    return(Val_int(map_nlopt_result(res)));
}

/* Local/subsidiary optimization algorithm */

value ml_nlopt_set_local_optimizer(value ml_opt, value ml_local_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_opt local_opt = MLOPT_VAL(ml_local_opt).opt;
    nlopt_result res;

    res = nlopt_set_local_optimizer(opt, local_opt);
    
    return(Val_int(map_nlopt_result(res)));
}

/* Stochastic population */

value ml_nlopt_set_population(value ml_opt, value ml_pop)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_set_population(opt, (unsigned) Int_val(ml_pop));

    return(Val_int(map_nlopt_result(res)));
}


/* Vector storage for limited-memory quasi-Newton algorithms */

value ml_nlopt_set_vector_storage(value ml_opt, value ml_M)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;
    nlopt_result res;

    res = nlopt_set_vector_storage(opt, (unsigned) Int_val(ml_M));

    return(Val_int(map_nlopt_result(res)));
}

value ml_nlopt_get_vector_storage(value ml_opt)
{
    nlopt_opt opt = MLOPT_VAL(ml_opt).opt;

    return(Val_int(nlopt_get_vector_storage(opt)));
}


/* Version */

value ml_nlopt_version(value ml_unit)
{
    CAMLparam1(ml_unit);
    CAMLlocal1(ml_ver);

    int ver[3];

    nlopt_version(&ver[0], &ver[1], &ver[2]);

    ml_ver = caml_alloc(3, 0);

    Store_field(ml_ver, 0, Val_int(ver[0]));
    Store_field(ml_ver, 1, Val_int(ver[1]));
    Store_field(ml_ver, 2, Val_int(ver[2]));

    CAMLreturn(ml_ver);
}


