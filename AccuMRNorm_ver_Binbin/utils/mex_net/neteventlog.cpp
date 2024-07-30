/*
 * neteventlog.cpp
 * 
 * NOTES : This mex uses threads to perform continuous streaming of
 *         incoming data. BUT current Matlab (R12) is a single-thread
 *         application, meaning not thread-safe. As far as i tested,
 *         mexEvalString(), mexCallMATLAB() crash the Matlab.
 *
 * To compile this mex link thread-safe library,
 *   >>mex neteventlog.cpp libcmt.lib -D_MT
 *
 * ver.
 *   1.00  07-Aug-2002  Yusuke MURAYAMA, MPI
 *   1.01  08-Aug-2002  YM
 *   1.02  11-Aug-2002  YM, bug fix of data recv for PUT_string
 *   1.03  12-Aug-2002  YM, bug fix of logout
 *   1.04  15-Oct-2002  YM, disable pragma comment(lib,"libcmt.lib") for complation in Matlab R13
 *   1.05  24-Sep-2013  YM, use 'int' not 'long', for x86/x64 compatibility.
 */

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <string.h>

#if defined (_WIN32) || defined (_WIN64)
#  define  WIN32_LEAN_AND_MEAN
#  define  WIN64_LEAN_AND_MEAN
#  include <windows.h>
#  include <process.h>
//#  pragma comment(lib, "libcmt.lib")  // multithread static library
#  define EXCLUSION_INIT(a)    InitializeCriticalSection(a)
#  define EXCLUSION_DESTROY(a) DeleteCriticalSection(a)
#  define EXCLUSION_ENTER(a)   EnterCriticalSection(a)
#  define EXCLUSION_LEAVE(a)   LeaveCriticalSection(a)
//#  define WAIT_THREAD_END(a)   WaitForSingleObject(a,INFINITE)
#  define WAIT_THREAD_END(a)   Sleep(50)
typedef CRITICAL_SECTION  THREADLOCK;
typedef uintptr_t THANDLE;
#  define STRICMP   _stricmp
#  define STRNICMP  _strnicmp
#else
#  include <stdio.h>
#  include <pthread.h>
#  define EXCLUSION_INIT(a)    pthread_mutex_init(a,NULL)
#  define EXCLUSION_DESTROY(a) pthread_mutex_destroy(a)
#  define EXCLUSION_ENTER(a)   pthread_mutex_lock(a)
#  define EXCLUSION_LEAVE(a)   pthread_mutex_unlock(a)
#  define WAIT_THREAD_END(a)   pthread_join(a,NULL)
typedef pthread_t THANDLE;
typedef pthread_mutex_t THREADLOCK;
#  define STRICMP   strcasecmp
#  define STRNICMP  strncasecmp
#endif

#include "mex.h"
#include "matrix.h"

//#define NETAPI_IMPORT
#include "essnetapi.h"

// input/putput /////////////////////////////////////////
#define INP_COMMAND_STR  prhs[0]
#define INP_SERVER_NAME  prhs[1]
#define INP_SERVER_PORT  prhs[2]
#define INP_SOCKET       prhs[1]
#define OUT_SOCKET       plhs[0]
#define OUT_EVENTS       plhs[0]

// some definitions /////////////////////////////////////
#define MAX_SOCKETS     16
#define MAX_EVENTS     128

typedef struct _evtwork {
  SOCKET m_sock;       // socket handle
  ENET_MSGHEADER m_event[MAX_EVENTS];  // event buffer
  char  *m_data[MAX_EVENTS];           // data buffer
  int    m_nevents;    // number of events
  THANDLE m_thread;    // thread handle
  int    m_active;     // thread is running
  THREADLOCK m_lock;   // CRITICAL_SECTION or mutex
} EVTWORK;

// global variables /////////////////////////////////////
int    gNumSockets = 0;
EVTWORK gEvtWork[MAX_SOCKETS];

// prototypes ///////////////////////////////////////////
void netOnExt(void);
int  add_socket(SOCKET sock);
void remove_socket(SOCKET sock);
EVTWORK *find_socket(SOCKET sock);
void close_evtwork(EVTWORK *pwork);
void cmd_login(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_logout(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_read(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void mx_set_event(mxArray *plhs[], int i, int *fnumber, ENET_MSGHEADER *pmsgh, char *pdata);
#if defined (_WIN32) || defined (_WIN64)
void recv_thread(void *pdata);
#else
void *recv_thread(void *pdata);
#endif
void sleep_thread(int msec);


// functions ////////////////////////////////////////////
void netOnExit(void)
{
  int i,j;

  enet_startup();
  for (i = 0; i < MAX_SOCKETS; i++) {
    if (gEvtWork[i].m_sock != INVALID_SOCKET) {
      //enet_ws_logout(gEvtWork[i].m_sock);
      enet_close(gEvtWork[i].m_sock);
      gEvtWork[i].m_sock = INVALID_SOCKET;
    }
    if (gEvtWork[i].m_active) WAIT_THREAD_END(gEvtWork[i].m_thread);
    for (j = 0; j < MAX_EVENTS; j++) {
      if (gEvtWork[i].m_data[j] != NULL) {
        free(gEvtWork[i].m_data[j]);  gEvtWork[i].m_data[j] = NULL;
      }
    }
    EXCLUSION_DESTROY(&gEvtWork[i].m_lock);
  }
  enet_cleanup();
}

int add_socket(SOCKET sock)
{
  int i;
  EVTWORK *pwork;

  for (i = 0; i < MAX_SOCKETS; i++) {
    if (gEvtWork[i].m_sock == INVALID_SOCKET) break;
  }
  if (i >= MAX_SOCKETS)  {
    mexPrintf("%s: too many sockets (n=%d)\n",mexFunctionName(),gNumSockets);
    return -1;
  }
  pwork = &gEvtWork[i];
  
  pwork->m_sock = sock;
  pwork->m_nevents = 0;
  for (i = 0; i < MAX_EVENTS; i++) {
    if (pwork->m_data[i] != NULL) {
      free(pwork->m_data[i]);  pwork->m_data[i] = NULL;
    }
  }
  // begin thread
  pwork->m_active = 0;
  //mexPrintf(" n=%d thread...",gNumSockets);
#if defined (_WIN32)
  pwork->m_thread = _beginthread(recv_thread,0,(void *)pwork);
  if (pwork->m_thread == -1)  goto on_error;
#else
  if (pthread_create(&pwork->m_thread,NULL,
                       recv_thread,(void *)pwork) != 0)
    goto on_error;
#endif

  gNumSockets++;

  //mexPrintf("nsock=%d ",gNumSockets);

  return gNumSockets;

 on_error:
  //mexPrintf(" failed.");
  pwork->m_sock = INVALID_SOCKET;
  pwork->m_thread = -1;
  pwork->m_active = 0;
  return -1;
}

void remove_socket(SOCKET sock)
{
  EVTWORK *pwork;

  //mexPrintf("\nremove_socket: %d->",gNumSockets);

  if ((pwork = find_socket(sock)) == NULL)  return;

  close_evtwork(pwork);
  gNumSockets--;
  //mexPrintf("nsocks=%d ",gNumSockets);
  
  return;
}

EVTWORK *find_socket(SOCKET sock)
{
  int i;

  for (i = 0; i < MAX_SOCKETS; i++) {
    if (gEvtWork[i].m_sock == sock) break;
  }
  if (i >= MAX_SOCKETS)  return NULL;

  //mexPrintf(" find_socket = %d\n",i);

  return &gEvtWork[i];
}

void close_evtwork(EVTWORK *pwork)
{
  SOCKET sock;
  
  if (pwork == NULL)  return;

  // close socket
  sock = pwork->m_sock;
  pwork->m_sock = INVALID_SOCKET;
  if (sock != INVALID_SOCKET)  enet_close(sock);
  // wait the thread and free buffer
  if (pwork->m_active)  WAIT_THREAD_END(pwork->m_thread);
  pwork->m_active = 0;
  // clear other vars
  for (int j = 0; j < MAX_EVENTS; j++) {
    if (pwork->m_data[j] != NULL) {
      free(pwork->m_data[j]);  pwork->m_data[j] = NULL;
    }
  }
  pwork->m_nevents = 0;

  return;
}


#if defined (_WIN32)
void recv_thread(void *pdata)
#else
void *recv_thread(void *pdata)
#endif
{
  int bready,brecv;
  struct enet_msgheader msgh;
  char *buff;
  EVTWORK *pwork;

  pwork = (EVTWORK *)pdata; buff = NULL;
  pwork->m_active = 1;
  while (pwork->m_sock != INVALID_SOCKET) {
    // is data ready?
    bready = enet_readable(pwork->m_sock,0);
    if (bready < 0)  goto on_exit;
    if (bready == 0) {
      sleep_thread(10);  continue;
    }
    // yes, let's get message header
    memset(&msgh,0,sizeof(msgh));
    brecv = enet_recv(pwork->m_sock,(char *)&msgh,sizeof(msgh),0);
    if (brecv != sizeof(msgh) || msgh.nelements < 0)  goto on_exit;
    if (msgh.nelements > 0) {
      // gets data
      if (buff != NULL) { free(buff);  buff = NULL; }
      buff = (char *)malloc(msgh.nbytes);
      brecv = enet_recv(pwork->m_sock,(char *)buff,msgh.nbytes,0);
      if (brecv != msgh.nbytes)  goto on_exit;
      //if (msgh.tag != (char)ENETTAG_ESSEVENT)  continue;
      if (msgh.datatype == (short)PUT_string) {
        msgh.nelements = 1;
        for (brecv = 0; brecv < msgh.nbytes-1; brecv++) {
          if (buff[brecv] == '\0')  msgh.nelements++;
        }
      }
    }
    // retreive data
    EXCLUSION_ENTER(&pwork->m_lock);
    {
      // any space?
      if (pwork->m_nevents >= MAX_EVENTS) {
        pwork->m_nevents--;
        memmove(&(pwork->m_event[0]),&(pwork->m_event[1]),
                sizeof(ENET_MSGHEADER)*pwork->m_nevents);
        if (pwork->m_data[0] != NULL)  free(pwork->m_data[0]);
        memmove(&(pwork->m_data[0]), &(pwork->m_data[1]),
                sizeof(char *)*pwork->m_nevents);
        pwork->m_data[pwork->m_nevents] = NULL;
      }
      // copy events
      memcpy(&(pwork->m_event[pwork->m_nevents]),&msgh,sizeof(ENET_MSGHEADER));
      if (msgh.nbytes > 0) {
        // copy data
        pwork->m_data[pwork->m_nevents] = (char *)malloc(msgh.nbytes);
        memcpy(pwork->m_data[pwork->m_nevents],buff,msgh.nbytes);
      }
      pwork->m_nevents++;
    }
    EXCLUSION_LEAVE(&pwork->m_lock);
    free(buff);  buff = NULL;
  }

 on_exit:
  //Beep(1940,80);  Beep(970,80);
  if (buff != NULL)  free(buff);
  pwork->m_active = 0;
  remove_socket(pwork->m_sock);

#if defined (_WIN32)
  _endthread();
#else
  return NULL;
#endif
}

void sleep_thread(int msec)
{
#if defined (_WIN32)
  Sleep(msec);
#else
  
#endif
}

void cmd_login(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char *server = NULL;
  int buflen, port;
  SOCKET sock;

  if (nrhs < 2)  mexErrMsgTxt(" no essmailer host specified.");
  // get server name
  if (!mxIsChar(INP_SERVER_NAME)) 	mexErrMsgTxt(" failed to get server name");
  buflen = mxGetM(INP_SERVER_NAME)*mxGetN(INP_SERVER_NAME) + 1;
  server = (char *)mxCalloc(buflen,sizeof(char));
  mxGetString(INP_SERVER_NAME,server,buflen);
  // get server port
  if (nrhs > 2) {
    if (!mxIsNumeric(INP_SERVER_PORT)) {
      mexErrMsgTxt(" failed to get server port");
    }
    port = (int)mxGetScalar(INP_SERVER_PORT);
  } else {
    port = ESSMAILER_PORT;
  }
  sock = enet_connect(server,port);   mxFree(server);

  //mexPrintf(" sock=%d ",sock);
  if (sock != INVALID_SOCKET) {
    enet_buffersize(sock,SO_RCVBUF,1024*16);
    if (add_socket(sock) < 0) {
      enet_close(sock);
      mexPrintf("%s: failed to add socket.\n",mexFunctionName());
      sock = INVALID_SOCKET;
    }
  }

  OUT_SOCKET = mxCreateDoubleMatrix(1,1,mxREAL);
  if (sock != INVALID_SOCKET)   *mxGetPr(OUT_SOCKET) = (double)sock;
  else                          *mxGetPr(OUT_SOCKET) = -1.; 

  return;
}

void cmd_logout(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  SOCKET sock;
  char *sockstr = NULL;
  int buflen;
  EVTWORK *pwork;

  if (nrhs < 2)  mexErrMsgTxt(" no sock id specified.");
  // get socket
  if (mxIsChar(INP_SOCKET)) {
    buflen = mxGetM(INP_SOCKET)*mxGetN(INP_SOCKET) + 1;
    sockstr = (char *)mxCalloc(buflen,sizeof(char));
    mxGetString(INP_SOCKET,sockstr,buflen);
    if (STRICMP(sockstr,"all") == 0) {
      for (buflen = 0; buflen < MAX_SOCKETS; buflen++) {
        close_evtwork(&gEvtWork[buflen]);
      }
      gNumSockets = 0;
    }
    mxFree(sockstr);
  } else if (mxIsNumeric(INP_SOCKET)) {
    sock = (SOCKET)mxGetScalar(INP_SOCKET);
    //mexPrintf("\n nsocks=%d ",gNumSockets);
    close_evtwork(find_socket(sock));
    //mexPrintf("\n nsocks=%d ",gNumSockets);
  } else {
    mexErrMsgTxt(" failed to get socket");
  }

  return;
}

void cmd_read(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  SOCKET sock;
  int nevents,i;
  EVTWORK *pwork = NULL;
  ENET_MSGHEADER tmpmsgh[MAX_EVENTS];
  char *tmpdata[MAX_EVENTS];
  const char *fieldnames[] = {"tag","type","subtype","timestamp","data"};
  const int nfields = 5;
  int fnumber[nfields];

  if (nrhs < 2)  mexErrMsgTxt(" no sock id specified.");
  if (!mxIsNumeric(INP_SOCKET))   mexErrMsgTxt(" failed to get socket");

  sock = (SOCKET)mxGetScalar(INP_SOCKET);
  nevents = 0;
  if ((pwork = find_socket(sock)) != NULL) {
    EXCLUSION_ENTER(&pwork->m_lock);
    {
      nevents = pwork->m_nevents;
      if (nevents > 0) {
        // copy events
        memcpy(&tmpmsgh,&(pwork->m_event[0]),sizeof(ENET_MSGHEADER)*nevents);
        // copy event-data, then free it
        for (i = 0; i < nevents; i++) {
          if (pwork->m_data[i] != NULL) {
            tmpdata[i] = (char *)malloc(tmpmsgh[i].nbytes);
            memcpy(tmpdata[i],pwork->m_data[i],tmpmsgh[i].nbytes);
            free(pwork->m_data[i]);  pwork->m_data[i] = NULL;
          } else {
            tmpdata[i] = NULL;
          }
        }
        // reset number of events
        pwork->m_nevents = 0;
      }
    }
    EXCLUSION_LEAVE(&pwork->m_lock);
    //mexPrintf("\n here0.1 %.4f %.4f %d %d ",endtime,sampt,nchans,cpsize);
    // waveform
    if (nevents > 0) {
      // create 1*nevents struct
      OUT_EVENTS = mxCreateStructMatrix(1,nevents,nfields,fieldnames);
      for (i = 0; i < nfields; i++)
        fnumber[i] = mxGetFieldNumber(OUT_EVENTS,fieldnames[i]);
      for (i = 0; i < nevents; i++) {
        mx_set_event(plhs,i,fnumber,&tmpmsgh[i],tmpdata[i]);
        if (tmpdata[i] != NULL)  free(tmpdata[i]);
      }
    } else {
      OUT_EVENTS = mxCreateDoubleMatrix(0,0,mxREAL);
    }
  } else {
    OUT_EVENTS = mxCreateDoubleMatrix(1,1,mxREAL);
    *mxGetPr(OUT_EVENTS) = -1;
  }

  return;
}

void mx_set_event(mxArray *plhs[], int idx, int *fnumber, ENET_MSGHEADER *pmsgh, char *pdata)
{
  mxArray *fvalue;
  int i,j;
  short *sbuff;
  int *ibuff;
  float *fbuff;
  double *dbuff, *p, *dp;
  
  // tag
  fvalue = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(fvalue) = (double)pmsgh->magic;
  mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[0],fvalue);
  // type
  fvalue = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(fvalue) = (double)pmsgh->type;
  mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[1],fvalue);
  // subtype
  fvalue = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(fvalue) = (double)pmsgh->subtype;
  mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[2],fvalue);
  // timestamp
  fvalue = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(fvalue) = pmsgh->timestamp;
  mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[3],fvalue);
  // data
  if (pmsgh->nbytes <= 0 || pdata == NULL)  return;
  switch (pmsgh->datatype) {
  case (short)PUT_unknown :
  case (short)PUT_null :
    break;
  case (short)PUT_string :
    if (pmsgh->nelements == 1) {
      fvalue = mxCreateString(pdata);
    } else {
      fvalue = mxCreateCellMatrix(1,pmsgh->nelements);
      mxSetCell(fvalue,0,mxCreateString(pdata));
      for (i = 0, j = 1; i < pmsgh->nbytes-1, j < pmsgh->nelements; i++) {
        if (pdata[i] != '\0')  continue;
        mxSetCell(fvalue,j++,mxCreateString(&pdata[i+1]));
      }
    }
    mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[4],fvalue);
    break;
  case (short)PUT_short :
    if (pmsgh->nbytes != pmsgh->nelements*(int)sizeof(short))  break;
    sbuff = (short *)pdata;
    fvalue = mxCreateDoubleMatrix(1,pmsgh->nelements,mxREAL);
    dp = mxGetPr(fvalue);
    for (p = dp, i = 0; i < pmsgh->nelements; i++)  *p++ = (double)sbuff[i];
    mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[4],fvalue);
    break;
  case (short)PUT_int32 :
    if (pmsgh->nbytes != pmsgh->nelements*(int)sizeof(int))  break;
    ibuff = (int *)pdata;
    fvalue = mxCreateDoubleMatrix(1,pmsgh->nelements,mxREAL);
    dp = mxGetPr(fvalue);
    for (p = dp, i = 0; i < pmsgh->nelements; i++)  *p++ = (double)ibuff[i];
    mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[4],fvalue);
    break;
  case (short)PUT_float :
    if (pmsgh->nbytes != pmsgh->nelements*(int)sizeof(float))  break;
    fbuff = (float *)pdata;
    fvalue = mxCreateDoubleMatrix(1,pmsgh->nelements,mxREAL);
    dp = mxGetPr(fvalue);
    for (p = dp, i = 0; i < pmsgh->nelements; i++)  *p++ = (double)fbuff[i];
    mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[4],fvalue);
    break;
  case (short)PUT_double :
    if (pmsgh->nbytes != pmsgh->nelements*(int)sizeof(double))  break;
    dbuff = (double *)pdata;
    fvalue = mxCreateDoubleMatrix(1,pmsgh->nelements,mxREAL);
    dp = mxGetPr(fvalue);
    for (p = dp, i = 0; i < pmsgh->nelements; i++)  *p++ = dbuff[i];
    mxSetFieldByNumber(OUT_EVENTS,idx,fnumber[4],fvalue);
    break;
  default :
    break;
  }
  
  return;
}



/* MEX function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  static int initialized = 0;
  char *cmdstr = NULL;
  int buflen,i;

  /* initialization */
  if (initialized == 0) {
    enet_startup();
    for (buflen = 0; buflen < MAX_SOCKETS; buflen++) {
      gEvtWork[buflen].m_sock = INVALID_SOCKET;
      gEvtWork[buflen].m_active = 0;
      gEvtWork[buflen].m_nevents = 0;
      for (i = 0; i < MAX_EVENTS; i++)  gEvtWork[buflen].m_data[i] = NULL;
      EXCLUSION_INIT(&gEvtWork[buflen].m_lock);
    }
    gNumSockets = 0;
    mexAtExit(netOnExit);
    initialized = 1;
  }

  /* Check for proper number of arguments. */
  if (nrhs < 1) {
		mexEvalString("help neteventlog;");  return;
  }

  // get a command string
  if (!mxIsChar(INP_COMMAND_STR)) 	mexErrMsgTxt(" failed to get command");
  buflen = mxGetM(INP_COMMAND_STR)*mxGetN(INP_COMMAND_STR) + 1;
  cmdstr = (char *)mxCalloc(buflen,sizeof(char));
  mxGetString(INP_COMMAND_STR,cmdstr,buflen);

  if (STRICMP(cmdstr,"read") == 0) {
    cmd_read(nlhs, plhs, nrhs, prhs);
  } else if (STRICMP(cmdstr,"logout") == 0 ||
             STRICMP(cmdstr,"logoff") == 0 ||
             STRICMP(cmdstr,"close") == 0) {
    cmd_logout(nlhs, plhs, nrhs, prhs);
  } else if (STRICMP(cmdstr,"login") == 0 ||
      STRICMP(cmdstr,"logon") == 0 ||
      STRICMP(cmdstr,"open") == 0) {
    cmd_login(nlhs, plhs, nrhs, prhs);
  } else {
    mexErrMsgTxt(" not supported command.");
    //mexPrintf("%s ERROR: not supported command '%s'.\n",
    //          mexFunctionName(),cmdstr);
  }

  mxFree(cmdstr);

  return;

}
