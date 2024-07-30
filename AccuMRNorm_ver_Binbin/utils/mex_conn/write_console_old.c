#include <stdio.h>
#include<windows.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <mex.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double d;
  int *i;
  int buflen;
  
  if (nrhs != 2) {
    mexErrMsgTxt("usage: output = write_console (f_out,string) [f_out as returned from open_console]");
  }
  d=mxGetScalar(prhs[0]);
  i=&d;
  buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
  mxGetString(prhs[1], (char *)*i, buflen);
  //printf("%d:%s\n",buflen,(char*)*i); return;

}
