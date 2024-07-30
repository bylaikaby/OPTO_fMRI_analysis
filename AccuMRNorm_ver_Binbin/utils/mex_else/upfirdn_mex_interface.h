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

#ifndef __upfirdn_mex_interface_h
#define __upfirdn_mex_interface_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_upfirdn_mex_interface(void);
extern void TerminateModule_upfirdn_mex_interface(void);
extern _mexLocalFunctionTable _local_function_table_upfirdn;

extern mxArray * mlfNUpfirdn(int nargout, mlfVarargoutList * varargout, ...);
extern mxArray * mlfUpfirdn(mlfVarargoutList * varargout, ...);
extern void mlfVUpfirdn(mxArray * synthetic_varargin_argument, ...);
extern void mlxUpfirdn(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
