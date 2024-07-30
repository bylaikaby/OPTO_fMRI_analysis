/*
 *  essnetapi.c : 
 *
 *  PURPOSE : To dispatch event message via TCP/IP network
 *  NOTES   : byte-ordering is not cared at all.
 *            so, essaging will work only between intel-intel machines.
 *
 *  VERSION : 1.00  01-Aug-02  Yusuke MURAYAMA, MPI
 *            1.05  08-Aug-02  YM, modify enet_select()
 *            1.06  09-Aug-02  YM, ent_rmt_send()
 *            1.07  10-Aug-02  YM, DLL export/import
 *            1.08  15-Oct-02  YM, enet_wait, modified enet_ws_fileclose()
 *            1.09  11-May-03  YM, use winsock2 (ws2_32.lib, ws2_32.dll).
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>  // memcpy
#include <stdarg.h>  // Access variable-argument lists

#if defined (_WIN32)
// for windows95, apply SP1 and install ws2_32.dll to support winsock2.
//#  pragma comment(lib, "wsock32.lib")
#  pragma comment(lib, "ws2_32.lib")
#elif defined (_WIN64)
// ??? who knows ???
#  pragma comment(lib, "ws2_64.lib")
#else
#  include <unistd.h>
#  include <unix.h>
#  include <signal.h>      // signal()
#  include <ioctl.h>       // ioctl()
#  include <netdb.h>
#  include <errno.h>
#  include <time.h>        // nanosleep()
#  include <sys/time.h>
#  include <sys/socket.h>  // socket
#  include <sys/types.h>   // socket
#  include <netinet/in.h>
#  include <netinet/tcp.h> // TCP_NODELAY
#  include <arpa/inet.h>
#endif

#if defined (__QNX__)
#  include <eventapi.h>
#  include <rtcapi.h>
#  include <sys/time.h>    // nanosleep()
#endif

#include "essnetapi.h"

#if !defined (EVENTAPI_H_INCLUDED)
#endif

#if !defined (RTCAPI_H_INCLUDED)
#  define rtc_ms(a)  0
#endif


/////////////////////////////////////////////////////////////
// global variables  ////////////////////////////////////////
char *gDataTypeStr[] = {
  "unknown", "null", "string", "short", "long", "float", "double" 
};
static int enet_initialized = 0;
NETAPI int enet_stim_port   = STIM_PORT;
NETAPI int enet_ws_port     = WINSTREAMER_PORT;


/////////////////////////////////////////////////////////////
// initialize network interface /////////////////////////////
NETAPI int enet_startup()
{
  int status = 0;
#if defined (_WINDOWS_)
  WORD wVersionRequested;
  WSADATA wsa;
#endif

  if (enet_initialized)  return status;
#if defined (_WINDOWS_)
  // win95 w/o update = winsock v1.1
  wVersionRequested = MAKEWORD(2,2);    // version 2.2
  status = WSAStartup(wVersionRequested, &wsa);
  if (status != 0) {
    if (status == WSAVERNOTSUPPORTED)  WSACleanup();
    return status;
  }
#endif

  if (status == 0)  enet_initialized = 1;

  return status;
}

NETAPI int enet_cleanup()
{
  int status = 0;

  if (enet_initialized == 0)  return 0;
#if defined (_WINDOWS_)
  status = WSACleanup();
#endif
  if (status == 0)  enet_initialized = 0;

  return status;
}

// enet_xxx server functions ////////////////////////////////
// open the server
NETAPI SOCKET enet_server_open(int port)
{
  SOCKET server = INVALID_SOCKET;
  int status;
  struct sockaddr_in saddrin;
#if defined(USE_ASYNC_IO)
  int on;
  pid_t pgrp;
#endif

  // open the socket
  server = socket(AF_INET, SOCK_STREAM, 0);
  if (server == INVALID_SOCKET)  return INVALID_SOCKET;
  
  // bind the socket
  saddrin.sin_family = AF_INET;
  saddrin.sin_addr.s_addr = INADDR_ANY;
  saddrin.sin_port = htons((short)port);
  status = bind(server, (struct sockaddr *)&saddrin, sizeof(saddrin));
  if (status < 0) {
    closesocket(server);  return INVALID_SOCKET;
  }

  return server;
}

// close the server
NETAPI void enet_server_close(SOCKET server)
{
  closesocket(server);
}

// listen to client connections
NETAPI int enet_server_listen(SOCKET server)
{
  return listen(server,5);
}

// check whether connection request from client
NETAPI int enet_server_select(SOCKET server, long timeout_msec)
{
  int status;
  struct timeval tout, *ptout;
  fd_set fds;

  if (timeout_msec < 0) {
    tout.tv_sec = -1;  tout.tv_usec = -1;
    ptout = NULL;
  } else {
    tout.tv_sec = timeout_msec / 1000L;
    tout.tv_usec = (timeout_msec%1000L)*1000L;
    ptout = &tout;
  }

  FD_ZERO(&fds);
  FD_SET(server, &fds);

#if defined(_WINDOWS_)
  status = select(0, &fds, NULL, NULL, ptout);
#else
  status = select(server+1, &fds, NULL, NULL, ptout);
#endif

  if (status < 0)  return -1;
  if (!FD_ISSET(server,&fds))  return -2;

  return status;
}

// accept connection
NETAPI SOCKET enet_server_accept(SOCKET server)
{
  SOCKET newsock;
  struct sockaddr_in from;
  int len;

  // accept a new socket
  newsock = accept(server,(struct sockaddr *)&from,&len);

  return newsock;
}


// client functions ///////////////////////////////////////////////////
// connect to the server
NETAPI SOCKET enet_connect(char *hostname, int port)
{
  SOCKET sock = INVALID_SOCKET;
  struct hostent *pHost;
  struct sockaddr_in saddrin;

  memset((char *)&saddrin, 0, sizeof(saddrin));

  // query server info
  pHost = gethostbyname(hostname);
  if (pHost == NULL)  return INVALID_SOCKET;

  saddrin.sin_family = AF_INET;
  //memcpy(&saddrin.sin_addr, pHost->h_addr, sizeof(saddrin.sin_addr));
  saddrin.sin_addr.s_addr = (*(unsigned long *)(pHost->h_addr));
  saddrin.sin_port = htons((short)port);

  // open the socket
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock == INVALID_SOCKET)  return INVALID_SOCKET;

  if (connect(sock,(struct sockaddr *)&saddrin,sizeof(saddrin)) < 0) {
    closesocket(sock);  return INVALID_SOCKET;
  }
  
  return sock;
}

// close the socket
NETAPI void enet_close(SOCKET sock)
{
  closesocket(sock);
}

// check data-ready, useful in non-blocking mode
NETAPI int enet_select(SOCKET sock, fd_set *pfr, fd_set *pfw, long timeout_msec)
{
  struct timeval tout, *ptout;
  int status;

  if (timeout_msec < 0) {
    ptout = NULL;
  } else {
    tout.tv_sec = timeout_msec / 1000L;
    tout.tv_usec = (timeout_msec%1000L)*1000L;
    ptout = &tout;
  }

  if (pfr != NULL) {
    FD_ZERO(pfr);  FD_SET(sock,pfr);
  }
  if (pfw != NULL) {
    FD_ZERO(pfw);  FD_SET(sock,pfw);
  }

#if defined(_WINDOWS_)
  status = select(0, pfr, pfw, NULL, ptout);
#else
  status = select(sock+1, pfr, pfw, NULL, ptout);
#endif
  
  return status;
}

// check data-ready, useful in non-blocking mode
NETAPI int enet_ready(SOCKET sock, long timeout_msec)
{
  int status;
  fd_set rfds, wfds;
  
  switch (enet_select(sock,&rfds,&wfds,timeout_msec)) {
  case 0:
    status = 0;  break;
  case SOCKET_ERROR:
    status = -1;  break;
  default:
    status = 1;  break;
  }
  return status;
}

NETAPI int enet_readable(SOCKET sock, long timeout_msec)
{
  int status;
  fd_set fds;

  switch (enet_select(sock,&fds,NULL,timeout_msec)) {
  case 0:
    status = 0;  break;
  case SOCKET_ERROR:
    status = -1;  break;
  default:
    status = 1;  break;
  }
  return status;
}

NETAPI int enet_writable(SOCKET sock, long timeout_msec)
{
  int status;
  fd_set fds;

  switch (enet_select(sock,NULL,&fds,timeout_msec)) {
  case 0:
    status = 0;  break;
  case SOCKET_ERROR:
    status = -1;  break;
  default:
    status = 1;  break;
  }
  return status;
}

// recv data
NETAPI int enet_recv(SOCKET sock, char *buf, int len, int flags)
{
  int bcount, bread;

  bcount = bread = 0;
  while (bcount < len) {
    bread = recv(sock, buf, len-bcount, flags);
    if (bread > 0) {
      bcount += bread;
      buf += bread;
    } else if (bread == 0) {
      return bcount;
    } else {
      return SOCKET_ERROR;
    }
  }
  //printf(" brecv=%d/%d ",bcount,len);
  
  return bcount;
}

// send data
NETAPI int enet_send(SOCKET sock, char *buf, int len, int flags)
{
  int bcount, bwrite;

  bcount = bwrite = 0;
  while (bcount < len) {
    bwrite = send(sock,buf,len-bcount,flags);
    if (bwrite > 0) {
      bcount += bwrite;
      buf += bwrite;
    } else if (bwrite == 0) {
      return bcount;
    } else {
      return SOCKET_ERROR;
    }
  }

  return bcount;
}


// messaging functions ////////////////////////////////////////////////
// make a message from EVT_EVENT
NETAPI void enet_msg_setevent(EVT_EVENT *e, ENET_MSGHEADER *pmsgh, void *pdata)
{
  // prepare a message
  pmsgh->magic     = (short)ENETTAG_ESSEVENT;
  pmsgh->type      = (short)e->type;
  pmsgh->subtype   = (short)e->subtype;
  pmsgh->datatype  = (short)e->puttype;
  pmsgh->timestamp = rtc_ms((RTC_TIME *)e->timestamp);
  pmsgh->nbytes    = (long)e->ndata;

  if (pmsgh->nbytes > 0) {
    memcpy(pdata,evdatap(e),pmsgh->nbytes);
    switch (e->puttype) {
    case PUT_string:
      pmsgh->nelements = 1;  break;
    case PUT_short:
      pmsgh->nelements = pmsgh->nbytes/sizeof(short);   break;
    case PUT_long:
      pmsgh->nelements = pmsgh->nbytes/sizeof(long);    break;
    case PUT_float:
      pmsgh->nelements = pmsgh->nbytes/sizeof(float);   break;
    case PUT_double:
      pmsgh->nelements = pmsgh->nbytes/sizeof(double);  break;
    case PUT_null:
    case PUT_unknown:
    default:
      pmsgh->nelements = 0;  pmsgh->nbytes = 0;
      break;
    }
  } else {
    pmsgh->nelements = 0;  pmsgh->nbytes = 0;
  }
  return;
}

// receive a message
NETAPI int enet_msg_recv(SOCKET sock, ENET_MSGHEADER *pmsgh, void *pdata)
{
  int brecv;
  char *cbuff;
  
  brecv = enet_recv(sock,(char *)pmsgh,sizeof(ENET_MSGHEADER),0);
  //printf(" brecv1=%d/%d ",brecv,sizeof(ENET_MSGHEADER));
  
  if (brecv != sizeof(ENET_MSGHEADER))  return -1;
  
  if (pmsgh->nelements > 0 && pmsgh->nbytes > 0) {
    cbuff = (char *)pdata;
    brecv = enet_recv(sock,cbuff,pmsgh->nbytes,0);
    //printf(" brecv2=%d/%d ",brecv,(int)pmsgh->nbytes);
    if (brecv != pmsgh->nbytes)   return -2;
  } else if (pmsgh->nelements != 0 || pmsgh->nbytes != 0) {
    return -3;
  }

  return 0;
}

// send a message
NETAPI int enet_msg_send(SOCKET sock, ENET_MSGHEADER *pmsgh, void *pdata)
{
  int bsend;

  //enet_msg_print(pmsgh);
  
  bsend = enet_send(sock,(char *)pmsgh,sizeof(ENET_MSGHEADER),0);
  //printf(" bsend1=%d/%d ",bsend,sizeof(ENET_MSGHEADER));
  if (bsend != sizeof(ENET_MSGHEADER))  return -1;

  if (pmsgh->nbytes == 0)  return 0;
  bsend = enet_send(sock,(char *)pdata,pmsgh->nbytes,0);
  //printf(" bsend2=%d/%d ",bsend,(int)pmsgh->nbytes);
  if (bsend != pmsgh->nbytes)  return -2;

  return 0;
}

// prints the message
NETAPI void enet_msg_print(ENET_MSGHEADER *pmsgh)
{
  printf("\n %.lf: %3d.%3d  %8s  %3ld  %ld ",pmsgh->timestamp,
         (unsigned char)pmsgh->type, (unsigned char)pmsgh->subtype,
         gDataTypeStr[pmsgh->datatype],
         pmsgh->nelements, pmsgh->nbytes);
}



// misc. functions ////////////////////////////////////////////////////
// change socket's blocking mode
int enet_blocking_mode(SOCKET sock, int mode)
{
  int status;
#if defined (_WINDOWS_)
  unsigned long b;
  b = (unsigned long)mode;
  status = ioctlsocket(sock, FIONBIO, &b);
#else
  status = ioctl(sock,FIONBIO,&mode);

#  if 0
  int flags;
  if (-1 == (flags = fcntl(m_socket, F_GETFL, 0)))  flags = 0;
  if (mode == ENET_BLOCKING_MODE) {
    flags = flags & ~O_NONBLOCK;
  } else {
    flags = flags | O_NONBLOCK;
  }
  status = fcntl(m_socket, F_SETFL, flags);
#  endif

#endif

  return status;
}

// set/unset the flag for Nagle algorithm
NETAPI int enet_nodelay(SOCKET sock, int nodelay)
{
  return setsockopt(sock,IPPROTO_TCP,TCP_NODELAY,(char *)&nodelay,sizeof(int));
}

// change buffer size
NETAPI int enet_buffersize(SOCKET sock, int buftype, int nbuf)
{
  int status, nallocated = 0;
  
  if (nbuf > 2048) {
    status = setsockopt(sock,SOL_SOCKET,buftype,(char *)&nbuf,sizeof(int));
    if (status == SOCKET_ERROR)  return SOCKET_ERROR;
  }
  status = sizeof(int);
  getsockopt(sock,SOL_SOCKET,buftype,(char *)&nallocated,&status);

  return nallocated;
}

// set callback of asynchronous events
#if defined(_WINDOWS_)
NETAPI int enet_set_async_event(SOCKET sock, HWND hWnd, unsigned int wMsg, long lEvent)
{
  return WSAAsyncSelect(sock, hWnd, wMsg, lEvent);
}
#else
NETAPI int enet_set_async_signal(SOCKET sock, void (* evtfunc)(int))
{
  int on;
  // set the process receiving SIGIO.SIGURG to us
  signal(SIGIO, evtfunc);
  if (evtfunc != NULL)  on = 1;
  else                  on = 0;
  // allow receipt of aynchronous io signals
  if (ioctl(sock,FIOASYNC,&on) < 0) {
    signal(SIGIO,SIG_DFL);  return -1;
  }
  return 0;
}
#endif

// get error
NETAPI int enet_get_error()
{
  return NETSOCKET_ERRORNUM;
}

// get IPaddress from hostname
NETAPI int enet_hostaddr(char *addr, char *name)
{
  struct hostent *pHost = NULL;
  struct in_addr inaddr;
  char tmphost[128];
 
  if (addr == NULL)  return SOCKET_ERROR;

  addr[0] = '\n';
  if (name == NULL) {
    gethostname(tmphost,64);
    pHost = gethostbyname(tmphost);
   } else {
    pHost = gethostbyname(name);
  }
  if (pHost == NULL)  return SOCKET_ERROR;

  inaddr.s_addr = (unsigned long)(*(unsigned long *)(pHost->h_addr));
  sprintf(addr,"%s",inet_ntoa(inaddr));

  return 0;  
}

// get hostname from IPaddress
NETAPI int enet_hostname(char *name, char *addr)
{
  struct hostent *pHost = NULL;
  struct in_addr inaddr;
  char tmphost[128];

  if (name == NULL)  return SOCKET_ERROR;

  name[0] = '\0';
  if (addr == NULL) {
    gethostname(tmphost,64);
    pHost = gethostbyname(tmphost);
   } else {
    inaddr.s_addr = inet_addr(addr);
    pHost = gethostbyaddr(inet_ntoa(inaddr),4, AF_INET);
  }

  if (pHost == NULL)  return SOCKET_ERROR;
  sprintf(name, "%s", pHost->h_name);

  return 0;
}

// wait function
NETAPI void enet_wait(int msec)
{
#if defined(_WINDOWS_)
  Sleep((DWORD)msec);
#else
  struct timespec tspec;
  tspec.tv_sec = (long)(msec/1000);
  tspec.tv_nsec = 1000L*(long)(msec%1000);
  nanosleep(&tspec,NULL);
#endif

  return;
}


// stim communication ///////////////////////////////////////
NETAPI char *enet_rmt_send(char *server, char *format,...) 
{
  static char buff[16384];
  char *eol;
  int nbytes,status;
  SOCKET sock;

  va_list arglist;
  va_start(arglist, format);
  vsprintf(buff, format, arglist);
  va_end(arglist);

	nbytes = strlen(buff) - 1;
	if (buff[nbytes] != '\n') {
		buff[nbytes+1] = '\n';
		buff[nbytes+2] = '\0';
	}

  // connect, set as blocking mode
  sock = enet_connect(server,enet_stim_port);
  if (sock == INVALID_SOCKET)  return NULL;
  // send
  nbytes = strlen(buff);
  status = enet_send(sock,buff,nbytes,0);
  if (status != nbytes) {
    enet_close(sock);  return NULL;
  }
  // set as non-blocking mode
  enet_blocking_mode(sock, ENET_NONBLOCKING_MODE);
  // is data ready ?, wait forever.
  if (enet_readable(sock,-1) <= 0) {
    enet_close(sock);  return NULL;
  }
  // recv
  buff[0] = '\0';
  nbytes = recv(sock,buff,4096,0);
  // close socket
  enet_close(sock);

  if (nbytes <= 0)  return NULL;
  buff[nbytes-1] = '\0';
  if (eol = strrchr(buff,'\n')) *eol = 0;
  if (eol = strrchr(buff,'\r')) *eol = 0;

  return buff;
}

NETAPI char *enet_rmt_sendex(char *server, int tout, char *format,...) 
{
  static char buff[16384];
  char *eol;
  int nbytes,sockcnt,status;
  SOCKET sock;

  va_list arglist;
  va_start(arglist, format);
  vsprintf(buff, format, arglist);
  va_end(arglist);

	nbytes = strlen(buff) - 1;
	if (buff[nbytes] != '\n') {
		buff[nbytes+1] = '\n';
		buff[nbytes+2] = '\0';
	}

  // connect, set as non-blocking mode
  sock = enet_connect(server,enet_stim_port);
  if (sock == INVALID_SOCKET)  return NULL;
  enet_blocking_mode(sock, ENET_NONBLOCKING_MODE);
  // send
  nbytes = strlen(buff);
  status = enet_send(sock,buff,nbytes,0);
  if (status != nbytes) {
    enet_close(sock);  return NULL;
  }
  // is data ready ?,
  if (enet_readable(sock,tout) <= 0) {
    enet_close(sock);  return NULL;
  }
  // recv
  buff[0] = '\0';
  nbytes = recv(sock,buff,4096,0);
  // close socket
  enet_close(sock);

  if (nbytes <= 0)  return NULL;
  buff[nbytes-1] = '\0';
  if (eol = strrchr(buff,'\n')) *eol = 0;
  if (eol = strrchr(buff,'\r')) *eol = 0;

  return buff;
}


// winstreamer control //////////////////////////////////////
// open datafile
NETAPI int enet_ws_fileopen(char *server, char *fname) 
{
  int sock, nbytes;
  ENET_MSGHEADER *pmsgh;
  char buf[256];

  // init message
  pmsgh = (struct enet_msgheader *)buf;
  pmsgh->magic     = (short)ENETTAG_WINSTREAMER;
  pmsgh->type      = (short)WSTYPE_SET_VALUE;
  pmsgh->subtype   = (short)WSSUBT_FILEOPEN;
  pmsgh->datatype  = (short)PUT_string;
  pmsgh->timestamp = 0.0;
  pmsgh->nelements = 1;
  pmsgh->nbytes = strlen(fname) + 1;  // includes a NULL terminator
  sprintf(&buf[sizeof(ENET_MSGHEADER)],"%s",fname);
  nbytes = sizeof(ENET_MSGHEADER) + pmsgh->nbytes;

  sock = enet_connect(server,enet_ws_port);
  if (sock == INVALID_SOCKET)  return -1;
  if (enet_send(sock,buf,nbytes,0) != nbytes) {
    enet_close(sock);
    return -2;
  }
  enet_close(sock);
  
  return 1;
}

// close datafile
NETAPI int enet_ws_fileclose(char *server)
{
  int sock, nbytes;
  ENET_MSGHEADER *pmsgh;
  char buf[256];

  // init message
  pmsgh = (struct enet_msgheader *)buf;
  pmsgh->magic     = (short)ENETTAG_WINSTREAMER;
  pmsgh->type      = (short)WSTYPE_SET_VALUE;
  pmsgh->subtype   = (short)WSSUBT_FILECLOSE;
  pmsgh->datatype  = (short)PUT_null;
  pmsgh->timestamp = 0.0;
  pmsgh->nelements = 0;
  pmsgh->nbytes = 0;
  nbytes = sizeof(ENET_MSGHEADER) + pmsgh->nbytes;

  sock = enet_connect(server,enet_ws_port);
  if (sock == INVALID_SOCKET)  return -1;
  if (enet_send(sock,buf,nbytes,0) != nbytes) {
    enet_close(sock);
    return -2;
  }
  enet_close(sock);

  // wait a little to make WinStreamer to write the last data safely.
  enet_wait(500);
  
  return 1;
}

// set some values, not fully implemented yet 06-Aug-02 YM
NETAPI int enet_ws_set(char *server, int what, void *pdata)
{
  int sock, nbytes;
  ENET_MSGHEADER *pmsgh;
  char buf[256];

  // init message
  pmsgh = (struct enet_msgheader *)buf;
  pmsgh->magic     = (short)ENETTAG_WINSTREAMER;
  pmsgh->type      = (short)WSTYPE_SET_VALUE;
  pmsgh->subtype   = (short)what;
  pmsgh->datatype  = (short)PUT_null;
  pmsgh->timestamp = 0.0;
  pmsgh->nelements = 0;
  pmsgh->nbytes    = 0;
  nbytes = sizeof(ENET_MSGHEADER) + pmsgh->nbytes;
  
  // send request
  sock = enet_connect(server,enet_ws_port);
  if (sock == INVALID_SOCKET)  return -2;
  if (enet_send(sock,buf,nbytes,0) != nbytes) {
    enet_close(sock);
    return -3;
  }
#if 0  // not supported yet, should modify winstreamer codes
  // receive reply
  if (enet_msg_recv(sock,pmsgh,pdata) < 0) {
    enet_close(sock);
    return -4;
  }
#endif
  enet_close(sock);

  return 1;
}

// get some information
NETAPI int enet_ws_query(char *server, int what, void *pdata)
{
  int sock, nbytes;
  ENET_MSGHEADER *pmsgh;
  char buf[256];

  // init message
  pmsgh = (struct enet_msgheader *)buf;
  pmsgh->magic     = (short)ENETTAG_WINSTREAMER;
  pmsgh->type      = (short)WSTYPE_QUERY_VALUE;
  pmsgh->subtype   = (short)what;
  pmsgh->datatype  = (short)PUT_null;
  pmsgh->timestamp = 0.0;
  pmsgh->nelements = 0;
  pmsgh->nbytes    = 0;
  nbytes = sizeof(ENET_MSGHEADER) + pmsgh->nbytes;
  
  // send request
  sock = enet_connect(server,enet_ws_port);
  if (sock == INVALID_SOCKET)  return -2;
  if (enet_send(sock,buf,nbytes,0) != nbytes) {
    enet_close(sock);
    return -3;
  }
  // receive reply
  if (enet_msg_recv(sock,pmsgh,pdata) < 0) {
    enet_close(sock);
    return -4;
  }
  enet_close(sock);

  return 1;
}

// login to the winstreamer to get waveform constantly
NETAPI SOCKET enet_ws_login(char *server)
{
  int sock, nbytes;
  ENET_MSGHEADER *pmsgh;
  char buf[256];

  // init message
  pmsgh = (struct enet_msgheader *)buf;
  pmsgh->magic     = (short)ENETTAG_WINSTREAMER;
  pmsgh->type      = (short)WSTYPE_LOGIN;
  pmsgh->subtype   = 0;
  pmsgh->datatype  = (short)PUT_null;
  pmsgh->timestamp = 0.0;
  pmsgh->nelements = 0;
  pmsgh->nbytes    = 0;
  nbytes = sizeof(ENET_MSGHEADER) + pmsgh->nbytes;

  sock = enet_connect(server,enet_ws_port);
  if (sock == INVALID_SOCKET)  return INVALID_SOCKET;

  // 1024*1024/21kHz(pts/sec)*16chans*2bytes=1.56sec
  enet_buffersize(sock,SO_RCVBUF,1024*1024);

  if (enet_send(sock,buf,nbytes,0) != nbytes) {
    enet_close(sock);
    return INVALID_SOCKET;
  }

  return sock;
}

// logout from the winstreamer
NETAPI void enet_ws_logout(SOCKET sock)
{
  int nbytes;
  ENET_MSGHEADER *pmsgh;
  char buf[256];

  if (sock == INVALID_SOCKET)  return;

  // init message
  pmsgh = (struct enet_msgheader *)buf;
  pmsgh->magic      = (short)ENETTAG_WINSTREAMER;
  pmsgh->type       = (short)WSTYPE_LOGOUT;
  pmsgh->subtype    = 0;
  pmsgh->datatype   = (short)PUT_null;
  pmsgh->timestamp  = 0.0;
  pmsgh->nelements  = 0;
  pmsgh->nbytes     = 0;
  nbytes = sizeof(ENET_MSGHEADER) + pmsgh->nbytes;

  if (enet_writable(sock,0))  enet_send(sock,buf,nbytes,0);
  enet_close(sock);

  return;
}



#if defined (_WINDOWS_) && defined (NETAPI_EXPORT)
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
