/* compile with: "mex write_console.c user32.lib ws2_32.lib" */
#include <stdio.h>
#include<windows.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <mex.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int *sock_array;
  double d;
  int *j;
  int i,iknk;
  int blocking=0;
  double *knk;

  char *inbuf;
  char *outbuf;
  FILE *hf0,*hf1,*hf2;
  char *buffer=NULL;
  int buflen;

  
  if (nrhs != 2) {
    mexErrMsgTxt("usage: output = write_console (handle [returned from open_console or open_conn], string)");
  }

  //printf("%d:%d\n",buflen,*i); return;
  d=mxGetScalar(prhs[0]);
  j=&d;
  //printf("%d\n",(int *)*j); return;
  sock_array=*j;
  if(!*j || !sock_array[1] || sock_array[12]) {mexErrMsgTxt("Console not initialized!");return;}
  hf0=(FILE *)sock_array[0];hf1=(FILE *)sock_array[1];
  inbuf=(char *)sock_array[2];outbuf=(char *)sock_array[3];
  // printf("%d::%d:%d:%d:%d\n",sock_array,hf0,hf1,inbuf,outbuf);return;

  buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
  if ((buffer=realloc(buffer,buflen))) {
    mxGetString(prhs[1], buffer, buflen);
    buffer[buflen]=0;
    buflen=fprintf(hf1,"%s",buffer);
  } else {
    buflen=-1;
  }

  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL); knk= (mxGetPr(plhs[0]));  *knk= 1. * buflen;

}
