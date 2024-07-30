/*
 * mmtimer.c :
 *
 * PURPOSE : timer function for Matlab, using windows multimedia timer
 * To compile this, 
 *    mex mmtimer.c winmm.lib libcmt.lib -DWIN32
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

//#define USE_THREAD
#define TIMER_RESOLUTION (1)    // timer resolution
#define MAX_TIMERS (16)         // max number of timers

#define MMTCMD_INVALID   0
#define MMTCMD_SETTIMER  1
#define MMTCMD_KILLTIMER 2
#define MMTCMD_KILLALL   3

#define INP_TIMERIDX prhs[0]
#define INP_CMD      prhs[1]
#define INP_DELAY    prhs[2]
#define INP_TYPE     prhs[3]
#define INP_CALLBACK prhs[4]

static UINT gTimerID[MAX_TIMERS];      // timer id
static char gTimerCB[MAX_TIMERS][128]; // matlab script as timer callback
static HANDLE hStdIn, hStdOut, hStdErr, hModule;

static void mmtimerOnExit(void)
{
  int i;
  for (i=0; i < MAX_TIMERS; i++) {
    if (gTimerID[i] != 0)   timeKillEvent(gTimerID[i]);
  }
  timeEndPeriod(1);
}

void invokeMatlabScript(void *arg)
{
#ifdef USE_THREAD
  static char tmpcmd[128];
  sprintf(tmpcmd,"%s",(char *)arg);
  mexEvalString(tmpcmd);
  _endthread();
#endif
}

void CALLBACK mmtimerProc(UINT uID, UINT uMsg, DWORD dwUser, DWORD dw1, DWORD dw2)
{
#ifdef USE_THREAD
  _beginthread(invokeMatlabScript, 0, (void *)gTimerCB[dwUser]);
#else
  DWORD tmp;

  //SetStdHandle(hStdIn, STD_INPUT_HANDLE);
  //SetStdHandle(hStdOut, STD_OUTPUT_HANDLE);
  //SetStdHandle(hStdErr, STD_ERROR_HANDLE);
  //WriteConsole(hStdOut,". ",2,&tmp,NULL);
  //static char tmpcmd[128];
  //sprintf(tmpcmd,"%s",gTimerCB[1]);
  //printf("hey ");  // cause matlab crash
  //mexPrintf("hey ");
  //mexCallMATLAB(0,NULL,0,NULL,(const char *)tmpcmd);
  //mexCallMATLAB(0,NULL,0,NULL,"sayhello"); // cause matlab crash
  mexEvalString("sayhello;");           // cause matlab crash
#endif
#ifdef _DEBUG
	//Beep(1940,80);
	//Beep(970,80);
#endif
}

DWORD WINAPI ThreadFunc(LPVOID lpParameter)
{
  DWORD t0,t;
  t0 = t = timeGetTime();
  while (t-t0 < 2500) {
    Beep(1940,80);
    Beep(970,80);
    Sleep(500);
    //mexCallMATLAB(0,NULL,0,NULL,"sayhello"); // cause matlab crash
    //mexEvalString("sayhello");           // cause matlab crash
    printf("hey ");
    t = timeGetTime();
  }
  return 0;
}


int getCommandID(char *cmdstr)
{
  if (_stricmp(cmdstr,"settimer") == 0)  return MMTCMD_SETTIMER;
  else if (_stricmp(cmdstr,"killtimer") == 0)  return MMTCMD_KILLTIMER;
  else if (_stricmp(cmdstr,"killall") == 0)  return MMTCMD_KILLALL;
  else  return MMTCMD_INVALID;
}

UINT mmtimerSetTimer(int mytimer, int delay, int type, char *matlabCB)
{
  UINT timerID;
  sprintf(gTimerCB[mytimer],"%s",matlabCB);
  mexPrintf("%s ",gTimerCB[mytimer]);
  timerID = (UINT)timeSetEvent(delay,TIMER_RESOLUTION,mmtimerProc,(DWORD)mytimer,type);
  if (timerID != 0) {
    gTimerID[mytimer] = timerID;
  }
  mexPrintf("\n timer: %d ",timerID);
  return timerID;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  static int firstEnter = 0;
  int i, timerIdx, buflen, delay, type;
  char *cmdstr, *typestr, *cbstr;

  // test
  DWORD IDThread;
  HANDLE hThread;

  if (firstEnter == 0) {
    mexAtExit(mmtimerOnExit);
    timeBeginPeriod(1);
    hStdIn = GetStdHandle(STD_INPUT_HANDLE);
    hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    hStdErr = GetStdHandle(STD_ERROR_HANDLE);
    hModule = GetModuleHandle(NULL);
    firstEnter = 1;
    mexPrintf("%s: module=%d stdin=%d stdout=%d stderr=%d\n",mexFunctionName(), 
              hModule,hStdIn, hStdOut, hStdErr);
  }

  /* Check for proper number of arguments */
  if (nrhs < 2) {
    mexPrintf("Usage: %s(timerid,'cmd',...)\n",mexFunctionName());
    mexPrintf("Notes: timerid: 0-15, cmd: SetTimer, KillTimer    ver.1.01 Jul-2002\n");
    return;
  }

  // get timer index
  timerIdx = (int)mxGetScalar(INP_TIMERIDX);
  if (timerIdx < 0 || timerIdx >= MAX_TIMERS) {
    mexErrMsgTxt("timerid must be 0 to 15.");
  }

  // get a command string
  if (mxIsChar(INP_CMD) != 1)   mexErrMsgTxt("command must be a string.");
  buflen = (mxGetM(INP_CMD) * mxGetN(INP_CMD)) + 1;
  cmdstr = mxCalloc(buflen, sizeof(char));
  mxGetString(INP_CMD, cmdstr, buflen);

  switch (getCommandID(cmdstr)) {
  case MMTCMD_SETTIMER:
    if (nrhs < 5)  mexErrMsgTxt("mmtimer(timeridx,'cmd',delay,'type','callback')");
    // delay
    delay = (int)mxGetScalar(INP_DELAY);
    if (delay <= 0) mexErrMsgTxt("delay must be > 0 (in msec).");
    // type
    if (mxIsChar(INP_TYPE) != 1) {
      mexErrMsgTxt("type must be a string {periodic|oneshot}.");
    }
    buflen = (mxGetM(INP_TYPE) * mxGetN(INP_TYPE)) + 1;
    typestr = mxCalloc(buflen, sizeof(char));
    mxGetString(INP_TYPE, typestr, buflen);
    if (_stricmp(typestr,"periodic")==0)  type = TIME_PERIODIC;
    else                                 type = TIME_ONESHOT;
    // callback
    if (mxIsChar(INP_CALLBACK) != 1) {
      mexErrMsgTxt("callback must be a string.");
    }
    buflen = (mxGetM(INP_CALLBACK) * mxGetN(INP_CALLBACK)) + 1;
    cbstr = mxCalloc(buflen, sizeof(char));
    mxGetString(INP_CALLBACK, cbstr, buflen);
    if (mmtimerSetTimer(timerIdx,delay,type,cbstr) == 0) {
      mexErrMsgTxt("faild to start timer.");
    }

    // test
    //hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)ThreadFunc,
    //                      NULL, 0, &IDThread);

    break;
  case MMTCMD_KILLTIMER:
    if (gTimerID[timerIdx] == 0)  break;
    timeKillEvent(gTimerID[timerIdx]);
    break;
  case MMTCMD_KILLALL:
    for (i=0; i < MAX_TIMERS; i++) {
      if (gTimerID[i] != 0)   timeKillEvent(gTimerID[i]);
    }
    break;
  default:
    mexErrMsgTxt("not supported command.");
  }

  return;
}


BOOL WINAPI DllEntryPoint(HINSTANCE hinstDll, DWORD fdwReason,
                          LPVOID lpvReserved)
{
  switch (fdwReason) {
  case DLL_PROCESS_ATTACH: {
    for (int i=0; i < MAX_TIMERS; i++)  gTimerID[i] = 0;
    break;
  }  
  case DLL_PROCESS_DETACH:  {
  }  break;
  }
  return 1;
}
