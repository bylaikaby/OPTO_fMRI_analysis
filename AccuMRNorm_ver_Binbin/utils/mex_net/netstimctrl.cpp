/*
 * netstimctrl.cpp
 * 
 * NOTES : This mex handles communication to the stim program.
 *
 * SEEALSO : essnetapi.c, rmt_send.m, mexnet.m
 *
 * To compile this mex,
 *   >>mex netstimctrl.cpp essnetapi.c
 *
 * ver. 1.00  11-May-2003  Yusuke MURAYAMA, MPI
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
#define INP_COMMAND_STR  prhs[0]
#define INP_SEND_SERVER  prhs[1]
#define INP_SEND_ARG1    prhs[2]
#define INP_SEND_ARG2    prhs[3]
#define OUT_SEND_RESULT  plhs[0]
#define INP_NONBLOCKING  prhs[1]
#define OUT_NONBLOCKING  plhs[0]
#define INP_TIMEOUT      prhs[1]
#define OUT_TIMEOUT      plhs[0]

// globals //////////////////////////////////////////////
int gTimeOut     = -1;

// prototypes ///////////////////////////////////////////
void cmd_send(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_timeout(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);


// functions ////////////////////////////////////////////
void cmd_send(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char *server = NULL, *cmdstr = NULL, *result = NULL;
  int buflen;

  if (nrhs < 2)  mexErrMsgTxt(" no stim host specified.");
  // get stim hostname
  if (!mxIsChar(INP_SEND_SERVER)) 	mexErrMsgTxt(" failed to get server name.");
  buflen = mxGetM(INP_SEND_SERVER)*mxGetN(INP_SEND_SERVER) + 1;
  server = (char *)mxCalloc(buflen,sizeof(char));
  mxGetString(INP_SEND_SERVER,server,buflen);
  // get port/cmdstr
  if (mxIsNumeric(INP_SEND_ARG1)) {
    enet_stim_port = (int)mxGetScalar(INP_SEND_ARG1);
    buflen = mxGetM(INP_SEND_ARG2)*mxGetN(INP_SEND_ARG2) + 1;
    cmdstr = (char *)mxCalloc(buflen,sizeof(char));
    mxGetString(INP_SEND_ARG2,cmdstr,buflen);
  } else {
    buflen = mxGetM(INP_SEND_ARG1)*mxGetN(INP_SEND_ARG1) + 1;
    cmdstr = (char *)mxCalloc(buflen,sizeof(char));
    mxGetString(INP_SEND_ARG1,cmdstr,buflen);
  }

  // send a command and receive the result.
  result = enet_rmt_sendex(server,gTimeOut,cmdstr);
  if (result == NULL) {
    OUT_SEND_RESULT = mxCreateString("");
  } else {
    OUT_SEND_RESULT = mxCreateString(result);
  }

  return;
}

void cmd_timeout(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int oldv = gTimeOut;

  if (mxIsNumeric(INP_TIMEOUT) != 1)  mexErrMsgTxt(" faild to get numeric.");
  gTimeOut = (int)mxGetScalar(INP_TIMEOUT);
  OUT_TIMEOUT = mxCreateDoubleScalar((double)oldv);

  return;
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char *cmdstr = NULL;
  int buflen;

  // check for proper number of arguments.
  if (nrhs < 1) {
    mexEvalString("help netstimctrl;");  return;
  }

  // get a command string
  if (!mxIsChar(INP_COMMAND_STR)) 	mexErrMsgTxt(" failed to get command");
  buflen = mxGetM(INP_COMMAND_STR)*mxGetN(INP_COMMAND_STR) + 1;
  cmdstr = (char *)mxCalloc(buflen,sizeof(char));
  mxGetString(INP_COMMAND_STR,cmdstr,buflen);

  if (stricmp(cmdstr,"send") == 0) {
    cmd_send(nlhs, plhs, nrhs, prhs);
  } else if (stricmp(cmdstr,"timeout") == 0) {
    cmd_timeout(nlhs, plhs, nrhs, prhs);
  } else {
    mexErrMsgTxt(" not supported command.");
    //mexPrintf("%s ERROR: not supported command '%s'.\n",
    //          mexFunctionName(),cmdstr);
  }

  mxFree(cmdstr);

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
