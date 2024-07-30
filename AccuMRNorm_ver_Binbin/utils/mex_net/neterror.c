/*
 * neterror.c
 * 
 *
 *
 * ver. 1.00  05-Aug-2002  Yusuke MURAYAMA, MPI
 *
 */

#if defined (_WIN32) || defined (_WIN64)
#else
#endif

#include "mex.h"
#include "matrix.h"

#include "essnetapi.h"

#define OUT_RESULT   plhs[0]

/* MEX function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int status;

  /* Check for proper number of arguments. */
  if (nrhs != 0) {
		mexEvalString("help neterror;");  return;
  }

  OUT_RESULT = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(OUT_RESULT) = (double)enet_get_error();

  return;
}
