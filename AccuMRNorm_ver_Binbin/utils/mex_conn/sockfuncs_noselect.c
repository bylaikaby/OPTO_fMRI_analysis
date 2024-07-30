/*
 * FILE
 *   sockfuncs.c
 *
 * DESCRIPTION
 *   support for remote socket communication
 *
 * AUTHOR
 *   DLS
 *
 * CREDIT
 *  Almost all of this code is taken from the below mentioned source...
 *
 */

/*---------------------------------------------------------------------
 *
 * Program: AS_ECHO.EXE  Asynch Echo Server (TCP)
 *
 * filename: as_echo.c
 *
 * copyright by Bob Quinn, 1995
 *   
 * Description:
 *  Server application that implements echo protocol service as
 *  described by RFC 862.  This application demonstrates simultaneous
 *  multiple user support using asynchronous operation mode.
 *
 *  This software is not subject to any  export  provision  of
 *  the  United  States  Department  of  Commerce,  and may be
 *  exported to any country or planet.
 *
 *  Permission is granted to anyone to use this  software  for any  
 *  purpose  on  any computer system, and to alter it and redistribute 
 *  it freely, subject to the following  restrictions:
 *
 *  1. The author is not responsible for the consequences of
 *     use of this software, no matter how awful, even if they
 *     arise from flaws in it.
 *
 *  2. The origin of this software must not be misrepresented,
 *     either by explicit claim or by omission.  Since few users
 *     ever read sources, credits must appear in the documentation.
 *
 *  3. Altered versions must be plainly marked as such, and
 *     must not be misrepresented as being the original software.
 *     Since few users ever read sources, credits must appear in
 *     the documentation.
 *
 *  4. This notice may not be removed or altered.
 *
 * Edit History
 *  10/22/95  Fixed calculation of cbLeftToSend.  Martin Spronk
 *            helpfully pointed out that the operands were reversed.
 *	 
 ---------------------------------------------------------------------*/
#define STRICT
#include <wsa_xtra.h>
#include <windows.h>
#include <windowsx.h>

#include <winsock.h>
//#include "sockres.h"
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <stdio.h>
#include <dos.h>
#include <direct.h>
#include <winsockx.h>

#include <stim.h>

/*-------------- global data -------------*/

static HWND hWinMain;
static HINSTANCE hInst;
SOCKET hLstnSock=INVALID_SOCKET; /* Listening socket */
static SOCKADDR_IN stLclName;           /* Local address and port number */
static int  iActiveConns;               /* Number of active connections */
static long lByteCount;                 /* Total bytes read */
static int  iTotalConns;                /* Connections closed so far */

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
extern LPCONNDATA *lpstSockHeadp;     /* Head of the list; must be extern here, since the client needs the control */
 
BOOL  bReAsync=TRUE;
// int ionbio=0; // blocking sockets (recv esp.) normally good enough in console mode
int ionbio=1; // non-blocking sockets (recv esp.)
#ifdef OPEN_CONN
extern char tcl_rcv[], tcl_rep[];
#else
extern char *tcl_rcv, *tcl_rep;
#endif

extern FILE *hf1; // for debugging purposes only
fd_set readfds;
fd_set writefds;
// fd_set exceptfds;
struct timeval timeoutn;

/*------------ function prototypes -----------*/
BOOL InitLstnSock(int iLstnPort, PSOCKADDR_IN pstSockName, 
  HWND hWnd, u_int nAsyncMsg);
SOCKET AcceptConn(SOCKET, PSOCKADDR_IN);
int SendData(SOCKET, LPSTR, int);
int RecvData(SOCKET, LPSTR, int);
int CloseConn(SOCKET, LPSTR, int, HWND);
LPCONNDATA NewConn (SOCKET, PSOCKADDR_IN);
LPCONNDATA FindConn (SOCKET);
void RemoveConn (LPCONNDATA);

/*--------------------------------------------------------------------
 *  Function: InitSocket()
 *
 *  Description: 
 *     Initialize WinSock and enter message loop
 */
int InitSocket(HWND hWin, HINSTANCE hInstance)
{
  int nRet;
  
  hWinMain = hWin;		/* Store a copy away */
  hInst = hInstance;

  /*-------------initialize WinSock DLL------------*/
  nRet = WSAStartup(WSA_VERSION, &stWSAData);
  /* WSAStartup() returns error value if failed (0 on success) */
  if (nRet != 0) {    
    if(hWinMain) WSAperror(nRet, "WSAStartup()", hInst);
    else if(hf1) fprintf(hf1,"WSAStartup: Error %d\n",nRet); 
    return 0;
  } 
  // craete a sockhead pointer
  lpstSockHeadp = malloc(sizeof(LPCONNDATA));
  if (!lpstSockHeadp || ! tcl_rcv || ! tcl_rep) {
    if(hWinMain) {
      MessageBox (hWinMain, "Sockhead allocation failed",
        "LocalAlloc() Error", MB_OK | MB_ICONASTERISK);
    } else if(hf1) fprintf(hf1,"Sockhead allocation failed"); 
    return 0;
  } 
  lpstSockHeadp[0]=0;
  timeoutn.tv_sec=0; timeoutn.tv_usec=750;

  /* Get a socket listening */
  hLstnSock = InitLstnSock (STIM_PORT, &stLclName, hWinMain, WSA_ASYNC);
  return 1;
}

int CloseSocket(void)
{    
  int nRet;

  /* Close listening socket */
  if (hLstnSock != INVALID_SOCKET)
    closesocket(hLstnSock);

  /*---------------release WinSock DLL--------------*/
  nRet = WSACleanup();
  if (nRet == SOCKET_ERROR) {
    if (hInst) WSAperror(WSAGetLastError(), "WSACleanup()", hInst);
    else if(hf1) fprintf(hf1,"WSACleanup(): Error %d\n",WSAGetLastError());
    return 0;
  }
  return 1;
}

/*--------------------------------------------------------------------
 * Function: doSocketMessage()
 *
 * Description:
 *  Process asynchronous WinSock messages.
 */

BOOL doSocketMessage (HWND hWinMain, UINT msg, UINT wParam, LPARAM lParam)
{                      
  LPCONNDATA lpstSock;             /* Work Pointer */
  WORD WSAEvent, WSAErr;
  SOCKADDR_IN stRmtName;
  SOCKET hSock;
  BOOL bRet = FALSE;
  int  nRet;

  char *tcl_result;
  //static char tcl_rcv[SOCK_BUF_SIZE], tcl_rep[SOCK_BUF_SIZE];
  
  /*------------------------------------- 
   * Async notification message handlers 
   *------------------------------------*/ 
  hSock = (SOCKET)wParam;                 /* socket */
  WSAEvent = WSAGETSELECTEVENT (lParam);  /* extract event */
  WSAErr   = WSAGETSELECTERROR (lParam);  /* extract error */
  lpstSock = FindConn(hSock);             /* find our socket structure */

  /* Close connection on error (don't show error message in server */
  if (WSAErr && (hSock != hLstnSock))  {
    if (hWinMain) {
      PostMessage (hWinMain, WSA_ASYNC,
		 (WPARAM)hSock, WSAMAKESELECTREPLY(FD_CLOSE,0)); 
    } else {
      if(hf1) fprintf(hf1,"Socket: Error: %d\n",WSAErr);
    }
    return 0;
  }
  switch (WSAEvent) {
  case FD_READ:
    if (lpstSock) {
      /* Read data from socket */
      nRet = RecvData(hSock, 
		      (LPSTR)&(lpstSock->achIOBuf), 
		      INPUT_SIZE);
      if (nRet==-2) {tcl_rcv[0]=0; return -2;}
      memcpy(tcl_rcv, (char *)&(lpstSock->achIOBuf), nRet);

      /* Why should this happen?!?! */
      ///if (nRet == 0) break; // near jump to FD_CLOSE?
      tcl_rcv[nRet] = 0;

      /*
      if (hWinMain) {
        tcl_result = sendTclCommand(tcl_rcv);
        // Now write result back to client
        memcpy(tcl_rep, tcl_result, nRet = strlen(tcl_result));

        tcl_rep[nRet] = '\n';
        tcl_rep[nRet+1] = '\0';
        SendData(hSock, tcl_rep, nRet+2);
      
        // Now reset the data
        tcl_rep[0] = 0;
      }
      */
    }
    break;
  case FD_ACCEPT:
    /* Accept the incoming data connection request */
    hSock = AcceptConn(hLstnSock, &stRmtName);
    if (hSock != INVALID_SOCKET) {
      /* get a new socket structure */
      lpstSock = NewConn(hSock, &stRmtName);
      if (!lpstSock) {
	CloseConn(hSock, (LPSTR)0, INPUT_SIZE, hWinMain);
      } else {
	iActiveConns++;
      }
    }
    break;
  case FD_CLOSE:                    /* Data connection closed */
    if (hSock != hLstnSock) {
      /* Read any remaining data and close connection */  
      CloseConn(hSock, (LPSTR)0, INPUT_SIZE, hWinMain);
      if (lpstSock) {
	RemoveConn(lpstSock);
	iTotalConns++;
	iActiveConns--;
      }
    }
    break;
  default:
    break;
  } /* end switch(WSAEvent) */
  return 1;
} /* end SocketMain() */

/*---------------------------------------------------------------
 * Function: InitLstnSock()
 *
 * Description: Get a stream socket, and start listening for 
 *  incoming connection requests.
 */
BOOL InitLstnSock(int iLstnPort, PSOCKADDR_IN pstSockName, 
  HWND hWnd, u_int nAsyncMsg)
{
  int nRet;
  SOCKET hLstnSock;
  int nLen = SOCKADDR_LEN;
  
  /* Get a TCP socket to use for data connection listen */
  hLstnSock = socket (AF_INET, SOCK_STREAM, 0);
  if (hLstnSock == INVALID_SOCKET)  {
    if (hInst) WSAperror(WSAGetLastError(), "socket()", hInst);
    else if(hf1) fprintf(hf1,"socket(): Error %d\n",WSAGetLastError());
  } else {
    /* Request async notification for most events */
    nRet = 0;
    if (hInst) {
      nRet = WSAAsyncSelect(hLstnSock, hWnd, nAsyncMsg, 
           (FD_ACCEPT | FD_READ | FD_WRITE | FD_CLOSE));
      if (nRet == SOCKET_ERROR) {
        WSAperror(WSAGetLastError(), "WSAAsyncSelect()", hInst);
      }
      
    }
    /* set the socket to async mode?
    else {
      nRet = ioctlsocket(hLstnSock,FIONBIO,&ionbio);
      if (nRet == SOCKET_ERROR) if(hf1) fprintf(hf1,"ioctlsocket(): Error %d\n",WSAGetLastError());
    } */
    if (nRet == 0) {
      /* Name the local socket with bind() */
      pstSockName->sin_family = PF_INET;
      pstSockName->sin_port   = (u_short) htons((u_short)iLstnPort);  
      nRet = bind(hLstnSock,(LPSOCKADDR)pstSockName,SOCKADDR_LEN);
      if (nRet == SOCKET_ERROR) {
	if (hInst) WSAperror(WSAGetLastError(), "bind()", hInst);
        else if(hf1) fprintf(hf1,"bind(): Error %d\n",WSAGetLastError());
      } else {

        /* Listen for incoming connection requests */
        nRet = listen(hLstnSock, 5);
        if (nRet == SOCKET_ERROR) {
          if (hInst) WSAperror(WSAGetLastError(), "listen()", hInst);
          else if(hf1) fprintf(hf1,"listen(): Error %d\n",WSAGetLastError());
        }
      }
    }
    /* If we had an error then we have a problem.  Clean up */
    if (nRet == SOCKET_ERROR) {
	  closesocket(hLstnSock);
	  hLstnSock = INVALID_SOCKET;
    }
  }
  return (hLstnSock);
} /* end InitLstnSock() */

/*--------------------------------------------------------------
 * Function: AcceptConn()
 *
 * Description: Accept an incoming connection request (this is
 *  called in response to an FD_ACCEPT event notification).
 */
SOCKET AcceptConn(SOCKET hLstnSock, PSOCKADDR_IN pstName)
{
  SOCKET hNewSock;
  int nRet, nLen = SOCKADDR_LEN;
  
  hNewSock = accept (hLstnSock, (LPSOCKADDR)pstName, (LPINT)&nLen);
  if (hNewSock == SOCKET_ERROR) {
    int WSAErr = WSAGetLastError();
    if (WSAErr != WSAEWOULDBLOCK) {
      if (hInst) WSAperror (WSAErr, "accept", hInst);
      else if(hf1) fprintf(hf1,"accept(): Error %d\n",WSAErr);
    }
  } else if (bReAsync) {
    /* This SHOULD be unnecessary, since all new sockets are supposed
     *  to inherit properties of the listening socket (like all the
     *  asynch events registered but some WinSocks don't do this.
     * Request async notification for most events */
    nRet=0;
    if (hInst) {
      nRet = WSAAsyncSelect(hNewSock, hWinMain, WSA_ASYNC, 
           (FD_READ | FD_WRITE | FD_CLOSE));
      if (nRet == SOCKET_ERROR) {
        WSAperror(WSAGetLastError(), "WSAAsyncSelect()", hInst);
      }
    }
    /* set the socket to async mode? */
    else {
      nRet = ioctlsocket(hNewSock,FIONBIO,&ionbio);
      if (nRet == SOCKET_ERROR) if(hf1) fprintf(hf1,"ioctlsocket(): Error %d\n",WSAGetLastError());
    }
    /* Try to get lots of buffer space */
    GetBuf(hNewSock, INPUT_SIZE, SO_RCVBUF);
    GetBuf(hNewSock, INPUT_SIZE, SO_SNDBUF);
  }
  return (hNewSock);
} /* end AcceptConn() */

/*--------------------------------------------------------------
 * Function: SendData()
 *
 * Description: Send data received back to client that sent it.
 */
int SendData(SOCKET hSock, LPSTR lpOutBuf, int cbTotalToSend)
{
  int cbTotalSent  = 0;
  int cbLeftToSend = cbTotalToSend;
  int nRet, WSAErr;

  /* Send as much data as we can */
  while (cbLeftToSend > 0) {
  
    /* Send data to client */
    nRet = send (hSock, lpOutBuf+cbTotalSent, 
      cbLeftToSend < MTU_SIZE ? cbLeftToSend : MTU_SIZE, 0);

    if (nRet == SOCKET_ERROR) {
      WSAErr = WSAGetLastError();
      /* Display significant errors, then close connection */
      if (WSAErr != WSAEWOULDBLOCK) {
        if(hInst) {
          WSAperror(WSAErr, (LPSTR)"send()", hInst);
          PostMessage(hWinMain, WSA_ASYNC, hSock, WSAMAKEASYNCREPLY(FD_CLOSE,0));
        } else {
	  if(hf1) fprintf(hf1,"send(): Error %d\n",WSAErr);
        }
	return (-1);
      }
      break;
    } else {
      /* Update byte counter, and display. */
      cbTotalSent += nRet;
    }
    /* calculate what's left to send */
    cbLeftToSend = cbTotalToSend - cbTotalSent; 
  }
  return (cbTotalSent);
} /* end SendData() */

/*--------------------------------------------------------------
 * Function: RecvData()
 *
 * Description: Receive data into buffer 
 */
int RecvData(SOCKET hSock, LPSTR lpInBuf, int cbTotalToRecv)
{
  int cbTotalRcvd = 0;
  int cbLeftToRecv = cbTotalToRecv;
  int nRet=0, WSAErr;

  /* Read as much as we can buffer from client */
  for (;;) {

    nRet = recv (hSock,lpInBuf+cbTotalRcvd, cbLeftToRecv, 0);
    if (nRet == SOCKET_ERROR) {
      socket_error:
      WSAErr = WSAGetLastError();
      /* Display significant errors */
      if (WSAErr == WSAECONNRESET) return 0; /* anyway: let the main loop close our side of the socket */
      if (WSAErr != WSAEWOULDBLOCK) {
	if (hInst) {
          WSAperror(WSAErr, (LPSTR)"recv()", hInst);
          PostMessage(hWinMain, WSA_ASYNC, hSock, WSAMAKEASYNCREPLY(FD_CLOSE,0));
	} else {
	  if(hf1) fprintf(hf1,"recv(): Error %d\n", WSAErr);
	}
      }
      else { //WSAEWOULDBLOCK -> inform clients by return value
	if (!cbTotalRcvd) return -2; // no data yet -> blocking
      }
      /* exit recv() loop on any error */
      break;
    } else if (nRet == 0) { /* Other side closed socket */
      /* quit if server closed connection */
      break;
    } else {
      /* Update byte counter */
      cbTotalRcvd += nRet;
    }
    cbLeftToRecv = cbTotalToRecv - cbTotalRcvd;
    if (!cbLeftToRecv) break;
    // we don't use non-blocking I/O, the first call succeeds from main, all subsequent ones must be caught
    // (although they should fail anyway, because all standard rmt_send's fit in one packet (-> .75ms only))
    readfds.fd_count=1; readfds.fd_array[0]=hSock;
    nRet = select(1,&readfds,NULL,NULL,&timeoutn);
    if (nRet == 0) break; // timeout
    if (nRet == SOCKET_ERROR) goto socket_error;
  }
  return (cbTotalRcvd);
} /* end RecvData() */

/*---------------------------------------------------------------
 * Function:NewConn()
 *
 * Description: Create a new socket structure and put in list
 */
LPCONNDATA NewConn (SOCKET hSock, PSOCKADDR_IN pstRmtName) {
  int nAddrSize = sizeof(SOCKADDR);
  LPCONNDATA lpstSockTmp, lpstSock = (LPCONNDATA)0;
  HLOCAL hConnData;

  /* Allocate memory for the new socket structure */
  hConnData = LocalAlloc (LMEM_ZEROINIT, sizeof(CONNDATA));
  
  if (hConnData != 0) {
    /* Lock it down and link it into the list */
    lpstSock = LocalLock(hConnData);
    
    if (!lpstSockHeadp[0]) {
      lpstSockHeadp[0] = lpstSock;
    } else {
      for (lpstSockTmp = lpstSockHeadp[0]; 
           lpstSockTmp && lpstSockTmp->lpstNext; 
           lpstSockTmp = lpstSockTmp->lpstNext);
      lpstSockTmp->lpstNext = lpstSock;
    }
  
    /* Initialize socket structure */
    lpstSock->hSock = hSock;
    _fmemcpy ((LPSTR)&(lpstSock->stRmtName), 
              (LPSTR)pstRmtName, sizeof(SOCKADDR));
    lpstSock->lStartTime = GetTickCount();
  } else {
    if(hWinMain) {
      MessageBox (hWinMain, "Unable allocate memory for connection",
        "LocalAlloc() Error", MB_OK | MB_ICONASTERISK);
    } else {
      if(hf1) fprintf(hf1,"Unable allocate memory for connection\n");
    }
  }
  return (lpstSock);
} /* end NewConn() */  

/*---------------------------------------------------------------
 * Function: FindConn()
 *
 * Description: Find socket structure for connection
 */
LPCONNDATA FindConn (SOCKET hSock) {
  LPCONNDATA lpstSockTmp;
  
  for (lpstSockTmp = lpstSockHeadp[0]; 
       lpstSockTmp;
       lpstSockTmp = lpstSockTmp->lpstNext) {
    if (lpstSockTmp->hSock == hSock)
      break;
  }
       
  return (lpstSockTmp);
} /* end FindConn() */  

/*---------------------------------------------------------------
 * Function: RemoveConn()
 *
 * Description: Free the memory for socket structure
 */
void RemoveConn (LPCONNDATA lpstSock) {
  LPCONNDATA lpstSockTmp;
  HLOCAL hSock;

  if (lpstSock == lpstSockHeadp[0]) {
    lpstSockHeadp[0] = lpstSock->lpstNext;
  } else {  
    for (lpstSockTmp = lpstSockHeadp[0]; 
         lpstSockTmp;
         lpstSockTmp = lpstSockTmp->lpstNext) {
      if (lpstSockTmp->lpstNext == lpstSock)
        lpstSockTmp->lpstNext = lpstSock->lpstNext;
    }     
  }
  hSock = LocalHandle(lpstSock);
  LocalUnlock (hSock);
  LocalFree (hSock);
} /* end RemoveConn() */  

