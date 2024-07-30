/*
 * MATLAB Compiler: 2.1
 * Date: Wed Mar 20 12:44:06 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "resample" 
 */
#include "resample.h"
#include "firls.h"
#include "kaiser.h"
#include "libmatlbm.h"
#include "mod.h"
#include "rat.h"
#include "upfirdn_mex_interface.h"

static mxChar _array1_[134] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 's', 'a', 'm',
                                'p', 'l', 'e', ' ', 'L', 'i', 'n', 'e', ':',
                                ' ', '1', ' ', 'C', 'o', 'l', 'u', 'm', 'n',
                                ':', ' ', '1', ' ', 'T', 'h', 'e', ' ', 'f',
                                'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', '"',
                                'r', 'e', 's', 'a', 'm', 'p', 'l', 'e', '"',
                                ' ', 'w', 'a', 's', ' ', 'c', 'a', 'l', 'l',
                                'e', 'd', ' ', 'w', 'i', 't', 'h', ' ', 'm',
                                'o', 'r', 'e', ' ', 't', 'h', 'a', 'n', ' ',
                                't', 'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a',
                                'r', 'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e',
                                'r', ' ', 'o', 'f', ' ', 'o', 'u', 't', 'p',
                                'u', 't', 's', ' ', '(', '2', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[133] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 's', 'a', 'm',
                                'p', 'l', 'e', ' ', 'L', 'i', 'n', 'e', ':',
                                ' ', '1', ' ', 'C', 'o', 'l', 'u', 'm', 'n',
                                ':', ' ', '1', ' ', 'T', 'h', 'e', ' ', 'f',
                                'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', '"',
                                'r', 'e', 's', 'a', 'm', 'p', 'l', 'e', '"',
                                ' ', 'w', 'a', 's', ' ', 'c', 'a', 'l', 'l',
                                'e', 'd', ' ', 'w', 'i', 't', 'h', ' ', 'm',
                                'o', 'r', 'e', ' ', 't', 'h', 'a', 'n', ' ',
                                't', 'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a',
                                'r', 'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e',
                                'r', ' ', 'o', 'f', ' ', 'i', 'n', 'p', 'u',
                                't', 's', ' ', '(', '5', ')', '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;
static mxArray * _mxarray5_;
static mxArray * _mxarray6_;

static mxChar _array8_[29] = { 'P', ' ', 'm', 'u', 's', 't', ' ', 'b', 'e', ' ',
                               'a', ' ', 'p', 'o', 's', 'i', 't', 'i', 'v', 'e',
                               ' ', 'i', 'n', 't', 'e', 'g', 'e', 'r', '.' };
static mxArray * _mxarray7_;

static mxChar _array10_[29] = { 'Q', ' ', 'm', 'u', 's', 't', ' ', 'b',
                                'e', ' ', 'a', ' ', 'p', 'o', 's', 'i',
                                't', 'i', 'v', 'e', ' ', 'i', 'n', 't',
                                'e', 'g', 'e', 'r', '.' };
static mxArray * _mxarray9_;
static mxArray * _mxarray11_;
static mxArray * _mxarray12_;
static mxArray * _mxarray13_;
static mxArray * _mxarray14_;

static double _array16_[4] = { 1.0, 1.0, 0.0, 0.0 };
static mxArray * _mxarray15_;

void InitializeModule_resample(void) {
    _mxarray0_ = mclInitializeString(134, _array1_);
    _mxarray2_ = mclInitializeString(133, _array3_);
    _mxarray4_ = mclInitializeDouble(5.0);
    _mxarray5_ = mclInitializeDouble(10.0);
    _mxarray6_ = mclInitializeDouble(0.0);
    _mxarray7_ = mclInitializeString(29, _array8_);
    _mxarray9_ = mclInitializeString(29, _array10_);
    _mxarray11_ = mclInitializeDouble(1e-12);
    _mxarray12_ = mclInitializeDouble(1.0);
    _mxarray13_ = mclInitializeDouble(.5);
    _mxarray14_ = mclInitializeDouble(2.0);
    _mxarray15_ = mclInitializeDoubleVector(1, 4, _array16_);
}

void TerminateModule_resample(void) {
    mxDestroyArray(_mxarray15_);
    mxDestroyArray(_mxarray14_);
    mxDestroyArray(_mxarray13_);
    mxDestroyArray(_mxarray12_);
    mxDestroyArray(_mxarray11_);
    mxDestroyArray(_mxarray9_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray6_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mresample(mxArray * * h,
                           int nargout_,
                           mxArray * x,
                           mxArray * p,
                           mxArray * q,
                           mxArray * N,
                           mxArray * beta);

_mexLocalFunctionTable _local_function_table_resample
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfResample" contains the normal interface for the "resample"
 * M-function from file "D:\analysis\matlab\utils\else\resample.m" (lines
 * 1-119). This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
mxArray * mlfResample(mxArray * * h,
                      mxArray * x,
                      mxArray * p,
                      mxArray * q,
                      mxArray * N,
                      mxArray * beta) {
    int nargout = 1;
    mxArray * y = mclGetUninitializedArray();
    mxArray * h__ = mclGetUninitializedArray();
    mlfEnterNewContext(1, 5, h, x, p, q, N, beta);
    if (h != NULL) {
        ++nargout;
    }
    y = Mresample(&h__, nargout, x, p, q, N, beta);
    mlfRestorePreviousContext(1, 5, h, x, p, q, N, beta);
    if (h != NULL) {
        mclCopyOutputArg(h, h__);
    } else {
        mxDestroyArray(h__);
    }
    return mlfReturnValue(y);
}

/*
 * The function "mlxResample" contains the feval interface for the "resample"
 * M-function from file "D:\analysis\matlab\utils\else\resample.m" (lines
 * 1-119). The feval function calls the implementation version of resample
 * through this function. This function processes any input arguments and
 * passes them to the implementation version of the function, appearing above.
 */
void mlxResample(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[5];
    mxArray * mplhs[2];
    int i;
    if (nlhs > 2) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 5) {
        mlfError(_mxarray2_);
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
      = Mresample(
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

/*
 * The function "Mresample" is the implementation version of the "resample"
 * M-function from file "D:\analysis\matlab\utils\else\resample.m" (lines
 * 1-119). It contains the actual compiled code for that M-function. It is a
 * static function and must only be called from one of the interface functions,
 * appearing below.
 */
/*
 * function  [y, h] = resample( x, p, q, N, beta )
 */
static mxArray * Mresample(mxArray * * h,
                           int nargout_,
                           mxArray * x,
                           mxArray * p,
                           mxArray * q,
                           mxArray * N,
                           mxArray * beta) {
    mexLocalFunctionTable save_local_function_table_ = mclSetCurrentLocalFunctionTable(
                                                         &_local_function_table_resample);
    int nargin_ = mclNargin(5, x, p, q, N, beta, NULL);
    mxArray * y = mclGetUninitializedArray();
    mxArray * Ly = mclGetUninitializedArray();
    mxArray * nz1 = mclGetUninitializedArray();
    mxArray * delay = mclGetUninitializedArray();
    mxArray * z = mclGetUninitializedArray();
    mxArray * nz = mclGetUninitializedArray();
    mxArray * num_sigs = mclGetUninitializedArray();
    mxArray * Lx = mclGetUninitializedArray();
    mxArray * isvect = mclGetUninitializedArray();
    mxArray * Lhalf = mclGetUninitializedArray();
    mxArray * fc = mclGetUninitializedArray();
    mxArray * L = mclGetUninitializedArray();
    mxArray * pqmax = mclGetUninitializedArray();
    mxArray * col = mclGetUninitializedArray();
    mxArray * row = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    mclCopyArray(&x);
    mclCopyArray(&p);
    mclCopyArray(&q);
    mclCopyArray(&N);
    mclCopyArray(&beta);
    /*
     * %RESAMPLE  Change the sampling rate of a signal.
     * %   Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times
     * %   the original sample rate using a polyphase implementation.  Y is P/Q 
     * %   times the length of X (or the ceiling of this if P/Q is not an integer).  
     * %   P and Q must be positive integers.
     * %
     * %   RESAMPLE applies an anti-aliasing (lowpass) FIR filter to X during the 
     * %   resampling process, and compensates for the filter's delay.  The filter 
     * %   is designed using FIRLS.  RESAMPLE provides an easy-to-use alternative
     * %   to UPFIRDN, which does not require you to supply a filter or compensate
     * %   for the signal delay introduced by filtering.
     * %
     * %   Y = RESAMPLE(X,P,Q,N) uses a weighted sum of 2*N*max(1,Q/P) samples of X 
     * %   to compute each sample of Y.  The length of the FIR filter RESAMPLE applies
     * %   is proportional to N; by increasing N you will get better accuracy at the 
     * %   expense of a longer computation time.  If you don't specify N, RESAMPLE uses
     * %   N = 10 by default.  If you let N = 0, RESAMPLE performs a nearest
     * %   neighbor interpolation; that is, the output Y(n) is X(round((n-1)*Q/P)+1)
     * %   ( Y(n) = 0 if round((n-1)*Q/P)+1 > length(X) ).
     * %
     * %   Y = RESAMPLE(X,P,Q,N,BETA) uses BETA as the design parameter for the 
     * %   Kaiser window used to design the filter.  RESAMPLE uses BETA = 5 if
     * %   you don't specify a value.
     * %
     * %   Y = RESAMPLE(X,P,Q,B) uses B to filter X (after upsampling) if B is a 
     * %   vector of filter coefficients.  RESAMPLE assumes B has odd length and
     * %   linear phase when compensating for the filter's delay; for even length 
     * %   filters, the delay is overcompensated by 1/2 sample.  For non-linear 
     * %   phase filters consider using UPFIRDN.
     * %
     * %   [Y,B] = RESAMPLE(X,P,Q,...) returns in B the coefficients of the filter
     * %   applied to X during the resampling process (after upsampling).
     * %
     * %   If X is a matrix, RESAMPLE resamples the columns of X.
     * %
     * %   See also UPFIRDN, INTERP, DECIMATE, FIRLS, KAISER, INTFILT.
     * 
     * %   NOTE-1: digital anti-alias filter is desiged via windowing
     * 
     * %   Author(s): James McClellan, 6-11-93
     * %              Modified to use upfirdn, T. Krauss, 2-27-96
     * %   Copyright 1988-2000 The MathWorks, Inc.
     * %   $Revision: 1.6 $  $Date: 2000/06/09 22:06:58 $
     * 
     * if nargin < 5,  beta = 5;  end   %--- design parameter for Kaiser window LPF
     */
    if (nargin_ < 5) {
        mlfAssign(&beta, _mxarray4_);
    }
    /*
     * if nargin < 4,   N = 10;   end
     */
    if (nargin_ < 4) {
        mlfAssign(&N, _mxarray5_);
    }
    /*
     * if abs(round(p))~=p | p==0, error('P must be a positive integer.'), end
     */
    {
        mxArray * a_ = mclInitialize(
                         mclNe(
                           mclVe(mlfAbs(mclVe(mlfRound(mclVa(p, "p"))))),
                           mclVa(p, "p")));
        if (mlfTobool(a_)
            || mlfTobool(mclOr(a_, mclEq(mclVa(p, "p"), _mxarray6_)))) {
            mxDestroyArray(a_);
            mlfError(_mxarray7_);
        } else {
            mxDestroyArray(a_);
        }
    }
    /*
     * if abs(round(q))~=q | q==0, error('Q must be a positive integer.'), end
     */
    {
        mxArray * a_ = mclInitialize(
                         mclNe(
                           mclVe(mlfAbs(mclVe(mlfRound(mclVa(q, "q"))))),
                           mclVa(q, "q")));
        if (mlfTobool(a_)
            || mlfTobool(mclOr(a_, mclEq(mclVa(q, "q"), _mxarray6_)))) {
            mxDestroyArray(a_);
            mlfError(_mxarray9_);
        } else {
            mxDestroyArray(a_);
        }
    }
    /*
     * [row,col]=size(x);
     */
    mlfSize(mlfVarargout(&row, &col, NULL), mclVa(x, "x"), NULL);
    /*
     * 
     * [p,q] = rat( p/q, 1e-12 );  %--- reduce to lowest terms 
     */
    mlfAssign(
      &p,
      mlfNRat(2, &q, mclMrdivide(mclVa(p, "p"), mclVa(q, "q")), _mxarray11_));
    /*
     * % (usually exact, sometimes not; loses at most 1 second every 10^12 seconds)
     * if (p==1)&(q==1)
     */
    {
        mxArray * a_ = mclInitialize(mclEq(mclVa(p, "p"), _mxarray12_));
        if (mlfTobool(a_)
            && mlfTobool(mclAnd(a_, mclEq(mclVa(q, "q"), _mxarray12_)))) {
            mxDestroyArray(a_);
            /*
             * y = x; 
             */
            mlfAssign(&y, mclVsa(x, "x"));
            /*
             * h = 1;
             */
            mlfAssign(h, _mxarray12_);
            /*
             * return
             */
            goto return_;
        } else {
            mxDestroyArray(a_);
        }
    /*
     * end
     */
    }
    /*
     * pqmax = max(p,q);
     */
    mlfAssign(&pqmax, mlfMax(NULL, mclVa(p, "p"), mclVa(q, "q"), NULL));
    /*
     * if length(N)>1      % use input filter
     */
    if (mclLengthInt(mclVa(N, "N")) > 1) {
        /*
         * L = length(N);
         */
        mlfAssign(&L, mlfScalar(mclLengthInt(mclVa(N, "N"))));
        /*
         * h = N;
         */
        mlfAssign(h, mclVsa(N, "N"));
    /*
     * else                % design filter
     */
    } else {
        /*
         * if( N>0 )
         */
        if (mclGtBool(mclVa(N, "N"), _mxarray6_)) {
            /*
             * fc = 1/2/pqmax;
             */
            mlfAssign(&fc, mclMrdivide(_mxarray13_, mclVv(pqmax, "pqmax")));
            /*
             * L = 2*N*pqmax + 1;
             */
            mlfAssign(
              &L,
              mclPlus(
                mclMtimes(
                  mclMtimes(_mxarray14_, mclVa(N, "N")), mclVv(pqmax, "pqmax")),
                _mxarray12_));
            /*
             * h = p*firls( L-1, [0 2*fc 2*fc 1], [1 1 0 0]).*kaiser(L,beta)' ;
             */
            mlfAssign(
              h,
              mclTimes(
                mclMtimes(
                  mclVa(p, "p"),
                  mclVe(
                    mlfNFirls(
                      1,
                      NULL,
                      mclMinus(mclVv(L, "L"), _mxarray12_),
                      mlfHorzcat(
                        _mxarray6_,
                        mclMtimes(_mxarray14_, mclVv(fc, "fc")),
                        mclMtimes(_mxarray14_, mclVv(fc, "fc")),
                        _mxarray12_,
                        NULL),
                      _mxarray15_,
                      NULL,
                      NULL))),
                mlfCtranspose(
                  mclVe(mlfKaiser(mclVv(L, "L"), mclVa(beta, "beta"))))));
        /*
         * % h = p*fir1( L-1, 2*fc, kaiser(L,beta)) ;
         * else
         */
        } else {
            /*
             * L = p;
             */
            mlfAssign(&L, mclVsa(p, "p"));
            /*
             * h = ones(1,p);
             */
            mlfAssign(h, mlfOnes(_mxarray12_, mclVa(p, "p"), NULL));
        /*
         * end
         */
        }
    /*
     * end
     */
    }
    /*
     * 
     * Lhalf = (L-1)/2;
     */
    mlfAssign(
      &Lhalf, mclMrdivide(mclMinus(mclVv(L, "L"), _mxarray12_), _mxarray14_));
    /*
     * isvect = any(size(x)==1);
     */
    mlfAssign(
      &isvect,
      mlfAny(
        mclEq(
          mclVe(mlfSize(mclValueVarargout(), mclVa(x, "x"), NULL)),
          _mxarray12_),
        NULL));
    /*
     * if isvect
     */
    if (mlfTobool(mclVv(isvect, "isvect"))) {
        /*
         * Lx = length(x);
         */
        mlfAssign(&Lx, mlfScalar(mclLengthInt(mclVa(x, "x"))));
    /*
     * else
     */
    } else {
        /*
         * [Lx,num_sigs]=size(x);
         */
        mlfSize(mlfVarargout(&Lx, &num_sigs, NULL), mclVa(x, "x"), NULL);
    /*
     * end
     */
    }
    /*
     * 
     * % Need to delay output so that downsampling by q hits center tap of filter.
     * nz = floor(q-mod(Lhalf,q));
     */
    mlfAssign(
      &nz,
      mlfFloor(
        mclMinus(
          mclVa(q, "q"), mclVe(mlfMod(mclVv(Lhalf, "Lhalf"), mclVa(q, "q"))))));
    /*
     * z = zeros(1,nz);
     */
    mlfAssign(&z, mlfZeros(_mxarray12_, mclVv(nz, "nz"), NULL));
    /*
     * h = [z h(:)'];
     */
    mlfAssign(
      h,
      mlfHorzcat(
        mclVv(z, "z"),
        mlfCtranspose(
          mclVe(mclArrayRef1(mclVsv(*h, "h"), mlfCreateColonIndex()))),
        NULL));
    /*
     * Lhalf = Lhalf + nz;
     */
    mlfAssign(&Lhalf, mclPlus(mclVv(Lhalf, "Lhalf"), mclVv(nz, "nz")));
    /*
     * 
     * % Number of samples removed from beginning of output sequence 
     * % to compensate for delay of linear phase filter:
     * delay = floor(ceil(Lhalf)/q);
     */
    mlfAssign(
      &delay,
      mlfFloor(
        mclMrdivide(mclVe(mlfCeil(mclVv(Lhalf, "Lhalf"))), mclVa(q, "q"))));
    /*
     * 
     * % Need to zero-pad so output length is exactly ceil(Lx*p/q).
     * nz1 = 0;
     */
    mlfAssign(&nz1, _mxarray6_);
    /*
     * while ceil( ((Lx-1)*p+length(h)+nz1 )/q ) - delay < ceil(Lx*p/q)
     */
    while (mclLtBool(
             mclMinus(
               mclVe(
                 mlfCeil(
                   mclMrdivide(
                     mclPlus(
                       mclPlus(
                         mclMtimes(
                           mclMinus(mclVv(Lx, "Lx"), _mxarray12_),
                           mclVa(p, "p")),
                         mlfScalar(mclLengthInt(mclVv(*h, "h")))),
                       mclVv(nz1, "nz1")),
                     mclVa(q, "q")))),
               mclVv(delay, "delay")),
             mclVe(
               mlfCeil(
                 mclMrdivide(
                   mclMtimes(mclVv(Lx, "Lx"), mclVa(p, "p")),
                   mclVa(q, "q")))))) {
        /*
         * nz1 = nz1+1;
         */
        mlfAssign(&nz1, mclPlus(mclVv(nz1, "nz1"), _mxarray12_));
    /*
     * end
     */
    }
    /*
     * h = [h zeros(1,nz1)];
     */
    mlfAssign(
      h,
      mlfHorzcat(
        mclVv(*h, "h"),
        mclVe(mlfZeros(_mxarray12_, mclVv(nz1, "nz1"), NULL)),
        NULL));
    /*
     * 
     * % ----  HERE'S THE CALL TO UPFIRDN  ----------------------------
     * y = upfirdn(x,h,p,q);
     */
    mlfAssign(
      &y,
      mlfNUpfirdn(
        0,
        mclValueVarargout(),
        mclVa(x, "x"),
        mclVv(*h, "h"),
        mclVa(p, "p"),
        mclVa(q, "q"),
        NULL));
    /*
     * 
     * % Get rid of trailing and leading data so input and output signals line up
     * % temporally:
     * Ly = ceil(Lx*p/q);  % output length
     */
    mlfAssign(
      &Ly,
      mlfCeil(
        mclMrdivide(mclMtimes(mclVv(Lx, "Lx"), mclVa(p, "p")), mclVa(q, "q"))));
    /*
     * % Ly = floor((Lx-1)*p/q+1);  <-- alternately, to prevent "running-off" the
     * %                                data (extrapolation)
     * if isvect
     */
    if (mlfTobool(mclVv(isvect, "isvect"))) {
        /*
         * y(1:delay) = [];
         */
        mlfIndexDelete(
          &y, "(?)", mlfColon(_mxarray12_, mclVv(delay, "delay"), NULL));
        /*
         * y(Ly+1:end) = [];
         */
        mlfIndexDelete(
          &y,
          "(?)",
          mlfColon(
            mclPlus(mclVv(Ly, "Ly"), _mxarray12_),
            mlfEnd(mclVv(y, "y"), _mxarray12_, _mxarray12_),
            NULL));
    /*
     * else
     */
    } else {
        /*
         * y(1:delay,:) = [];
         */
        mlfIndexDelete(
          &y,
          "(?,?)",
          mlfColon(_mxarray12_, mclVv(delay, "delay"), NULL),
          mlfCreateColonIndex());
        /*
         * y(Ly+1:end,:) = [];
         */
        mlfIndexDelete(
          &y,
          "(?,?)",
          mlfColon(
            mclPlus(mclVv(Ly, "Ly"), _mxarray12_),
            mlfEnd(mclVv(y, "y"), _mxarray12_, _mxarray14_),
            NULL),
          mlfCreateColonIndex());
    /*
     * end
     */
    }
    /*
     * 
     * h([1:nz (end-nz1+1):end]) = [];  % get rid of leading and trailing zeros 
     */
    mlfIndexDelete(
      h,
      "(?)",
      mlfHorzcat(
        mlfColon(_mxarray12_, mclVv(nz, "nz"), NULL),
        mlfColon(
          mclPlus(
            mclMinus(
              mlfEnd(mclVv(*h, "h"), _mxarray12_, _mxarray12_),
              mclVv(nz1, "nz1")),
            _mxarray12_),
          mlfEnd(mclVv(*h, "h"), _mxarray12_, _mxarray12_),
          NULL),
        NULL));
    /*
     * % in case filter is output
     * 
     */
    return_:
    mclValidateOutput(y, 1, nargout_, "y", "resample");
    mclValidateOutput(*h, 2, nargout_, "h", "resample");
    mxDestroyArray(ans);
    mxDestroyArray(row);
    mxDestroyArray(col);
    mxDestroyArray(pqmax);
    mxDestroyArray(L);
    mxDestroyArray(fc);
    mxDestroyArray(Lhalf);
    mxDestroyArray(isvect);
    mxDestroyArray(Lx);
    mxDestroyArray(num_sigs);
    mxDestroyArray(nz);
    mxDestroyArray(z);
    mxDestroyArray(delay);
    mxDestroyArray(nz1);
    mxDestroyArray(Ly);
    mxDestroyArray(beta);
    mxDestroyArray(N);
    mxDestroyArray(q);
    mxDestroyArray(p);
    mxDestroyArray(x);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return y;
}
