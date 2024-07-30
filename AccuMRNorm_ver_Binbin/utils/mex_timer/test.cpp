/*
 * test.c :
 *
 * PURPOSE : timer function for Matlab, using windows multimedia timer
 * To compile this, 
 *    mex mmtimer.c winmm.lib -DWIN32
 *
 * VERSION : 1.00  25-Jul-02  Yusuke MURAYAMA, MPI
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined (WIN32)
#  define  WIN32_LEAN_AND_MEAN // Make widows header simple
#  define  STRICT			         // Enabling STRICT Type Checking
#  include <windows.h>
#  include <process.h>         // _beginthread, _endthread
#  include <stddef.h>
#  include <mmsystem.h>
#endif

#include "matrix.h"
#include "mex.h"


static char gMatlabCmd[128];

void threadFunc(void *param)
{
  DWORD t0, t;

  t0 = timeGetTime();
  t = t0;
  while (t-t0 < 1000) {
    t = timeGetTime();
  }

  mexEvalString(gMatlabCmd);
  _endthread();
}

DWORD WINAPI threadFunc2(LPVOID lpParameter)
{
  return 0;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{

  _beginthread()
  

  return;
}


