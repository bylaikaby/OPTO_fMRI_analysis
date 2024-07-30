/*
 * test.c :
 *
 * PURPOSE : timer function for Matlab, using windows multimedia timer
 * To compile this, 
 *    mex mmtimer.c winmm.lib libcmt.lib -DWIN32
 *
 * VERSION : 1.00  25-Jul-02  Yusuke MURAYAMA, MPI
 */

#include <windows.h>
#include <process.h>         // _beginthread, _endthread
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <stddef.h>
#include <mmsystem.h>


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
  //endthread();
}

DWORD WINAPI threadFunc2(LPVOID lpParameter)
{
  DWORD t0, t;

  t0 = timeGetTime();
  t = t0;
  while (t-t0 < 1000) {
    t = timeGetTime();
  }

  mexEvalString(gMatlabCmd);
  return 0;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{

  sprintf(gMatlabCmd,"fprintf(\"hello \");");
  //_beginthread(threadFunc, 0, (void *)gMatlabCmd);

  HANDLE hThrd; 
  DWORD IDThread; 

  hThrd = CreateThread(NULL,  // no security attributes 
                       0,                // use default stack size 
                       (LPTHREAD_START_ROUTINE) threadFunc2, 
                       (LPVOID)gMatlabCmd, // param to thread func 
                       CREATE_SUSPENDED, // creation flag 
                       &IDThread);       // thread identifier 
  if ((ResumeThread(hThrd)) == -1) 
    mexErrMsgTxt("ResumeThread failed!"); 

  return;
}


