#include <stdio.h>
#define _WIN32_WINNT 0x0500
#define WINVER 0x0500
#define _WINNT
#include <windows.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <mex.h>

FILE *hf0,*hf1,*hf2;
int initialized=0;
static DWORD TerminalThreadID = -1;
static DWORD Mode;
HANDLE inHandle=NULL;
char inbuf[256];
char outbuf[256];

static void TerminalThread(void)
{
  int inp;
  int ctr;
  char inpc;
  INPUT_RECORD inrec;

  GetConsoleMode(inHandle,&Mode);
  //SetConsoleMode(inHandle,Mode&(~ENABLE_LINE_INPUT)&(~ENABLE_ECHO_INPUT)&(~ENABLE_MOUSE_INPUT));
  SetConsoleMode(inHandle,Mode&(~ENABLE_LINE_INPUT)&(~ENABLE_MOUSE_INPUT));
  ctr=0;
  memset(inbuf,0,256);
  memset(outbuf,0,256);
  for(;;) {
    if(outbuf[0]==4)break;
    if(outbuf[0]) {fprintf(hf1,"%s",outbuf);fflush(hf1);memset(outbuf,0,256);}
    if(!inbuf[0]) ctr=0;
    //_sleep(100); //test only
    // neither kbhit nor getch seem to be reentrant (i.e. use the allocated console correctly on consecutive calls)
    //if(_kbhit()) {
    //inpc=97;if(WriteConsoleInput(inHandle,&inpc,1,&inp)) fprintf(hf1,"noerr\n");
    PeekConsoleInput(inHandle,&inrec,1,&inp);
    if (inp) {
      if (inrec.EventType == KEY_EVENT) {
        //inp=_getch();
        //if (_read(0,&inpc,1) > 0) { //linemode and echomode only
        if (ReadConsoleInput(inHandle,&inrec,1,&inp) && inrec.Event.KeyEvent.bKeyDown) {
	  inpc=inrec.Event.KeyEvent.uChar.AsciiChar;
          fputc(inpc,hf1);
	  if(inpc==4)break;
	  if(inpc==13)fputc(10,hf1);else if(inpc==8){fputc(32,hf1);fputc(inpc,hf1);}
          if(ctr==256) {memset(inbuf,0,256);ctr=0;}
	  else if(ctr) { if (inbuf[--ctr]==13 || inbuf[ctr++]==10) {memset(inbuf,0,ctr);ctr=0;}}
          inbuf[ctr++]=inrec.Event.KeyEvent.uChar.AsciiChar;
          // printf goes to the matlab console and , therefore, crashes, because the thread isn't attached to the console any more
          // only the main mex function returns 'printf' correctly (after finishing the mex function)
          // printf("%d\n",inp);
        }
      } else ReadConsoleInput(inHandle,&inrec,1,&inp); // usually mouse if enabled, otherwise e.g. focus ...
    }
    SwitchToThread();
    _sleep(5);
  }
  //close(0);close(1);close(2);
  FreeConsole();
  initialized=0;
  ExitThread(0);
}

static HANDLE InitTerm(void)
{
  //extern void TerminalThread(void);
  HANDLE hThread;

  hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) TerminalThread,
                         NULL, 0, &TerminalThreadID);

  WaitForSingleObject(hThread, 10);
  CloseHandle(hThread);
  return hThread;
}

void SetupConsole()
{
  int hCrt;
  //FILE *hf;
  //static int initialized = 0;
  DWORD rv;

  rv = GetLastError();

  if(initialized == 1){
        fprintf(hf2,"Setup console only needs to be called once\n");
        return;
  }

  close(0);close(1);close(2);
  if (!AllocConsole()) return;
  // WinXP only (Visual C++ v7), attaches to starting console (if applicable), not the main window!: if (!AttachConsole(ATTACH_PARENT_PROCESS)) return;

  inHandle = GetStdHandle(STD_INPUT_HANDLE);
  hCrt = _open_osfhandle( (long) inHandle, _O_TEXT );
  hf0 = _fdopen(hCrt, "r");
  if (hf0) {
    setvbuf(hf0, NULL, _IONBF, 0);
  }

  // Setup stdout
  hCrt = _open_osfhandle( (long)GetStdHandle(STD_OUTPUT_HANDLE), _O_TEXT );
  hf1 = _fdopen(hCrt, "w");
  if (hf1) {
    setvbuf(hf1, NULL, _IONBF, 0);
    //memcpy(stdout,hf1,sizeof(FILE)); // useless since 'printf' doesn't print to stdout!!
  }

  // Setup stderr
  hCrt = _open_osfhandle( (long)GetStdHandle(STD_ERROR_HANDLE), _O_TEXT );
  hf2 = _fdopen(hCrt, "w");
  if (hf2) {
    setvbuf(hf2, NULL, _IONBF, 0);
    //memcpy(stderr,hf2,sizeof(FILE));
  }

  initialized = 1;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int i;
  int *knk;
  if (nrhs != 0) {
  //mexErrMsgTxt("usage: [f_in,f_out] = open_console (use_newconsole[0,1] debug[0,1])");
  mexErrMsgTxt("usage: [f_in,f_out] = open_console");
  }
  //if (mxGetScalar(prhs[0]) == 1.) {
    if (initialized) mexErrMsgTxt("open_console only needs to be called once\n");
    SetupConsole();
    //if(mxGetScalar(prhs[1]) == 1.) initialized=2; //debugging only
    InitTerm();
    // printf("%d,%d\n",inbuf,outbuf);
    plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL); i=inbuf; knk= (mxGetPr(plhs[0]));  *knk=i;
    plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL); /*i=outbuf*/i=hf1; knk = (mxGetPr(plhs[1]));  *knk=i;
    //plhs[2] = mxCreateDoubleMatrix(1,1, mxREAL); i=hf2; *(mxGetPr(plhs[2])) = i;
  //}
}
