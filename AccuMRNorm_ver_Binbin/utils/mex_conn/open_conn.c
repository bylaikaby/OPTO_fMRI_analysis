/* compile with: "mex -DCOOKED -DBLOCKING_SOCKET -DOPEN_CONN -I/usr/local/include open_conn.c sockfuncs.c user32.lib ws2_32.lib"
		  if defined 'OLD' (see sockfuncs.c) add "d:\usr\local\lib\wsock32x.lib"
		  pref. use 'DCOOKED' since it handles backspaces correctly; pref. use DBLOCKING_SOCKET */
#include <stdio.h>
#define _WIN32_WINNT 0x0500
#define WINVER 0x0500
#define _WINNT
#include <windows.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <wsa_xtra.h>
#include <windowsx.h>

#include <winsock.h>
//#include "sockres.h"
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <dos.h>
#include <direct.h>
#include <winsockx.h>

#define SOCK_BUF_SIZE 16384
#include <mex.h>

int sock_array[14];
FILE *hf0,*hf1,*hf2;
int initialized=0;
int console=0;
int wnd_ctr;
#define MAXNR_MATLABWND 20
HANDLE wnd_list[MAXNR_MATLABWND];
static DWORD ConnThreadID = -1;
HANDLE hThread;
static DWORD Mode;
HANDLE inHandle=NULL;
HANDLE waitHandle=NULL;
char inbuf[256];
char outbuf[256];
fd_set readfdso;
fd_set writefdso;
// fd_set exceptfdso;
struct timeval timeouto;
struct linger lng;
extern int ionbio;

extern SOCKET hLstnSock; /* Listening socket */
extern SOCKADDR_IN stLclName;           /* Local address and port number */
extern int  iActiveConns;               /* Number of active connections */
extern long lByteCount;                 /* Total bytes read */
extern int  iTotalConns;                /* Connections closed so far */

typedef struct stConnData {
  SOCKET hSock;                  /* Connection socket */
  SOCKADDR_IN stRmtName;         /* Remote host address & port */
  LONG lStartTime;               /* Time of connect */
  BOOL bReadPending;             /* Deferred read flag */
  int  iBytesRcvd;               /* Data currently buffered */
  int  iBytesSent;               /* Data sent from buffer */
  long lByteCount;               /* Total bytes received */
  char achIOBuf  [INPUT_SIZE];   /* Network I/O data buffer */
  struct stConnData FAR*lpstNext;/* Pointer to next record */
} CONNDATA, *PCONNDATA, FAR *LPCONNDATA;

LPCONNDATA *lpstSockHeadp;     /* Head of the list */

extern BOOL  bReAsync;
char tcl_rcv[SOCK_BUF_SIZE], tcl_rep[SOCK_BUF_SIZE];
SOCKET kill_sock;

/*------------ function prototypes -----------*/
int InitSocket(HWND hWin, HINSTANCE hInstance);
BOOL InitLstnSock(int iLstnPort, PSOCKADDR_IN pstSockName,
  HWND hWnd, u_int nAsyncMsg);
SOCKET AcceptConn(SOCKET, PSOCKADDR_IN);
int SendData(SOCKET, LPSTR, int);
int RecvData(SOCKET, LPSTR, int);
int CloseConn(SOCKET, LPSTR, int, HWND);
LPCONNDATA NewConn (SOCKET, PSOCKADDR_IN);
LPCONNDATA FindConn (SOCKET);
void RemoveConn (LPCONNDATA);
BOOL doSocketMessage (HWND hWinMain, UINT msg, UINT wParam, LPARAM lParam);
/*--------------------------------------------*/

BOOL CALLBACK
MyEnumWindowsProc(
  HWND hwnd,      // handle to parent window
  LPARAM lParam   // application-defined value
)
{
  int i;
  LPTSTR title[65];
  GetWindowText(hwnd,title,64);
  if (strncmp("MATLAB",title,6)) return 1;
  if (lParam == NULL) {
    wnd_list[wnd_ctr++]=hwnd;
    if (wnd_ctr == MAXNR_MATLABWND) return 0;
  } else {
    for(i=0;i<wnd_ctr,i<MAXNR_MATLABWND;i++) {
      if(wnd_list[i]==hwnd) return 1;
    }
    SetWindowText(hwnd,"MATLAB Console");
    return 0;
  }
  return 1; // continue to end
}

static void ConnThread(void)
{
  int inp;
  int ctr,i,nRet;
  char inpc;
  INPUT_RECORD inrec;
  LPCONNDATA lpstSockTmp;
  LPARAM lParam;

  if (console) {
    GetConsoleMode(inHandle,&Mode);
    //SetConsoleMode(inHandle,Mode&(~ENABLE_LINE_INPUT)&(~ENABLE_ECHO_INPUT)&(~ENABLE_MOUSE_INPUT));
    SetConsoleMode(inHandle,Mode&(~ENABLE_LINE_INPUT)&(~ENABLE_MOUSE_INPUT));
    ctr=0;
    memset(inbuf,0,256);
    memset(outbuf,0,256);
    sock_array[10]=-2; sock_array[11]=0; // communication with read_console, write_console
  }
  FD_ZERO(&readfdso); // FD_ZERO(&writefds); FD_ZERO(&exceptfds);
  timeouto.tv_sec=0; timeouto.tv_usec=1000;
  //lpstSockHeadp[0]=0;
  sock_array[7]=0;
  sock_array[12]=0;
  sock_array[13]=0;
  if (!InitSocket(NULL,NULL) || hLstnSock == INVALID_SOCKET) {_sleep (2000);goto _end;}
  waitHandle = CreateEvent(NULL,FALSE,FALSE,"Sock_Close");
  for(;;) {
    if(sock_array[13]>=0) {
     if (WaitForSingleObject(waitHandle,0) == WAIT_OBJECT_0 || sock_array[12]) {//Shutdown the current blocking socket (from read_conn or write_conn)
       int ionbio;
       ResetEvent(waitHandle);
       inform_clients:
       kill_sock = sock_array[13];
       sock_array[13] = -1; // tell read_conn, write_conn to finish
#ifdef BLOCKING_SOCKET
       // the hard way: (setting a blocking socket to nonblocking and back to blocking is the soft way but we probably use this only in severe cases)
       lng.l_onoff=1; lng.l_linger=0; setsockopt(kill_sock,SOL_SOCKET,SO_LINGER,&lng,sizeof(struct linger));
       shutdown(kill_sock,2);
       closesocket(kill_sock); // we should close the socket here ungracefully because it might not return from doSocketMessage's graceful FD_CLOSE 
       doSocketMessage(NULL,0,kill_sock,FD_CLOSE); // try to clean up the struct's anyway
       /*
       sock_array[13] = -2; // tell read_conn, write_conn to finish and set back to blocking mode
       ioctlsocket(kill_sock,FIONBIO,&kill_sock);
       WSACancelBlockingCall();
       */
#endif
     }
    }
    if (sock_array[12]) {if(sock_array[13]>=0) goto inform_clients; break;} // exit from close_conn
    readfdso.fd_count=1; readfdso.fd_array[0]=hLstnSock;
    /* the clients are now handled in read_conn
    if (lpstSockHeadp[0]) {
      readfdso.fd_count++;readfdso.fd_array[1]=lpstSockHeadp[0]->hSock;i=1;
      for (lpstSockTmp = lpstSockHeadp[0];
	 lpstSockTmp && lpstSockTmp->lpstNext;
	 lpstSockTmp = lpstSockTmp->lpstNext) {
         FD_SET(lpstSockTmp->hSock,&readfdso);
         //readfdso.fd_count++; readfdso.fd_array[i++] = lpstSockTmp->hSock;
      }
    }
    */
    nRet = select(1,&readfdso,NULL,NULL,&timeouto);
    if (nRet > 0) { //something to do!
      /* the clients are now handled in read_conn
      for (i=0;i<readfdso.fd_count;i++) {
        if(readfdso.fd_array[i] == hLstnSock) doSocketMessage(NULL,0,readfdso.fd_array[i],FD_ACCEPT);
        else if(doSocketMessage(NULL,0,readfdso.fd_array[i],FD_READ)) {
	  if(!tcl_rcv[0]) {
	    doSocketMessage(NULL,0,readfdso.fd_array[i],FD_CLOSE);
          } else {
	    if(console) fprintf(hf1,"%s\n",tcl_rcv);
	  }
	}
      }
      */
      doSocketMessage(NULL,0,hLstnSock,FD_ACCEPT);
    }
    if(console) {
      if(sock_array[10]==-3) {sock_array[11]=1; continue;}
      if(sock_array[11]==2) {ctr=0; while(inbuf[ctr] && ctr<256)ctr++; sock_array[11]=0;}
      if(outbuf[0]) {if(outbuf[0]==4)break;fprintf(hf1,"%s",outbuf);fflush(hf1);memset(outbuf,0,256);}
      if(!inbuf[0]) ctr=0;
      PeekConsoleInput(inHandle,&inrec,1,&inp);
      if (inp) {
        if (inrec.EventType == KEY_EVENT) {
          if (ReadConsoleInput(inHandle,&inrec,1,&inp) && inrec.Event.KeyEvent.bKeyDown) {
            inpc=inrec.Event.KeyEvent.uChar.AsciiChar;
	    if(inpc==4) {sock_array[12]=1; continue; } //break; inform the clients also
	    if (inpc) { // otherwise Control Key
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
              if(ctr>=256) {memset(inbuf,0,256);ctr=0;}
	    }
          }
        } else ReadConsoleInput(inHandle,&inrec,1,&inp); // usually mouse if enabled, otherwise e.g. focus ...
      }
    }
    //SwitchToThread();
    //_sleep(5); //only with PeekConsole and no select (timeout)
    //_sleep(1000); // debugging only
  }
  _end:
  // lpstSockHeadp[0]=-1; _sleep(30); // give read_conn a chance to exit
  sock_array[12]=1; // for all clients
  CloseSocket();
  if (console) {
    // sock_array[0]=0; // for the console clients (now sock_array[12])
    FreeConsole();
  }
  initialized=0;
  ExitThread(0);
}

static HANDLE InitConn(void)
{
  hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) ConnThread,
                         NULL, 0, &ConnThreadID);

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
  wnd_ctr=0;
  EnumWindows(
    (WNDENUMPROC) MyEnumWindowsProc,  // pointer to callback function
    NULL            // application-defined value
  );
  if (AllocConsole()) { // otherwise we're on the console already most likely

  EnumWindows(
    (WNDENUMPROC) MyEnumWindowsProc,  // pointer to callback function
    1            // application-defined value
  );

  // close(0);close(1);close(2); uncommented console can't be reopened

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
  // initialized = 1;

}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int i,j;
  int *knk; double *dknk;
  if (nrhs != 1) {
  //mexErrMsgTxt("usage: [f_in,f_out] = open_console (use_newconsole[0,1] debug[0,1])");
  //mexErrMsgTxt("usage: [f_in,f_out,net_in,net_out] = open_conn(debug [0/1]; f_in,f_out are not used with debug=0");
  mexErrMsgTxt("usage: [socket] = open_conn(debug [0/1]");
  return;
  }
  if (initialized) {
     // trying to return s directly; mexErrMsgTxt("open_conn only needs to be called once\n");
     plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL); knk= (mxGetPr(plhs[0])); *knk=sock_array;
     plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL); dknk= (mxGetPr(plhs[1]));  *dknk=1.; // repeated call
     return;
  }
  if (mxGetScalar(prhs[0]) == 1.) {
    SetupConsole();
    if(!hf1) { // happens probably only when descr 0,1,2 are closed in SetupConsole (see there)
      mexErrMsgTxt("Warning:couldn't allocate console, try close_conn and reopen again if console required\n");
    }
    console=1;
    /* now sock_array
    i=inbuf;
    // j=outbuf;
    j=hf1;
    */
  } else {
   console=0;
   hf0=0;hf1=0;
   //i=0;j=0;
  }
  InitConn();
  if(hThread) initialized=1;
  else mexErrMsgTxt(" Error: couldn't open connection handler\n");

  //printf("%d,%d:%d\n",inbuf,outbuf,hf0);
  /* socket array as single return instead
  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL); knk= (mxGetPr(plhs[0]));  *knk=i;
  plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL); knk = (mxGetPr(plhs[1]));  *knk=j;
  plhs[2] = mxCreateDoubleMatrix(1,1, mxREAL); i=tcl_rcv; knk = (mxGetPr(plhs[2]));  *knk=i;
  plhs[3] = mxCreateDoubleMatrix(1,1, mxREAL); i=tcl_rep; knk = (mxGetPr(plhs[3]));  *knk=i;
  //plhs[2] = mxCreateDoubleMatrix(1,1, mxREAL); i=hf0; knk = (mxGetPr(plhs[2])); *knk = i;
  */
  // inbuf and outbuf provide non-blocking console I/O, although output isn't really ever blocking (explorer hangs ...), so outbuf isn't really needed
  sock_array[0]=hf0;sock_array[1]=hf1;sock_array[2]=inbuf;sock_array[3]=outbuf;
  sock_array[4]=tcl_rcv;sock_array[5]=tcl_rep;sock_array[6]=lpstSockHeadp;
  sock_array[9]=inHandle;sock_array[8]=waitHandle;
  _end:
  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL); knk= (mxGetPr(plhs[0]));  *knk=sock_array;
  plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL); dknk= (mxGetPr(plhs[1]));  *dknk=0.; // first run
  //printf("%d::%d:%d:%d:%d:%d:%d:%d\n",sock_array,hf0,hf1,inbuf,outbuf,tcl_rcv,tcl_rep,lpstSockHeadp);
}
