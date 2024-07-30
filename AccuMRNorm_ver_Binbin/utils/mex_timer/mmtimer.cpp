/*
 * mmtimer.cpp
 *
 * PURPOSE : timer function for Matlab, using windows (multimedia) timer
 * NOTES:    call of Matlab script from the thread obviously crashes Matlab R12.
 *           multimedia timer is sometimes unstable under Matlab R12,
 *           so use normal timer although the name is mmtimer...
 *
 * To compile this, 
 *    >>mex mmtimer.c -D_MT -D_USE_THREAD  (to use thread)
 *    >>mex mmtimer.c -D_USE_WIN_MMTIMER   (use windows multimedia timer)
 *    >>mex mmtimer.c                      (use windows normal timer)
 *
 * VERSION : 1.00  25-Jul-02  Yusuke MURAYAMA, MPI
 *           1.01  07-Aug-02  YM
 *           1.02  09-Aug-02  YM
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined (_WIN32)
#  define  WIN32_LEAN_AND_MEAN // Make widows header simple
#  define  STRICT			         // Enabling STRICT Type Checking
#  include <windows.h>
#  include <process.h>         // _beginthread, _endthread
#  include <stddef.h>
#endif

#include "matrix.h"
#include "mex.h"

//#define _USE_THREAD            // crashes Matlab R12
#if defined(_WIN32) && defined (_USE_THREAD)
#  pragma comment(lib, "libcmt.lib")  // multithread static library
#endif

//#define _USE_WIN_MMTIMER
#if defined(_WIN32)
#  if defined (_USE_WIN_MMTIMER)
#    include <mmsystem.h>
#    pragma comment(lib, "winmm.lib")   // windows multimedia library
#    define KILLTIMER(a) timeKillEvent(a)
#  else
#    include <winuser.h>
#    define TIME_ONESHOT  0x0000   /* program timer for single event */
#    define TIME_PERIODIC 0x0001   /* program for continuous periodic event */
#    pragma comment(lib, "user32.lib")  // windows user library
#    define KILLTIMER(a) KillTimer(NULL,a)
#  endif
#endif


#define TARGET_RESOLUTION (1)   // timer resolution
#define MAX_TIMERS (16)         // max number of timers

#define MMTCMD_INVALID   0
#define MMTCMD_SETTIMER  1
#define MMTCMD_KILLTIMER 2
#define MMTCMD_KILLALL   3
#define MMTCMD_QUERYRES  4
#define MMTCMD_QUERYID   5

#define INP_CMD      prhs[0]
#define INP_TIMERIDX prhs[1]
#define INP_DELAY    prhs[2]
#define INP_TYPE     prhs[3]
#define INP_CALLBACK prhs[4]

// timer data
typedef struct _timerwork {
  UINT m_tid;          // timer id;
  char m_script[128];  // script
  int  m_type;         // periodic or oneshot
} TIMERWORK;

// prototypes
void mmtimerOnExit(void);
void killTimerWork(int idx);
TIMERWORK *findTimerWork(UINT id);
void invokeMatlabScript(void *arg);
void CALLBACK mmtimerProc(UINT uID, UINT uMsg, DWORD dwUser, DWORD dw1, DWORD dw2);
void CALLBACK timerProc(HWND hWnd, UINT uMsg, UINT idEvent, DWORD dwTime);
int  evalCommandStr(char *cmdstr);
UINT mmtimerSetTimer(int mytimer, int delay, int type, char *matlabCB);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[]);

// global variable;
TIMERWORK gTimerWork[MAX_TIMERS];
UINT      gTimerRes;
#if defined (_USE_WIN_MMTIMER)
TIMECAPS  gTimeCaps;
#endif

void mmtimerOnExit(void)
{
  int i;
  for (i=0; i < MAX_TIMERS; i++)  killTimerWork(i);
#if defined (_USE_WIN_MMTIMER)
  timeEndPeriod(gTimerRes);
#endif
}


void killTimerWork(int idx)
{
  if (idx < 0 || idx >= MAX_TIMERS)  return;
  if (gTimerWork[idx].m_tid != 0) {
    KILLTIMER(gTimerWork[idx].m_tid);
  }
  gTimerWork[idx].m_tid = 0;
  gTimerWork[idx].m_script[0] = '\0';
  return;
}

TIMERWORK *findTimerWork(UINT tid)
{
  int i;

  for (i = 0; i < MAX_TIMERS; i++) {
    if (gTimerWork[i].m_tid == tid)  break;
  }
  if (i >= MAX_TIMERS)  return NULL;
  if (gTimerWork[i].m_script[0] == '\0')  return NULL;

  return &gTimerWork[i];
}

void invokeMatlabScript(void *arg)
{
#if defined(_USE_THREAD)
  mexEvalString((char *)arg);
  _endthread();
#endif
}

void CALLBACK mmtimerProc(UINT uID, UINT uMsg, DWORD dwUser, DWORD dw1, DWORD dw2)
{
  TIMERWORK *pwork;

  if ((pwork = findTimerWork(uID)) == NULL)  return;
#if defined(_USE_THREAD)
  _beginthread(invokeMatlabScript, 0, (void *)pwork->m_script);
#else
#  if defined (_DEBUG)
  mexPrintf("tid=%d dwUser=%d: %s\n", uID,dwUser,pwork->m_script);
#  endif
  mexEvalString(pwork->m_script);
#endif

#if defined(_DEBUG)
	Beep(1940,80);
	Beep(970,80);
#endif

  return;
}

void CALLBACK timerProc(HWND hWnd, UINT uMsg, UINT idEvent, DWORD dwTime)
{
  TIMERWORK *pwork;

  if ((pwork = findTimerWork(idEvent)) == NULL)  return;
#if defined(_USE_THREAD)
  _beginthread(invokeMatlabScript, 0, (void *)pwork->m_script);
#else
#  if defined(_DEBUG)
  mexPrintf("tid=%d dwTime=%d: %s\n", idEvent,dwTime,pwork->m_script);
#  endif
  mexEvalString(pwork->m_script);
#endif
#if defined(_DEBUG)
	Beep(1940,80);
	Beep(970,80);
#endif

  if (pwork->m_type == TIME_ONESHOT) {
    KILLTIMER(pwork->m_tid);
  }

  return;
}


DWORD WINAPI ThreadFuncTest(LPVOID lpParameter)
{
  DWORD t0,t;
#if defined (_USE_WIN_MMTIMER)
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
#endif
  return 0;
}


int evalCommandStr(char *cmdstr)
{
  if (_stricmp(cmdstr,"settimer") == 0)         return MMTCMD_SETTIMER;
  else if (_stricmp(cmdstr,"killtimer") == 0)   return MMTCMD_KILLTIMER;
  else if (_stricmp(cmdstr,"killall") == 0)     return MMTCMD_KILLALL;
  else if (_stricmp(cmdstr,"resolution") == 0)  return MMTCMD_QUERYRES;
  else if (_stricmp(cmdstr,"gettimerid") == 0)  return MMTCMD_QUERYID;
  else  return MMTCMD_INVALID;
}

UINT mmtimerSetTimer(int mytimer, int delay, int type, char *matlabCB)
{
  UINT timerID;

  sprintf(gTimerWork[mytimer].m_script,"%s",matlabCB);
  //timerID = (UINT)timeSetEvent(delay,0,mmtimerProc,(DWORD)mytimer,type);
#if defined (_USE_WIN_MMTIMER)
  timerID = (UINT)timeSetEvent(delay,gTimerRes,mmtimerProc,(DWORD)mytimer,type);
#else
  timerID = SetTimer(NULL,NULL,delay,(TIMERPROC)timerProc);
#endif
  if (timerID != 0) {
    if (gTimerWork[mytimer].m_tid != 0)   killTimerWork(mytimer);
    gTimerWork[mytimer].m_tid = timerID;
    gTimerWork[mytimer].m_type = type;
  } else {
  }
#if defined(_DEBUG)
  mexPrintf(" timer[%d]: id=%d cb='%s'",
            mytimer,timerID,gTimerWork[mytimer].m_script);
#endif
  return timerID;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  static int firstEnter = 0;
  int i, timerIdx, buflen, delay, type;
  char *cmdstr, *typestr, *cbstr;
  double *pdouble;

  if (firstEnter == 0) {
    for (i = 0; i < MAX_TIMERS; i++) {
      gTimerWork[i].m_tid = 0;
      gTimerWork[i].m_script[0] = '\0';
    }
#if defined (_USE_WIN_MMTIMER)
    // determine timer resolution
    if (timeGetDevCaps(&gTimeCaps, sizeof(TIMECAPS)) != TIMERR_NOERROR) {
      mexErrMsgTxt("can't use multimedia timer on this computer.");
    }
    gTimerRes = min(max(gTimeCaps.wPeriodMin, TARGET_RESOLUTION), gTimeCaps.wPeriodMax);
    timeBeginPeriod(gTimerRes);
#else
    gTimerRes = 0;
#endif
    mexAtExit(mmtimerOnExit);
    firstEnter = 1;
#if defined(_DEBUG)
    mexPrintf("%s: min timer resolution is %dms.",mexFunctionName(),gTimerRes);
#endif
  }

  /* Check for proper number of arguments */
  if (nrhs < 1) {
    mexEvalString("help mmtimer;");
    return;
  }

  // get a command string
  if (mxIsChar(INP_CMD) != 1)   mexErrMsgTxt("command must be a string.");
  buflen = (mxGetM(INP_CMD) * mxGetN(INP_CMD)) + 1;
  cmdstr = (char *)mxCalloc(buflen, sizeof(char));
  mxGetString(INP_CMD, cmdstr, buflen);

  if (nrhs > 1) {
    // get timer index
    timerIdx = (int)mxGetScalar(INP_TIMERIDX);
    if (timerIdx < 0 || timerIdx >= MAX_TIMERS) {
      mexErrMsgTxt("timerid must be 0 to 15.");
    }
  }

  switch (evalCommandStr(cmdstr)) {
  case MMTCMD_SETTIMER:
    if (nrhs < 5)  mexErrMsgTxt("mmtimer('SetTimer',timer,delay,'type','callback')");
    // delay
    delay = (int)mxGetScalar(INP_DELAY);
    if (delay <= 0) mexErrMsgTxt("delay must be > 0 (in msec).");
    // type
    if (mxIsChar(INP_TYPE) != 1) {
      mexErrMsgTxt("type must be a string {periodic|oneshot}.");
    }
    buflen = (mxGetM(INP_TYPE) * mxGetN(INP_TYPE)) + 1;
    typestr = (char *)mxCalloc(buflen, sizeof(char));
    mxGetString(INP_TYPE, typestr, buflen);
    if (_stricmp(typestr,"periodic")==0)  type = TIME_PERIODIC;
    else                                  type = TIME_ONESHOT;
    // callback
    if (mxIsChar(INP_CALLBACK) != 1) {
      mexErrMsgTxt("callback must be a string.");
    }
    buflen = (mxGetM(INP_CALLBACK) * mxGetN(INP_CALLBACK)) + 1;
    cbstr = (char *)mxCalloc(buflen, sizeof(char));
    mxGetString(INP_CALLBACK, cbstr, buflen);
    if (mmtimerSetTimer(timerIdx,delay,type,cbstr) == 0) {
      mexErrMsgTxt("faild to start timer.");
    }

    break;
  case MMTCMD_KILLTIMER:
    if (nrhs < 2)  mexErrMsgTxt("mmtimer('KillTimer',timer)");
    killTimerWork(timerIdx);
    break;
  case MMTCMD_KILLALL:
    for (i=0; i < MAX_TIMERS; i++)  killTimerWork(i);
    break;
  case MMTCMD_QUERYRES:
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    pdouble = (double *)mxGetPr(plhs[0]);
    *pdouble = (double)gTimerRes;
    break;
  case MMTCMD_QUERYID:
    if (nrhs < 2)  mexErrMsgTxt("mmtimer('GetTimerID',timer)");
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    pdouble = (double *)mxGetPr(plhs[0]);
    *pdouble = (double)gTimerWork[timerIdx].m_tid;
    break;

  default:
    mexErrMsgTxt("not supported command.");
  }

  return;
}


