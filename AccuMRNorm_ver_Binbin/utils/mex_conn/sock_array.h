extern int initialized;
extern int console;

#include <winsockx.h>
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

#include <stim.h> // only reason: SOCK_BUF_SIZE
char ret_buf[SOCK_BUF_SIZE];
extern int ret_val;

/* sock_array variables:
sock_array[0]  hf0 (console input)
sock_array[1]  hf1 (console output)
               hf2 (console error, not used outside open_con...)
sock_array[2]  inbuf (input buffer for console input)
sock_array[3]  outbuf (output buffer for console output, normally not used, since output never really blocks, so use hf1)
sock_array[4]  tcl_rcv (network socket input buffer)
sock_array[5]  tcl_rep (network socket output buffer)
sock_array[6]  lpstSockHeadp (network socket list)
sock_array[7]  current network socket
sock_array[8]  waitHandle (to cancel network i/o gracefully)
sock_array[9]  console terminal handle in open_console and read_console
sock_array[10] switches input from main thread read_console in read_console (disabled(-2) from open_conn)
sock_array[11] acknowledges the switch of the input control to read_console
sock_array[12] requests all clients to close connection(s) and exits main conn thread
sock_array[13] current network socket in case of socket close request (0 otherwise)
*/


extern FILE *hf0,*hf1,*hf2;
extern char inbuf[];
extern char outbuf[];
extern char tcl_rcv[];
extern char tcl_rep[];
extern LPCONNDATA *lpstSockHeadp;
extern SOCKET curr_sock;
extern HANDLE waitHandle;
extern HANDLE inHandle;
extern SOCKET kill_sock;
extern int control_request;
extern int control_ack;
extern int close_request;
extern struct timeval timeoutr;
extern struct timeval timeoutw;

/* function prototypes */
char * read_conn();
int write_conn();
