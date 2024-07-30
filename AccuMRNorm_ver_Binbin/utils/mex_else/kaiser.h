/*
 * MATLAB Compiler: 2.1
 * Date: Wed Mar 20 12:44:06 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "resample" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#ifndef __kaiser_h
#define __kaiser_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_kaiser(void);
extern void TerminateModule_kaiser(void);
extern _mexLocalFunctionTable _local_function_table_kaiser;

extern mxArray * mlfKaiser(mxArray * n_est, mxArray * beta);
extern void mlxKaiser(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
