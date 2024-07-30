/*
 *  essnetapi.h
 *
 *  PURPOSE : To dispatch event message via TCP/IP network
 *  NOTES   : byte-ordering is not cared at all.
 *            so, essaging will work only between intel-intel machines.
 *  In WIN32, SOCKET is u_int and INVALID_SOCKE=4294967295(ulong_max)
 *  In Unix,  socket handle is int and INVALID_SOCKET=-1
 *
 *  VERSION : 1.00  01-Aug-02  Yusuke MURAYAMA, MPI
 *            1.03  07-Aug-02  YM, supports c++
 *            1.04  07-Aug-02  YM, modify enet_select()
 *            1.05  09-Aug-02  YM, enet_rmt_send() for stim
 *            1.06  10-Aug-02  YM, DLL export/import
 *            1.07  15-Aug-02  YM, enet_wait()
 */

#ifndef _ESSNETAPI_H_INCLUDED
#define _ESSNETAPI_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

#if defined (_WIN32) || defined (_WIN64)
#  define WIN32_LEAN_AND_MEAN
#  define WIN64_LEAN_AND_MEAN
#  include <winsock2.h>    // SOCKET
#  define NETSOCKET_ERRORNUM WSAGetLastError()
#  define SHUT_RD   SD_RECEIVE
#  define SHUT_WR   SD_SEND
#  define SHUT_RDWR SD_BOTH
#  define SHUT_RW   SD_BOTH
#  if defined (NETAPI_EXPORT)
#  define NETAPI __declspec(dllexport)
#  elif defined (NETAPI_IMPORT)
#  define NETAPI __declspec(dllimport)
#  else
#  define NETAPI
#  endif
#else
#  include <sys/select.h>  // fd_set
#  define NETSOCKET_ERRORNUM errno
#  define INVALID_SOCKET -1
#  define SOCKET_ERROR   -1
#  define closesocket(s)  close(s)
   typedef int SOCKET;
   typedef struct in_addr IN_ADDR;
   typedef struct sockaddr_in SOCKADD_IN;
#  if defined (NETAPI_EXPORT)
#  define NETAPI
#  elif defined (NETAPI_IMPORT)
#  define NETAPI extern
#  else
#  define NETAPI
#  endif
#endif

// default server port
#define STIM_PORT        4610
#define WINSTREAMER_PORT 4612
#define ESSMAILER_PORT   4622
// socket buffer size for stim
#define STIM_BUFF_SIZE   16384

// message magic tags
#define ENETTAG_ESSEVENT      10
#define ENETTAG_WINSTREAMER   20
// message type/subtype for winstreamer
#define WSTYPE_QUERY_VALUE  130
#define WSTYPE_QUERY_RETURN 131
#define WSTYPE_SET_VALUE    140
#define WSTYPE_SET_RETURN   141
#define WSTYPE_LOGIN        142
#define WSTYPE_LOGOUT       143
#define WSTYPE_WAVEDATA     144
#define WSSUBT_SAMP_RATE    11
#define WSSUBT_SCAN_RATE    12
#define WSSUBT_CHAN_GAIN    13
#define WSSUBT_NUM_MAXCHANS 14
#define WSSUBT_NUM_RECHANS  15
#define WSSUBT_RECCHANS     16
#define WSSUBT_FILEOPEN     21
#define WSSUBT_FILECLOSE    22

// socket blocking modes
enum { ENET_BLOCKING_MODE, ENET_NONBLOCKING_MODE };

#pragma pack(1)
typedef struct enet_msgheader {
  short magic;        // message tag
  short type;         // type
  short subtype;      // subtype
  short datatype;     // data type
  double timestamp;   // time stamp
  long nelements;     // nelements of data
  long nbytes;        // data size in bytes
} ENET_MSGHEADER;
#pragma pack()

#if !defined (EVENTAPI_H_INCLUDED)
typedef struct {
	char type;          //event type
	char subtype;       //event subtype
	char timestamp[8];	//string, double *, float * or long * per metadata
	char puttype;       //datatype of this event's parameters
	char ndata;         //number of bytes in following data
} EVT_EVENT;          //event header
typedef enum {
    PUT_unknown,  //unknown or complex variable data, evt_put fails
    PUT_null,     //no variable data to evt_put
    PUT_string,   //evt_put variable args are chars (NUL terminated)
    PUT_short,    //evt_put variable args are shorts
    PUT_long,     //evt_put variable args are longs
    PUT_float,    //evt_put variable args are floats
    PUT_double,   //evt_put variable args are doubles
    PUT_TYPES
} PUT_TYPE;
#  define evdatap(ev)	((char *)ev+sizeof(EVT_EVENT))
#endif

// global variables //////////////////////////////////////////////////
extern NETAPI int enet_stim_port;           // stim server port
extern NETAPI int enet_ws_port;             // winstreamer server port

// prototypes ////////////////////////////////////////////////////////
NETAPI int    enet_startup(void);
NETAPI int    enet_cleanup(void);
// server functions
NETAPI SOCKET enet_server_open(int port);
NETAPI void   enet_server_close(SOCKET server);
NETAPI int    enet_server_listen(SOCKET server);
NETAPI int    enet_server_select(SOCKET server, long timeout_msec);
NETAPI SOCKET enet_server_accept(SOCKET server);
// client functions
NETAPI SOCKET enet_connect(char *hostname, int port);
NETAPI void   enet_close(SOCKET sock);
NETAPI int    enet_select(SOCKET sock, fd_set *pfr, fd_set *pfw, long timeout_msec);
NETAPI int    enet_ready(SOCKET sock, long timeout_msec);
NETAPI int    enet_readable(SOCKET sock, long timeout_msec);
NETAPI int    enet_writable(SOCKET sock, long timeout_msec);
NETAPI int    enet_recv(SOCKET sock, char *buf, int len, int flags);
NETAPI int    enet_send(SOCKET sock, char *buf, int len, int flags);
NETAPI void   enet_msg_setevent(EVT_EVENT *e, ENET_MSGHEADER *pmsgh, void *pdata);
NETAPI int    enet_msg_recv(SOCKET sock, ENET_MSGHEADER *pmsgh, void *pdata);
NETAPI int    enet_msg_send(SOCKET sock, ENET_MSGHEADER *pmsgh, void *pdata);
NETAPI void   enet_msg_print(ENET_MSGHEADER *pmsgh);
// misc.
NETAPI int    enet_blocking_mode(SOCKET sock, int mode);
NETAPI int    enet_nodelay(SOCKET sock, int nodelay);
NETAPI int    enet_buffersize(SOCKET sock, int buftype, int nbuf);
#if defined(_WINDOWS_)
NETAPI int    enet_set_async_event(SOCKET sock, HWND hWnd, unsigned int wMsg, long lEvent);
#else
NETAPI int    enet_set_async_signal(SOCKET sock, void (* evtfunc)(int));
#endif
NETAPI int    enet_get_error(void);
NETAPI int    enet_hostaddr(char *addr, char *name);
NETAPI int    enet_hostname(char *name, char *addr);
NETAPI void   enet_wait(int msec);
// stim communication
NETAPI char  *enet_rmt_send(char *server, char *format, ...);
NETAPI char  *enet_rmt_sendex(char *server, int tout, char *format, ...);
// winstreamer functions
NETAPI int    enet_ws_fileopen(char *server, char *fname);
NETAPI int    enet_ws_fileclose(char *server);
NETAPI int    enet_ws_set(char *server, int what, void *pdata);
NETAPI int    enet_ws_query(char *server,int what, void *pdata);
NETAPI SOCKET enet_ws_login(char *server);
NETAPI void   enet_ws_logout(SOCKET sock);
// for compatibility
#define winstreamer_fileOpen(a,b)  enet_ws_fileopen(a,b)
#define winstreamer_fileClose(a)   enet_ws_fileclose(a)

#ifdef __cplusplus
}
#endif

#endif  // end of _ESSNETAPI_H_INCLUDED
