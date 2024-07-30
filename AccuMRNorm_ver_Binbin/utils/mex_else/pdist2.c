/*
 * pdist2.c
 * an altnative for MATLAB pdist() function 
 *
 * This is much faster than MATLAB native function.
 *
 * ver. 1.00  13-12-1999  Yusuke MURAYAMA
 *
 * To make mex DLL,
 * >>mex pdist2.c
 *
 */

#include "mex.h"
#include "matrix.h"

#include <math.h>
#include <string.h>


enum { EUCLID, SEUCLID, MAHAL, CITYBLOCK, MINKOWSKI };

/* prototypes */
void euclid_d(double *y, mxArray *mx, int *xi, int *xj, int n_vars, int n_dist);
void seuclid_d(double *y, mxArray *mx, int *xi, int *xj, int n_vars, int n_dist);
void mahal_d(double *y, mxArray *mx, int *xi, int *xj, int n_vars, int n_dist);
void cityblock_d(double *y, mxArray *mx, int xi[], int xj[], int n_vars, int n_dist);
void minkowski_d(double *y, mxArray *mx, int xi[], int xj[], int n_vars, int n_dist, double p);
void pdist2(double *y, mxArray *mx, int n_data, int n_vars, int n_dist, int metric, double p);


/* compute distance */
void euclid_d(double *y, mxArray *mx, int *xi, int *xj, 
			  int n_vars, int n_dist)
{
  mxArray *minp[1], *mxtr[1];
  int i, j, k1, k2;
  double *x, tmp_d, tmp_s;

  /* Transpose the input matrix, because MatLab gives it as column first. */ 
  minp[0] = mx;
  mexCallMATLAB(1, mxtr, 1, minp  , "transpose");
  x = mxGetPr(mxtr[0]);

#ifdef YM
  y[0] = x[0];
  y[1] = x[1];
  y[2] = x[2];
  return;
#endif

  for (i = 0; i < n_dist; i++) {
		k1 = xi[i]*n_vars;
		k2 = xj[i]*n_vars;
		tmp_s = 0;
		for (j = 0; j < n_vars; j++) {
			tmp_d = x[k1+j] - x[k2+j];
			tmp_s += tmp_d * tmp_d;
		}
		y[i] = sqrt(tmp_s);
  }
  return;
}


void seuclid_d(double *y, mxArray *mx, int *xi, int *xj, 
			   int n_vars, int n_dist)
{
  mxArray *minp[1], *mxtr[1], *mvar[1];
  int i, j, k1, k2;
  double *x, tmp_d, tmp_s, *vari;
 
  minp[0] = mx;
  mexCallMATLAB(1, mxtr,  1, minp, "transpose");
  x = mxGetPr(mxtr[0]);
  mexCallMATLAB(1, mvar,  1, minp, "var");
  vari = mxGetPr(mvar[0]);
	
  for (i = 0; i < n_dist; i++) {
		k1 = xi[i]*n_vars;
		k2 = xj[i]*n_vars;
		tmp_s = 0;
		for (j = 0; j < n_vars; j++) {
			tmp_d = x[k1+j] - x[k2+j];
			/*	  tmp_s += tmp_d * tmp_d / vari[j]; */
			tmp_s += tmp_d * tmp_d * vari[j];
		}
		y[i] = sqrt(tmp_s);
  }
  return;
}


void mahal_d(double *y, mxArray *mx, int *xi, int *xj,
			 int n_vars, int n_dist)
{
  mxArray *minp[1], *mxtr[1], *mtmp[1], *minv[1];
  int i, j, k1, k2, k3, k;
  double *x, *tmp_d, tmp_s, *tmp_d2, *inv;

  minp[0] = mx;
  mexCallMATLAB(1, mxtr, 1, minp  , "transpose");
  x = mxGetPr(mxtr[0]);
  mexCallMATLAB(1, mtmp, 1, minp, "cov");
  mexCallMATLAB(1, minv, 1, mtmp, "inv");
  /*  mexCallMATLAB(1, mtmp,  1, minv, "transpose"); */
  /*  inv = mxGetPr(mtmp[0]); */
  inv  = mxGetPr(minv[0]);
  tmp_d  = (double *)mxMalloc(n_vars*sizeof(double));
  tmp_d2 = (double *)mxMalloc(n_vars*sizeof(double));

  for (i = 0; i < n_dist; i++) {
		k1 = xi[i]*n_vars;
		k2 = xj[i]*n_vars;
		tmp_s = 0;
		for (j = 0; j < n_vars; j++) {
			tmp_d[j] = x[k1+j] - x[k2+j];
		}
		for (j = 0; j < n_vars; j++) {
			k3 = j*n_vars;
			tmp_d2[j] = 0;
			for (k = 0; k < n_vars; k++) {
				tmp_d2[j] += inv[k3+k]*tmp_d[k];
			}
		}
		for (j = 0; j < n_vars; j++) {
			tmp_s += tmp_d2[j] * tmp_d[j];
		}
		y[i] = sqrt(tmp_s);
  }
	
  mxFree(tmp_d);  mxFree(tmp_d2);
	
  return;
}


void cityblock_d(double *y, mxArray *mx, int xi[], int xj[],
				 int n_vars, int n_dist)
{
  mxArray *minp[1], *mxtr[1];
  int i, j, k1, k2;
  double *x, tmp_d, tmp_s;

  minp[0] = mx;
  mexCallMATLAB(1, mxtr, 1, minp  , "transpose");
  x = mxGetPr(mxtr[0]);

  for (i = 0; i < n_dist; i++) {
		k1 = xi[i]*n_vars;
		k2 = xj[i]*n_vars;
		tmp_s = 0;
		for (j = 0; j < n_vars; j++) {
			tmp_d = x[k1+j] - x[k2+j];
			tmp_s += fabs(tmp_d);
		}
		y[i] = tmp_s;
  }
  return;
}

void minkowski_d(double *y, mxArray *mx, int xi[], int xj[], 
			  int n_vars, int n_dist, double p)
{
  mxArray *minp[1], *mxtr[1];
  int i, j, k1, k2;
  double *x, tmp_d, tmp_s, pinv;

  minp[0] = mx;
  mexCallMATLAB(1, mxtr, 1, minp  , "transpose");
  x = mxGetPr(mxtr[0]);
  pinv = 1./p;

  for (i = 0; i < n_dist; i++) {
		k1 = xi[i]*n_vars;
		k2 = xj[i]*n_vars;
		tmp_s = 0;
		for (j = 0; j < n_vars; j++) {
			tmp_d = x[k1+j] - x[k2+j];
			tmp_s += pow(fabs(tmp_d), p);
		}
		y[i] = pow(tmp_s, pinv);
  }
  return;
}


/* pdis2 function */
void pdist2(double *y, mxArray *mx, int n_data, int n_vars, int n_dist, 
			int metric, double p)
{
  int *xi, *xj;
  int i, j, k;

  xi = (int *)mxMalloc(n_dist*sizeof(int));
  xj = (int *)mxMalloc(n_dist*sizeof(int));
  k = 0;
  for (i = 0; i < n_data; i++) {
	for (j = i+1; j < n_data; j++) {
	  xi[k] = i;  xj[k] = j;  k++;
	}
  }

  switch (metric) {
  case EUCLID:
		euclid_d(y, mx, xi, xj, n_vars, n_dist);
		break;
  case SEUCLID:
		seuclid_d(y, mx, xi, xj, n_vars, n_dist);
		break;
  case MAHAL:
		mahal_d(y, mx, xi, xj, n_vars, n_dist);
		break;
  case CITYBLOCK:
		cityblock_d(y, mx, xi, xj, n_vars, n_dist);
		break;
  case MINKOWSKI:
		minkowski_d(y, mx, xi, xj, n_vars, n_dist, p);
		break;
  }

  mxFree(xi);
  mxFree(xj);
  
  return;

}


/* MEX function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double *y;
  char ch_metric[32];
  int  n_data, n_vars, n_dist;
  int status, metric;
  double p;

  /* initialization */
  y = NULL;
  n_data = n_vars = n_dist = 0;
  sprintf(ch_metric, "");  metric = EUCLID;
  p = 2.0;

  /* Check for proper number of arguments. */
  if (nrhs == 0 || nlhs > 1) {
		mexErrMsgTxt(" USAGE: y = pdist2(x, 'metric')");
  }
  if (!mxIsNumeric(prhs[0])) {
		mexErrMsgTxt(" Input x must be numeric.");
  }

  /* Get dimension of an input matrix */
  n_data = (int) mxGetM(prhs[0]);
  n_vars = (int) mxGetN(prhs[0]);
  n_dist = (n_data*(n_data-1))/2;

  /* Create a matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(1, n_dist, mxREAL);
  y = mxGetPr(plhs[0]);

  /* Get a method to compute distance, if possible. */
  if (nrhs >= 2) {
		status = mxGetString(prhs[1], ch_metric, 2+1); 
	if (!stricmp(ch_metric, "EU"))      metric = EUCLID;
	else if (!stricmp(ch_metric, "SE")) metric = SEUCLID;
	else if (!stricmp(ch_metric, "MA")) metric = MAHAL;
	else if (!stricmp(ch_metric, "CI")) metric = CITYBLOCK;
	else if (!stricmp(ch_metric, "MI")) metric = MINKOWSKI;
	else mexErrMsgTxt(" Unknown metric method.");
  }
  if (nrhs >= 3) {
		p = mxGetScalar(prhs[2]);
		if (p <= 0)  mexErrMsgTxt(" The 3rd arg. must be positive.");
  }
	
  /* Call pdist2(). */
  pdist2(y, prhs[0], n_data, n_vars, n_dist, metric, p);
	
  return;

}
