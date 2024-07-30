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

#ifndef __resample_h
#define __resample_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_resample(void);
extern void TerminateModule_resample(void);
extern _mexLocalFunctionTable _local_function_table_resample;

extern mxArray * mlfResample(mxArray * * h,
                             mxArray * x,
                             mxArray * p,
                             mxArray * q,
                             mxArray * N,
                             mxArray * beta);
extern void mlxResample(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
