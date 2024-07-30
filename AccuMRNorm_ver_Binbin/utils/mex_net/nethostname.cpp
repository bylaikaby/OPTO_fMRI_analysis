/*
 * nethostname.cpp
 * 
 * NOTES : This mex gets hostname from IP address.
 *
 * SEEALSO : essnetapi.c, rmt_send.m, mexnet.m
 *
 * To compile this mex,
 *   >>mex nethostname.cpp essnetapi.c
 *
 * ver. 1.00  29-Feb-2004  Yusuke MURAYAMA, MPI
 */

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <string.h>

#if defined (_WIN32) || defined (_WIN64)
#  define  WIN32_LEAN_AND_MEAN
#  define  WIN64_LEAN_AND_MEAN
#  include <windows.h>
#else
#  include <stdio.h>
#endif

#include "mex.h"
#include "matrix.h"

//#define NETAPI_IMPORT
#include "essnetapi.h"

// input/putput /////////////////////////////////////////
#define INP_IPADDRESS  prhs[0]
#define OUT_HOSTNAME   plhs[0]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char hname[128], ipaddr[128];
  int buflen, status;

  // check for proper number of input arguments.
  if (nrhs > 1) {
    mexEvalString("help nethostname;");  return;
  }

  // get a command string
  if (nrhs > 0) {
    if (!mxIsChar(INP_IPADDRESS)) 	mexErrMsgTxt(" failed to get IP address");
    buflen = mxGetM(INP_IPADDRESS)*mxGetN(INP_IPADDRESS) + 1;
    mxGetString(INP_IPADDRESS,ipaddr,buflen);
    status = enet_hostname(hname,ipaddr);
  } else {
    status = enet_hostname(hname,NULL);
  }

  if (status == SOCKET_ERROR)
    mexErrMsgTxt("nethostname: failed to get hostname.\n");

  OUT_HOSTNAME = mxCreateString(hname);

  return;
}


#if defined (_WINDOWS_)
BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved )
{
  switch (ul_reason_for_call) {
  case DLL_PROCESS_ATTACH:
    enet_startup();
    //printf("process_attach\n");
    break;
  case DLL_THREAD_ATTACH:
    //printf("thread_attach\n");
    break;
  case DLL_THREAD_DETACH:
    //printf("thread_detach\n");
    break;
  case DLL_PROCESS_DETACH:
    //printf("process_detach\n");
    enet_cleanup();
    break;
  }
  return TRUE;
}
#endif
