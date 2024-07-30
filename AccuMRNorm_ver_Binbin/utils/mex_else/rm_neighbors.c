/*
 * rm_neighbors.c
 *
 * USAGE :
 *   [locs indx] = rm_neighbors(locs,min_distance)  removes neighboring values 
 *   within "min_distance" from "locs".  Combining with findpeaks(), this provides 
 *   much faster processing (see EXAMPLE).  "indx" has a array of indices selected.
 * 
 * COMPILE :
 *   mex rm_neighbors.c
 *   mex -largeArrayDims rm_neighbors.c
 *
 * EXAMPLE :
 *   x = rand(1,100000);
 *   tic
 *   [vals locs] = findpeaks(x,'sortstr','descend');
 *   [locs indx] = rm_neighbors(locs,3.0);
 *   vals = vals(indx);
 *   toc
 *   tic
 *   [vals2 locs2] = findpeaks(x,'sortstr','descend','minpeakdistance',3.0);
 *   toc
 *   isequal(locs, locs2)    % R2007b may have a bug(s) of findpeaks(), while R2011b ok.
 *
 * VERSION :
 *   1.00 13-02-2013 YM  pre-release
 *   1.01 14-02-2013 YM  improved memory usage.
 *
 * See also findpeaks test_rm_neighbors
 *
 */

#include "mex.h"
#include "matrix.h"

#include <math.h>
#include <memory.h>
#include <string.h>

// Input Arguments
#define	IN_LOCS   prhs[0]
#define IN_DIST   prhs[1]
// Output Arguments
#define OUT_LOCS  plhs[0]
#define OUT_INDX  plhs[1]



// proto-types
mwSize remove_neighbors_d(double *locs, char *sels, mwSize len, double dist);


mwSize remove_neighbors_d(double *locs, char *sels, mwSize len, double dist)
{
  mwSize i, k, n;
  double tmps, tmpe;

  for (i = 0; i < len; i++)  sels[i] = 1;

  if (dist == 0)  return len;

  n = 0;
  for (i = 0; i < len; i++) {
	if (sels[i] == 0)  continue;
	tmps = locs[i] - dist;
	tmpe = locs[i] + dist;
	for (k = i+1; k < len; k++) {
	  if (locs[k] >= tmps && locs[k] <= tmpe)  sels[k] = 0;
	}
	n++;
  }

  return n;
}



// MEX function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // initialization
  mwSize nelements, M, N, nnew, i, k;
  double dist;
  double *locs, *newlocs, *newindx;
  char   *sels;

  // Check for proper number of arguments.
  if (nrhs != 2 || nlhs > 2) {
	mexErrMsgTxt(" USAGE: [locs indx] = rm_neighbors(locs, min_distance)");
  }
  if (!mxIsNumeric(IN_LOCS)) {
	mexErrMsgTxt(" Input 'locs' must be a numeric vector (double).");
  }
  if (!mxIsNumeric(IN_DIST)) {
	mexErrMsgTxt(" Input 'min_distance' must be a numeric scalar.");
  }

  // Get dimension of an input vector
  nelements = mxGetNumberOfElements(IN_LOCS);
  M    = mxGetM(IN_LOCS);
  N    = mxGetN(IN_LOCS);
  if (M > 1 && N > 1) {
	mexErrMsgTxt(" Input 'locs' must be a numeric vector.");
  }

  if (!mxIsDouble(IN_LOCS)) {
	mexErrMsgTxt(" Input 'locs' must be 'double'.");
  }

  locs = mxGetPr(IN_LOCS);
  dist = mxGetScalar(IN_DIST);

  sels = (char *)mxCalloc(nelements,sizeof(char));
  if (sels == NULL) {
	mexErrMsgTxt(" Failed to allocate memory.");
  }

  nnew = remove_neighbors_d(locs,sels,nelements,dist);

  if (N == 1)  OUT_LOCS = mxCreateDoubleMatrix(nnew,1,mxREAL);
  else         OUT_LOCS = mxCreateDoubleMatrix(1,nnew,mxREAL);
  newlocs = mxGetPr(OUT_LOCS);

  k = 0;
  if (nlhs > 1) {
	if (N == 1)  OUT_INDX = mxCreateDoubleMatrix(nnew,1,mxREAL);
	else         OUT_INDX = mxCreateDoubleMatrix(1,nnew,mxREAL);
	newindx = mxGetPr(OUT_INDX);

	k = 0;
	for (i = 0; i < nelements; i++) {
	  if (sels[i] == 0)  continue;
	  newlocs[k] = locs[i];
	  newindx[k] = (double)(i+1);
	  k++;
	}
  } else {
	k = 0;
	for (i = 0; i < nelements; i++) {
	  if (sels[i] == 0)  continue;
	  newlocs[k] = locs[i];
	  k++;
	}
  }

  mxFree(sels);

  return;

}
