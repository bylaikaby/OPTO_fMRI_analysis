/*****************************************************************************
** Copyright (C) Cambridge Electronic Design Limited 1988-2005
** All Rights Reserved
**
** son.h
**                                                               78 cols --->*
** Definitions of the structures and routines for the SON filing             *
** system. This is the include file for standard use, all access             *
** is by means of functions - no access to the internal SON data. The file   *
** machine.h provides some common definitions across separate platforms,     *
** note that the MS variants are designed to accomodate medium model - far   *
** pointers are explicitly used where necessary.
**
** SONAPI Don't declare this to give a pascal type on the Mac, there is a MPW
**        compiler bug that corrupts floats passed to pascal functions!!!!!!
**
** 01/Feb/00    GPS Added SON_MAXADCMARK as maximum points allowed in a spike
** 04/Feb/02    TDB Added SONIsSaving and SONBookFileSpace functions.
** 17/Nov/04    TDB Added SONChanBytes function.
**
*/

#ifndef __SON__
#define __SON__

#include "machine.h"

#if defined(macintosh) || defined(_MAC) /* define SONCONVERT in here if you want it */
//    #include <Types.h>   NBNB     this gets rid of stupid VC++
//    #include <Files.h>            dependency search errors
//    #include <Errors.h>
#define  SONAPI(type) type
#undef LLIO                         /* LLIO is not used for Mac             */
#endif                              /* End of the Mac stuff, now for DOS    */

#ifdef _IS_MSDOS_
    #include <malloc.h>
    #include <dos.h>
    #include <errno.h>
    #define LLIO                    /* We can use LLIO for MSC/DOS          */
    #define SONAPI(type) type _pascal
#endif

#if defined(_IS_WINDOWS_) && !defined(_MAC) && !defined(WIN32)
    #define LLIO                    /* We can use LLIO for MSC/Windows      */
    #define SONAPI(type) type WINAPI
#endif

#ifdef WIN32
    #undef  LLIO                    /* We can use LLIO for MSC/Windows      */
    #define SONAPI(type) type WINAPI
#endif

#define SONMAXCHANS 32              /* The old limit on channels, now the minimum number */
#define SONABSMAXCHANS 451          /* Maximum possible channels from SON file structures */

/*
** Now define the error constants used throughout the program
*/
#define SON_NO_FILE  -1
#define SON_NO_DOS_FILE -2          /* Not used by son.c - historical */
#define SON_NO_PATH -3              /* Not used by son.c - historical */
#define SON_NO_HANDLES -4
#define SON_NO_ACCESS  -5
#define SON_BAD_HANDLE -6
#define SON_MEMORY_ZAP -7           /* Not used by son.c - historical */
#define SON_OUT_OF_MEMORY -8
#define SON_INVALID_DRIVE -15       /* Not used by son.c - historical (Mac?) */
#define SON_OUT_OF_HANDLES -16      /* This refers to SON file handles */

#define SON_FILE_ALREADY_OPEN -600  /* Used on 68k Mac, not used by son.c */

#define SON_BAD_READ -17
#define SON_BAD_WRITE -18

/*
** now some of our own errors, put in holes that we think we will never
** get from DOS... famous last words!
*/
#define SON_NO_CHANNEL -9
#define SON_CHANNEL_USED -10
#define SON_CHANNEL_UNUSED -11
#define SON_PAST_EOF -12
#define SON_WRONG_FILE -13
#define SON_NO_EXTRA -14
#define SON_CORRUPT_FILE -19
#define SON_PAST_SOF -20
#define SON_READ_ONLY -21
#define SON_BAD_PARAM -22

/*
** These constants define the number and length of various strings
*/
#define SON_NUMFILECOMMENTS 5
#define SON_COMMENTSZ 79
#define SON_CHANCOMSZ 71
#define SON_UNITSZ 5
#define SON_TITLESZ 9

/*
** These define the types of data we can store in our file, and a type
** that will hold one of these values.
*/
typedef enum
{
    ChanOff=0,          /* the channel is OFF - */
    Adc,                /* a 16-bit waveform channel */
    EventFall,          /* Event times (falling edges) */
    EventRise,          /* Event times (rising edges) */
    EventBoth,          /* Event times (both edges) */
    Marker,             /* Event time plus 4 8-bit codes */
    AdcMark,            /* Marker plus Adc waveform data */
    RealMark,           /* Marker plus float numbers */
    TextMark,           /* Marker plus text string */
    RealWave            /* waveform of float numbers */
} TDataKind;

/*
** These constants defines the state of a created file. They should never be
** used in modern code.
*/
#define FastWrite 0
#define NormalWrite 1

/*
**  The TMarker structure defines the marker data structure, which holds
**  a time value with associated data. The TAdcMark structure is a marker
**  with attached array of ADC data. TRealMark and TTextMark are very
**  similar - with real or text data attached.
*/
typedef long TSTime;
#define TSTIME_MAX LONG_MAX
typedef short TAdc;
typedef char TMarkBytes[4];


typedef struct
{
    TSTime mark;                /* Marker time as for events */
    TMarkBytes mvals;           /* the marker values */
} TMarker;

#define SON_MAXADCMARK 1024     /* maximum points in AdcMark data (arbitrary) */
#define SON_MAXAMTRACE 4        /* maximum interleaved traces in AdcMark data */
typedef struct
{
    TMarker m;                  /* the marker structure */
    TAdc a[SON_MAXADCMARK*SON_MAXAMTRACE];     /* the attached ADC data */
} TAdcMark;

#define SON_MAXREALMARK 512     /* maximum points in RealMark (arbitrary) */
typedef struct
{
    TMarker m;                  /* the marker structure */
    float r[SON_MAXREALMARK];   /* the attached floating point data */
} TRealMark;

#define SON_MAXTEXTMARK 2048    /* maximum points in a Textmark (arbitrary) */
typedef struct
{
    TMarker m;                  /* the marker structure */
    char t[SON_MAXTEXTMARK];    /* the attached text data */
} TTextMark;

typedef TAdc FAR * TpAdc;
typedef TSTime FAR *TpSTime;
typedef TMarker FAR * TpMarker;
typedef TAdcMark FAR * TpAdcMark;
typedef TRealMark FAR * TpRealMark;
typedef TTextMark FAR * TpTextMark;
typedef char FAR * TpStr;
typedef const char FAR * TpCStr;
typedef WORD FAR * TpWORD;
typedef BOOLEAN FAR * TpBOOL;
typedef float FAR * TpFloat;
typedef void FAR * TpVoid;
typedef short FAR * TpShort;
typedef TMarkBytes FAR * TpMarkBytes;

/* 
**
** The marker filter extensions to SON
**
** The declaration of the types is only to allow you to declare a structure
** of type TFilterMask. This structure is to be passed into the two
** functions only. No other use should be made, except to save it, if
** needed.
**
** We have changed the implementation of TFilterMask so we can use the
** marker filer in different ways. As long as you made no use of cAllSet
** the changes should be transparent as the structure is the same size.
** if you MUST have the old format, #define SON_USEOLDFILTERMASK
**
** In the new method we no longer use flags to show that an entire layer is
** set. Instead, we have a filter mode (bit 0 of the lFlags). All other bits
** should be 0 as we will use them for further modes in future and we intend
** this to be backwards compatible.
**
** We also have define a new function to get/set the filter mode. We avoid bits
** 0, 8, 16 and 24 as these were used in the old version to flag complete masks.
**
*/

#define SON_FMASKSZ 32                      /* number of TFilterElt in mask */
typedef unsigned char TFilterElt;           /* element of a map */
typedef TFilterElt TLayerMask[SON_FMASKSZ]; /* 256 bits in the bitmap */

typedef struct
{
#ifdef SON_USEOLDFILTERMASK
    char cAllSet[4];                        /* set non-zero if all markers enabled */
#else
    long lFlags;                            /* private flags used by the marker filering */
#endif
    TLayerMask aMask[4];                    /* set of masks for each layer */
} TFilterMask;

#define SON_FMASK_ORMODE 0x02000000         /* use OR if data rather than AND */
#define SON_FMASK_ANDMODE 0x00000000
#define SON_FMASK_VALID  0x02000000         /* bits that are valid in the mask */

typedef TFilterMask FAR *TpFilterMask;

#define SON_FALLLAYERS  -1
#define SON_FALLITEMS   -1
#define SON_FCLEAR      0
#define SON_FSET        1
#define SON_FINVERT     2
#define SON_FREAD       -1


#ifdef __cplusplus
extern "C" {
#endif


/*
** Now definitions of the functions defined in the code
*/
SONAPI(void) SONInitFiles(void);
SONAPI(void) SONCleanUp(void);

#if defined(macintosh) || defined(_MAC)
SONAPI(short) SONOpenOldFile(ConstStr255Param name, short vRefNum, long dirID,
                    SignedByte perm);
SONAPI(short) SONOpenNewFile(ConstStr255Param name, short fMode, unsigned short extra,
                short vRefNum, long dirID, SignedByte perm, 
                OSType creator, OSType fileType);
#else
SONAPI(short) SONOpenOldFile(const char* name, int iOpenMode);
SONAPI(short) SONOpenNewFile(const char* name, short fMode, unsigned short extra);
#endif

SONAPI(short) SONCanWrite(short fh);
SONAPI(short) SONCloseFile(short fh);
SONAPI(short) SONEmptyFile(short fh);
SONAPI(short) SONSetBuffSpace(short fh);
SONAPI(short) SONGetFreeChan(short fh);
SONAPI(void) SONSetFileClock(short fh, unsigned short usPerTime, unsigned short timePerADC);
SONAPI(short) SONSetADCChan(short fh, unsigned short chan, short sPhyCh, short dvd,
                 long lBufSz, const char* szCom, const char* szTitle, float fRate,
                 float scl, float offs, const char* szUnt);
SONAPI(short) SONSetADCMarkChan(short fh, unsigned short chan, short sPhyCh, short dvd,
                 long lBufSz, const char* szCom, const char* szTitle, float fRate, float scl,
                 float offs, const char* szUnt, unsigned short points, short preTrig);
SONAPI(short) SONSetWaveChan(short fh, unsigned short chan, short sPhyCh, TSTime dvd,
                 long lBufSz, const char* szCom, const char* szTitle,
                 float scl, float offs, const char* szUnt);
SONAPI(short) SONSetWaveMarkChan(short fh, unsigned short chan, short sPhyCh, TSTime dvd,
                 long lBufSz, const char* szCom, const char* szTitle, float fRate, float scl,
                 float offs, const char* szUnt, unsigned short points, short preTrig, int nTrace);
SONAPI(short) SONSetRealMarkChan(short fh, unsigned short chan, short sPhyCh,
                 long lBufSz, const char* szCom, const char* szTitle, float fRate,
                 float min, float max, const char* szUnt, unsigned short points);
SONAPI(short) SONSetTextMarkChan(short fh, unsigned short chan, short sPhyCh,
                 long lBufSz, const char* szCom, const char* szTitle,
                 float fRate, const char* szUnt, unsigned short points);
SONAPI(void) SONSetInitLow(short fh, unsigned short chan, short bLow);
SONAPI(short) SONSetEventChan(short fh, unsigned short chan, short sPhyCh,
                 long lBufSz, const char* szCom, const char* szTitle, float fRate, TDataKind evtKind);

SONAPI(short) SONSetBuffering(short fh, int nChan, int nBytes);
SONAPI(short) SONUpdateStart(short fh);
SONAPI(void) SONSetFileComment(short fh, unsigned short which, const char* szFCom);
SONAPI(void) SONGetFileComment(short fh, unsigned short which, char * pcFCom, short sMax);
SONAPI(void) SONSetChanComment(short fh, unsigned short chan, const char* szCom);
SONAPI(void) SONGetChanComment(short fh, unsigned short chan, char * pcCom, short sMax);
SONAPI(void) SONSetChanTitle(short fh, unsigned short chan, const char* szTitle);
SONAPI(void) SONGetChanTitle(short fh, unsigned short chan, char * pcTitle);
SONAPI(void) SONGetIdealLimits(short fh, unsigned short chan, float* pfRate, float* pfMin, float* pfMax);
SONAPI(unsigned short) SONGetusPerTime(short fh);
SONAPI(unsigned short) SONGetTimePerADC(short fh);
SONAPI(void) SONSetADCUnits(short fh, unsigned short chan, const char* szUnt);
SONAPI(void) SONSetADCOffset(short fh, unsigned short chan, float offset);
SONAPI(void) SONSetADCScale(short fh, unsigned short chan, float scale);
SONAPI(void) SONGetADCInfo(short fh, unsigned short chan, float* scale, float* offset,
                 char * pcUnt, unsigned short* points, short* preTrig);
SONAPI(void) SONGetExtMarkInfo(short fh, unsigned short chan, char * pcUnt,
                 unsigned short* points, short* preTrig);

SONAPI(short) SONWriteEventBlock(short fh, unsigned short chan, TpSTime plBuf, long count);
SONAPI(short) SONWriteMarkBlock(short fh, unsigned short chan, TpMarker pM, long count);
SONAPI(TSTime) SONWriteADCBlock(short fh, unsigned short chan, TpAdc psBuf, long count, TSTime sTime);
SONAPI(short) SONWriteExtMarkBlock(short fh, unsigned short chan, TpMarker pM, long count);

SONAPI(short) SONSave(short fh, int nChan, TSTime sTime, short bKeep);
SONAPI(short) SONSaveRange(short fh, int nChan, TSTime sTime, TSTime eTime);
SONAPI(short) SONKillRange(short fh, int nChan, TSTime sTime, TSTime eTime);
SONAPI(short) SONIsSaving(short fh, int nChan);
SONAPI(unsigned long) SONFileBytes(short fh);
SONAPI(unsigned long) SONChanBytes(short fh, unsigned short chan);

SONAPI(short) SONLatestTime(short fh, unsigned short chan, TSTime sTime);
SONAPI(short) SONCommitIdle(short fh);
SONAPI(short) SONCommitFile(short fh, short bDelete);

SONAPI(long) SONGetEventData(short fh, unsigned short chan, TpSTime plTimes, long max,
                  TSTime sTime, TSTime eTime, TpBOOL levLowP, 
                  TpFilterMask pFiltMask);
SONAPI(long) SONGetMarkData(short fh, unsigned short chan,TpMarker pMark, long max,
                  TSTime sTime,TSTime eTime, TpFilterMask pFiltMask);
SONAPI(long) SONGetADCData(short fh,unsigned short chan,TpAdc adcDataP, long max,
                  TSTime sTime,TSTime eTime,TpSTime pbTime, 
                  TpFilterMask pFiltMask);

SONAPI(long) SONGetExtMarkData(short fh, unsigned short chan, TpMarker pMark, long max,
                  TSTime sTime,TSTime eTime, TpFilterMask pFiltMask);
SONAPI(long) SONGetExtraDataSize(short fh);
SONAPI(int) SONGetVersion(short fh);
SONAPI(short) SONGetExtraData(short fh, TpVoid buff, unsigned short bytes,
                  unsigned short offset, short writeIt);
SONAPI(short) SONSetMarker(short fh, unsigned short chan, TSTime time, TpMarker pMark,
                  unsigned short size);
SONAPI(short)  SONChanDelete(short fh, unsigned short chan);
SONAPI(TDataKind) SONChanKind(short fh, unsigned short chan);
SONAPI(TSTime) SONChanDivide(short fh, unsigned short chan);
SONAPI(unsigned short)   SONItemSize(short fh, unsigned short chan);
SONAPI(TSTime) SONChanMaxTime(short fh, unsigned short chan);
SONAPI(TSTime) SONMaxTime(short fh);

SONAPI(TSTime) SONLastTime(short fh, unsigned short wChan, TSTime sTime, TSTime eTime,
                    TpVoid pvVal, TpMarkBytes pMB,
                    TpBOOL pbMk, TpFilterMask pFiltMask);

SONAPI(TSTime) SONLastPointsTime(short fh, unsigned short wChan, TSTime sTime, TSTime eTime,
                    long lPoints, short bAdc, TpFilterMask pFiltMask);

SONAPI(long) SONFileSize(short fh);
SONAPI(int) SONMarkerItem(short fh, unsigned short wChan, TpMarker pBuff, int n,
                                          TpMarker pM, TpVoid pvData, short bSet);

SONAPI(int) SONFilter(TpMarker pM, TpFilterMask pFM);
SONAPI(int) SONFControl(TpFilterMask pFM, int layer, int item, int set);
SONAPI(short) SONFEqual(TpFilterMask pFiltMask1, TpFilterMask pFiltMask2);
SONAPI(int) SONFActive(TpFilterMask pFM);   // added 14/May/02

#ifndef SON_USEOLDFILTERMASK
SONAPI(long) SONFMode(TpFilterMask pFM, long lNew);
#endif

/****************************************************************************
** New things added at Revision 6
*/
typedef struct
{
    unsigned char ucHun;    /* hundreths of a second, 0-99 */
    unsigned char ucSec;    /* seconds, 0-59 */
    unsigned char ucMin;    /* minutes, 0-59 */
    unsigned char ucHour;   /* hour - 24 hour clock, 0-23 */
    unsigned char ucDay;    /* day of month, 1-31 */
    unsigned char ucMon;    /* month of year, 1-12 */
    unsigned short wYear;             /* year 1980-65535! */
}TSONTimeDate;

#if defined(macintosh) || defined(_MAC)
SONAPI(short) SONCreateFile(ConstStr255Param name, int nChannels, unsigned short extra, 
                short vRefNum, long dirID, SignedByte perm, 
                OSType creator, OSType fileType);
#else
SONAPI(short) SONCreateFile(const char* name, int nChannels, unsigned short extra);
#endif
SONAPI(int) SONMaxChans(short fh);
SONAPI(int) SONPhyChan(short fh, unsigned short wChan);
SONAPI(float) SONIdealRate(short fh, unsigned short wChan, float fIR);
SONAPI(void) SONYRange(short fh, unsigned short chan, float* pfMin, float* pfMax);
SONAPI(int) SONYRangeSet(short fh, unsigned short chan, float fMin, float fMax);
SONAPI(int) SONMaxItems(short fh, unsigned short chan);
SONAPI(int) SONPhySz(short fh, unsigned short chan);
SONAPI(int) SONBlocks(short fh, unsigned short chan);
SONAPI(int) SONDelBlocks(short fh, unsigned short chan);
SONAPI(int) SONSetRealChan(short fh, unsigned short chan, short sPhyChan, TSTime dvd,
                 long lBufSz, const char* szCom, const char* szTitle,
                 float scale, float offset, const char* szUnt);
SONAPI(TSTime) SONWriteRealBlock(short fh, unsigned short chan, float* pfBuff, long count, TSTime sTime);
SONAPI(long) SONGetRealData(short fh, unsigned short chan, float* pfData, long max,
                  TSTime sTime,TSTime eTime,TpSTime pbTime, 
                  TpFilterMask pFiltMask);
SONAPI(int) SONTimeDate(short fh, TSONTimeDate* pTDGet, const TSONTimeDate* pTDSet);
SONAPI(double) SONTimeBase(short fh, double dTB);
typedef struct {char acID[8];} TSONCreator;    /* application identifier */
SONAPI(int) SONAppID(short fh, TSONCreator* pCGet, const TSONCreator* pCSet);
SONAPI(int) SONChanInterleave(short fh, unsigned short chan);

/* Version 7 */
SONAPI(int) SONExtMarkAlign(short fh, int n);
#ifdef __cplusplus
}
#endif

#endif /* __SON__ */
