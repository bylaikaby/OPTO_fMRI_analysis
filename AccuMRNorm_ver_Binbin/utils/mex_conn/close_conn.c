/* compile with: "mex -I/usr/local/include close_conn.c sockfuncs.c user32.lib ws2_32.lib d:\usr\local\lib\wsock32x.lib" */
#include <stdio.h>
/*
#define _WIN32_WINNT 0x0500
#define WINVER 0x0500
*/
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

#include <stim.h>

#include <mex.h>

FILE *hf0,*hf1,*hf2;
int console=0;
static DWORD ConnThreadID = -1;
HANDLE hThread;
static DWORD Mode;
HANDLE inHandle=NULL;
char *inbuf;
char *outbuf;
fd_set readfds;
fd_set writefds;
// fd_set exceptfds;
struct timeval timeout;

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
  int hostlen,datalen;
  char hostip[256];
  int blocking=0;
  LPCONNDATA lpstSockTmp;
  SOCKET send_sock;
 
  if (nrhs != 1) {
    mexErrMsgTxt("usage: close_conn (socket[from open_conn])");
  }

  d=mxGetScalar(prhs[0]);
  j=&d;
  //printf("%d\n",(int *)*j); return;
  if(!*j) mexErrMsgTxt("Network socket not initialized!");
  sock_array=*j;
  /*
  hf0=(FILE *)sock_array[0];hf1=(FILE *)sock_array[1];
  inbuf=(char *)sock_array[2];outbuf=(char *)sock_array[3];
  tcl_rcv=(char *)sock_array[4];tcl_rep=(char *)sock_array[5];
  lpstSockHeadp=sock_array[6];
  */
  // printf("%d::%d:%d:%d:%d:%d:%d:%d\n",sock_array,hf0,hf1,inbuf,outbuf,tcl_rcv,tcl_rep,lpstSockHeadp);return;

  // lpstSockHeadp[0]=-1; network only; instead for all clients:
  sock_array[12]=1; return;

}
