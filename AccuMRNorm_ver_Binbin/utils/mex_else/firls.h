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

#ifndef __firls_h
#define __firls_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_firls(void);
extern void TerminateModule_firls(void);
extern _mexLocalFunctionTable _local_function_table_firls;

extern mxArray * mlfNFirls(int nargout,
                           mxArray * * a,
                           mxArray * N,
                           mxArray * F,
                           mxArray * M,
                           mxArray * W,
                           mxArray * ftype);
extern mxArray * mlfFirls(mxArray * * a,
                          mxArray * N,
                          mxArray * F,
                          mxArray * M,
                          mxArray * W,
                          mxArray * ftype);
extern void mlfVFirls(mxArray * N,
                      mxArray * F,
                      mxArray * M,
                      mxArray * W,
                      mxArray * ftype);
extern void mlxFirls(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
