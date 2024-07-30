/* compile with: "mex <-DCOOKED> open_console.c user32.lib ws2_32.lib" */
#include <stdio.h>
#define _WIN32_WINNT 0x0500
#define WINVER 0x0500
#define _WINNT
#include <windows.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <mex.h>

int sock_array[14];
FILE *hf0,*hf1,*hf2;
int initialized=0;
static DWORD TerminalThreadID = -1;
HANDLE hThread;
static DWORD Mode;
HANDLE inHandle=NULL;
HANDLE waitHandle=NULL;
char inbuf[256];
char outbuf[256];
int debug;

static void TerminalThread(void)
{
  int inp;
  int ctr;
  char inpc;
  INPUT_RECORD inrec;

  waitHandle = CreateEvent(NULL,FALSE,FALSE,"Sock_Close");
  GetConsoleMode(inHandle,&Mode);
  //SetConsoleMode(inHandle,Mode&(~ENABLE_LINE_INPUT)&(~ENABLE_ECHO_INPUT)&(~ENABLE_MOUSE_INPUT));
  SetConsoleMode(inHandle,Mode&(~ENABLE_LINE_INPUT)&(~ENABLE_MOUSE_INPUT));
  ctr=0;
  memset(inbuf,0,256);
  memset(outbuf,0,256);
  sock_array[10]=0; sock_array[11]=0; // not recv_blocked at thread startup
  sock_array[12]=0;
  for(;;) {
    if (sock_array[12]) break;
    if (!debug) /* don't do anything, just run */ {sock_array[10]=-1;sock_array[11]=0;_sleep(1000); continue;}
    if(outbuf[0]) {if(outbuf[0]==4)break;fprintf(hf1,"%s",outbuf);fflush(hf1);memset(outbuf,0,256);}
    if(!inbuf[0]) ctr=0;
    // now handled in read_console unless debug=1 (-> polling the keyboard here empties the local keyboard buffer
    // which is sometimes preferable in physiology experiments)
    if(!sock_array[10] /*  not recv_blocked */) {
      //sock_array[11]=0;
      if(sock_array[11]==2) {ctr=0;while(ctr<256 && inbuf[ctr])ctr++; sock_array[11]=0;}
      // neither kbhit nor getch seem to be reentrant (i.e. use the allocated console correctly on consecutive calls)
      //if(_kbhit()) {
      //inpc=97;if(WriteConsoleInput(inHandle,&inpc,1,&inp)) fprintf(hf1,"noerr\n");
      PeekConsoleInput(inHandle,&inrec,1,&inp);
      if (inp) {
        if (inrec.EventType == KEY_EVENT) {
          //inp=_getch();
          //if (_read(0,&inpc,1) > 0) { //linemode and echomode only
          if (ReadConsoleInput(inHandle,&inrec,1,&inp) && inrec.EventType == KEY_EVENT && inrec.Event.KeyEvent.bKeyDown) {
	    inpc=inrec.Event.KeyEvent.uChar.AsciiChar;
	    if(inpc==4)break;
            if(inpc /*else: entering inrec.Event.KeyEvent.dwControlKeyState*/) {
	      fputc(inpc,hf1);
              //pressing any char after <RET> deletes the old line (to avoid matlab overflows)
              if(ctr) { if (inbuf[--ctr]==13 || inbuf[ctr++]==10) {memset(inbuf,0,ctr);ctr=0;}}
              if(inpc==13) {inpc=10;fputc(inpc,hf1);}
              inbuf[ctr++]=inpc;
#ifdef COOKED
              //if(inpc==13){fputc(10,hf1);if(ctr<256)inbuf[ctr++]=10;}
              //else
                if(inpc==8){fputc(32,hf1);fputc(inpc,hf1);inbuf[--ctr]=0;if(ctr)inbuf[--ctr]=0;}
#else
              //if(inpc==13)fputc(10,hf1);else
                if(inpc==8){fputc(32,hf1);fputc(inpc,hf1);}
#endif
              if(ctr==256) {memmove(inbuf,inbuf+1,255);ctr--; inbuf[255]=0;}
              // printf goes to the matlab console and , therefore, crashes, because the thread isn't attached to the console any more
              // only the main mex function returns 'printf' correctly (after finishing the mex function)
              // printf("%d\n",inp);
	    }
          }
        } else ReadConsoleInput(inHandle,&inrec,1,&inp); // usually mouse if enabled, otherwise e.g. focus ...
      }
    } else
      sock_array[11]=1; // acknowledge recv_blocked
    //SwitchToThread();
    //_sleep(5); //only with PeekConsole, not needed in blocking mode; rather wait for event
    WaitForSingleObject(waitHandle,10);
  }
  //close(0);close(1);close(2);
  FreeConsole();
  initialized=0;
  sock_array[12]=1; // for the clients
  ExitThread(0);
}

static HANDLE InitTerm(void)
{
  //extern void TerminalThread(void);
  //HANDLE hThread;

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

  // WinXP only (Visual C++ v7), attaches to starting console (if applicable), not the main window!: if (!AttachConsole(ATTACH_PARENT_PROCESS)) return;
  if (AllocConsole()) { // otherwise we're on the console already most likely

  close(0);close(1);close(2);

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
  } else {//AllocConsole
    inHandle = GetStdHandle(STD_INPUT_HANDLE);
    if(inHandle == INVALID_HANDLE_VALUE) {hf1=0;return;}
    hf0=stdin;
    hf1=stdout;
    hf2=stderr;
  }

  initialized = 1;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int i;
  int *knk;
  if (nrhs != 1) {
  mexErrMsgTxt("usage: [handle] = open_console (debug[0,1], debug = 1 clears input automatically)");
  //mexErrMsgTxt("usage: [handle] = open_console");
  }
  if (initialized) {mexErrMsgTxt("open_console only needs to be called once\n"); return;}
  if (mxGetScalar(prhs[0]) == 1.) debug=1; else debug=0;
  SetupConsole();
  sock_array[4]=0; // read_conn check whether network or console application
  sock_array[6]=0;
  InitTerm();
  /*
  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL); i=inbuf; knk= (mxGetPr(plhs[0]));  *knk=i;
  plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL); *//*i=outbuf*//*i=hf1; knk = (mxGetPr(plhs[1]));  *knk=i;
  //plhs[2] = mxCreateDoubleMatrix(1,1, mxREAL); i=hf0; knk = (mxGetPr(plhs[2])); *knk = i;
  */
  sock_array[0]=hf0;sock_array[1]=hf1;sock_array[2]=inbuf;sock_array[3]=outbuf;
  sock_array[9]=inHandle;sock_array[8]=waitHandle;
  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL); knk= (mxGetPr(plhs[0]));  *knk=sock_array;
  //printf("%d::%d:%d:%d:%d:%d:%d:%d\n",sock_array,hf0,hf1,inbuf,outbuf,tcl_rcv,tcl_rep,lpstSockHeadp);
}
