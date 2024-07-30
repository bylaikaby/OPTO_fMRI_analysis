/*
 * acov.c
 * an altnative for MATLAB cov() function 
 *
 * This is less memory consumer than MATLAB native function.
 *
 * VERSION/AUTHOR/NOTES
 *  1.00 10.10.01 Yusuke MURAYAMA  pre-release
 *  1.01 14.07.09 Yusuke MURAYAMA  supports single
 *  1.10 23.07.09 Yusuke MURAYAMA  improved speed
 *
 */

#include "mex.h"
#include "matrix.h"

#include <math.h>

//#define USE_TRANSPOSED_DATA



double innerprod(double *u, double *v, int n)
{
  int i, n8;
  double r;

  r = 0;  n8 = n%8;
  for (i = 0; i < n8; i++)  r = r + u[i]*v[i];
  for (i = n8; i < n; i++)
    r = r + u[i]*v[i] + u[i+1]*v[i+1] + u[i+2]*v[i+2] + u[i+3]*v[i+3] 
      + u[i+4]*v[i+4] + u[i+5]*v[i+5] + u[i+6]*v[i+6] + u[i+7]*v[i+7];

  return r;
}


void mycov(double *xt, int n_data, int n_dim, double *xy, int flag)
{
  double *xm;
  double dn;
  int i, j, k, ixy, ix, iy;

  //for (i = 0; i < 10; i++)  printf("%g\n",xt[i]);

  dn = (double) n_data;
  xm = (double *)mxCalloc(n_dim, sizeof(double));
  
  for (k = 0; k < n_data; k++) {
    for (i = 0, ix = k*n_dim; i < n_dim; i++, ix++) {
      xm[i] = xm[i] + xt[ix]/dn;
      for (j = 0, iy = k*n_dim, ixy = i*n_dim; j <= i; j++, iy++, ixy++) {
        xy[ixy]  = xy[ixy] + xt[ix] * xt[iy];
      }
    }
  }
  for (i = 0; i < n_dim; i++) {
    for (j = 0, ixy = i*n_dim; j <= i; j++, ixy++) {
      xy[ixy] = xy[ixy] / dn - xm[i]*xm[j];
      xy[j*n_dim + i] = xy[ixy];
    }
  }
  if (flag == 0) {
    dn = dn / (dn - 1);
    for (i = 0; i < n_dim*n_dim; i++)  xy[i] = xy[i] * dn;
  }

  mxFree(xm);

  return;
}


void mycov2d(double *x, int n_data, int n_dim, double *xy, int flag)
{
  double *xm;
  double *tmpx, *tmpy;
  double dn, tmps;
  int i, j, k, ixy, n8, ix, iy;

  //for (i = 0; i < 10; i++)  printf("%g\n",x[i]);

  dn = (double) n_data;
  xm = (double *)mxCalloc(n_dim, sizeof(double));


  if (n_dim > n_data) {
    for (i = 0; i < n_dim; i++) {
      tmpx = &x[i*n_data];
      for (j = 0; j < n_data; j++) {
        xm[i] = xm[i] + tmpx[j]/dn;
      }
    }
    n8 = n_data%8;
    for (i = 0; i < n_dim; i++) {
      tmpx = &x[i*n_data];
      for (k = 0, ixy = i*n_dim; k <= i; k++, ixy++) {
        tmpy = &x[k*n_data];
        tmps = 0;
        for (j = 0; j < n8; j++) {
          tmps = tmps + tmpx[j]*tmpy[j];
        }
        for (j = n8; j < n_data; j+=8) {
          tmps = tmps + tmpx[j]*tmpy[j]
            + tmpx[j+1]*tmpy[j+1]
            + tmpx[j+2]*tmpy[j+2]
            + tmpx[j+3]*tmpy[j+3]
            + tmpx[j+4]*tmpy[j+4]
            + tmpx[j+5]*tmpy[j+5]
            + tmpx[j+6]*tmpy[j+6]
            + tmpx[j+7]*tmpy[j+7];
        }
        tmps = tmps/dn - xm[i]*xm[k];
        xy[ixy] = tmps;
        xy[k*n_dim + i] = tmps;
      }
    }
  } else {
    n8 = n_data%8;
    for (k = 0; k < n8; k++) {
      for (i = 0, ix = k; i < n_dim; i++, ix+=n_data) {
        xm[i] = xm[i] + x[ix];
        for (j = 0, iy = k, ixy = i*n_dim; j <= i; j++, iy+=n_data, ixy++) {
          xy[ixy]  = xy[ixy] + x[ix] * x[iy];
        }
      }
    }
    for (k = n8; k < n_data; k+=8) {
      for (i = 0, ix = k; i < n_dim; i++, ix+=n_data) {
        xm[i] = xm[i] + x[ix]
          + x[ix+1]
          + x[ix+2]
          + x[ix+3]
          + x[ix+4]
          + x[ix+5]
          + x[ix+6]
          + x[ix+7];
        for (j = 0, iy = k, ixy = i*n_dim; j <= i; j++, iy+=n_data, ixy++) {
          xy[ixy]  = xy[ixy] + x[ix]*x[iy]
            + x[ix+1]*x[iy+1]
            + x[ix+2]*x[iy+2]
            + x[ix+3]*x[iy+3]
            + x[ix+4]*x[iy+4]
            + x[ix+5]*x[iy+5]
            + x[ix+6]*x[iy+6]
            + x[ix+7]*x[iy+7];
        }
      }
    }
    for (i = 0; i < n_dim; i++) {
      for (j = 0, ixy = i*n_dim; j <= i; j++, ixy++) {
        xy[ixy] = xy[ixy] / dn - xm[i]*xm[j]/dn/dn;
        xy[j*n_dim + i] = xy[ixy];
      }
    }
  }


  if (flag == 0) {
    dn = dn / (dn - 1);
    for (i = 0; i < n_dim*n_dim; i++)  xy[i] = xy[i] * dn;
  }

  mxFree(xm);

  return;
}

void mycov2f(float *x, int n_data, int n_dim, float *xy, int flag)
{
  float *xm;
  float *tmpx, *tmpy;
  float dn, tmps;
  int i, j, k, ixy, ix, iy, n8;

  //for (i = 0; i < 10; i++)  printf("%g\n",x[i]);

  dn = (float) n_data;
  xm = (float *)mxCalloc(n_dim, sizeof(float));

  if (n_dim > n_data) {
    for (i = 0; i < n_dim; i++) {
      tmpx = &x[i*n_data];
      for (j = 0; j < n_data; j++) {
        xm[i] = xm[i] + tmpx[j];
      }
      xm[i] = xm[i] / dn;
    }
    n8 = n_data%8;
    for (i = 0; i < n_dim; i++) {
      tmpx = &x[i*n_data];
      for (k = 0, ixy = i*n_dim; k <= i; k++, ixy++) {
        tmpy = &x[k*n_data];
        tmps = 0;
        for (j = 0; j < n8; j++) {
          tmps = tmps + tmpx[j]*tmpy[j];
        }
        for (j = n8; j < n_data; j+=8) {
          tmps = tmps + tmpx[j]*tmpy[j]
            + tmpx[j+1]*tmpy[j+1]
            + tmpx[j+2]*tmpy[j+2]
            + tmpx[j+3]*tmpy[j+3]
            + tmpx[j+4]*tmpy[j+4]
            + tmpx[j+5]*tmpy[j+5]
            + tmpx[j+6]*tmpy[j+6]
            + tmpx[j+7]*tmpy[j+7];
        }
        tmps = tmps/dn - xm[i]*xm[k];
        xy[ixy] = tmps;
        xy[k*n_dim + i] = tmps;
      }
    }
  } else {
    n8 = n_data%8;
    for (k = 0; k < n8; k++) {
      for (i = 0, ix = k; i < n_dim; i++, ix+=n_data) {
        xm[i] = xm[i] + x[ix];
        for (j = 0, iy = k, ixy = i*n_dim; j <= i; j++, iy+=n_data, ixy++) {
          xy[ixy]  = xy[ixy] + x[ix] * x[iy];
        }
      }
    }
    for (k = n8; k < n_data; k+=8) {
      for (i = 0, ix = k; i < n_dim; i++, ix+=n_data) {
        xm[i] = xm[i] + x[ix]
          + x[ix+1]
          + x[ix+2]
          + x[ix+3]
          + x[ix+4]
          + x[ix+5]
          + x[ix+6]
          + x[ix+7];
        for (j = 0, iy = k, ixy = i*n_dim; j <= i; j++, iy+=n_data, ixy++) {
          xy[ixy]  = xy[ixy] + x[ix]*x[iy]
            + x[ix+1]*x[iy+1]
            + x[ix+2]*x[iy+2]
            + x[ix+3]*x[iy+3]
            + x[ix+4]*x[iy+4]
            + x[ix+5]*x[iy+5]
            + x[ix+6]*x[iy+6]
            + x[ix+7]*x[iy+7];
        }
      }
    }
    for (i = 0; i < n_dim; i++) {
      for (j = 0, ixy = i*n_dim; j <= i; j++, ixy++) {
        xy[ixy] = xy[ixy] / dn - xm[i]*xm[j]/dn/dn;
        xy[j*n_dim + i] = xy[ixy];
      }
    }
  }


  if (flag == 0) {
    dn = dn / (dn - 1);
    for (i = 0; i < n_dim*n_dim; i++)  xy[i] = xy[i] * dn;
  }

  mxFree(xm);

  return;
}


/* MEX function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  mxArray *minp[1], *mxtr[1];
  mxArray *mx, *my;
  int  n_data, n_dim;
  int  nx, status;
  int flag;

  /* initialization */
  mx = my = NULL;
  n_data = n_dim = 0;  nx = 0;
  flag = 0;

  /* Check for proper number of arguments. */
  if (nrhs == 0 || nlhs > 1) {
    mexPrintf("Usage: C = lmcov(x,...), less memory cov() function.\n");
    return;
  }
  if (!mxIsNumeric(prhs[0])) {
		mexErrMsgTxt(" Input x must be numeric.");
  }
  if (!mxIsDouble(prhs[0]) && !mxIsSingle(prhs[0])) {
    mexErrMsgTxt(" Input must be single or double.");
  }

  if (mxIsEmpty(prhs[0])) {
    plhs[0] = mxCreateNumericMatrix(1,1,mxGetClassID(prhs[0]),mxREAL);
    return;
  }

  /* Get dimension of an input matrix */
  n_data = (int) mxGetM(prhs[0]);
  n_dim  = (int) mxGetN(prhs[0]);
  nx     = mxGetNumberOfElements(prhs[0]);

  if (nx == 1 && n_dim == 1) {
    // input is just a scalar value...
    plhs[0] = mxCreateNumericMatrix(1,1,mxGetClassID(prhs[0]),mxREAL);
    return;
  } else if (n_data == 1 || n_dim == 1) {
    // input as a vector, doesn't matter column or raw..
    n_dim = 1;
    n_data = nx;
  }

  mx = prhs[0];
  //x = mxGetPr(prhs[0]);
  
  if (nrhs == 2 || nrhs == 3) {
    if (mxGetNumberOfElements(prhs[nrhs-1]) == 1) {
      flag = (int)mxGetScalar(prhs[nrhs-1]);
      if (mxGetNumberOfElements(prhs[nrhs-2]) != nx) {
        mexErrMsgTxt(" lmcov: The lengths of x and y must match.");
      }
      my = prhs[nrhs-2];
      //y = mxGetPr(prhs[nrhs-2]);
    } else {
      my = prhs[nrhs-1];
      //y = mxGetPr(prhs[nrhs-1]);
    }
    if (mxGetClassID(mx) != mxGetClassID(my)) {
      mexErrMsgTxt(" Different data class of x/y, must be the same.");
    }
  }


  if (mx != my && my != NULL) {
    // when cov(x,y,...), it should be cov([x(:) y(:)])
    mx = mxCreateNumericMatrix(nx,2,mxGetClassID(prhs[0]),mxREAL);
    my = NULL;
    if (mxIsSingle(prhs[0])) {
      memcpy(mxGetData(mx), mxGetData(prhs[0]),sizeof(float)*nx);
      memcpy(&((float *)mxGetData(mx))[nx],mxGetData(prhs[1]),sizeof(float)*nx);
    } else {
      memcpy(mxGetData(mx), mxGetData(prhs[0]),sizeof(double)*nx);
      memcpy(&((double *)mxGetData(mx))[nx],mxGetData(prhs[1]),sizeof(double)*nx);
    }
    n_dim  = 2;
    n_data = nx;
  }

  /* Create a matrix for the return argument. */
  plhs[0] = mxCreateNumericMatrix(n_dim, n_dim, mxGetClassID(mx),mxREAL);

#ifdef USE_TRANSPOSED_DATA
  /* Transpose input matrix */
  minp[0] = mx;
  mexCallMATLAB(1, mxtr, 1, minp  , "transpose");
  /* Call mycov(). */
  mycov((double *)mxGetData(mxtr[0]), n_data, n_dim, (double *)mxGetData(plhs[0]), flag);
#else
  if (mxIsSingle(prhs[0])) {
    mycov2f((float *)mxGetData(mx), n_data, n_dim, (float *)mxGetData(plhs[0]), flag);
  } else {
    mycov2d((double *)mxGetData(mx), n_data, n_dim, (double *)mxGetData(plhs[0]), flag);
  }
#endif

  return;
}
