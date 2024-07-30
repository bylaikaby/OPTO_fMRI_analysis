/*
 * linkage2.c
 * an altnative for MATLAB linkage() function 
 *
 * This is much faster than MATLAB native function.
 *
 * ver. 1.00  16-12-1999  Yusuke MURAYAMA
 *
 */

#include "mex.h"
#include "matrix.h"

#include <math.h>
#include <memory.h>
#include <string.h>


enum { SINGLE, COMPLETE, AVERAGE, CENTROID, WARD };


#define M1

double find_min(double *a, int n, int *idx)
{
  int i;
  double v;

  v = a[0]; *idx = 0;
  for (i = 1; i < n; i++) {
	if (v > a[i]) {  v = a[i]; *idx = i; }
  }
  return v;
}


int remove_x(double *x, int *tmp_idx, int *rm_idx, int n_x, int n_rm)
{
  int i, j;

  for (i = 0; i < n_x; i++)  tmp_idx[i] = 1;
  for (i = 0; i < n_rm; i++) tmp_idx[rm_idx[i]] = 0;

  j = 0;
  for (i = 0; i < n_x; i++) {
	if (tmp_idx[i]) {
	  x[j] = x[i];  j++;
	}
  }
  return j;
}

void find_clusterIJ(int *ci, int *cj, int i0, int j0, int m)
{
  int h, c;
  int tmpi, tmpj, tmpm;

  tmpi = 0;
  tmpm = -m;
  for (h = 1; h < i0; h++) {
		// tmpi = h * (m - (h+1.)/2.) - m;
		// ci[h-1] = tmpi + i0 - 1;	  cj[h-1] = tmpi + j0 - 1;
		tmpi += h;  tmpm += m;
		ci[h-1] = tmpm - tmpi + i0 - 1;
		cj[h-1] = tmpm - tmpi + j0 - 1;
  }

  c = i0-1;
  tmpi = (i0-1)*m - (i0*(i0+1))/2;
  tmpj = (i0*(i0+1))/2;
  tmpm = (i0-1)*m;
  for (h = i0+1; h < j0; h++) {
		// ci[c] = i0 * (m - (i0+1.)/2.) - m + h  - 1;
		// cj[c] = h  * (m - (h +1.)/2.) - m + j0 - 1;
		tmpj += h;  tmpm += m;
		ci[c] = tmpi + h - 1;
		cj[c] = tmpm - tmpj + j0 - 1;
		c++;
  }
  // tmpi = i * (m - (i+1.)/2.) - m;
  // tmpj = j * (m - (j+1.)/2.) - m;
  tmpi = (i0-1)*m - (i0*(i0+1))/2;
  tmpj = (j0-1)*m - (j0*(j0+1))/2;
  for (h = j0+1; h <= m; h++) {
		ci[c] = tmpi + h - 1;
		cj[c] = tmpj + h - 1;
		c++;
  }

  // for (i1 = m-12; i1 <= m-2; i1++)
  //  printf("\n %3d: %4d %4d %4d", i1, tmpi, iidx[i1-1]+1, jidx[i1-1]+1);

  return;
}

void x_average(double *xavr, double *x, int *ri, int *np, int m)
{
  int i, j, k;
  double nri, n;

  k = 0;
  for (i = 0; i < m-1; i++) {
		nri = (double)np[ri[i] - 1];
		for (j = i+1; j < m; j++) {
			n = nri * (double)np[ri[j] - 1];
			//if (n == 0) xavr[k] = x[k];
			//else        xavr[k] = x[k] / n;
			xavr[k] = x[k] / n;
			k++;
			//printf("%4d %4d %4d %.4f %.4f\n", k, ri[i], ri[j], x[k], xavr[k]); 
		}
  }
  return;
}

/* updata functions  */
void update_xmin(double *x, int *ci, int *cj, int n_x)
{
  int i;
  for (i = 0; i < n_x; i++) {
		if (x[ci[i]] > x[cj[i]]) x[ci[i]] = x[cj[i]];
  }
  return;
}
void update_xmax(double *x, int *ci, int *cj, int n_x)
{
  int i;
  for (i = 0; i < n_x; i++) {
		if (x[ci[i]] < x[cj[i]]) x[ci[i]] = x[cj[i]];
  }
  return;
}
void update_xsum(double *x, int *ci, int *cj, int n_x)
{
  int i;
  for (i = 0; i < n_x; i++) {
		x[ci[i]] = x[ci[i]] + x[cj[i]];
  }
  return;
}
void update_xcent(double *x, int *ci, int *cj, int n_x, 
				  double minv, double nri, double nrj)
{
  int i;
  double k, k1, tmp;

  k = nri + nrj;
  k1 = nri * nrj * minv * minv / k / k;
  for (i = 0; i < n_x; i++) {
		tmp = (nri*x[ci[i]] + nrj*x[cj[i]]) / k;
		x[ci[i]] = tmp - k1;
  }
  return;
}
#ifdef M1
void update_xward(double *x, int *ci, int *cj, int n_x,
				  int *np, int *u, int *ri, int i0, int j0, double minv)
{
  int i;
  double nru, nri, nrj, nri_nrj, tmpd;

  nri = (double)np[ri[i0-1] - 1];
  nrj = (double)np[ri[j0-1] - 1];
  nri_nrj = nri + nrj;
  for (i = 0; i < n_x; i++) {
		nru = (double)np[ri[u[i]-1]-1];
		tmpd = (nru + nri)*x[ci[i]] + (nru + nrj)*x[cj[i]] - nru*minv;
		x[ci[i]] = tmpd / (nri_nrj + nru);
		//printf("\n %3d np=%3d u=%3d ri=%3d", i+1, (int)nru, u[i]-1, ri[u[i]-1]);
  }
  return;
}
#else
void update_xward(double *x, int *ci, int *cj, int n_x,
				  int *np, int *ri, int i0, int j0, double minv)
{
  int i, k, r;
  double nru, nri, nrj, nri_nrj, tmpd;

  nri = (double)np[ri[i0-1] - 1];
  nrj = (double)np[ri[j0-1] - 1];
  nri_nrj = nri + nrj;
  k = 0;
  for (i = 0; i < i0-1; i++) {
		r = ri[k] - 1;
		//nru = (double)np[ri[k]-1];
		nru = (double)np[r];
		tmpd = (nru + nri)*x[ci[i]] + (nru + nrj)*x[cj[i]] - nru*minv;
		x[ci[i]] = tmpd / (nri_nrj + nru);
		//printf("\n %3d np=%3d u=%3d ri=%3d", i+1, (int)nru, i, ri[i]);
		k++;
  }
  k = i0;
  for (i = i0-1; i < j0-2; i++) {
		r = ri[k] - 1;
		nru = (double)np[r];
		tmpd = (nru + nri)*x[ci[i]] + (nru + nrj)*x[cj[i]] - nru*minv;
		x[ci[i]] = tmpd / (nri_nrj + nru);
		//printf("\n %3d np=%3d u=%3d ri=%3d", i+1, (int)nru, i+1, ri[i+1]);
		k++;
  }
  k = j0;
  for (i = j0-2; i < n_x; i++) {
		r = ri[k] - 1;
		nru = (double)np[r];
		tmpd = (nru + nri)*x[ci[i]] + (nru + nrj)*x[cj[i]] - nru*minv;
		x[ci[i]] = tmpd / (nri_nrj + nru);
		//printf("\n %3d np=%3d u=%3d ri=%3d", i+1, (int)nru, i+2, ri[i+2]);
		k++;
  }

  return;
}
#endif


void l_single(double *z, double *x, int *ri, int n_dist, int n_data)
{
  int m, n_x, i, j;
  int s, si, k;
  int *ci, *cj, *tmp_idx, n_ij;
  double minv;

  ci = (int *)mxMalloc(n_data*sizeof(int));
  cj = (int *)mxMalloc(n_data*sizeof(int));
  tmp_idx = (int *)mxMalloc(n_dist*sizeof(int));

  m = n_data;
  n_x = n_dist;

  s = si = 0;
  for (s = 1, si = 0; s <= n_data-1; s++, si+=3) {

		minv = find_min(x, n_x, &k);
		/* match index i, j to Matlab so, k->k+1                   */
		/* so, note 1 <= i,j <= n_x and be care for using i, j     */
		/* ri also begins from 1                                   */ 
		i = (int)floor(m + 0.5 - sqrt(m*m - m + 0.25 - 2.*k));
		j = k + 1 - (i-1)*m + ((i-1)*i)/2 + i;
		z[si] = ri[i-1];  z[si+1] = ri[j-1], z[si+2] = minv;
		
		find_clusterIJ(ci, cj, i, j, m);
		n_ij = m - 2;
		
		/* update x  */
		update_xmin(x, ci, cj, n_ij);
		
		/* remove values of cluster J */
		cj[n_ij] = k;
		n_x = remove_x(x, tmp_idx, cj, n_x, n_ij+1);
		
		/* updata m, ri */
		m--;
		ri[i-1] = n_data + s;
		memmove(&ri[j-1], &ri[j], (n_data-j)*sizeof(int));
  }

  mxFree(ci);  mxFree(cj);
  mxFree(tmp_idx);
	
  return;
}

void l_complete(double *z, double *x, int *ri, int n_dist, int n_data)
{
  int m, n_x, i, j;
  int s, si, k;
  int *ci, *cj, *tmp_idx, n_ij;
  double minv;

  ci = (int *)mxMalloc(n_data*sizeof(int));
  cj = (int *)mxMalloc(n_data*sizeof(int));
  tmp_idx = (int *)mxMalloc(n_dist*sizeof(int));

  m = n_data;
  n_x = n_dist;

  s = si = 0;
  for (s = 1, si = 0; s <= n_data-1; s++, si+=3) {

		minv = find_min(x, n_x, &k);
		/* match index i, j to Matlab so, k->k+1                   */
		/* so, note 1 <= i,j <= n_x and be care for using i, j     */
		/* ri also begins from 1                                   */ 
		i = (int)floor(m + 0.5 - sqrt(m*m - m + 0.25 - 2.*k));
		j = k + 1 - (i-1)*m + ((i-1)*i)/2 + i;
		z[si] = ri[i-1];  z[si+1] = ri[j-1], z[si+2] = minv;
		
		find_clusterIJ(ci, cj, i, j, m);
		n_ij = m - 2;
		
		/* update x  */
		update_xmax(x, ci, cj, n_ij);
		
		/* remove values of cluster J */
		cj[n_ij] = k;
		n_x = remove_x(x, tmp_idx, cj, n_x, n_ij+1);
		
		/* updata n, ri, rj */
		m--;
		ri[i-1] = n_data + s;
		memmove(&ri[j-1], &ri[j], (n_data-j)*sizeof(int));
  }

  mxFree(ci);  mxFree(cj);
  mxFree(tmp_idx);

  return;
}

void l_average(double *z, double *x, int *ri, int n_dist, int n_data)
{
  int m, n_x, i, j;
  int s, si, k;
  int *ci, *cj, *tmp_idx, n_ij;
  double minv, *xavr;
  int *np;

  ci = (int *)mxMalloc(n_data*sizeof(int));
  cj = (int *)mxMalloc(n_data*sizeof(int));
  tmp_idx = (int *)mxMalloc(n_dist*sizeof(int));
  
  /* np denotes how many points are contained in each cluster */
  np = (int *)mxCalloc(2*n_data-1, sizeof(int));
  for (s = 0; s < n_data; s++)  np[s] = 1;
  //  for (s = n_data; s < 2*n_data-1; s++) np[s] = 0;

  xavr = (double *)mxMalloc(n_dist*sizeof(double));
	
  m = n_data;
  n_x = n_dist;

  s = si = 0;
  for (s = 1, si = 0; s <= n_data-1; s++, si+=3) {

		x_average(xavr, x, ri, np, m);

		minv = find_min(xavr, n_x, &k);
		/* match index i, j to Matlab so, k->k+1                   */
		/* so, note 1 <= i,j <= n_x and be care for using i, j     */
		/* ri also begins from 1                                   */ 
		i = (int)floor(m + 0.5 - sqrt(m*m - m + 0.25 - 2.*k));
		j = k + 1 - (i-1)*m + ((i-1)*i)/2 + i;
		z[si] = ri[i-1];  z[si+1] = ri[j-1], z[si+2] = minv;

		find_clusterIJ(ci, cj, i, j, m);
		n_ij = m - 2;
		
		/* update x  */
		update_xsum(x, ci, cj, n_ij);
		
		/* remove values of cluster J */
		cj[n_ij] = k;
		n_x = remove_x(x, tmp_idx, cj, n_x, n_ij+1);

		/* updata n, np, ri, rj */
		m--;
		np[n_data+s-1] = np[ri[i-1]-1] + np[ri[j-1]-1];
		ri[i-1] = n_data + s;
		memmove(&ri[j-1], &ri[j], (n_data-j)*sizeof(int));
  }

  mxFree(ci);  mxFree(cj);
  mxFree(tmp_idx);
  mxFree(np);
  mxFree(xavr);

  return;
}

void l_centroid(double *z, double *x, int *ri, int n_dist, int n_data)
{
  int m, n_x, i, j;
  int s, si, k;
  int *ci, *cj, *tmp_idx, n_ij;
  double minv;
  int *np;

  ci = (int *)mxMalloc(n_data*sizeof(int));
  cj = (int *)mxMalloc(n_data*sizeof(int));
  tmp_idx = (int *)mxMalloc(n_dist*sizeof(int));
  
  /* np denotes how many points are contained in each cluster */
  np = (int *)mxCalloc(2*n_data-1, sizeof(int));
  for (s = 0; s < n_data; s++)          np[s] = 1;
  //for (s = n_data; s < 2*n_data-1; s++) np[s] = 0;

  /* square the X so that it is easier to update */
  for (s = 0; s < n_dist; s++)  x[s] = x[s]*x[s];

  m = n_data;
  n_x = n_dist;

  s = si = 0;
  for (s = 1, si = 0; s <= n_data-1; s++, si+=3) {

		minv = find_min(x, n_x, &k);
		minv = sqrt(minv);

		/* match index i, j to Matlab so, k->k+1                   */
		/* so, note 1 <= i,j <= n_x and be care for using i, j     */
		/* ri also begins from 1                                   */ 
		i = (int)floor(m + 0.5 - sqrt(m*m - m + 0.25 - 2.*k));
		j = k + 1 - (i-1)*m + ((i-1)*i)/2 + i;
		z[si] = ri[i-1];  z[si+1] = ri[j-1], z[si+2] = minv;
		
		find_clusterIJ(ci, cj, i, j, m);
		n_ij = m - 2;

		/* update x  */
		update_xcent(x, ci, cj, n_ij, minv, np[ri[i-1]-1], np[ri[j-1]-1]);

		/* remove values of cluster J */
		cj[n_ij] = k;
		n_x = remove_x(x, tmp_idx, cj, n_x, n_ij+1);

		/* updata m, np, ri, rj */
		m--;
		np[n_data+s-1] = np[ri[i-1]-1] + np[ri[j-1]-1];
		ri[i-1] = n_data + s;
		memmove(&ri[j-1], &ri[j], (n_data-j)*sizeof(int));
  }

  mxFree(ci);  mxFree(cj);
  mxFree(tmp_idx);
  mxFree(np);

  return;
}

void l_ward(double *z, double *x, int *ri, int n_dist, int n_data)
{
  int m, n_x, i, j;
  int s, si, k;
  int *ci, *cj, *tmp_idx, n_ij;
  double minv;
  int *np, u;

  ci = (int *)mxMalloc(n_data*sizeof(int));
  cj = (int *)mxMalloc(n_data*sizeof(int));
  tmp_idx = (int *)mxMalloc(n_dist*sizeof(int));
  
  /* np denotes how many points are contained in each cluster */
  np = (int *)mxCalloc(2*n_data-1, sizeof(int));
  for (s = 0; s < n_data; s++)        np[s] = 1;
  //for (s = n_data; s < 2*n_data-1; s++) np[s] = 0;

  /* square the X so that it is easier to update */
  for (s = 0; s < n_dist; s++)  x[s] = x[s]*x[s]/2.;

  m = n_data;
  n_x = n_dist;

  s = si = 0;
  for (s = 1, si = 0; s <= n_data-1; s++, si+=3) {

		minv = find_min(x, n_x, &k);

		/* match index i, j to Matlab so, k->k+1                   */
		/* so, note 1 <= i,j <= n_x and be care for using i, j     */
		/* ri also begins from 1                                   */ 
		i = (int)floor(m + 0.5 - sqrt(m*m - m + 0.25 - 2.*k));
		j = k + 1 - (i-1)*m + ((i-1)*i)/2 + i;
		z[si] = ri[i-1];  z[si+1] = ri[j-1], z[si+2] = sqrt(minv);

		//printf(" s=%3d i=%4d j=%4d k=%4d v=%.4f \n", s, i, j, k, minv); 

		find_clusterIJ(ci, cj, i, j, m);
		n_ij = m - 2;

	/* update x  */
#ifdef M1
		for (u = 1;   u < i;    u++)  tmp_idx[u-1] = u;
		for (u = i+1; u < j;    u++)  tmp_idx[u-2] = u;
		for (u = j+1; u <= m;   u++)  tmp_idx[u-3] = u;
		update_xward(x, ci, cj, n_ij, np, tmp_idx, ri, i, j, minv);  
#else
		update_xward(x, ci, cj, n_ij, np, ri, i, j, minv);
#endif
		//printf("\n");
		//for (u=0; u < n_x; u++ ) printf(" %4d x=%.4f\n",u+1, x[u]);

		//	break;
		/* remove values of cluster J */
		cj[n_ij] = k;
		n_x = remove_x(x, tmp_idx, cj, n_x, n_ij+1);
		
		/* updata m, np, ri, rj */
		m--;
		np[n_data+s-1] = np[ri[i-1]-1] + np[ri[j-1]-1];
		ri[i-1] = n_data + s;
		memmove(&ri[j-1], &ri[j], (n_data-j)*sizeof(int));
  }

  mxFree(ci);  mxFree(cj);
  mxFree(tmp_idx);
  mxFree(np);

  return;
}


void linkage2(double *z, double *y, int n_dist, int n_data, int method)
{
  int  *ri, i;
  double *x;

  ri = (int *)mxMalloc(n_data*sizeof(int));
  x = (double *)mxMalloc(n_dist*sizeof(double));
  memcpy(x, y, n_dist*sizeof(double));

  /* Note 1 <= ri <= n_data */
  for (i = 0; i < n_data; i++) ri[i] = i+1;


  switch (method) {
  case SINGLE:
		l_single(z, x, ri, n_dist, n_data);
		break;
  case COMPLETE:
		l_complete(z, x, ri, n_dist, n_data);
		break;
  case AVERAGE:
		l_average(z, x, ri, n_dist, n_data);
	break;
  case CENTROID:
		l_centroid(z, x, ri, n_dist, n_data);
		break;
  case WARD:
		l_ward(z, x, ri, n_dist, n_data);
		break;
  }

  mxFree(ri);  mxFree(x);
  return;
}



/* MEX function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  mxArray *mx_tmp[1];
  double *z, *y;
  char ch_method[32];
  int  n_dist, n_vars, n_datai;
  double n_datad;
  int status, method;

  /* initialization */
  y = NULL;
  n_dist = n_vars = n_datai = 0;
  n_datad = 0;
  sprintf(ch_method, "");  method = SINGLE;


  /* Check for proper number of arguments. */
  if (nrhs == 0 || nlhs > 1) {
		mexErrMsgTxt(" USAGE: z = linkage2(y, 'method')");
  }
  if (!mxIsNumeric(prhs[0])) {
		mexErrMsgTxt(" Input y must be numeric.");
  }

  /* Get dimension of an input matrix */
  n_vars = (int) mxGetM(prhs[0]);
  n_dist = (int) mxGetN(prhs[0]);
  if (n_dist < 3) {
		mexErrMsgTxt(" You have to have at least 3 distances to do a linkage.");
  }
  
  n_datad = (1 + sqrt(1. + 8.* n_dist)) / 2.;
  n_datai = (int)n_datad;
  n_datad = fabs(n_datad - (double)n_datai);
  if ((n_vars != 1) || (n_datad >= 1.0e-10)) {
		mexErrMsgTxt(" Tthe 1st input has to match the output of pdist() in size.");
  }

  /* Get a method to compute distance, if possible. */
  if (nrhs >= 2) {
		status = mxGetString(prhs[1], ch_method, 2+1); 
		if (!stricmp(ch_method, "SI"))      method = SINGLE;
		else if (!stricmp(ch_method, "CO")) method = COMPLETE;
		else if (!stricmp(ch_method, "AV")) method = AVERAGE;
		else if (!stricmp(ch_method, "CE")) method = CENTROID;
		else if (!stricmp(ch_method, "WA")) method = WARD;
		else mexErrMsgTxt(" Unknown metric method.");
  }

  /* Call linkage2(). */
  y = mxGetPr(prhs[0]);
  mx_tmp[0] = mxCreateDoubleMatrix(3, n_datai-1, mxREAL);
  z = mxGetPr(mx_tmp[0]);
  linkage2(z, y, n_dist, n_datai, method);
	
  /* Get a matrix for the return argument. */
  mexCallMATLAB(1, plhs, 1, mx_tmp, "transpose");
  mxDestroyArray(mx_tmp[0]);

  return;

}
