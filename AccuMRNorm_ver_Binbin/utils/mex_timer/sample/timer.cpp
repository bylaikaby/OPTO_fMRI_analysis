/***********************************************************************
 APPLICATION : MATLAB TIMER.DLL C++ SOURCE CODE
 VERSION     : 1.0 Demo
 AUTHOR      : Igor Kaufman, SPAC, Lancaster University
************************************************************************/
#include <windows.h>
#include <mem.h>
#include <string.h>
#include "mex.h"

const strLen  = 256;         //Max length of MatLab eval string
const tmMax   =  16;         //Max number of Timers
const isError =  -1;         //Error Code

enum TimerCmd {              //Timer commands
   cmNoCmd,                  //Dummy
   cmSetTimer,               //Set new W95 Timer
   cmSetCallBack,            //Set new MATLAB CallBack
   cmKillTimer,              //Kill Timer
   cmMaxCmd                  //Dummy
};

struct TimerParam {          //Timer parameters
   UINT idTimer;             //Timer idetifier
   char tmEvalStr[strLen];   //String callback for mexEvalString
};

static TimerParam tpParam[tmMax];        //Table of Timer parameters
static char buf[strLen];                 //Static string buffer

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray
*prhs[]);
VOID CALLBACK TimerProc (HWND hwnd, UINT uMsg, UINT idEvent,DWORD dwTime);
BOOL WINAPI DllEntryPoint(HINSTANCE , DWORD , LPVOID);
char *psTmCmd (TimerCmd cmCmd);          //Get command string from code
TimerCmd cmGetCmdNum(const char* psCmd); //Get code from command string
int FindTimer(UINT theTimer);            //Find entry in timers table

/*********************Implementation**************************************
*/

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray
*prhs[])
{
   int tmCur;
   UINT idCurTimer;
   int buflen;

   int Result=0;                         //mexFunction result
   TimerCmd cmCurCmd=cmNoCmd;            //Current Matlab command

   if (nrhs) {
      if (mxGetClassID(prhs[0])==mxCHAR_CLASS) {
      	buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
        mxGetString(prhs[0], buf,buflen);
     	cmCurCmd=cmGetCmdNum(buf);
      }  else
     	cmCurCmd=(TimerCmd)mxGetScalar(prhs[0]);
   }
   mexPrintf("Timer Command=%s\n",psTmCmd(cmCurCmd)); //Demo version

   switch (cmCurCmd) {
      case  cmSetTimer:  {
         if (nrhs==3) {
            UINT uElapse=(UINT) mxGetScalar(prhs[1]);
            buflen = (mxGetM(prhs[2]) * mxGetN(prhs[2])) + 1;
            mxGetString(prhs[2], buf,buflen);
            tmCur=FindTimer(NULL);
            if (tmCur>isError) {
               tpParam[tmCur].idTimer=
                  SetTimer(NULL,NULL,uElapse,(TIMERPROC)TimerProc);
               if (tpParam[tmCur].idTimer) {
                  strcpy(tpParam[tmCur].tmEvalStr,buf);
                  Result=tpParam[tmCur].idTimer;
               }
            }
         }
      }  break;

      case  cmSetCallBack:  {
         if (nrhs==3)   {
            idCurTimer=(UINT) mxGetScalar(prhs[1]);
            buflen = (mxGetM(prhs[2]) * mxGetN(prhs[2])) + 1;
            mxGetString(prhs[2], buf,buflen);
            tmCur=FindTimer(idCurTimer);
            if (tmCur>isError) {
               strcpy(tpParam[tmCur].tmEvalStr,buf);
               Result=idCurTimer;
            }
         }
      }  break;

      case  cmKillTimer: {
         if (nrhs>1)  {
            idCurTimer=(UINT) mxGetScalar(prhs[1]);
            tmCur=FindTimer(idCurTimer);
            if (tmCur>isError) {
               tpParam[tmCur].idTimer=NULL;
               tpParam[tmCur].tmEvalStr[0]=0;
               Result=KillTimer(NULL,idCurTimer);
	    }
         } else
            for (tmCur=0;tmCur<tmMax;tmCur++) {
	       if (tpParam[tmCur].idTimer) {
      	          KillTimer(NULL,tpParam[tmCur].idTimer);
                  Result=1;
            	}
            }
      }  break;

      default : Result=0;
   }

   if (!plhs[0]) {
      plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
      if (plhs[0]) *(mxGetPr(plhs[0]))=Result;
   }
}

VOID CALLBACK TimerProc(HWND hwnd, UINT uMsg, UINT idEvent, DWORD dwTime)
{
   int tmCur=FindTimer(idEvent);
   if (tmCur>isError && tpParam[tmCur].tmEvalStr[0])
      mexEvalString(tpParam[tmCur].tmEvalStr);
}

BOOL WINAPI DllEntryPoint(HINSTANCE hinstDll, DWORD fdwReason,
                          LPVOID lpvReserved)
{
    switch (fdwReason) {
       case DLL_PROCESS_ATTACH: {
          memset(tpParam,sizeof(tpParam),0);
          memset(buf,sizeof(buf),0);
       } break;

       case DLL_PROCESS_DETACH:  {
          for (int tmCur=0;tmCur<tmMax;tmCur++)
             if (tpParam[tmCur].idTimer)
                KillTimer(NULL,tpParam[tmCur].idTimer);
       }  break;
    }
    return 1;
}

char *psTmCmd (TimerCmd cmCmd)
{
   switch (cmCmd) {
      case cmSetTimer      :return  "SetTimer";
      case cmSetCallBack   :return  "SetCallBack";
      case cmKillTimer     :return  "KillTimer";
      default              :return  "";
   }
}

int FindTimer(UINT theTimer)
{
   for (int tmCur=0;tmCur<tmMax;tmCur++)
      if (tpParam[tmCur].idTimer==theTimer) return tmCur;
   return isError;
}

TimerCmd cmGetCmdNum(const char* psCmd)
{
   for (TimerCmd cmCurCmd=cmNoCmd;cmCurCmd<cmMaxCmd;cmCurCmd++)
      if (!strcmp(psCmd,psTmCmd(cmCurCmd))) return cmCurCmd;
   return cmNoCmd;
}

