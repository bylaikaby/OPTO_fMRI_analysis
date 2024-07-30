/*
 * sub_order_mds.c
 * subfunction for order_mds.m
 *
 * ver. 1.00  16-02-2012  Yusuke MURAYAMA@MPI
 *
 * To make mex DLL,
 * >> mex sub_order_mds.c
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
  double *dS_dx, *gdist, *x, *hat_dist_x, v;
  mwSize  m, M, n, N, r, s, dS_dxM, gdistM, xM;
  mwSize  rmin, rmax, smin, smax;


  // initialization

  // Check for proper number of arguments.
  // sub_order_mds(M,dS_dx,gdist,x,hat_dist_x)
  //mexPrintf("nlhs/nrhs=%d/%d\n",nlhs,nrhs);
  if (nrhs != 5 || nlhs != 0) {
	mexErrMsgTxt(" USAGE: sub_order_mds(M,dS_dx,gdist,x,hat_dist_x)");
  }

  // Get dimension of an input matrix
  M = (int)mxGetScalar(prhs[0]);
  N = (int)mxGetN(prhs[1]);
  //mexPrintf("M/N=%d/%d\n",M,N);
  dS_dx = (double *)mxGetPr(prhs[1]);
  gdist = (double *)mxGetPr(prhs[2]);
  x     = (double *)mxGetPr(prhs[3]);
  hat_dist_x = (double *)mxGetPr(prhs[4]);

  dS_dxM = mxGetM(prhs[1]);
  gdistM = mxGetM(prhs[2]);
  xM     = mxGetM(prhs[3]);

  r = s = 0;
  rmin = rmax = smin = smax = 0;
  
  //mexPrintf("dS_dx      = (%d,%d)\n",mxGetM(prhs[1]),mxGetN(prhs[1]));
  //mexPrintf("gdist      = (%d,%d)\n",mxGetM(prhs[2]),mxGetN(prhs[2]));
  //mexPrintf("x          = (%d,%d)\n",mxGetM(prhs[3]),mxGetN(prhs[3]));
  //mexPrintf("hat_dist_x = (%d,%d)\n",mxGetM(prhs[4]),mxGetN(prhs[4]));

  //m = 0;
  //mexPrintf("gdist(%d,:) = (%g,%g,%g)\n",m,
  //			gdist[gdistM*0+m],gdist[gdistM*1+m],gdist[gdistM*2+m]);
#if 0
  for (n = 0; n < N; n++) {
	for (m = 0; m < M; m++) {
	  r = (int)(gdist[gdistM   + m]+0.5)-1;
	  s = (int)(gdist[gdistM*2 + m]+0.5)-1;
	  v = (x[n*xM + r]-x[n*xM + s]) * hat_dist_x[m];
	  dS_dx[n*dS_dxM + r] = dS_dx[n*dS_dxM + r] + v;
	  dS_dx[n*dS_dxM + s] = dS_dx[n*dS_dxM + s] - v;
	}
  }
  // mexPrintf("r/s = %d-%d/%d-%d\n",rmin,rmax,smin,smax);
#else
  for (m = 0; m < M; m++) {
	r = (int)(gdist[gdistM   + m]+0.5)-1;
	s = (int)(gdist[gdistM*2 + m]+0.5)-1;
	//if (r > rmax)  rmax = r;
	//if (r < rmin)  rmin = r;
	//if (s > smax)  smax = s;
	//if (s < smin)  smin = s;
	for (n = 0; n < N; n++) {
	  //v = (x[r][n]-x[s][n]) * hat_dist_x[m];
	  v = (x[n*xM + r]-x[n*xM + s]) * hat_dist_x[m];
	  //mexPrintf("(r,s,n) = (%d,%d,%d)\n",r,s,n);
	  // dS_dx[r][n] = dS_dx[r][n] + v;
	  // dS_dx[s][n] = dS_dx[s][n] - v;
	  dS_dx[n*dS_dxM + r] = dS_dx[n*dS_dxM + r] + v;
	  dS_dx[n*dS_dxM + s] = dS_dx[n*dS_dxM + s] - v;
	}
  }
  // mexPrintf("r/s = %d-%d/%d-%d\n",rmin,rmax,smin,smax);
#endif

  // set the output
  //plhs[0] = prhs[0];
	
  return;
}
