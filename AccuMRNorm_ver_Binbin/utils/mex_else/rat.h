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

#ifndef __rat_h
#define __rat_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_rat(void);
extern void TerminateModule_rat(void);
extern _mexLocalFunctionTable _local_function_table_rat;

extern mxArray * mlfNRat(int nargout,
                         mxArray * * D,
                         mxArray * X,
                         mxArray * tol);
extern mxArray * mlfRat(mxArray * * D, mxArray * X, mxArray * tol);
extern void mlfVRat(mxArray * X, mxArray * tol);
extern void mlxRat(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
