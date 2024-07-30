/*****************************************************************************
** Copyright (C) Cambridge Electronic Design Limited 1988-2003
** All Rights Reserved
**
** sonintl.h
**
******************************************************************************
**
**  Definitions of the file structures and other internals for the SON
**  filing system. This is not normally required by library users, but
**  is supplied for specialised use. The file machine.h (included in son.h)
**  provides some common definitions across separate platforms.
**
**  This should be included AFTER son.h.
**
*/

#ifndef __SON__
#include "son.h"
#endif

#ifndef __SONINTL__
#define __SONINTL__

#define LSTRING(size) union{unsigned char len;char string[size+1];}

#define SON_VER 8                           /* the version of the library */
#ifdef WIN32
#define MAXFILES 256                        /* The maximum number of files allowed */
#else
#define MAXFILES 32                         /* The maximum number of files allowed */
#endif

#define MINLOOK 32                          /* Initial lookup table entries per channel */
#define MAXLOOK 2048                        /* Lookup table entries per channel */
#define MAXWBUF 128                         /* Write buffers per channel in new file */
#define CHANGES 8                           /* Stored changes per channel in new file */
#define DISKBLOCK 512                       /* Size of a disk block */
#define ROUND_TO_DB(num) (((num)+DISKBLOCK-1)&0xfe00)
#define LENCOPYRIGHT  10                    /* Length of copyright and serial strings */
#define COPYRIGHT "(C) CED 87"              /* The copyright string used */

/*
** the field osFormat is a 16 bit word, used to detect file format, so byte
** swapping will not affect this value
*/
#define DOSFORMAT   0x0000
#define MACFORMAT   0x0101
#if defined(macintosh) || defined(_MAC)
#define OSFORMAT MACFORMAT
#else
#define OSFORMAT DOSFORMAT
#endif

#define CHAINEND -1  /* The value that indicates the end of chain of blocks */

typedef LSTRING(SON_CHANCOMSZ) TChanComm;
typedef LSTRING(SON_COMMENTSZ) TComment;
typedef LSTRING(SON_TITLESZ) TTitle;
typedef TComment TFileComment[SON_NUMFILECOMMENTS];  /* file comment for header */
typedef LSTRING(SON_UNITSZ) TUnits;            /* units string for adc channels */

/*
** Macro to mode a generic pointer on by n bytes
*/
#define movePtr(p,n) ((void FAR *)((TpStr)(p) + (n)))

#if defined(_IS_MSDOS_) || defined(_IS_WINDOWS_)
#pragma pack(2)
#endif

/*
** Now a structure which defines the first disk block of a file.  We
** pad the structure out to 512 bytes as we assume that all files are
** efficient if we make reads and writes multiples of 512
*/
typedef struct                    /* first disk block of file */
{
    short systemID;               /* filing system revision level */
    char copyright[LENCOPYRIGHT]; /* space for "(C) CED 87" */
    TSONCreator creator;          /* optional application identifier */
    WORD usPerTime;               /* microsecs per time unit */
    WORD timePerADC;              /* time units per ADC interrupt */
    short fileState;              /* condition of the file */
    long firstData;               /* offset to first data block */
    short channels;               /* maximum number of channels */
    WORD chanSize;                /* memory size to hold chans */
    WORD extraData;               /* No of bytes of extra data in file */
    WORD bufferSz;                /* Not used on disk; bufferP in bytes */
    WORD osFormat ;               /* either 0x0101 for Mac, or 0x00 for PC */
    TSTime maxFTime;              /* max time in the data file */
    double dTimeBase;             /* time scale factor, normally 1.0e-6 */
    TSONTimeDate timeDate;        /* time that corresponds to tick 0 */ 
    char cAlignFlag;              /* 0 if not aligned to 4, set bit 1 if aligned */
    char pad[51];                 /* padding for the future */
    TFileComment fileComment;     /* what user thinks of it so far */
} TFileHead;

typedef TFileHead FAR * TpFileHead;

/*
** TChannel is a structure which tells us about an individual channel
** of data.  An array of these follows the header block of the file.
*/
typedef struct
{
    WORD delSize;       /* number of blocks in deleted chain, 0=none */
    long nextDelBlock;  /* if deleted, first block in chain pointer */
    long firstBlock;    /* points at first block in file */
    long lastBlock;     /* points at last block in file */
    WORD blocks;        /* number of blocks in file holding data */
    WORD nExtra;        /* Number of extra bytes attached to marker */
    short preTrig;      /* Pre-trig points for ADC Marker data */
    short free0;        /* Keeps space OK */
    WORD phySz;         /* physical size of block written =n*512 */
    WORD maxData;       /* maximum number of data items in block */
    TChanComm comment;  /* string commenting on this data */
    long maxChanTime;   /* last time on this channel */
    long lChanDvd;      /* Was 0, V6: waveform divide from usPerTime, else 0 */
    short phyChan;      /* physical channel used */
    TTitle title;       /* user name for channel */
    float idealRate;    /* ideal rate:ADC, estimate:event */
    unsigned char kind; /* data type in the channel - really is TDataKind*/
    unsigned char pad;  /* padding just to keep up with Pascal... */

    union                       /* Section which changes with the data */
    {
        struct
        {                       /* Data for ADC and ADCMark channels */
            float scale;
            float offset;       /* to convert to units */
            TUnits units;       /* channel units */
            WORD divide;        /* was ADC divide, now AdcMark interleave */
        } adc;
        struct
        {                       /* only used by EventBoth channels */
            BOOLEAN initLow;    /* initial event state */
            BOOLEAN nextLow;    /* expected state of next write */
        } event;
        struct
        {                       /* This one for real marker data */
            float min;          /* expected minimum value */
            float max;          /* expected maximum value */
            TUnits units;       /* channel units */
        } real;                 /* NB this is laid out as for adc data */
    } v;

} TChannel;

typedef TChannel FAR * TpChannel;

/*
** Now a structure, being all the channels in an array.  This is saved
** on disk starting at offset 512 into the file. We also define a Macro for
** the size of this structure, rounded up to a disk block. Apologies for
** the 0xfe00, but this is simplest way to express the result.
*/
#define CHANSIZE(n) ((sizeof(TChannel)*n + DISKBLOCK-1) & 0xFE00)

/*
** These two macros convert channel numbers between the (rather nasty)
**  arrangement we are forced to use on disk and simple numbers used
**  internally. On disk channel numbers are 9 bits. We store the channel
**  number+1, with the bottonm 8 bits in the 8 bits of the data and the
**  ninth bit stored in the tenth bit of the data.
*/
#define CHFRDISK(n) (((n & 0xff) + ((n & 0x200) >> 1))-1)
#define CHTODISK(n) (((n+1) & 0xff) + (((n+1) & 0x100) << 1))

/*
** The data is stored in blocks (again multiples of 512 bytes long)
** on disk.  All the blocks have an identical header, but the rest
** depends on what the data is.
**
** On the Mac you're not allowed structs > 32k, so the original definition of
** TDataBlock will not compile. So I have defined ADCdataBlkSize etc to be
** half the size
*/
#if defined(macintosh) || defined(_MAC)
#define ADCdataBlkSize  16000
#define timeDataBlkSize 8000
#define markDataBlkSize 4000
#define realDataClkSize 4000
#else
#define ADCdataBlkSize  32000
#define timeDataBlkSize 16000
#define markDataBlkSize 8000
#define realDataBlkSize 8000
#endif

typedef struct
{
    long   predBlock;     /* Predecessor block in the file */
    long   succBlock;     /* Following block in the file */
    TSTime startTime;     /* First time in the block */
    TSTime endTime;       /* Last time in the block */
    WORD   chanNumber;    /* Channel number+1 for the block */
    WORD   items;         /* Actual number of data items found */
    union
    {
        TAdc      int2Data [ADCdataBlkSize];    /* ADC data */
        TSTime    int4Data [timeDataBlkSize];   /* time data */
        TMarker   markData [markDataBlkSize];   /* marker data */
        TAdcMark  adcMarkData;                  /* ADC marker data */
        float     realData [realDataBlkSize];   /* RealWave data */
    } data ;
} TDataBlock;

typedef TDataBlock FAR * TpDataBlock;
#define SONDBHEADSZ 20              /* size of the TDataBlock header itself */
extern TpDataBlock _near workP;     /* points at DISKBLOCK bytes work area */

#if (defined(_IS_MSDOS_) || defined(_IS_WINDOWS_)) && !defined(_MAC)
#pragma pack()
#endif


/*
** Define an internal type TFH here to stand in for the various
** file handle types used to make things
*/
#if defined(macintosh) || defined(_MAC)
  #define   TFH int
#else
  #ifdef WIN32
    #define TFH HANDLE
  #else
    #ifdef LLIO
      #define   TFH int
    #else
      #define   TFH FILE*
    #endif
  #endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
** Now declarations of the functions defined in the code
*/
SONAPI(short)  SONRead(short fh, void FAR * buffer, WORD bytes, long offset);
SONAPI(short)  SONWrite(short fh, void FAR * buffer, WORD bytes, long offset);
SONAPI(short)  SONGetBlock(short fh, long offset);
SONAPI(long)   SONGetPred(short fh, long offset) ;
SONAPI(long)   SONGetSucc(short fh, long offset);
SONAPI(short)  SONSetSucc(short fh, long offset, long succOffs);
SONAPI(long)   SONFindBlock(short fh, WORD channel,TSTime sTime, TSTime eTime);
SONAPI(short)  SONReadBlock(short fh, WORD channel, long position);
SONAPI(short)  SONWriteBlock(short fh, WORD chan, BYTE* buffer, long items,
                            int nSize, TSTime sTime, TSTime eTime);
SONAPI(TpChannel) SONChanPnt(short fh, WORD chan);
SONAPI(TSTime) SONIntlChanMaxTime(short fh, WORD chan);
SONAPI(TSTime) SONIntlMaxTime(short fh);
SONAPI(long)   SONUpdateMaxTimes(short fh);
SONAPI(void)   SONExtendMaxTime(short fh, long time);
SONAPI(long)   SONGetFirstData(short fh);
SONAPI(TFH)    SONFileHandle(short fh);
SONAPI(short)  SONBookFileSpace(short fh, long lSpace);

/* from here on, functions that are new in VERSION 6 */
SONAPI(void)   SONSetPhySz(short fh, WORD chan, long lSize);

/*
** These two functions are intended to be used to find out about channel data
**  without reading it all. SONNextSection is used to find contiguous sections
**  of waveform data, SONItemCount returns the count of data items, primarily
**  for event type channels.
*/
//SONAPI(short)  SONNextSection(short fh, WORD chan, TSTime& sTime, TSTime& eTime);
//SONAPI(long)   SONItemCount(short fh, WORD chan);

#ifdef __cplusplus
}
#endif

#endif
