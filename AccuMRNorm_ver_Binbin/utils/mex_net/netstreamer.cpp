/*
 * netstreamer.cpp
 * 
 * NOTES : This mex uses threads to perform continuous streaming of
 *         incoming data. BUT current Matlab (R12) is a single-thread
 *         application, meaning not thread-safe. As far as i tested,
 *         mexEvalString(), mexCallMATLAB() crash the Matlab.
 *
 * To compile this mex link thread-safe library,
 *   >> mex netstreamer.cpp essnetapi.c libcmt.lib -D_MT
 * or 
 *   >> mex netstreamer.cpp essnetapi.c
 *
 * ver.
 *   1.00  07-Aug-2002  Yusuke MURAYAMA, MPI
 *   1.01  08-Aug-2002  YM
 *   1.02  12-Aug-2002  YM, bug fix of logout
 *   1.03  15-Oct-2002  YM, disable pragma comment(lib,"libcmt.lib") for complation in Matlab R13
 *   1.10  19-Sep-2013  YM, supports WinStreamerMx.
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

#include "adfxheader.h"  // ADFX header


// input/output /////////////////////////////////////////
#define INP_COMMAND_STR    prhs[0]
#define INP_SERVER_NAME    prhs[1]
#define INP_SERVER_PORT    prhs[2]
#define INP_SOCKET         prhs[1]
#define INP_LOGIC_H        prhs[1]
#define INP_LOGIC_L        prhs[2]
#define OUT_SOCKET         plhs[0]
#define OUT_AI_WAVE        plhs[0]
#define OUT_ENDTIME        plhs[1]
#define OUT_SAMPT          plhs[2]
#define OUT_DI_PATT        plhs[3]
#define OUT_DI_PORT_WIDTH  plhs[4]

// some definitions /////////////////////////////////////
#define DAQ_ANALOG_LOW_STRMR_VOLTS  (0.8)
#define DAQ_ANALOG_HIGH_STRMR_VOLTS (1.8)
#define MAX_SOCKETS        16
#define MAX_BUFFERSIZE   (1024*1024*4)
// 4Mbytes for short integer, 
// 4M/(21kHz(pts/sec)*16chans*2bytes) = ~5.9sec

typedef struct _wswork {
    SOCKET m_sock;       // socket handle
    char  *m_buff;       // data buffer
    char  *m_data_type;  // data type of each channel
    int   *m_channels;   // recorded channels, +:Ai, -:Di
    int    m_isWinStreamerMx;
    int    m_nbytes_per_sample;
    int    m_nsamples;   // available size in samples
    int    m_nchans_ai;  // numchans of ai data
    int    m_nchans_di;  // numchans of di data
    int    m_obspchan;   // obsp channel
    double m_endtime;    // timestamp since beginobs in msec
    double m_samptime;   // samptime in msec
    THANDLE m_thread;    // thread handle
    int    m_active;     // thread is running
    THREADLOCK m_lock;   // CRITICAL_SECTION or mutex
    int    m_logicH;
    int    m_logicL;
} WSWORK;

// global variables /////////////////////////////////////
int    gLogicH = -1;
int    gLogicL = -1;
int    gNumSockets = 0;
WSWORK gWsWork[MAX_SOCKETS];

// prototypes ///////////////////////////////////////////
void netOnExt(void);
int  add_socket(SOCKET sock);
void remove_socket(SOCKET sock);
WSWORK *find_socket(SOCKET sock);
void free_wswork(WSWORK *pwork);
void close_wswork(WSWORK *pwork);
void cmd_login(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_logout(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_read(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_llevel(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
int  proc_winstreamermx(WSWORK *pwork, ENET_MSGHEADER *pmsgh, char *buff, int *pPrevLevel);
int  proc_winstreamer(WSWORK *pwork, ENET_MSGHEADER *pmsgh, short *buff, int *pPrevLevel);
#if defined (_WIN32)
void recv_thread(void *pdata);
#else
void *recv_thread(void *pdata);
#endif
void sleep_thread(int msec);


// functions ////////////////////////////////////////////
void netOnExit(void)
{
    int i;

    enet_startup();
    for (i = 0; i < MAX_SOCKETS; i++) {
        if (gWsWork[i].m_sock != INVALID_SOCKET) {
            //enet_ws_logout(gWsWork[i].m_sock);
            enet_close(gWsWork[i].m_sock);
            gWsWork[i].m_sock = INVALID_SOCKET;
        }
        if (gWsWork[i].m_active) WAIT_THREAD_END(gWsWork[i].m_thread);
        if (gWsWork[i].m_buff != NULL) {
            free(gWsWork[i].m_buff);  gWsWork[i].m_buff = NULL;
        }
        if (gWsWork[i].m_data_type != NULL) {
            free(gWsWork[i].m_data_type);  gWsWork[i].m_data_type = NULL;
        }
        if (gWsWork[i].m_channels != NULL) {
            free(gWsWork[i].m_channels);  gWsWork[i].m_channels = NULL;
        }
        EXCLUSION_DESTROY(&gWsWork[i].m_lock);
    }
    enet_cleanup();
}

int add_socket(SOCKET sock)
{
    int i;
    WSWORK *pwork;

    if (gNumSockets == MAX_SOCKETS)  return -1;
  
    for (i = 0; i < MAX_SOCKETS; i++) {
        if (gWsWork[i].m_sock == INVALID_SOCKET) break;
    }

    if (i >= MAX_SOCKETS)  {
        mexPrintf("%s: too many sockets (n=%d)\n",mexFunctionName(),gNumSockets);
        return -1;
    }
    pwork = &gWsWork[i];

    free_wswork(pwork);

    pwork->m_sock   = sock;
    pwork->m_logicL = gLogicL;
    pwork->m_logicH = gLogicH;
    // prepare buffer
    pwork->m_buff = (char *)malloc(MAX_BUFFERSIZE);
    if (pwork->m_buff == NULL) goto on_error;
    // begin thread
#if defined (_WIN32)
    pwork->m_thread = _beginthread(recv_thread,0,(void *)pwork);
    if (pwork->m_thread == -1)  goto on_error;
#else
    if (pthread_create(&pwork->m_thread,NULL,recv_thread,(void *)pwork) != 0)
        goto on_error;
#endif
  
    gNumSockets++;

    return gNumSockets;

on_error:
    pwork->m_sock = INVALID_SOCKET;
    pwork->m_active = 0;
    return -1;
}

void remove_socket(SOCKET sock)
{
    WSWORK *pwork;

    if ((pwork = find_socket(sock)) == NULL)  return;

    close_wswork(pwork);
    gNumSockets--;
  
    return;
}

WSWORK *find_socket(SOCKET sock)
{
    int i;

    for (i = 0; i < MAX_SOCKETS; i++) {
        if (gWsWork[i].m_sock == sock)  break;
    }
    if (i >= MAX_SOCKETS)  return NULL;

    //mexPrintf(" find_socket = %d\n",i);

    return &gWsWork[i];
}

void free_wswork(WSWORK *pwork)
{
    if (pwork == NULL)  return;

    // free buffers
    if (pwork->m_buff != NULL) {
        free(pwork->m_buff);  pwork->m_buff = NULL;
    }
    if (pwork->m_data_type != NULL) {
        free(pwork->m_data_type);  pwork->m_data_type = NULL;
    }
    if (pwork->m_channels != NULL) {
        free(pwork->m_channels);  pwork->m_channels = NULL;
    }
    // clear other vars
    pwork->m_nbytes_per_sample = 0;
    pwork->m_nsamples  = 0;
    pwork->m_nchans_ai = 0;
    pwork->m_nchans_di = 0;
    pwork->m_obspchan  = 0;
    pwork->m_endtime   = 0;
    pwork->m_samptime  = 0;
  
    return;
}

void close_wswork(WSWORK *pwork)
{
    SOCKET sock;
  
    if (pwork == NULL)  return;

    // close socket
    sock = pwork->m_sock;
    pwork->m_sock = INVALID_SOCKET;
    //if (sock != INVALID_SOCKET)  enet_ws_logout(sock);
    if (sock != INVALID_SOCKET)  enet_close(sock);
    // wait the thread and free buffer
    if (pwork->m_active)  WAIT_THREAD_END(pwork->m_thread);
    pwork->m_active = 0;

    // free buffers
    free_wswork(pwork);

    return;
}

int proc_winstreamermx(WSWORK *pwork, ENET_MSGHEADER *pmsgh, char *buff, int *pPrevLevel)
{
    ADFX_HEADER *padfx;
    int i, nchans, nmaxsamps, nsamps, nbytes, nmaxbytes, npts;
    char *devices, *data_type;
    int32_t *channels;
    char *cbuff;
    int noffs;
    char cval;
    short sval, slogicL, slogicH, sPrevLevel;
    int ival, ilogicL, ilogicH, iPrevLevel;
    double *adc2volts;

    padfx = (ADFX_HEADER *)buff;
    nchans = padfx->nchannels_ai + padfx->nchannels_di;
    devices   = (char    *)&buff[ADFX_HEADER_STATIC_SIZE];
    data_type = (char    *)&buff[ADFX_HEADER_STATIC_SIZE + nchans];
    channels  = (int32_t *)&buff[ADFX_HEADER_STATIC_SIZE + nchans*(1+1)];
    adc2volts = (double  *)&buff[ADFX_HEADER_STATIC_SIZE + nchans*(1+1+4)];

    // check
    if (pwork->m_nsamples != 0) {
        if (pwork->m_nchans_ai != padfx->nchannels_ai)       pwork->m_nsamples = 0;
        else if (pwork->m_nchans_di != padfx->nchannels_di)  pwork->m_nsamples = 0;
        else if (pwork->m_data_type == NULL)                 pwork->m_nsamples = 0;
        else {
            for (i = 0; i < nchans; i++) {
                if (pwork->m_data_type[i] != data_type[i]) {
                    pwork->m_nsamples = 0;  break;
                }
            }
        }
    }
    // init
    if (pwork->m_nsamples == 0) {
        if (pwork->m_data_type == NULL) {
            pwork->m_data_type = (char *)malloc(nchans*sizeof(char));
            pwork->m_channels  = (int  *)malloc(nchans*sizeof(int));
        } else if (pwork->m_nchans_ai + pwork->m_nchans_di < nchans) {
            free(pwork->m_data_type);  pwork->m_data_type = NULL;
            free(pwork->m_channels);   pwork->m_channels  = NULL;
            pwork->m_data_type = (char *)malloc(nchans*sizeof(char));
            pwork->m_channels  = (int  *)malloc(nchans*sizeof(int));
        }
        memcpy(pwork->m_data_type, data_type, nchans);
        memcpy(pwork->m_channels,  channels,  nchans*sizeof(int));
 
        pwork->m_nchans_ai = padfx->nchannels_ai;
        pwork->m_nchans_di = padfx->nchannels_di;
        pwork->m_obspchan  = padfx->obsp_chan;
        pwork->m_samptime  = padfx->us_per_sample/1000.0;
        pwork->m_endtime   = 0;

        pwork->m_nbytes_per_sample = 0;
        for (i = 0; i < nchans; i++) {
            switch (pwork->m_data_type[i]) {
            case 'c':
                pwork->m_nbytes_per_sample += 1;  break;
            case 's':
                pwork->m_nbytes_per_sample += 2;  break;
            case 'i':
                pwork->m_nbytes_per_sample += 4;  break;
            }
        }
//printf("obspch=%d(%c).",pwork->m_obspchan,pwork->m_data_type[pwork->m_obspchan]);
        if (pwork->m_channels[pwork->m_obspchan] > 0) {
            // Ai as OBSP-TTL
            if (gLogicL > 0) {
                pwork->m_logicL = gLogicL;
            } else {
                pwork->m_logicL = (int)(((double)DAQ_ANALOG_LOW_STRMR_VOLTS)/adc2volts[pwork->m_obspchan]);
            }
            if (gLogicH > 0) {
                pwork->m_logicH = gLogicH;
            } else {
                pwork->m_logicH = (int)(((double)DAQ_ANALOG_HIGH_STRMR_VOLTS)/adc2volts[pwork->m_obspchan]);
            }
        } else {
            // Di as OBSP-TTL
            pwork->m_logicL = 0;
            pwork->m_logicH = 1;
        }
        *pPrevLevel = pwork->m_logicL;
    }

    if (pwork->m_nbytes_per_sample == 0)  return 0;

    cbuff = (char *)pwork->m_buff;
    nbytes = pwork->m_nbytes_per_sample;

    // move data if needed
    nmaxsamps = (MAX_BUFFERSIZE)/nbytes;
    nsamps = pwork->m_nsamples + pmsgh->nelements - nmaxsamps;
//mexPrintf("nsamps=%d+%d/%d",pwork->m_nsamples,pmsgh->nelements,nmaxsamps);
    if (nsamps > 0) {
        pwork->m_nsamples = pwork->m_nsamples - nsamps;
        memmove(&cbuff[0],&cbuff[nsamps*nbytes],pwork->m_nsamples*nbytes);
        //pwork->m_nsamples = 0;  // debug/testing...
    }
    // copy data
    i = ADFX_HEADER_STATIC_SIZE + (1+1+4+8)*nchans;
    memcpy(&cbuff[pwork->m_nsamples*nbytes],&buff[i],pmsgh->nelements*nbytes);
//mexPrintf(" nsamps=%d+%d/%d\n.",pwork->m_nsamples,pmsgh->nelements,nmaxsamps);
    pwork->m_nsamples = pwork->m_nsamples + pmsgh->nelements;

    // check obsp
    cbuff = (char *)&buff[i];
    noffs = 0;
    for (i = 0; i < pwork->m_obspchan; i++) {
        switch (pwork->m_data_type[i]) {
        case 'c':
            noffs += 1;  break;
        case 's':
            noffs += 2;  break;
        case 'i':
            noffs += 4;  break;
        }
    }

    nmaxbytes = pmsgh->nelements*nbytes;
    npts = 0;
    if (channels[pwork->m_obspchan] > 0) {
        // Ai as OBSP-TTL
        switch (pwork->m_data_type[pwork->m_obspchan]) {
        case 's':
            sPrevLevel = (int)*pPrevLevel;
            slogicL = (short)pwork->m_logicL;
            slogicH = (short)pwork->m_logicH;
            for (i = noffs; i < nmaxbytes; i+=nbytes) {
                sval = *((short *)&cbuff[i]);
                if (sval > slogicH && sPrevLevel < slogicL) {
                    // new obs entered
                    pwork->m_endtime = 0;  npts = 0;
                }
                npts++;
                sPrevLevel = sval;
            }
            *pPrevLevel = (int)sPrevLevel;
            break;
        case 'i':
            iPrevLevel = *pPrevLevel;
            ilogicL = pwork->m_logicL;
            ilogicH = pwork->m_logicH;
            for (i = noffs; i < nmaxbytes; i+=nbytes) {
                ival = *((int *)&cbuff[i]);
                if (ival > ilogicH && iPrevLevel < ilogicL) {
                    // new obs entered
                    pwork->m_endtime = 0;  npts = 0;
                }
                npts++;
                iPrevLevel = ival;
            }
            *pPrevLevel = iPrevLevel;
            break;
        }
    } else {
        // Di as OBSP-TTL
        iPrevLevel = *pPrevLevel;
        switch (pwork->m_data_type[pwork->m_obspchan]) {
        case 'c':
            for (i = noffs; i < nmaxbytes; i+=nbytes) {
                cval = (cbuff[i] & 0x01);
                if (cval != 0 && iPrevLevel == 0) {
                    // new obs entered
                    pwork->m_endtime = 0;  npts = 0;
                }
                npts++;
                iPrevLevel = (int)cval;
            }
            break;
        case 's':
            for (i = noffs; i < nmaxbytes; i+=nbytes) {
                sval = *((short *)&cbuff[i]);
                sval = (sval & 0x01);
                if (sval != 0 && iPrevLevel == 0) {
                    // new obs entered
                    pwork->m_endtime = 0;  npts = 0;
                }
                npts++;
                iPrevLevel = (int)sval;
            }
            break;
        case 'i':
            for (i = noffs; i < nmaxbytes; i+=nbytes) {
                ival = *((int *)&cbuff[i]);
                ival = (ival & 0x01);
                if (ival != 0 && iPrevLevel == 0) {
                    // new obs entered
                    pwork->m_endtime = 0;  npts = 0;
                }
                npts++;
                iPrevLevel = (int)sval;
            }
            break;
        }
        *pPrevLevel = iPrevLevel;
    }
    pwork->m_endtime = pwork->m_endtime + ((double)npts)*pwork->m_samptime;


    return 0;
}

int proc_winstreamer(WSWORK *pwork, ENET_MSGHEADER *pmsgh, short *buff, int *pPrevLevel)
{
    int nchans, i, npts, nmaxsamps, nbytes;
    char *cbuff;
    short prevLevel, logicL, logicH;

    // check nchans
    nchans = (int)pmsgh->subtype;
    if (pwork->m_nsamples > 0) {
        if (pwork->m_nchans_ai != nchans)     pwork->m_nsamples = 0;
        else if (pwork->m_data_type == NULL)  pwork->m_nsamples = 0;
    }

    if (pwork->m_nsamples == 0) {
        // ok, reset data

        // In WinStreamer, maxchans = 16.
        if (pwork->m_data_type == NULL) {
            pwork->m_data_type = (char *)malloc(16*sizeof(char));
            for (i = 0; i < 16; i++)  pwork->m_data_type[i] = 's';
        }
        if (pwork->m_channels == NULL) {
            pwork->m_channels  = (int *)malloc(16*sizeof(int));
            for (i = 0; i < 16; i++)  pwork->m_channels[i] = i+1;
        }
    
        pwork->m_nchans_ai = nchans;
        pwork->m_nchans_di = 0;
        pwork->m_obspchan  = nchans-1;
        pwork->m_endtime = 0;
        // NOTES : samptime is in msec, numchans includes a trigger channel
        pwork->m_samptime = pmsgh->timestamp;

        pwork->m_nbytes_per_sample = 2*nchans;

        if (gLogicL > 0) {
            pwork->m_logicL = gLogicL;
        } else {
            pwork->m_logicL = (int)(((double)DAQ_ANALOG_LOW_STRMR_VOLTS)/20.0*65536.0);
        }
        if (gLogicH > 0) {
            pwork->m_logicH = gLogicH;
        } else {
            pwork->m_logicH = (int)(((double)DAQ_ANALOG_HIGH_STRMR_VOLTS)/20.0*65536.0);
        }

        *pPrevLevel = pwork->m_logicL;
    }

    if (pwork->m_nbytes_per_sample == 0)  return 0;

    cbuff = (char *)pwork->m_buff;
    nbytes = pwork->m_nbytes_per_sample;
    // any space?
    nmaxsamps = (MAX_BUFFERSIZE*sizeof(short))/nbytes;
    npts = pmsgh->nelements/nchans + pwork->m_nsamples - nmaxsamps;
    if (npts > 0) {
        pwork->m_nsamples = pwork->m_nsamples - npts;
        memmove(&cbuff[0],&cbuff[npts*nbytes],pwork->m_nsamples*nbytes);
    }
    // copy data
    memcpy(&cbuff[pwork->m_nsamples*nbytes],&buff[0],pmsgh->nbytes);
    pwork->m_nsamples = pwork->m_nsamples + pmsgh->nelements/nchans;

    // check trigger level, skip=2!!!
    prevLevel = (short)*pPrevLevel;
    logicL    = (short)pwork->m_logicL;
    logicH    = (short)pwork->m_logicH;
    npts = 0;
    for (i = nchans-1;  i < pmsgh->nelements; i+=2*nchans) {
        if (buff[i] > logicH && *pPrevLevel < logicL) {
            // new obs entered
            pwork->m_endtime = 0;  npts = 0;
        }
        npts+=2;
        prevLevel = buff[i];  // update trigger level to check new-obs enter
    }
    *pPrevLevel = (int)prevLevel;
    pwork->m_endtime = pwork->m_endtime + ((double)npts)*pwork->m_samptime;

    return 0;
}


#if defined (_WIN32)
void recv_thread(void *pdata)
#else
void *recv_thread(void *pdata)
#endif
{
    int bready,brecv;
    struct enet_msgheader msgh;
    void *buff;
    WSWORK *pwork;
    int prevLevel;

    pwork = (WSWORK *)pdata;
    prevLevel = pwork->m_logicL;  buff = NULL;
    pwork->m_active = 1;
    while (pwork->m_sock != INVALID_SOCKET) {
        // is data ready?
        bready = enet_readable(pwork->m_sock,0);
        //bready = enet_ready(pwork->m_sock,0);
        if (bready < 0)  goto on_exit;
        if (bready == 0) {
            sleep_thread(20);  continue;
        }
        // yes, let's get message header
        memset(&msgh,0,sizeof(msgh));
        brecv = enet_recv(pwork->m_sock,(char *)&msgh,sizeof(msgh),0);
        if (brecv != sizeof(msgh) || msgh.nelements < 0)  goto on_exit;
        if (msgh.nbytes == 0)  continue;
        // gets data
        buff = malloc(msgh.nbytes);
//mexPrintf("bytes=%d\n",msgh.nbytes);
        brecv = enet_recv(pwork->m_sock,(char *)buff,msgh.nbytes,0);
        if (brecv != msgh.nbytes)  goto on_exit;
        if ((msgh.type != (short)WSTYPE_WAVEDATA && msgh.type != (short)WSTYPE_WAVEDATA_MX) || msgh.subtype <= 0) {
            free(buff);  buff = NULL;  
            continue;
        }
 
        // seems winstreamer settings to be changed.
        //if ((int)msgh.timestamp != (int)pwork->m_samptime)        Beep(970,80);
        //if (msgh.subtype != (short)pwork->m_nchans_ai)  Beep(1940,80);
        if (msgh.timestamp != pwork->m_samptime) {
            pwork->m_nsamples = 0;
            pwork->m_endtime = 0;  prevLevel = pwork->m_logicL;
            // NOTES : samptime is in msec, numchans includes a trigger channel
            pwork->m_samptime = msgh.timestamp;
        }

        // retreive data
        EXCLUSION_ENTER(&pwork->m_lock);
        {
            if (msgh.type == WSTYPE_WAVEDATA_MX) {
                // WinStreamerMx
                pwork->m_isWinStreamerMx = 1;
                if (proc_winstreamermx(pwork,&msgh,(char *)buff,&prevLevel) != 0)  goto on_exit;
            } else {
                // WinStreamer
                pwork->m_isWinStreamerMx = 0;
                if (proc_winstreamer(pwork,&msgh,(short *)buff,&prevLevel) != 0)  goto on_exit;
            }
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
    int buflen;
    SOCKET sock;

    if (nrhs < 2)  mexErrMsgTxt(" no winstreamer host specified.");
    // get server name
    if (!mxIsChar(INP_SERVER_NAME)) 	mexErrMsgTxt(" failed to get server name");
    buflen = (int)mxGetM(INP_SERVER_NAME)*(int)mxGetN(INP_SERVER_NAME) + 1;
    server = (char *)mxCalloc(buflen,sizeof(char));
    mxGetString(INP_SERVER_NAME,server,buflen);
    // get server port
    if (nrhs > 2) {
        if (!mxIsNumeric(INP_SERVER_PORT)) {
            mexErrMsgTxt(" failed to get server port");
        }
        enet_ws_port = (int)mxGetScalar(INP_SERVER_PORT);
    } else {
        enet_ws_port =  WINSTREAMER_PORT;
    }
    sock = enet_ws_login(server);   mxFree(server);

    if (sock != INVALID_SOCKET) {
        if (add_socket(sock) < 0) {
            enet_ws_logout(sock);
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

    // Actually, this close the socket(s) without sending "logout" to avoid blocking etc.

    if (nrhs < 2)  mexErrMsgTxt(" no sock id specified.");
    // get socket
    if (mxIsChar(INP_SOCKET)) {
        buflen = (int)mxGetM(INP_SOCKET)*(int)mxGetN(INP_SOCKET) + 1;
        sockstr = (char *)mxCalloc(buflen,sizeof(char));
        mxGetString(INP_SOCKET,sockstr,buflen);
        if (STRICMP(sockstr,"all") == 0) {
            for (buflen = 0; buflen < MAX_SOCKETS; buflen++) {
                close_wswork(&gWsWork[buflen]);
            }
            gNumSockets = 0;
        }
        mxFree(sockstr);
    } else if (mxIsNumeric(INP_SOCKET)) {
        sock = (SOCKET)mxGetScalar(INP_SOCKET);
        close_wswork(find_socket(sock));
    } else {
        mexErrMsgTxt(" failed to get socket");
    }

    return;
}

void cmd_read(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    SOCKET sock;
    int nsamps,nbytes,nchans_ai, nchans_di;
    double *dp, *p, endtime, sampt;
    void *buffer = NULL;
    char  *cbuff;
    short *sbuff;
    int   *ibuff;
    WSWORK *pwork = NULL;
    int i, n, k, j, noffs;
    mxClassID datatype;
    mwSize dims[2];
    unsigned char *ucbuf, *ucout;
    unsigned short *usbuf, *usout;
    unsigned int   *uibuf, *uiout;
    

    if (nrhs < 2)  mexErrMsgTxt(" no sock id specified.");
    if (!mxIsNumeric(INP_SOCKET))   mexErrMsgTxt(" failed to get socket");

    nchans_ai = 0;  nchans_di = 0;
    
    sock = (SOCKET)mxGetScalar(INP_SOCKET);
    if ((pwork = find_socket(sock)) != NULL) {
        buffer = NULL;  nsamps = 0;
        EXCLUSION_ENTER(&pwork->m_lock);
        {
            endtime   = pwork->m_endtime;
            sampt     = pwork->m_samptime;
            nsamps    = pwork->m_nsamples;
            nchans_ai = pwork->m_nchans_ai;
            nchans_di = pwork->m_nchans_di;

            // copy ai/di all together
            if (nsamps > 0 && pwork->m_nbytes_per_sample > 0) {
                buffer = (void *)mxCalloc(nsamps,pwork->m_nbytes_per_sample);
                memcpy(buffer,pwork->m_buff,nsamps*pwork->m_nbytes_per_sample);
                pwork->m_nsamples = 0;
            }
        }
        EXCLUSION_LEAVE(&pwork->m_lock);
        //mexPrintf("\n here0.1 %.4f %.4f %d %d ",endtime,sampt,nchans_ai,nsamps);
        // waveform
        if (nsamps > 0) {
            OUT_AI_WAVE = mxCreateDoubleMatrix(nchans_ai,nsamps,mxREAL);
            dp = mxGetPr(OUT_AI_WAVE);
            if (pwork->m_isWinStreamerMx) {
                nbytes = pwork->m_nbytes_per_sample;
                n = nbytes*nsamps;
                cbuff = (char *)buffer;
                for (p = dp, i = 0; i < n; i+=nbytes) {
                    for (k = 0, j = i; k < nchans_ai; k++) {
                        if (pwork->m_data_type[k] == 's') {
                            *p++ = (double)(*((short *)&cbuff[j]));
                            j += 2;
                        } else {
                            *p++ = (double)(*((int   *)&cbuff[j]));
                            j += 4;
                        }
                    }
                }
            } else {
                sbuff = (short *)buffer;
                n = nsamps*nchans_ai;
                for (p = dp, i = 0; i < n; i++)  *p++ = (double)sbuff[i];
            }

            // Di pattern
            if (nlhs > 3) {
                datatype = mxUINT8_CLASS;
                for (i = 0; i < nchans_di; i++) {
                    switch (pwork->m_data_type[nchans_ai+i]) {
                    case 's':
                        if (datatype == mxUINT8_CLASS)   datatype = mxUINT16_CLASS;
                        break;
                    case 'i':
                        if (datatype != mxUINT32_CLASS)  datatype = mxUINT32_CLASS;
                        break;
                    }
                }
                noffs = 0;
                for (i = 0; i < nchans_ai; i++) {
                    if (pwork->m_data_type[i] == 's')  noffs += 2;
                    else                               noffs += 4;
                }

                dims[0] = nchans_di;  dims[1] = nsamps;
                OUT_DI_PATT = mxCreateNumericArray(2, dims, datatype, mxREAL);
                n = nbytes*nsamps;
                if (datatype ==  mxUINT8_CLASS) {
                    ucbuf = (unsigned char *)buffer;
                    ucout = (unsigned char *)mxGetData(OUT_DI_PATT);
                    for (i = noffs; i < n; i+=nbytes) {
                        for (k = 0, j = i; k < nchans_di; k++) {
                            *ucout++ = ucbuf[j];
                            j++;
                        }
                    }
                } else if (datatype == mxUINT16_CLASS) {
                    cbuff = (char *)buffer;
                    usout = (unsigned short *)mxGetData(OUT_DI_PATT);
                    for (i = noffs; i < n; i+=nbytes) {
                        for (k = 0, j=i; k < nchans_di; k++) {
                            if (pwork->m_data_type[k] == 's') {
                                *usout++ = *(unsigned short *)&cbuff[j];
                                j+=2;
                            } else {
                                *usout++ = (unsigned short)(*(unsigned char *)&cbuff[j]);
                                j++;
                            }
                        }
                    }
                } else {
                    cbuff = (char *)buffer;
                    uiout = (unsigned int *)mxGetData(OUT_DI_PATT);
                    for (i = noffs; i < n; i+=nbytes) {
                        for (k = 0, j=i; k < nchans_di; k++) {
                            switch (pwork->m_data_type[k]) {
                            case 'i':
                                *uiout++ = *(unsigned int *)&cbuff[j];
                                j+=4;
                                break;
                            case 's':
                                *uiout++ = (unsigned int)(*(unsigned short *)&cbuff[j]);
                                j+=2;
                                break;
                            case 'c':
                                *uiout++ = (unsigned int)(*(unsigned char *)&cbuff[j]);
                                j++;
                                break;
                            }
                        }
                    }
                }
            }
            // Di port width
            if (nlhs > 4) {
                OUT_DI_PORT_WIDTH =  mxCreateDoubleMatrix(nchans_di,1,mxREAL);
                dp = mxGetPr(OUT_DI_PORT_WIDTH);
                for (p = dp, i = 0; i < nchans_di; i++) {
                    switch (pwork->m_data_type[nchans_ai+i]) {
                    case 'c':
                        *p++ =  8.0;  break;
                    case 's':
                        *p++ = 16.0;  break;
                    case 'i':
                        *p++ = 32.0;  break;
                    }
                }
            }
        } else {
            // Ai waveform
            OUT_AI_WAVE = mxCreateDoubleMatrix(0,0,mxREAL);
            // Di pattern
            if (nlhs > 3)  OUT_DI_PATT = mxCreateDoubleMatrix(0,0,mxREAL);
            // Di port width
            if (nlhs > 4)  OUT_DI_PORT_WIDTH =  mxCreateDoubleMatrix(0,0,mxREAL);
        }
        if (buffer != NULL)  {  mxFree(buffer);  buffer = NULL;  }
    } else {
        endtime = 0;
        sampt   = 0;
        // Ai waveform
        OUT_AI_WAVE = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(OUT_AI_WAVE) = -1;
        // Di pattern
        if (nlhs > 3) {
            OUT_DI_PATT = mxCreateDoubleMatrix(1,1,mxREAL);
            *mxGetPr(OUT_DI_PATT) = -1;
        }
        // Di port width
        if (nlhs > 4)  OUT_DI_PORT_WIDTH =  mxCreateDoubleMatrix(0,0,mxREAL);
    }

    // endtime
    if (nlhs > 1) {
        OUT_ENDTIME = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(OUT_ENDTIME) = endtime;  // in msec
    }
    // sampt
    if (nlhs > 2) {
        OUT_SAMPT = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(OUT_SAMPT) = sampt;  // in msec
    }

    return;
}

void cmd_llevel(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int logicH, logicL;

    if (nrhs != 3)  mexErrMsgTxt(" no logigH, logicL");
    if (!mxIsNumeric(INP_LOGIC_H))   mexErrMsgTxt(" failed to get logicH");
    if (!mxIsNumeric(INP_LOGIC_L))   mexErrMsgTxt(" failed to get logicL");
    logicH = (int)mxGetScalar(INP_LOGIC_H);
    logicL = (int)mxGetScalar(INP_LOGIC_L);

    if (logicH < logicL) {
        gLogicH = logicL;  gLogicL = logicH;
    } else {
        gLogicH = logicH;  gLogicL = logicL;
    }

    return;
}


/* MEX function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    static int initialized = 0;
    char *cmdstr = NULL;
    int buflen;

    /* initialization */
    if (initialized == 0) {
        enet_startup();
        for (buflen = 0; buflen < MAX_SOCKETS; buflen++) {
            memset(&gWsWork[buflen],0,sizeof(WSWORK));
            gWsWork[buflen].m_sock      = INVALID_SOCKET;
            gWsWork[buflen].m_active    = 0;
            gWsWork[buflen].m_buff      = NULL;
            gWsWork[buflen].m_data_type = NULL;
            gWsWork[buflen].m_channels  = NULL;
            EXCLUSION_INIT(&gWsWork[buflen].m_lock);
        }
        gNumSockets = 0;
        mexAtExit(netOnExit);
        initialized = 1;
    }

    /* Check for proper number of arguments. */
    if (nrhs < 1) {
        mexPrintf("Usage: [ret,...] = netstreamer(cmd,...)\n");
        mexPrintf("       cmd as 'longin'|'read'|'logout'\n");
        mexPrintf("ver.1.10 Sep-2013,  See 'help netstreamer' for detail.\n");
        return;
    }

    // get a command string
    if (!mxIsChar(INP_COMMAND_STR)) 	mexErrMsgTxt(" failed to get command");
    buflen = (int)mxGetM(INP_COMMAND_STR)*(int)mxGetN(INP_COMMAND_STR) + 1;
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
    } else if (STRICMP(cmdstr,"logiclevel") == 0) {
        cmd_llevel(nlhs, plhs, nrhs, prhs);
    } else {
        mexErrMsgTxt(" not supported command.");
        //mexPrintf("%s ERROR: not supported command '%s'.\n",
        //          mexFunctionName(),cmdstr);
    }

    mxFree(cmdstr);

    return;

}
