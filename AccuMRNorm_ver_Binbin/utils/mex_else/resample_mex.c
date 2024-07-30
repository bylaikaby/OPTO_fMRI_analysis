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

#include "libmatlb.h"
#include "resample.h"
#include "firls.h"
#include "kaiser.h"
#include "mod.h"
#include "rat.h"
#include "upfirdn_mex_interface.h"

static mexFunctionTableEntry function_table[6]
  = { { "resample", mlxResample, 5, 2, &_local_function_table_resample },
      { "firls", mlxFirls, 5, 2, NULL }, { "kaiser", mlxKaiser, 2, 1, NULL },
      { "mod", mlxMod, 2, 1, NULL }, { "rat", mlxRat, 2, 2, NULL },
      { "upfirdn", mlxUpfirdn, -1, -1, NULL } };

static _mexInitTermTableEntry init_term_table[1]
  = { { InitializeModule_resample, TerminateModule_resample } };

static _mex_information _mex_info
  = { 1, 6, function_table, 0, NULL, 0, NULL, 1, init_term_table };

/*
 * The function "Mupfirdn" is the MATLAB callback version of the "upfirdn"
 * function from file "D:\matlabR12\toolbox\signal\signal\upfirdn.dll". It
 * performs a callback to MATLAB to run the "upfirdn" function, and passes any
 * resulting output arguments back to its calling function.
 */
static mxArray * Mupfirdn(int nargout_, mxArray * varargin) {
    mxArray * varargout = mclGetUninitializedArray();
    mclFevalCallMATLAB(
      mclNVarargout(nargout_, 1, &varargout, NULL),
      "upfirdn",
      mlfIndexRef(varargin, "{?}", mlfCreateColonIndex()), NULL);
    return varargout;
}

/*
 * The function "Mrat" is the MATLAB callback version of the "rat" function
 * from file "D:\matlabR12\toolbox\matlab\specfun\rat.m". It performs a
 * callback to MATLAB to run the "rat" function, and passes any resulting
 * output arguments back to its calling function.
 */
static mxArray * Mrat(mxArray * * D, int nargout_, mxArray * X, mxArray * tol) {
    mxArray * N = mclGetUninitializedArray();
    mclFevalCallMATLAB(
      mclNVarargout(nargout_, 0, &N, D, NULL), "rat", X, tol, NULL);
    return N;
}

/*
 * The function "Mmod" is the MATLAB callback version of the "mod" function
 * from file "D:\matlabR12\toolbox\matlab\elfun\mod.m". It performs a callback
 * to MATLAB to run the "mod" function, and passes any resulting output
 * arguments back to its calling function.
 */
static mxArray * Mmod(int nargout_, mxArray * x, mxArray * y) {
    mxArray * z = mclGetUninitializedArray();
    mclFevalCallMATLAB(mclNVarargout(nargout_, 0, &z, NULL), "mod", x, y, NULL);
    return z;
}

/*
 * The function "Mkaiser" is the MATLAB callback version of the "kaiser"
 * function from file "D:\matlabR12\toolbox\signal\signal\kaiser.m". It
 * performs a callback to MATLAB to run the "kaiser" function, and passes any
 * resulting output arguments back to its calling function.
 */
static mxArray * Mkaiser(int nargout_, mxArray * n_est, mxArray * beta) {
    mxArray * w = mclGetUninitializedArray();
    mclFevalCallMATLAB(
      mclNVarargout(nargout_, 0, &w, NULL), "kaiser", n_est, beta, NULL);
    return w;
}

/*
 * The function "Mfirls" is the MATLAB callback version of the "firls" function
 * from file "D:\matlabR12\toolbox\signal\signal\firls.m". It performs a
 * callback to MATLAB to run the "firls" function, and passes any resulting
 * output arguments back to its calling function.
 */
static mxArray * Mfirls(mxArray * * a,
                        int nargout_,
                        mxArray * N,
                        mxArray * F,
                        mxArray * M,
                        mxArray * W,
                        mxArray * ftype) {
    mxArray * h = mclGetUninitializedArray();
    mclFevalCallMATLAB(
      mclNVarargout(nargout_, 0, &h, a, NULL),
      "firls",
      N, F, M, W, ftype, NULL);
    return h;
}

/*
 * The function "mexLibrary" is a Compiler-generated mex wrapper, suitable for
 * building a MEX-function. It initializes any persistent variables as well as
 * a function table for use by the feval function. It then calls the function
 * "mlxResample". Finally, it clears the feval table and exits.
 */
mex_information mexLibrary(void) {
    return &_mex_info;
}

/*
 * The function "mlfNUpfirdn" contains the nargout interface for the "upfirdn"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\upfirdn.dll" (lines
 * 0-0). This interface is only produced if the M-function uses the special
 * variable "nargout". The nargout interface allows the number of requested
 * outputs to be specified via the nargout argument, as opposed to the normal
 * interface which dynamically calculates the number of outputs based on the
 * number of non-NULL inputs it receives. This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfNUpfirdn(int nargout, mlfVarargoutList * varargout, ...) {
    mxArray * varargin = NULL;
    mlfVarargin(&varargin, varargout, 0);
    mlfEnterNewContext(0, -1, varargin);
    nargout += mclNargout(varargout);
    *mlfGetVarargoutCellPtr(varargout) = Mupfirdn(nargout, varargin);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
    return mlfAssignOutputs(varargout);
}

/*
 * The function "mlfUpfirdn" contains the normal interface for the "upfirdn"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\upfirdn.dll" (lines
 * 0-0). This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
mxArray * mlfUpfirdn(mlfVarargoutList * varargout, ...) {
    mxArray * varargin = NULL;
    int nargout = 0;
    mlfVarargin(&varargin, varargout, 0);
    mlfEnterNewContext(0, -1, varargin);
    nargout += mclNargout(varargout);
    *mlfGetVarargoutCellPtr(varargout) = Mupfirdn(nargout, varargin);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
    return mlfAssignOutputs(varargout);
}

/*
 * The function "mlfVUpfirdn" contains the void interface for the "upfirdn"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\upfirdn.dll" (lines
 * 0-0). The void interface is only produced if the M-function uses the special
 * variable "nargout", and has at least one output. The void interface function
 * specifies zero output arguments to the implementation version of the
 * function, and in the event that the implementation version still returns an
 * output (which, in MATLAB, would be assigned to the "ans" variable), it
 * deallocates the output. This function processes any input arguments and
 * passes them to the implementation version of the function, appearing above.
 */
void mlfVUpfirdn(mxArray * synthetic_varargin_argument, ...) {
    mxArray * varargin = NULL;
    mxArray * varargout = NULL;
    mlfVarargin(&varargin, synthetic_varargin_argument, 1);
    mlfEnterNewContext(0, -1, varargin);
    varargout = Mupfirdn(0, synthetic_varargin_argument);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
}

/*
 * The function "mlxUpfirdn" contains the feval interface for the "upfirdn"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\upfirdn.dll" (lines
 * 0-0). The feval function calls the implementation version of upfirdn through
 * this function. This function processes any input arguments and passes them
 * to the implementation version of the function, appearing above.
 */
void mlxUpfirdn(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[1];
    mxArray * mplhs[1];
    int i;
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    mlfEnterNewContext(0, 0);
    mprhs[0] = NULL;
    mlfAssign(&mprhs[0], mclCreateVararginCell(nrhs, prhs));
    mplhs[0] = Mupfirdn(nlhs, mprhs[0]);
    mclAssignVarargoutCell(0, nlhs, plhs, mplhs[0]);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(mprhs[0]);
}

/*
 * The function "mlfNRat" contains the nargout interface for the "rat"
 * M-function from file "D:\matlabR12\toolbox\matlab\specfun\rat.m" (lines
 * 0-0). This interface is only produced if the M-function uses the special
 * variable "nargout". The nargout interface allows the number of requested
 * outputs to be specified via the nargout argument, as opposed to the normal
 * interface which dynamically calculates the number of outputs based on the
 * number of non-NULL inputs it receives. This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfNRat(int nargout, mxArray * * D, mxArray * X, mxArray * tol) {
    mxArray * N = mclGetUninitializedArray();
    mxArray * D__ = mclGetUninitializedArray();
    mlfEnterNewContext(1, 2, D, X, tol);
    N = Mrat(&D__, nargout, X, tol);
    mlfRestorePreviousContext(1, 2, D, X, tol);
    if (D != NULL) {
        mclCopyOutputArg(D, D__);
    } else {
        mxDestroyArray(D__);
    }
    return mlfReturnValue(N);
}

/*
 * The function "mlfRat" contains the normal interface for the "rat" M-function
 * from file "D:\matlabR12\toolbox\matlab\specfun\rat.m" (lines 0-0). This
 * function processes any input arguments and passes them to the implementation
 * version of the function, appearing above.
 */
mxArray * mlfRat(mxArray * * D, mxArray * X, mxArray * tol) {
    int nargout = 1;
    mxArray * N = mclGetUninitializedArray();
    mxArray * D__ = mclGetUninitializedArray();
    mlfEnterNewContext(1, 2, D, X, tol);
    if (D != NULL) {
        ++nargout;
    }
    N = Mrat(&D__, nargout, X, tol);
    mlfRestorePreviousContext(1, 2, D, X, tol);
    if (D != NULL) {
        mclCopyOutputArg(D, D__);
    } else {
        mxDestroyArray(D__);
    }
    return mlfReturnValue(N);
}

/*
 * The function "mlfVRat" contains the void interface for the "rat" M-function
 * from file "D:\matlabR12\toolbox\matlab\specfun\rat.m" (lines 0-0). The void
 * interface is only produced if the M-function uses the special variable
 * "nargout", and has at least one output. The void interface function
 * specifies zero output arguments to the implementation version of the
 * function, and in the event that the implementation version still returns an
 * output (which, in MATLAB, would be assigned to the "ans" variable), it
 * deallocates the output. This function processes any input arguments and
 * passes them to the implementation version of the function, appearing above.
 */
void mlfVRat(mxArray * X, mxArray * tol) {
    mxArray * N = NULL;
    mxArray * D = NULL;
    mlfEnterNewContext(0, 2, X, tol);
    N = Mrat(&D, 0, X, tol);
    mlfRestorePreviousContext(0, 2, X, tol);
    mxDestroyArray(N);
    mxDestroyArray(D);
}

/*
 * The function "mlxRat" contains the feval interface for the "rat" M-function
 * from file "D:\matlabR12\toolbox\matlab\specfun\rat.m" (lines 0-0). The feval
 * function calls the implementation version of rat through this function. This
 * function processes any input arguments and passes them to the implementation
 * version of the function, appearing above.
 */
void mlxRat(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[2];
    mxArray * mplhs[2];
    int i;
    if (nlhs > 2) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: rat Line: 1 Column: 1 The function \"rat\" "
            "was called with more than the declared number of outputs (2)."));
    }
    if (nrhs > 2) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: rat Line: 1 Column: 1 The function \"rat\""
            " was called with more than the declared number of inputs (2)."));
    }
    for (i = 0; i < 2; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 2 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 2; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 2, mprhs[0], mprhs[1]);
    mplhs[0] = Mrat(&mplhs[1], nlhs, mprhs[0], mprhs[1]);
    mlfRestorePreviousContext(0, 2, mprhs[0], mprhs[1]);
    plhs[0] = mplhs[0];
    for (i = 1; i < 2 && i < nlhs; ++i) {
        plhs[i] = mplhs[i];
    }
    for (; i < 2; ++i) {
        mxDestroyArray(mplhs[i]);
    }
}

/*
 * The function "mlfMod" contains the normal interface for the "mod" M-function
 * from file "D:\matlabR12\toolbox\matlab\elfun\mod.m" (lines 0-0). This
 * function processes any input arguments and passes them to the implementation
 * version of the function, appearing above.
 */
mxArray * mlfMod(mxArray * x, mxArray * y) {
    int nargout = 1;
    mxArray * z = mclGetUninitializedArray();
    mlfEnterNewContext(0, 2, x, y);
    z = Mmod(nargout, x, y);
    mlfRestorePreviousContext(0, 2, x, y);
    return mlfReturnValue(z);
}

/*
 * The function "mlxMod" contains the feval interface for the "mod" M-function
 * from file "D:\matlabR12\toolbox\matlab\elfun\mod.m" (lines 0-0). The feval
 * function calls the implementation version of mod through this function. This
 * function processes any input arguments and passes them to the implementation
 * version of the function, appearing above.
 */
void mlxMod(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[2];
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: mod Line: 1 Column: 1 The function \"mod\" "
            "was called with more than the declared number of outputs (1)."));
    }
    if (nrhs > 2) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: mod Line: 1 Column: 1 The function \"mod\""
            " was called with more than the declared number of inputs (2)."));
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 2 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 2; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 2, mprhs[0], mprhs[1]);
    mplhs[0] = Mmod(nlhs, mprhs[0], mprhs[1]);
    mlfRestorePreviousContext(0, 2, mprhs[0], mprhs[1]);
    plhs[0] = mplhs[0];
}

/*
 * The function "mlfKaiser" contains the normal interface for the "kaiser"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\kaiser.m" (lines
 * 0-0). This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
mxArray * mlfKaiser(mxArray * n_est, mxArray * beta) {
    int nargout = 1;
    mxArray * w = mclGetUninitializedArray();
    mlfEnterNewContext(0, 2, n_est, beta);
    w = Mkaiser(nargout, n_est, beta);
    mlfRestorePreviousContext(0, 2, n_est, beta);
    return mlfReturnValue(w);
}

/*
 * The function "mlxKaiser" contains the feval interface for the "kaiser"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\kaiser.m" (lines
 * 0-0). The feval function calls the implementation version of kaiser through
 * this function. This function processes any input arguments and passes them
 * to the implementation version of the function, appearing above.
 */
void mlxKaiser(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[2];
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: kaiser Line: 1 Column: "
            "1 The function \"kaiser\" was called with mor"
            "e than the declared number of outputs (1)."));
    }
    if (nrhs > 2) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: kaiser Line: 1 Column: "
            "1 The function \"kaiser\" was called with mor"
            "e than the declared number of inputs (2)."));
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 2 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 2; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 2, mprhs[0], mprhs[1]);
    mplhs[0] = Mkaiser(nlhs, mprhs[0], mprhs[1]);
    mlfRestorePreviousContext(0, 2, mprhs[0], mprhs[1]);
    plhs[0] = mplhs[0];
}

/*
 * The function "mlfNFirls" contains the nargout interface for the "firls"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\firls.m" (lines
 * 0-0). This interface is only produced if the M-function uses the special
 * variable "nargout". The nargout interface allows the number of requested
 * outputs to be specified via the nargout argument, as opposed to the normal
 * interface which dynamically calculates the number of outputs based on the
 * number of non-NULL inputs it receives. This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfNFirls(int nargout,
                    mxArray * * a,
                    mxArray * N,
                    mxArray * F,
                    mxArray * M,
                    mxArray * W,
                    mxArray * ftype) {
    mxArray * h = mclGetUninitializedArray();
    mxArray * a__ = mclGetUninitializedArray();
    mlfEnterNewContext(1, 5, a, N, F, M, W, ftype);
    h = Mfirls(&a__, nargout, N, F, M, W, ftype);
    mlfRestorePreviousContext(1, 5, a, N, F, M, W, ftype);
    if (a != NULL) {
        mclCopyOutputArg(a, a__);
    } else {
        mxDestroyArray(a__);
    }
    return mlfReturnValue(h);
}

/*
 * The function "mlfFirls" contains the normal interface for the "firls"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\firls.m" (lines
 * 0-0). This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
mxArray * mlfFirls(mxArray * * a,
                   mxArray * N,
                   mxArray * F,
                   mxArray * M,
                   mxArray * W,
                   mxArray * ftype) {
    int nargout = 1;
    mxArray * h = mclGetUninitializedArray();
    mxArray * a__ = mclGetUninitializedArray();
    mlfEnterNewContext(1, 5, a, N, F, M, W, ftype);
    if (a != NULL) {
        ++nargout;
    }
    h = Mfirls(&a__, nargout, N, F, M, W, ftype);
    mlfRestorePreviousContext(1, 5, a, N, F, M, W, ftype);
    if (a != NULL) {
        mclCopyOutputArg(a, a__);
    } else {
        mxDestroyArray(a__);
    }
    return mlfReturnValue(h);
}

/*
 * The function "mlfVFirls" contains the void interface for the "firls"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\firls.m" (lines
 * 0-0). The void interface is only produced if the M-function uses the special
 * variable "nargout", and has at least one output. The void interface function
 * specifies zero output arguments to the implementation version of the
 * function, and in the event that the implementation version still returns an
 * output (which, in MATLAB, would be assigned to the "ans" variable), it
 * deallocates the output. This function processes any input arguments and
 * passes them to the implementation version of the function, appearing above.
 */
void mlfVFirls(mxArray * N,
               mxArray * F,
               mxArray * M,
               mxArray * W,
               mxArray * ftype) {
    mxArray * h = NULL;
    mxArray * a = NULL;
    mlfEnterNewContext(0, 5, N, F, M, W, ftype);
    h = Mfirls(&a, 0, N, F, M, W, ftype);
    mlfRestorePreviousContext(0, 5, N, F, M, W, ftype);
    mxDestroyArray(h);
    mxDestroyArray(a);
}

/*
 * The function "mlxFirls" contains the feval interface for the "firls"
 * M-function from file "D:\matlabR12\toolbox\signal\signal\firls.m" (lines
 * 0-0). The feval function calls the implementation version of firls through
 * this function. This function processes any input arguments and passes them
 * to the implementation version of the function, appearing above.
 */
void mlxFirls(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[5];
    mxArray * mplhs[2];
    int i;
    if (nlhs > 2) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: firls Line: 1 Column: 1"
            " The function \"firls\" was called with more "
            "than the declared number of outputs (2)."));
    }
    if (nrhs > 5) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: firls Line: 1 Column: 1 The function \"firls"
            "\" was called with more than the declared number of inputs (5)."));
    }
    for (i = 0; i < 2; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 5 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 5; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 5, mprhs[0], mprhs[1], mprhs[2], mprhs[3], mprhs[4]);
    mplhs[0]
      = Mfirls(
          &mplhs[1], nlhs, mprhs[0], mprhs[1], mprhs[2], mprhs[3], mprhs[4]);
    mlfRestorePreviousContext(
      0, 5, mprhs[0], mprhs[1], mprhs[2], mprhs[3], mprhs[4]);
    plhs[0] = mplhs[0];
    for (i = 1; i < 2 && i < nlhs; ++i) {
        plhs[i] = mplhs[i];
    }
    for (; i < 2; ++i) {
        mxDestroyArray(mplhs[i]);
    }
}
