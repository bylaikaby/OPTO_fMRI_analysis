/*
 * sub_order_mds2.c
 * subfunction for order_mds.m
 *
 * ver. 1.00  16-02-2012  Yusuke MURAYAMA@MPI
 *
 * To make mex DLL,
 * >> mex sub_order_mds2.c
 *
 */

#include "mex.h"
#include "matrix.h"

#include <math.h>
#include <string.h>




/* prototypes */



/* MEX function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double *dS_dx, *r, *s, *v;
  mwSize  m, M, n, N, dS_dxM, sM, rM, vM;
  mwSize  ri, si;


  // initialization

  // Check for proper number of arguments.
  // sub_order_mds2(M,dS_dx,r,s,v)
  //mexPrintf("nlhs/nrhs=%d/%d\n",nlhs,nrhs);
  if (nrhs != 5 || nlhs != 0) {
	mexErrMsgTxt(" USAGE: sub_order_mds2(M,dS_dx,r,s,v);");
  }

  // Get dimension of an input matrix
  M = (int)mxGetScalar(prhs[0]);
  N = (int)mxGetN(prhs[1]);
  //mexPrintf("M/N=%d/%d\n",M,N);
  dS_dx = (double *)mxGetPr(prhs[1]);
  r     = (double *)mxGetPr(prhs[2]);
  s     = (double *)mxGetPr(prhs[3]);
  v     = (double *)mxGetPr(prhs[4]);

  dS_dxM = mxGetM(prhs[1]);
  rM     = mxGetM(prhs[2]);
  sM     = mxGetM(prhs[3]);
  vM     = mxGetM(prhs[4]);

  for (m = 0; m < M; m++) {
	ri = (mwSize)(r[m]+0.5)-1;
	si = (mwSize)(s[m]+0.5)-1;
	for (n = 0; n < N; n++) {
	  dS_dx[n*dS_dxM + ri] = dS_dx[n*dS_dxM + ri] + v[n*vM + m];
	  dS_dx[n*dS_dxM + si] = dS_dx[n*dS_dxM + si] - v[n*vM + m];
	}
  }
	
  return;
}
