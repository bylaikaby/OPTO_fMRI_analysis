/* compile with: "mex [-DBLOCKING_SOCKET] -I/usr/local/include write_conn.c sockfuncs.c user32.lib ws2_32.lib"
		  if defined 'OLD' (see sockfuncs.c) add "d:\usr\local\lib\wsock32x.lib" */
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

//#include <stim.h>
#define SOCK_BUF_SIZE 16384

#include <mex.h>

FILE *hf0,*hf1,*hf2;
char *inbuf;
char *outbuf;
fd_set readfdsw;
fd_set writefdsw;
// fd_set exceptfdsw;
struct timeval timeoutw;

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

char *tcl_rcv, *tcl_rep;

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

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double d;
  int *sock_array;
  int *j;
  double *knk;
  int i,lasthost;
  int hostlen,datalen,data_sent,retval;
  char hostip[256];
  int blocking=0;
  LPCONNDATA lpstSockTmp;
  SOCKET send_sock;
 
  if (nrhs != 4) {
    mexErrMsgTxt("usage: write_conn (socket[from open_conn],host[or 'last'],blocking_mode[0=non-blocking,1=blocking],datastring)");
    return;
  }
  if (nlhs > 1) {
    mexErrMsgTxt("output is success(nr of bytes) or failure(0 [blocking] or -1 [error])");
    return;
  }

  d=mxGetScalar(prhs[0]);
  j=&d;
  //printf("%d\n",(int *)*j); return;
  sock_array=*j;
  if(!*j || sock_array[12]) mexErrMsgTxt("Network socket not initialized!");
  hf0=(FILE *)sock_array[0];hf1=(FILE *)sock_array[1];
  inbuf=(char *)sock_array[2];outbuf=(char *)sock_array[3];
  tcl_rcv=(char *)sock_array[4];tcl_rep=(char *)sock_array[5];
  lpstSockHeadp=sock_array[6];
  // printf("%d::%d:%d:%d:%d:%d:%d:%d\n",sock_array,hf0,hf1,inbuf,outbuf,tcl_rcv,tcl_rep,lpstSockHeadp);return;

  hostlen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
  mxGetString(prhs[1], hostip, hostlen);
  if (!strcmp(hostip,"last")) {if((send_sock = sock_array[7])) lasthost=1; else mexErrMsgTxt("no last connection yet");} else lasthost=0;

  if (mxGetScalar(prhs[2]) == 1.) blocking=1; else blocking=0;

  datalen = (mxGetM(prhs[3]) * mxGetN(prhs[3]));
  if (datalen > (SOCK_BUF_SIZE-2)) datalen = SOCK_BUF_SIZE-2;
  mxGetString(prhs[3], tcl_rep, datalen+1);

  data_sent=0;
  if(!datalen) goto _end;
  sock_array[13]=0; // output to permit closing the socket
  // if (lpstSockHeadp[0] == NULL) /* thread closed */ {datalen=-1; goto _end;}
  while (lpstSockHeadp[0] == NULL) {
    if(blocking) {
      _sleep(1) /* the user might poll too fast! */;
      // permit exiting of the loop instead
      ////if(WaitForSingleObject(sock_array[8],5) == WAIT_OBJECT_0) {
      ////  datalen=-1; goto _end;
      if (sock_array[13] == -1 || sock_array[12]) {datalen=-1; goto _end;}
    } else {
      datalen=0; goto _end;
    }
  }

  timeoutw.tv_sec=0; timeoutw.tv_usec=1000;

  if (!lasthost) {
    lpstSockTmp = lpstSockHeadp[0];
    for (;;) {
      if(strcmp(hostip,inet_ntoa((lpstSockTmp->stRmtName).sin_addr))) goto _next;
      send_sock = lpstSockTmp->hSock;
      break;
      _next:
      if (!lpstSockTmp->lpstNext) break;
      lpstSockTmp = lpstSockTmp->lpstNext;
    }
  }

#ifdef BLOCKING_SOCKET
  if (!blocking) { // check first
    FD_ZERO(&writefdsw);
    //writefdsw.fd_count=0;writefdsw.fd_array[0]=NULL;i=0;
    //FD_SET(send_sock,&writefdsw);
    writefdsw.fd_count=1; writefdsw.fd_array[0] = send_sock;
    // now test for output
    if(!select(1,NULL,&writefdsw,NULL,&timeoutw)) {
      datalen = 0; goto _end;
    }
  }
#endif

  // now send
  tcl_rep[datalen] = '\n';
  tcl_rep[datalen+1] = '\0';
  if (blocking) sock_array[13] = send_sock; // permit closing of blocking sockets
  send_more:
  if (sock_array[13] == -1) {data_sent=-1; goto _end; }
  retval=SendData(send_sock, tcl_rep + data_sent, datalen+2-data_sent);
  if (retval<0) {data_sent=-1;goto _end;} data_sent+=retval; // a nonblocking socket returns 0 on WSAEWOULDBLOCK, a negative value for any other error
  if (data_sent<(datalen+2) && blocking) {_sleep(1); goto send_more;}

  _end:
  if (data_sent>datalen) data_sent=datalen;
  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL); knk= (mxGetPr(plhs[0]));  *knk= 1. * data_sent;
  //memset(tcl_rcv,0,SOCK_BUF_SIZE); the following will do:
  tcl_rep[0]=0;
  sock_array[13]=0;

}
