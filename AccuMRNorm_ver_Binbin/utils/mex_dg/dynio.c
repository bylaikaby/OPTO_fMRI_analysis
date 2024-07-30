/*
 *    YM  15.Jul.2013  "long" as "int32" to support 64bit *nix/mac system.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#if defined(SUN4) || defined(LYNX)
#include <unistd.h>
#endif

#include <zlib.h>
#include "df.h"
#include "dynio.h"
#include "flip.h"


#ifdef _WIN32
#define FILENO  _fileno
#define STRDUP  _strdup
#else
#define FILENO  fileno
#define STRDUP  strdup
#endif



static int dgFlipEvents = 0;	/* to make up for byte ordering probs */
char dgMagicNumber[] = { 0x21, 0x12, 0x36, 0x63 };
float dgVersion = 1.0;

#define DG_DATA_BUFFER_SIZE 64000

static void dgDumpBuffer(unsigned char *buffer, int n, int type, FILE *fp);
static unsigned char *DgBuffer = NULL;
static int DgBufferIndex = 0;
static int DgBufferSize;
static int DgRecording = 0;

/* Keep track of which structure we're in using a stack */
static int DgCurStruct = DG_TOP_LEVEL;
static char *DgCurStructName = "DG_TOP_LEVEL";
static TAG_INFO *DgStructStack = NULL;
static int DgStructStackIncrement = 10;
static int DgStructStackSize = 0;
static int DgStructStackIndex = -1;

static void send_event(unsigned char type, unsigned char *data);
static void send_bytes(int n, unsigned char *data);
static void push(unsigned char *data, int, int);

static int dguBufferToDynGroup(BUF_DATA *bdata, DYN_GROUP *dg);
static int dguBufferToDynList(BUF_DATA *bdata, DYN_LIST *dl);


/***********************************************************************/
/*                        Structure Tag Tables                         */
/***********************************************************************/

/*                                                             */
/*   Tag_ID      Tag_Name     Tag_Type      Struct_Type        */
/* ------------  ----------  ------------  -------------       */

TAG_INFO DGTopLevelTags[] = {
  { DG_VERSION_TAG,  "VERSION",    DF_VERSION,    DG_TOP_LEVEL },
  { DG_BEGIN_TAG,    "DYN_GROUP",  DF_STRUCTURE,  DYN_GROUP_STRUCT }
};

TAG_INFO DGTags[] = {
  { DG_NAME_TAG,   "NAME",          DF_STRING,     DG_TOP_LEVEL },
  { DG_NLISTS_TAG, "NDYNLISTS",     DF_INT32,      DG_TOP_LEVEL },
  { DG_DYNLIST_TAG,"DYN_LIST",      DF_STRUCTURE,  DYN_LIST_STRUCT }
};

TAG_INFO DLTags[] = {
  { DL_NAME_TAG,        "NAME",        DF_STRING,       DG_TOP_LEVEL },
  { DL_INCREMENT_TAG,   "INCREMENT",   DF_INT32,        DG_TOP_LEVEL },
  { DL_DATA_TAG,        "DATA",        DF_VOID_ARRAY,   DG_TOP_LEVEL },
  { DL_STRING_DATA_TAG, "STRING_DATA", DF_STRING_ARRAY, DG_TOP_LEVEL },
  { DL_CHAR_DATA_TAG,   "CHAR_DATA",   DF_CHAR_ARRAY,   DG_TOP_LEVEL },
  { DL_SHORT_DATA_TAG,  "SHORT_DATA",  DF_SHORT_ARRAY,  DG_TOP_LEVEL },
  { DL_INT32_DATA_TAG,  "LONG_DATA",   DF_INT32_ARRAY,  DG_TOP_LEVEL },
  { DL_FLOAT_DATA_TAG,  "FLOAT_DATA",  DF_FLOAT_ARRAY,  DG_TOP_LEVEL },
  { DL_LIST_DATA_TAG,   "LIST_DATA",   DF_LIST_ARRAY,   DG_TOP_LEVEL },
  { DL_SUBLIST_TAG,     "SUBLIST",     DF_STRUCTURE,    DYN_LIST_STRUCT },
  { DL_FLAGS_TAG,       "FLAGS",       DF_INT32,        DG_TOP_LEVEL }
};

TAG_INFO *DGTagTable[] = { DGTopLevelTags, DGTags, DLTags };

/**************************************************************************/
/*                      Initialization Routines                           */
/**************************************************************************/

void dgInitBuffer(void)
{
  DgBufferSize = DG_DATA_BUFFER_SIZE;
  if (!(DgBuffer = (unsigned char *)
	calloc(DgBufferSize, sizeof(unsigned char)))) {
    fprintf(stderr,"Unable to allocate dg buffer\n");
    return;
  }
  
  dgResetBuffer();
}

void dgResetBuffer(void)
{
  DgRecording = 1;
  DgBufferIndex = 0;
  
  dgPushStruct(DG_TOP_LEVEL, "DG_TOP_LEVEL");
  
  dgRecordMagicNumber();
  dgRecordFloat(T_VERSION_TAG, dgVersion);
}

void dgCloseBuffer(void)
{
  if (DgBuffer) free(DgBuffer);
  dgFreeStructStack();
  DgRecording = 0;
}

unsigned char *dgGetBuffer(void)
{
  return DgBuffer;
}

int dgGetBufferSize(void)
{
  return DgBufferIndex;
}

void dgWriteBuffer(char *filename, char format)
{
   FILE *fp = stdout;
   char *filemode = "wb+";
   
   switch (format) {
      case DF_BINARY:
	 filemode = "wb+";
	 break;
      default:
	 filemode = "w+";
	 break;
   }
   
   if (filename && filename[0]) {
     if (!(fp = fopen(filename,filemode))) {
       fprintf(stderr,"dg: unable to open file \"%s\" for output\n",
	       filename);
       return;
     }
   }
   dgDumpBuffer(DgBuffer, DgBufferIndex, format, fp);

   if (filename && filename[0]) fclose(fp);
}

int dgWriteBufferCompressed(char *filename)
{
  gzFile file;
  
  if (filename && filename[0]) {
    if (!(file = gzopen(filename, "wb"))) {
      fprintf(stderr,"dg: unable to open file \"%s\" for output\n",
	      filename);
      return 0;
    }
  }
  else {
    file = gzdopen(FILENO(stdout), "wb");
  }
  
  if (gzwrite(file, DgBuffer, DgBufferIndex) != DgBufferIndex) {
    return 0;
  }
  
  if (filename && filename[0]) {
    if (gzclose(file) != Z_OK) {
      return 0;
    }
  }
  return 1;
}

int dgReadDynGroup(char *filename, DYN_GROUP *dg)
{
  FILE *fp = stdin;
  char *filemode = "rb";
  int status = 0;
  
  if (filename && filename[0]) {
    if (!(fp = fopen(filename, filemode))) {
      return(0);
    }
  }
  status = dguFileToStruct(fp, dg);
  
  if (filename && filename[0]) fclose(fp);
  return(status);
}

#ifdef COMPRESSION
int dgReadDynGroupCompressed(char *filename, DYN_GROUP *dg)
{
  char buf[BUFSIZ];
  int len, err;
  FILE *fp;
  gzFile file;
  int status = 0;
  char fname[L_tmpnam];

  tmpnam(fname);
  if (!(fp = fopen(fname,"wr"))) {
    fprintf(stderr,"dg: unable to open temp file \"%s\"\n",
	    fname);
    return 0;
  }

  if (filename && filename[0]) {
    if (!(file = gzopen(filename, "rb"))) {
      fprintf(stderr,"dg: unable to open file \"%s\" for input\n",
	      filename);
      return 0;
    }
  }
  else {
    file = gzdopen(FILENO(stdout), "rb");
  }

  for (;;) {
    len = gzread(file, buf, sizeof(buf));
    if (len < 0) {
      fprintf(stderr, gzerror(file, &err));
      return 0;
    }
    if (len == 0) break;
    if (fwrite(buf, 1, (unsigned)len, fp) != len) {
      fprintf(stderr, "fwrite: error writing uncompressed file");
      if (filename && filename[0]) gzclose(file);
      fclose(fp);
      return 0;
    }
  }

  if (filename && filename[0]) {
    if (gzclose(file) != Z_OK) {
      return 0;
    }
  }

  rewind(fp);
  status = dguFileToStruct(fp, dg);
  
  fclose(fp);
  unlink(fname);
  
  return(status);
}
#endif



void dgLoadStructure(DYN_GROUP *dg)
{
  dguBufferToStruct(DgBuffer, DgBufferIndex, dg);
}

/*********************************************************************/
/*                   High Level Recording Funcs                      */
/*********************************************************************/


void dgRecordDynList(unsigned char tag, DYN_LIST *dl)
{
  dgBeginStruct(tag);
  dgRecordString(DL_NAME_TAG, DYN_LIST_NAME(dl));
  dgRecordInt32(DL_INCREMENT_TAG, DYN_LIST_INCREMENT(dl));
  dgRecordInt32(DL_FLAGS_TAG, DYN_LIST_FLAGS(dl));
  dgRecordVoidArray(DL_DATA_TAG, DYN_LIST_DATATYPE(dl), DYN_LIST_N(dl),
		    DYN_LIST_VALS(dl));
  dgEndStruct();
}

void dgRecordDynGroup(DYN_GROUP *dg)
{
  int i = 0;
  dgBeginStruct(DG_BEGIN_TAG);
  dgRecordString(DG_NAME_TAG, DYN_GROUP_NAME(dg));
  dgRecordInt32(DG_NLISTS_TAG, DYN_GROUP_NLISTS(dg));
  for (i = 0; i < DYN_GROUP_NLISTS(dg); i++) 
    dgRecordDynList(DG_DYNLIST_TAG, DYN_GROUP_LIST(dg,i));
  dgEndStruct();
}

/*********************************************************************/
/*                   Array Event Recording Funcs                     */
/*********************************************************************/

void dgBeginStruct(unsigned char tag)
{
  dgRecordFlag(tag);
  dgPushStruct(dgGetStructureType(tag), dgGetTagName(tag));
}

void dgEndStruct(void)
{
  dgRecordFlag(END_STRUCT);
  dgPopStruct();
}

void dgRecordVoidArray(unsigned char type, int datatype, int n, void *data)
{
  int i;
  send_event(type, NULL);
  switch (datatype) {
  case DF_CHAR:
    dgRecordCharArray(DL_CHAR_DATA_TAG, n, (char *) data);
    break;
  case DF_SHORT:
    dgRecordShortArray(DL_SHORT_DATA_TAG, n, (short *) data);
    break;
  case DF_INT32:
    dgRecordInt32Array(DL_INT32_DATA_TAG, n, (int32_t *) data);
    break;
  case DF_FLOAT:
    dgRecordFloatArray(DL_FLOAT_DATA_TAG, n, (float *) data);
    break;
  case DF_STRING:
    dgRecordStringArray(DL_STRING_DATA_TAG, n, (char **) data);
    break;
  case DF_LIST:
    {
      DYN_LIST **vals = (DYN_LIST **) data;
      dgRecordListArray(DL_LIST_DATA_TAG, n);
      for (i = 0; i < n; i++) {
	dgRecordDynList(DL_SUBLIST_TAG, vals[i]);
      }
    }
    break;
  }
}


void dgRecordString(unsigned char type, char *str)
{
  int length;
  if (!str) return;
  length = (int)strlen(str) + 1;
  send_event(type, (unsigned char *) &length);
  send_bytes(length, (unsigned char *)str);
}

void dgRecordStringArray(unsigned char type, int n, char **s)
{
  int length, i;
  char *str;
  
  if (!s) return;
  send_event(type, (unsigned char *) &n);
  
  for (i = 0; i < n; i++) {
    str = s[i];
    length = (int)strlen(str) + 1;
    send_bytes(sizeof(int), (unsigned char *) &length);
    send_bytes(length, (unsigned char *)str);
  }
}

void dgRecordInt32Array(unsigned char type, int n, int32_t *a)
{
  send_event(type, (unsigned char *) &n);
  send_bytes(n*sizeof(int32_t), (unsigned char *) a);
}

void dgRecordCharArray(unsigned char type, int n, char *a)
{
  send_event(type, (unsigned char *) &n);
  send_bytes(n*sizeof(char), (unsigned char *) a);
}

void dgRecordShortArray(unsigned char type, int n, short *a)
{
  send_event(type, (unsigned char *) &n);
  send_bytes(n*sizeof(short), (unsigned char *) a);
}

void dgRecordFloatArray(unsigned char type, int n, float *a)
{
  send_event(type, (unsigned char *) &n);
  send_bytes(n*sizeof(float), (unsigned char *) a);
}

void dgRecordListArray(unsigned char type, int n)
{
  send_event(type, (unsigned char *) &n);
}

/*********************************************************************/
/*                  Low Level Event Recording Funcs                  */
/*********************************************************************/

void dgRecordMagicNumber(void)
{
  send_bytes(DG_MAGIC_NUMBER_SIZE, (unsigned char *) dgMagicNumber);
}

void dgRecordFlag(unsigned char type)
{
  send_event(type, (unsigned char *) NULL);
}

void dgRecordChar(unsigned char type, unsigned char val)
{
  send_event(type, (unsigned char *) &val);
}

void dgRecordInt32(unsigned char type, int32_t val)
{
  send_event(type, (unsigned char *) &val);
}

void dgRecordShort(unsigned char type, short val)
{
  send_event(type, (unsigned char *) &val);
}

void dgRecordFloat(unsigned char type, float val)
{
  send_event(type, (unsigned char *) &val);
}


/*********************************************************************/
/*                    Keep Track of Current Structure                */
/*********************************************************************/

void dgPushStruct(int newstruct, char *name)
{
  if (!DgStructStack) 
    DgStructStack = 
      (TAG_INFO *) calloc(DgStructStackIncrement, sizeof(TAG_INFO));
  
  else if (DgStructStackIndex == (DgStructStackSize-1)) {
    DgStructStackSize += DgStructStackIncrement;
    DgStructStack = 
      (TAG_INFO *) realloc(DgStructStack, DgStructStackSize*sizeof(TAG_INFO));
  }
  DgStructStackIndex++;
  DgStructStack[DgStructStackIndex].struct_type = newstruct;
  DgStructStack[DgStructStackIndex].tag_name = name;
  DgCurStruct = newstruct;
  DgCurStructName = name;
}
    
int dgPopStruct(void)
{
  if (!DgStructStackIndex) {
    fprintf(stderr, "dgPopStruct(): popped to an empty stack\n");
    return(-1);
  }

  DgStructStackIndex--;
  DgCurStruct = DgStructStack[DgStructStackIndex].struct_type;
  DgCurStructName = DgStructStack[DgStructStackIndex].tag_name;

  return(DgCurStruct);
}

void dgFreeStructStack(void)
{
  if (DgStructStack) free(DgStructStack);
  DgStructStack = NULL;
  DgStructStackSize = 0;
  DgStructStackIndex = -1;
}

int dgGetCurrentStruct(void)
{
  return(DgCurStruct);
}

char *dgGetCurrentStructName(void)
{
  return(DgCurStructName);
}


char *dgGetTagName(int type)
{
  return(DGTagTable[DgCurStruct][type].tag_name);
}

int dgGetDataType(int type)
{
  return(DGTagTable[DgCurStruct][type].data_type);
}

int dgGetStructureType(int type)
{
  return(DGTagTable[DgCurStruct][type].struct_type);
}
/*********************************************************************/
/*               Local Byte Stream Handling Functions                */
/*********************************************************************/

static void send_event(unsigned char type, unsigned char *data)
{
/* First push the tag into the buffer */
  push((unsigned char *)&type, 1, 1);
  
/* The only "special" tag is the END_STRUCT tag, which means pop up */
  if (type == END_STRUCT) return;

/* All other tags may have data; check the current struct tag table  */
  switch(DGTagTable[DgCurStruct][type].data_type) {
  case DF_STRUCTURE:            /* data follows via tags             */
  case DF_FLAG:		
  case DF_VOID_ARRAY:
    break;
  case DF_STRING:		/* all of these start w/a int32   */
  case DF_STRING_ARRAY:
  case DF_INT32_ARRAY:
  case DF_SHORT_ARRAY:
  case DF_FLOAT_ARRAY:
  case DF_CHAR_ARRAY:
  case DF_LIST_ARRAY:
  case DF_INT32:
    push(data, sizeof(int32_t), 1);
    break;
  case DF_CHAR:
    push(data, sizeof(char), 1);
    break;
  case DF_SHORT:
    push(data, sizeof(short), 1);
    break;
  case DF_VERSION:
  case DF_FLOAT:
    push(data, sizeof(float), 1);
    break;
  default:
    fprintf(stderr,"Unrecognized event type: %d\n", type);
    break;
  }
}

static void send_bytes(int n, unsigned char *data)
{
  push(data, sizeof(unsigned char), n);
}

static void push(unsigned char *data, int size, int count)
{
   int nbytes, newsize;
   
   nbytes = count * size;
   
   if (DgBufferIndex + nbytes >= DgBufferSize) {
	 do {
	   newsize = DgBufferSize + DG_DATA_BUFFER_SIZE;
	   DgBuffer = (unsigned char *) realloc(DgBuffer, newsize);
	   DgBufferSize = newsize;
	 } while(DgBufferIndex + nbytes >= DgBufferSize);
   }
   
   memcpy(&DgBuffer[DgBufferIndex], data, nbytes);
   DgBufferIndex += nbytes;
}


/*************************************************************************/
/*                         Dump Helper Funcs                             */
/*************************************************************************/

static void dgDumpBuffer(unsigned char *buffer, int n, int type, FILE *fp)
{
  switch(type) {
  case DF_BINARY:
    fwrite(buffer, sizeof(unsigned char), n, fp);
    fflush(fp);
    break;
  case DF_ASCII:
    dguBufferToAscii(buffer, n, fp);
    break;
  default:
    break;
  }
}


/*--------------------------------------------------------------------
  -----               Magic Number Functions                     -----
  -------------------------------------------------------------------*/

static 
int confirm_magic_number(FILE *InFP)
{
  int i;
  for (i = 0; i < DG_MAGIC_NUMBER_SIZE; i++) {
    if (getc(InFP) != dgMagicNumber[i]) return(0);
  }
  return(1);
}

static 
int vconfirm_magic_number(char *s)
{
  int i;
  char number[DG_MAGIC_NUMBER_SIZE];
  memcpy(number, s, DG_MAGIC_NUMBER_SIZE);
  for (i = 0; i < DG_MAGIC_NUMBER_SIZE; i++) {
    if (number[i] != dgMagicNumber[i]) return(0);
  }
  return(1);
}


/*--------------------------------------------------------------------
  -----                   File Read Functions                    -----
  -------------------------------------------------------------------*/


static 
void read_version(FILE *InFP, FILE *OutFP)
{
  float val;
  if (fread(&val, sizeof(float), 1, InFP) != 1) {
     fprintf(stderr,"Error reading float info\n");
     exit(-1);
  }

  /* 
   * The VERSION should stay as a float, so that byte ordering can be 
   * checked dynamically.  If it doesn't match the first way, then the
   * dgFlipEvents flag is set and it's tried again.
   */

  if (val != dgVersion) {
    dgFlipEvents = 1;
    val = flipfloat(val);
    if (val != dgVersion) {
      fprintf(stderr,
	      "Unable to read this version of data file (V %5.1f/%5.1f)\n",
	      val, flipfloat(val));
      exit(-1);
    }
  }
  else dgFlipEvents = 0;
  fprintf(OutFP,"%-20s\t%3.1f\n", "DG_VERSION", val);
}

static 
void read_flag(char type, FILE *InFP, FILE *OutFP)
{
  fprintf(OutFP, "%-20s\n", dgGetTagName(type));
}

static 
void read_float(char type, FILE *InFP, FILE *OutFP)
{
  float val;
  if (fread(&val, sizeof(float), 1, InFP) != 1) {
     fprintf(stderr,"Error reading float info\n");
     exit(-1);
  }
  if (dgFlipEvents) val = flipfloat(val);

  fprintf(OutFP, "%-20s\t%6.3f\n", dgGetTagName(type), val);
}

static 
void read_char(char type, FILE *InFP, FILE *OutFP)
{
  char val;
  if (fread(&val, sizeof(char), 1, InFP) != 1) {
     fprintf(stderr,"Error reading char val\n");
     exit(-1);
  }
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), val);
}


static
void read_int32(char type, FILE *InFP, FILE *OutFP)
{
  int32_t val;
  
  if (fread(&val, sizeof(int32_t), 1, InFP) != 1) {
    fprintf(stderr,"Error reading int32 val\n");
    exit(-1);
  }
  
  if (dgFlipEvents) val = flipint32(val);
  
  fprintf(OutFP, "%-20s\t%ld\n", dgGetTagName(type), val);
}

static
void read_short(char type, FILE *InFP, FILE *OutFP)
{
  short val;
  
  if (fread(&val, sizeof(short), 1, InFP) != 1) {
    fprintf(stderr,"Error reading short val\n");
    exit(-1);
  }
  
  if (dgFlipEvents) val = flipshort(val);

  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), val);
}   


/*********************** ARRAY VERSIONS ************************/

static
void read_string(char type, FILE *InFP, FILE *OutFP)
{
  int length;
  char *str = "";

  if (fread(&length, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading string length\n");
    exit(-1);
  }
  
  if (dgFlipEvents) length = flipint32(length);
  if (length) {
    str = (char *) malloc(length);
    
    if (fread(str, length, 1, InFP) != 1) {
      fprintf(stderr,"Error reading\n");
      exit(-1);
    }
  }

  fprintf(OutFP, "%-20s\t%s\n", dgGetTagName(type), str);
  if (length) free(str);
}

static
void read_strings(char type, FILE *InFP, FILE *OutFP)
{
  int n, i;
  int length;
  char *str;

  if (fread(&n, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading string length\n");
    exit(-1);
  }
  if (dgFlipEvents) n = flipint32(n);
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type),n);

  for (i = 0; i < n; i++) {
    if (fread(&length, sizeof(int), 1, InFP) != 1) {
      fprintf(stderr,"Error reading string length\n");
      exit(-1);
    }
    if (dgFlipEvents) length = flipint32(length);
    
    str = "";
    if (length) {
      str = (char *) malloc(length);
      
      if (fread(str, length, 1, InFP) != 1) {
	fprintf(stderr,"Error reading\n");
	exit(-1);
      }
    }
    
    fprintf(OutFP, "%d\t%s\n", i, str);
    if (length) free(str);
  }
}

static
void read_chars(char type, FILE *InFP, FILE *OutFP)
{
  int nchars, i;
  char *vals = NULL;
  
  if (fread(&nchars, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of chars\n");
    exit(-1);
  }

  if (dgFlipEvents) nchars = flipint32(nchars);
  
  if (nchars) {
    if (!(vals = (char *) calloc(nchars, sizeof(char)))) {
      fprintf(stderr,"Error allocating memory for char array\n");
      exit(-1);
    }
    
    if (fread(vals, sizeof(char), nchars, InFP) != nchars) {
      fprintf(stderr,"Error reading char array\n");
      exit(-1);
    }
  }
  
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), nchars); 
  
  for (i = 0; i < nchars; i++) {
    fprintf(OutFP, "%d\t%c\n", i+1, vals[i]);
  }
  if (vals) free(vals);
}


static
void read_int32s(char type, FILE *InFP, FILE *OutFP)
{
  int nint32s, i;
  int32_t *vals = NULL;
  
  if (fread(&nint32s, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of int32s\n");
    exit(-1);
  }
  
  if (dgFlipEvents) nint32s = flipint32(nint32s);
  
  if (nint32s) {
    if (!(vals = (int32_t *) calloc(nint32s, sizeof(int32_t)))) {
      fprintf(stderr,"Error allocating memory for int32 array\n");
      exit(-1);
    }
    
    if (fread(vals, sizeof(int32_t), nint32s, InFP) != nint32s) {
      fprintf(stderr,"Error reading int32 array\n");
      exit(-1);
    }
    
    if (dgFlipEvents) flipint32s(nint32s, vals);
  }

  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), nint32s); 
  
  for (i = 0; i < nint32s; i++) {
    fprintf(OutFP, "%d\t%ld\n", i+1, vals[i]);
  }
  if (vals) free(vals);
}


static
void read_shorts(char type, FILE *InFP, FILE *OutFP)
{
  int nshorts, i;
  short *vals = NULL;
  
  if (fread(&nshorts, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of shorts\n");
    exit(-1);
  }
  
  if (dgFlipEvents) nshorts = flipint32(nshorts);
  
  if (nshorts) {
    if (!(vals = (short *) calloc(nshorts, sizeof(short)))) {
      fprintf(stderr,"Error allocating memory for short array\n");
      exit(-1);
    }
    
    if (fread(vals, sizeof(short), nshorts, InFP) != nshorts) {
      fprintf(stderr,"Error reading short array\n");
      exit(-1);
    }
    
    if (dgFlipEvents) flipshorts(nshorts, vals);
  }
  
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), nshorts); 
  
  for (i = 0; i < nshorts; i++) {
    fprintf(OutFP, "%d\t%d\n", i+1, vals[i]);
  }
  if (vals) free(vals);
}

static
void read_floats(char type, FILE *InFP, FILE *OutFP)
{
  int nfloats, i;
  float *vals = NULL;
  
  if (fread(&nfloats, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of floats\n");
    exit(-1);
  }
  
  if (dgFlipEvents) nfloats = flipint32(nfloats);
  
  if (nfloats) {
    if (!(vals = (float *) calloc(nfloats, sizeof(float)))) {
      fprintf(stderr,"Error allocating memory for float array\n");
      exit(-1);
    }
    
    if (fread(vals, sizeof(float), nfloats, InFP) != nfloats) {
      fprintf(stderr,"Error reading float array\n");
      exit(-1);
    }
    
    if (dgFlipEvents) flipfloats(nfloats, vals);
  }
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), nfloats); 
  
  for (i = 0; i < nfloats; i++) {
    fprintf(OutFP, "%d\t%6.2f\n", i+1, vals[i]);
  }
  if (vals) free(vals);
}



/*--------------------------------------------------------------------
  -----                 Buffer Read Functions                    -----

      Routines for reading from a buffer & dumping events to stdout
      These functions (which start with a v...) all return the number
      of bytes which were accessed from the buffer.

  -----                                                          -----
  -------------------------------------------------------------------*/

static 
int vread_version(float *version, FILE *OutFP)
{
  float val;
  memcpy(&val, version, sizeof(float));
  
  /* 
   * The VERSION should stay as a float, so that byte ordering can be 
   * checked dynamically.  If it doesn't match the first way, then the
   * FlipEvents flag is set and it's tried again.
   */

  if (val != dgVersion) {
    dgFlipEvents = 1;
    val = flipfloat(val);
    if (val != dgVersion) {
      fprintf(stderr,
	      "Unable to read this version of data file (V %5.1f/%5.1f)\n",
	      val, flipfloat(val));
      exit(-1);
    }
  }
  else dgFlipEvents = 0;
  fprintf(OutFP,"%-20s\t%3.1f\n", "DG_VERSION", val);
  return(sizeof(float));
}

static int
vread_flag(char type, FILE *OutFP)
{
  fprintf(OutFP, "%-20s\n", dgGetTagName(type));
  return(0);
}

static 
int vread_float(char type, float *fval, FILE *OutFP)
{
  float val;
  memcpy(&val, fval, sizeof(float));

  if (dgFlipEvents) val = flipfloat(val);

  fprintf(OutFP, "%-20s\t%6.3f\n", dgGetTagName(type), val);
  return(sizeof(float));
}


static 
int vread_char(char type, char *cval, FILE *OutFP)
{
  char val;
  memcpy(&val, cval, sizeof(char));

  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), val);
  return(sizeof(char));
}


static
int vread_int32(char type, int32_t *ival, FILE *OutFP)
{
  int32_t val;
  memcpy(&val, ival, sizeof(int32_t));

  if (dgFlipEvents) val = flipint32(val);
  fprintf(OutFP, "%-20s\t%ld\n", dgGetTagName(type), val);
  return(sizeof(int32_t));
}   


static
int vread_short(char type, short *sval, FILE *OutFP)
{
  short val;
  memcpy(&val, sval, sizeof(short));

  if (dgFlipEvents) val = flipshort(val);
  
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), val);
  return(sizeof(short));
}   

/*********************** ARRAY VERSIONS ************************/

static 
int vread_string(char type, int *iptr, FILE *OutFP)
{
  int length;
  int *next = iptr+1;
  char *str = (char *) next;

  memcpy(&length, iptr, sizeof(int));

  if (dgFlipEvents) length = flipint32(length);
  
  if (length) fprintf(OutFP, "%-20s\t%s\n", dgGetTagName(type), str);
  return(length+sizeof(int32_t));
}

static 
int vread_strings(char type, int *iptr, FILE *OutFP)
{
  int n, i;
  int length, sum = 0;
  char *next = (char *) iptr + sizeof(int32_t);
  char *str = "";
  
  memcpy(&n, iptr++, sizeof(int));
  if (dgFlipEvents) n = flipint32(n);
  
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), n);

  for (i = 0; i < n; i++) {
    memcpy(&length, next, sizeof(int));
    if (dgFlipEvents) length = flipint32(length);

    if (length) str = (char *) next+sizeof(int32_t);
    
    fprintf(OutFP, "%d\t%s\n", i, str);
    sum += length;
    next += sizeof(int32_t)+length;
  }
  return(sum+(n*sizeof(int32_t))+sizeof(int32_t));
}

static
int vread_int32s(char type, int *n, FILE *OutFP)
{
  int i;
  int nvals;
  int *next = n+1;
  int32_t *vl = (int32_t *) next;
  int32_t *vals = NULL;

  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);

  if (nvals) {
    if (!(vals = (int32_t *) calloc(nvals, sizeof(int32_t)))) {
      fprintf(stderr,"dgutils: error allocating space for int32 array\n");
      exit(-1);
    }
    memcpy(vals, vl, sizeof(int32_t)*nvals);

    if (dgFlipEvents) flipint32s(nvals, vals);
  }
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), nvals);
  
  for (i = 0; i < nvals; i++) {
    fprintf(OutFP, "%d\t%ld\n", i+1, vals[i]);
  }
  
  if (vals) free(vals);
  return(sizeof(int)+nvals*sizeof(int32_t));
}


static
int vread_shorts(char type, int *n, FILE *OutFP)
{
  int i;
  int nvals;
  int *next = n+1;
  short *vl = (short *) next;
  short *vals = NULL;

  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);

  if (nvals) {
    if (!(vals = (short *) calloc(nvals, sizeof(short)))) {
      fprintf(stderr,"dgutils: error allocating space for short array\n");
      exit(-1);
    }
    memcpy(vals, vl, sizeof(short)*nvals);
    
    if (dgFlipEvents) flipshorts(nvals, vals);
  }
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), nvals);
  
  for (i = 0; i < nvals; i++) {
    fprintf(OutFP, "%d\t%d\n", i+1, vals[i]);
  }
  
  if (vals) free(vals);
  return(sizeof(int)+nvals*sizeof(short));
}


static
int vread_chars(char type, int *n, FILE *OutFP)
{
  int i;
  int nvals;
  int *next = n+1;
  char *vl = (char *) next;
  char *vals = NULL;

  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);

  if (nvals) {
    if (!(vals = (char *) calloc(nvals, sizeof(char)))) {
      fprintf(stderr,"dgutils: error allocating space for char array\n");
      exit(-1);
    }
    memcpy(vals, vl, sizeof(char)*nvals);
  }

  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), nvals);
  
  for (i = 0; i < nvals; i++) {
    fprintf(OutFP, "%d\t%c\n", i+1, vals[i]);
  }
  
  if (vals) free(vals);
  return(sizeof(int)+nvals*sizeof(char));
}

static
int vread_floats(char type, int *n, FILE *OutFP)
{
  int i;
  int nvals;
  int *next = n+1;
  float *vl = (float *) next;
  float *vals = NULL;

  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);

  if (nvals) {
    if (!(vals = (float *) calloc(nvals, sizeof(float)))) {
      fprintf(stderr,"dgutils: error allocating space for float array\n");
      exit(-1);
    }
    memcpy(vals, vl, sizeof(float)*nvals);
    
    if (dgFlipEvents) flipfloats(nvals, vals);
  }
  fprintf(OutFP, "%-20s\t%d\n", dgGetTagName(type), nvals);
  
  for (i = 0; i < nvals; i++) {
    fprintf(OutFP, "%d\t%6.2f\n", i+1, vals[i]);
  }
  
  if (vals) free(vals);
  return(sizeof(int)+nvals*sizeof(float));
}

/*--------------------------------------------------------------------
  -----                   File Skip Functions                    -----
  -------------------------------------------------------------------*/

static
int skip_bytes(FILE *InFP, int n)
{
  if (fseek(InFP, (long) sizeof(float), SEEK_CUR)) {
    fprintf(stderr,"Error skipping float\n");
    return(0);
  }
  return(1);
}

static
void skip_version(FILE *InFP) 
{
  float val;
  if (fread(&val, sizeof(float), 1, InFP) != 1) {
     fprintf(stderr,"Error reading float info\n");
     exit(-1);
  }

  /* 
   * The VERSION should stay as a float, so that byte ordering can be 
   * checked dynamically.  If it doesn't match the first way, then the
   * dgFlipEvents flag is set and it's tried again.
   */

  if (val != dgVersion) {
    dgFlipEvents = 1;
    val = flipfloat(val);
    if (val != dgVersion) {
      fprintf(stderr,
	      "Unable to read this version of data file (V %5.1f/%5.1f)\n",
	      val, flipfloat(val));
      exit(-1);
    }
  }
  else dgFlipEvents = 0;
}

static int skip_float(FILE *InFP) 
{
  return(skip_bytes(InFP, sizeof(float)));
}

static int skip_char(FILE *InFP)
{
  return(skip_bytes(InFP, sizeof(char)));
}

static int skip_short(FILE *InFP)
{
  return(skip_bytes(InFP, sizeof(short)));
}

static int skip_int32(FILE *InFP)
{
  return(skip_bytes(InFP, sizeof(int32_t)));
}

static int skip_string(FILE *InFP)
{
  int length;
  
  if (fread(&length, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading string length\n");
    return(0);
  }
  if (dgFlipEvents) length = flipint32(length);
  return(skip_bytes(InFP, length));
}

static int skip_strings(FILE *InFP)
{
  int i, n, sum = 0, size; 
  
  if (fread(&n, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of strings\n");
    return(0);
  }
  if (dgFlipEvents) n = flipint32(n);
  for (i = 0; i < n; i++) {
    size = skip_string(InFP);
    if (!size) return(0);
    sum += size;
  }
  return(sizeof(int32_t)+sum);
}

static int skip_int32s(FILE *InFP)
{
  int nvals;
  if (fread(&nvals, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of int32s\n");
    exit(-1);
  }
  if (dgFlipEvents) nvals = flipint32(nvals);
  return(skip_bytes(InFP, nvals*sizeof(int32_t)));
}

static int skip_shorts(FILE *InFP)
{
  int nvals;
  if (fread(&nvals, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of shorts\n");
    exit(-1);
  }
  if (dgFlipEvents) nvals = flipint32(nvals);
  return(skip_bytes(InFP, nvals*sizeof(short)));
}

static int skip_floats(FILE *InFP)
{
  int nvals;
  if (fread(&nvals, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of floats\n");
    exit(-1);
  }
  if (dgFlipEvents) nvals = flipint32(nvals);
  return(skip_bytes(InFP, nvals*sizeof(float)));
}

/*--------------------------------------------------------------------
  -----                   Buffer Skip Functions                  -----
  -------------------------------------------------------------------*/

static 
int vskip_version(float *version)
{
  float val;
  memcpy(&val, version, sizeof(float));
  
  /* 
   * The VERSION should stay as a float, so that byte ordering can be 
   * checked dynamically.  If it doesn't match the first way, then the
   * FlipEvents flag is set and it's tried again.
   */

  if (val != dgVersion) {
    dgFlipEvents = 1;
    val = flipfloat(val);
    if (val != dgVersion) {
      fprintf(stderr,
	      "Unable to read this version of data file (V %5.1f/%5.1f)\n",
	      val, flipfloat(val));
      exit(-1);
    }
  }
  else dgFlipEvents = 0;
  return(sizeof(float));
}

static int vskip_float(void)
{ 
  return(sizeof(float)); 
}

static int vskip_char(void) 
{ 
  return(sizeof(char));  
}

static int vskip_short(void) 
{ 
  return(sizeof(short)); 
}

static int vskip_int32(void) 
{ 
  return(sizeof(int32_t)); 
}

static int vskip_string(int *l)
{
  int length;
  memcpy(&length, l, sizeof(int));
  
  if (dgFlipEvents) length = flipint32(length);
  return(sizeof(int)+length);
}

static int vskip_strings(int *l)
{
  int n, size, sum = 0, i;
  char *next = (char *) (l) + sizeof(int32_t);

  memcpy(&n, l, sizeof(int));
  if (dgFlipEvents) n = flipint32(n);
  
  for (i = 0; i < n; i++) {
    size = vskip_string((int *)next);
    sum += size;
    next += size;
  }
  return(sizeof(int)+sum);
}

static int vskip_floats(int *n)
{
  int nvals;
  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);
  return(sizeof(int)+(nvals*sizeof(float)));
}

static int vskip_shorts(int *n)
{
  int nvals;
  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);
  return(sizeof(int)+(nvals*sizeof(short)));
}

static int vskip_int32s(int *n)
{
  int nvals;
  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);
  return(sizeof(int)+(nvals*sizeof(int32_t)));
}

/*--------------------------------------------------------------------
  -----                    File Get Functions                    -----
  -------------------------------------------------------------------*/

static 
void get_version(FILE *InFP, float *version)
{
  float val;
  if (fread(&val, sizeof(float), 1, InFP) != 1) {
     fprintf(stderr,"Error reading float info\n");
     exit(-1);
  }

  /* 
   * The VERSION should stay as a float, so that byte ordering can be 
   * checked dynamically.  If it doesn't match the first way, then the
   * dgFlipEvents flag is set and it's tried again.
   */

  if (val != dgVersion) {
    dgFlipEvents = 1;
    val = flipfloat(val);
    if (val != dgVersion) {
      fprintf(stderr,
	      "Unable to read this version of data file (V %5.1f/%5.1f)\n",
	      val, flipfloat(val));
      exit(-1);
    }
  }
  else dgFlipEvents = 0;
  *version = val;
}


static 
void get_float(FILE *InFP, float *fval)
{
  float val;
  if (fread(&val, sizeof(float), 1, InFP) != 1) {
     fprintf(stderr,"Error reading float info\n");
     exit(-1);
  }
  if (dgFlipEvents) val = flipfloat(val);
  *fval = val;
}

static
void get_char(FILE *InFP, char *cval)
{
  char val;
  if (fread(&val, sizeof(char), 1, InFP) != 1) {
     fprintf(stderr,"Error reading char val\n");
     exit(-1);
  }
  *cval = val;
}

static 
void get_int32(FILE *InFP,  int32_t *ival)
{
  int32_t val;
  
  if (fread(&val, sizeof(int32_t), 1, InFP) != 1) {
    fprintf(stderr,"Error reading int32 val\n");
    exit(-1);
  }
  
  if (dgFlipEvents) val = flipint32(val);

  *ival = val;
}

static
void get_short(FILE *InFP,  short *sval)
{
  short val;
  
  if (fread(&val, sizeof(short), 1, InFP) != 1) {
    fprintf(stderr,"Error reading short val\n");
    exit(-1);
  }
  
  if (dgFlipEvents) val = flipshort(val);
  *sval = val;
}

static
void get_string(FILE *InFP, int *n, char **s)
{
  int length;
  char *str;
  
  if (fread(&length, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading string length\n");
    exit(-1);
  }
  
  if (dgFlipEvents) length = flipint32(length);
  
  if (length) {
    str = (char *) malloc(length);
    
    if (fread(str, length, 1, InFP) != 1) {
      fprintf(stderr,"Error reading\n");
      exit(-1);
    }
  }
  else str = STRDUP("");	/* malloc'd empty string */
  
  *n = length;
  *s = str;
}   

static
void get_strings(FILE *InFP, int *num, char ***s)
{
  int i, n, length;
  char **strings = NULL;
  //long cseek;
  //int n2=0;
  //char tmpch[10];
  
  if (fread(&n, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of strings\n");
    exit(-1);
  }
  if (dgFlipEvents) n = flipint32(n);

  if (n) {
    strings = (char **) calloc(n, sizeof(char *));
    for (i = 0; i < n; i++) {
      get_string(InFP, &length, &strings[i]);
      //printf("\n%d/%d %d %s",i,n-1,length,strings[i]);
      //cseek=ftell(InFP);
      //if(strcmpi(strings[i],"config")==0) {
      //fread(tmpch, sizeof(char)*10, 1, InFP);
      // //get_string(InFP, &length, &strings[i]);
      // printf("\n%d/%d %d %s",i,n2,length,tmpch);
      // fseek(InFP,cseek, SEEK_SET);
      //}
    }
  }
  
  *num = n;
  *s = strings;
}   

static
void get_chars(FILE *InFP, int *n, char **v)
{
  int nvals;
  char *vals = NULL;

  if (fread(&nvals, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of chars\n");
    exit(-1);
  }
  
  if (dgFlipEvents) nvals = flipint32(nvals);
  
  if (nvals) {
    if (!(vals = (char *) calloc(nvals, sizeof(char)))) {
      fprintf(stderr,"Error allocating memory for char elements\n");
      exit(-1);
    }
    
    if (fread(vals, sizeof(char), nvals, InFP) != nvals) {
      fprintf(stderr,"Error reading char elements\n");
      exit(-1);
    }
  }

  *n = nvals;
  *v = vals;
}

static
void get_shorts(FILE *InFP, int *n, short **v)
{
  int nvals;
  short *vals = NULL;

  if (fread(&nvals, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of shorts\n");
    exit(-1);
  }
  
  if (dgFlipEvents) nvals = flipint32(nvals);
  
  if (nvals) {
    if (!(vals = (short *) calloc(nvals, sizeof(short)))) {
      fprintf(stderr,"Error allocating memory for short elements\n");
      exit(-1);
    }
    
    if (fread(vals, sizeof(short), nvals, InFP) != nvals) {
      fprintf(stderr,"Error reading short elements\n");
      exit(-1);
    }
  if (dgFlipEvents) flipshorts(nvals, vals);
  }

  *n = nvals;
  *v = vals;
}

static
void get_int32s(FILE *InFP, int *n, int32_t **v)
{
  int nvals;
  int32_t *vals = NULL;

  if (fread(&nvals, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of int32s\n");
    exit(-1);
  }
  
  if (dgFlipEvents) nvals = flipint32(nvals);
  
  if (nvals) {
    if (!(vals = (int32_t *) calloc(nvals, sizeof(int32_t)))) {
      fprintf(stderr,"Error allocating memory for int32 elements\n");
      exit(-1);
    }
    
    if (fread(vals, sizeof(int32_t), nvals, InFP) != nvals) {
      fprintf(stderr,"Error reading int32 elements\n");
      exit(-1);
    }
    
    if (dgFlipEvents) flipint32s(nvals, vals);
  }

  *n = nvals;
  *v = vals;
}

static
void get_floats(FILE *InFP, int *n, float **v)
{
  int nvals;
  float *vals = NULL;

  if (fread(&nvals, sizeof(int), 1, InFP) != 1) {
    fprintf(stderr,"Error reading number of floats\n");
    exit(-1);
  }
  
  if (dgFlipEvents) nvals = flipint32(nvals);
  
  if (nvals) {
    if (!(vals = (float *) calloc(nvals, sizeof(float)))) {
      fprintf(stderr,"Error allocating memory for float elements\n");
      exit(-1);
    }
    
    if (fread(vals, sizeof(float), nvals, InFP) != nvals) {
      fprintf(stderr,"Error reading float elements\n");
      exit(-1);
    }
    
    if (dgFlipEvents) flipfloats(nvals, vals);
  }

  *n = nvals;
  *v = vals;
}

/*--------------------------------------------------------------------
  -----                  Buffer Get Functions                    -----
  -------------------------------------------------------------------*/

static
int vget_version(float *v, float *version)
{
  float val;
  memcpy(&val, v, sizeof(float));
  if (val != dgVersion) {
    dgFlipEvents = 1;
    val = flipfloat(val);
    if (val != dgVersion) {
      fprintf(stderr,
	      "Unable to read this version of data file (V %5.1f/%5.1f)\n",
	      val, flipfloat(val));
      exit(-1);
    }
  }
  else dgFlipEvents = 0;
  *version = val;
  return(sizeof(float));
}
   

static 
int vget_float(float *fval, float *v)
{
  float val;
  memcpy(&val, fval, sizeof(float));

  if (dgFlipEvents) val = flipfloat(val);
  *v = val;
  return(sizeof(float));
}

static 
int vget_char(char *cval, char *c)
{
  *c = *cval;
  return(sizeof(char));
}

static
int vget_int32(int32_t *ival, int32_t *l)
{
  int32_t val;
  memcpy(&val, ival, sizeof(int32_t));

  if (dgFlipEvents) val = flipint32(val);
  *l = val;
  return(sizeof(int32_t));
}

static 
int vget_short(short *sval, short *s)
{
  short val;
  memcpy(&val, sval, sizeof(short));

  if (dgFlipEvents) val = flipshort(val);
  *s = val;
  return(sizeof(short));
}

static 
int vget_string(int *iptr, int *l, char **s)
{
  int length;
  int *next = iptr+1;
  static char *str = "";
  
  memcpy(&length, iptr, sizeof(int));
  
  if (dgFlipEvents) length = flipint32(length);
  
  if (length) {
    str = (char *) malloc(length);
    memcpy(str, (char *) next, length);
  }

  *l = length;
  *s = str;
  
  return(sizeof(int)+length);
}


static 
int vget_strings(int *iptr, int *num, char ***s)
{
  int n, i, size, sum, length;
  char *next = (char *) iptr + sizeof(int32_t);
  char **strings = NULL;

  memcpy(&n, iptr, sizeof(int));
  if (dgFlipEvents) n = flipint32(n);

  if (n) strings = (char **) calloc(n, sizeof(char *));
  for (i = 0, sum = 0; i < n; i++) {
    size = vget_string((int *) next, &length, &strings[i]);
    sum += size;
    next += size;
  }
  *num = n;
  *s = strings;

  return(sizeof(int)+sum);
}

static
int vget_shorts(int *n, int *nv, short **v)
{
  int nvals;
  int *next = n+1;
  short *vl = (short *) next;
  short *vals = NULL;

  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);

  if (nvals) {
    if (!(vals = (short *) calloc(nvals, sizeof(short)))) {
      fprintf(stderr,"dgutils: error allocating space for short array\n");
      exit(-1);
    }
    memcpy(vals, vl, sizeof(short)*nvals);
    
    if (dgFlipEvents) flipshorts(nvals, vals);
  }

  *nv = nvals;
  *v  = vals;

  return(sizeof(int)+nvals*sizeof(short));
}

static
int vget_chars(int *n, int *nv, char **v)
{
  int nvals;
  int *next = n+1;
  char *vl = (char *) next;
  char *vals = NULL;

  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);

  if (nvals) {
    if (!(vals = (char *) calloc(nvals, sizeof(char)))) {
      fprintf(stderr,"dgutils: error allocating space for char array\n");
      exit(-1);
    }
    memcpy(vals, vl, sizeof(char)*nvals);
  }

  *nv = nvals;
  *v  = vals;

  return(sizeof(int)+nvals*sizeof(char));
}

static
int vget_int32s(int *n, int *nv, int32_t **v)
{
  int nvals;
  int *next = n+1;
  int32_t *vl = (int32_t *) next;
  int32_t *vals = NULL;

  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);

  if (nvals) {
    if (!(vals = (int32_t *) calloc(nvals, sizeof(int32_t)))) {
      fprintf(stderr,"dgutils: error allocating space for int32 array\n");
      exit(-1);
    }
    memcpy(vals, vl, sizeof(int32_t)*nvals);
    
    if (dgFlipEvents) flipint32s(nvals, vals);
  }

  *nv = nvals;
  *v  = vals;

  return(sizeof(int)+nvals*sizeof(int32_t));
}

static
int vget_floats(int *n, int *nv, float **v)
{
  int nvals;
  int *next = n+1;
  float *vl = (float *) next;
  float *vals = NULL;

  memcpy(&nvals, n, sizeof(int));
  if (dgFlipEvents) nvals = flipint32(nvals);

  if (nvals) {
    if (!(vals = (float *) calloc(nvals, sizeof(float)))) {
      fprintf(stderr,"dgutils: error allocating space for float array\n");
      exit(-1);
    }
    memcpy(vals, vl, sizeof(float)*nvals);
    
    if (dgFlipEvents) flipfloats(nvals, vals);
  }

  *nv = nvals;
  *v  = vals;

  return(sizeof(int)+nvals*sizeof(float));
}



/*--------------------------------------------------------------------
  -----           File to Structure Transfer Functions           -----
  -------------------------------------------------------------------*/

int dguFileToStruct(FILE *InFP, DYN_GROUP *dg)
{
  int c, status = DF_OK;
  float version;
  
  if (!confirm_magic_number(InFP)) {
    fprintf(stderr,"dgutils: file not recognized as dg format\n");
    return(0);
  }
  
  while(status == DF_OK && (c = getc(InFP)) != EOF) {
    switch (c) {
    case END_STRUCT:
      status = DF_FINISHED;
      break;
    case DG_VERSION_TAG:
      get_version(InFP, &version);
      break;
    case DG_BEGIN_TAG:
      status = dguFileToDynGroup(InFP, dg);
      break;
    default:
      fprintf(stderr,"unknown event type %d\n", c);
      status = DF_ABORT;
      break;
    }
  }
  if (status != DF_ABORT) return(DF_OK);
  else return(status);
}

int dguFileToDynGroup(FILE *InFP, DYN_GROUP *dg)
{
  int n = 0, nlists, c, status = DF_OK;

  while(status == DF_OK && (c = getc(InFP)) != EOF) {
    switch (c) {
    case END_STRUCT:
      status = DF_FINISHED;
      break;
    case DG_NAME_TAG:
      {
        char *string;
        int n;
        get_string(InFP, &n, &string);
        strncpy(DYN_GROUP_NAME(dg), string, DYN_GROUP_NAME_SIZE-1);
        free((void *) string);
      }
      break;
    case DG_NLISTS_TAG:
      get_int32(InFP, (int32_t *) &nlists);
      break;
    case DG_DYNLIST_TAG:
      {
        DYN_LIST *dl = (DYN_LIST *) calloc(1, sizeof(DYN_LIST));
        DYN_LIST_INCREMENT(dl) = 10;
        status = dguFileToDynList(InFP, dl);
        dfuAddDynGroupExistingList(dg, DYN_LIST_NAME(dl), dl);
        n++;
      }
      break;
    default:
      fprintf(stderr,"unknown event type %d\n", c);
      status = DF_ABORT;
      break;
    }
  }
  if (status != DF_ABORT) return(DF_OK);
  else return(status);
}

int dguFileToDynList(FILE *InFP, DYN_LIST *dl)
{
  int c, status = DF_OK;

  while(status == DF_OK && (c = getc(InFP)) != EOF) {
    switch (c) {
    case END_STRUCT:
      status = DF_FINISHED;
      break;
    case DL_INCREMENT_TAG:
      get_int32(InFP, (int32_t *) &DYN_LIST_INCREMENT(dl));
      break;
    case DL_FLAGS_TAG:
      get_int32(InFP, (int32_t *) &DYN_LIST_FLAGS(dl));
      break;
    case DL_DATA_TAG:
      break;
    case DL_NAME_TAG:
      {
        char *string;
        int n;
        get_string(InFP, &n, &string);
        strncpy(DYN_LIST_NAME(dl), string, DYN_LIST_NAME_SIZE-1);
        free((void *) string);
      }
      break;
    case DL_STRING_DATA_TAG:
      {
        char **data;
        int n;
        get_strings(InFP, &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_STRING;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        if (n) DYN_LIST_VALS(dl) = data;
        else DYN_LIST_VALS(dl) = NULL;
      }
      break;
    case DL_FLOAT_DATA_TAG:
      {
        float *data;
        int n;
        get_floats(InFP, &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_FLOAT;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        if (n) DYN_LIST_VALS(dl) = data;
        else DYN_LIST_VALS(dl) = NULL;
      }
      break;
    case DL_INT32_DATA_TAG:
      {
        int32_t *data;
        int n;
        get_int32s(InFP, &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_INT32;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        if (n) DYN_LIST_VALS(dl) = data;
        else DYN_LIST_VALS(dl) = NULL;
      }
      break;
    case DL_SHORT_DATA_TAG:
      {
        short *data;
        int n;
        get_shorts(InFP, &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_SHORT;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        DYN_LIST_VALS(dl) = data;
      }
      break;
    case DL_CHAR_DATA_TAG:
      {
        char *data;
        int n;
        get_chars(InFP, &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_CHAR;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        if (n) DYN_LIST_VALS(dl) = data;
        else DYN_LIST_VALS(dl) = NULL;
      }
      break;
    case DL_LIST_DATA_TAG:
      {
        DYN_LIST *newlist, **vals;
        int n, i;
        
        /* Figure out how many there are */
        get_int32(InFP, (int32_t *) &n);
        
        /* Set the datatype */
        DYN_LIST_DATATYPE(dl) = DF_LIST;
        
        /* Setup and allocate the appropriate amount of space */
        DYN_LIST_INCREMENT(dl) = 10;
        DYN_LIST_MAX(dl) = n ? n : 1;
        DYN_LIST_N(dl) = n;
        DYN_LIST_VALS(dl) = 
          (DYN_LIST **) calloc(DYN_LIST_MAX(dl), sizeof(DYN_LIST *));
        vals = (DYN_LIST **) DYN_LIST_VALS(dl);
        
        /* Now fill up the list of lists by recursively calling this func */
        for (i = 0; i < n; i++) {
          newlist = (DYN_LIST *) calloc(1, sizeof(DYN_LIST));
          DYN_LIST_INCREMENT(newlist) = 10;
          if ((c = getc(InFP)) != DL_SUBLIST_TAG) return(DF_ABORT);
          status = dguFileToDynList(InFP, newlist);
          vals[i] = newlist;
        }
      }
      break;
    default:
      fprintf(stderr,"unknown event type %d\n", c);
      status = DF_ABORT;
      break;
    }
  }
  if (status != DF_ABORT) return(DF_OK);
  else return(status);
}


/*--------------------------------------------------------------------
  -----         Buffer to Structure Transfer Functions           -----
  -------------------------------------------------------------------*/

int dguBufferToStruct(unsigned char *vbuf, int bufsize, DYN_GROUP *dg)
{
  int c, status = DF_OK;
  int advance_bytes = 0;
  float version;
  BUF_DATA *bdata = (BUF_DATA *) calloc(1, sizeof(BUF_DATA));

  if (!vconfirm_magic_number((char *)vbuf)) {
    return(0);
  }

  BD_BUFFER(bdata) = vbuf;
  BD_INDEX(bdata) = DF_MAGIC_NUMBER_SIZE;
  BD_SIZE(bdata) = bufsize;
  
  while (status == DF_OK && BD_INDEX(bdata) < BD_SIZE(bdata)) {
    BD_INCINDEX(bdata, advance_bytes);
    advance_bytes = 0;
    c = BD_GETC(bdata);
    switch (c) {
    case END_STRUCT:
      status = DF_FINISHED;
      break;
    case DG_VERSION_TAG:
      advance_bytes += vget_version((float *) BD_DATA(bdata), &version);
      break;
    case DG_BEGIN_TAG:
      status = dguBufferToDynGroup(bdata, dg);
      break;
    default:
      fprintf(stderr,"unknown event type %d\n", c);
      status = DF_ABORT;
      break;
    }
  }
  free(bdata);

  if (status != DF_ABORT) return(DF_OK);
  else return(status);
}

static int dguBufferToDynGroup(BUF_DATA *bdata, DYN_GROUP *dg)
{
  int n = 0, c, status = DF_OK, advance_bytes = 0;
  int32_t nlists;

  while (status == DF_OK && !BD_EOF(bdata)) {
    BD_INCINDEX(bdata, advance_bytes);
    advance_bytes = 0;
    c = BD_GETC(bdata);
    switch (c) {
    case END_STRUCT:
      status = DF_FINISHED;
      break;
    case DG_NAME_TAG:
      {
	char *string;
	int n;
	advance_bytes += vget_string((int *) BD_DATA(bdata), 
				     &n, &string);
	strncpy(DYN_GROUP_NAME(dg), string, DYN_GROUP_NAME_SIZE-1);
	free((void *) string);
      }
      break;
    case DG_NLISTS_TAG:
      advance_bytes += vget_int32((int32_t *) BD_DATA(bdata), &nlists);
      break;
    case DG_DYNLIST_TAG:
      {
	DYN_LIST *dl = (DYN_LIST *) calloc(1, sizeof(DYN_LIST));
	DYN_LIST_INCREMENT(dl) = 10;
	status = dguBufferToDynList(bdata, dl);
	dfuAddDynGroupExistingList(dg, DYN_LIST_NAME(dl), dl);
	n++;
      }
      break;
    default:
      fprintf(stderr,"unknown event type %d\n", c);
      status = DF_ABORT;
      break;
    }
  }
  if (status != DF_ABORT) return(DF_OK);
  else return(status);
}

static int dguBufferToDynList(BUF_DATA *bdata, DYN_LIST *dl)
{
  int c, status = DF_OK;
  int advance_bytes = 0;

  while (status == DF_OK && !BD_EOF(bdata)) {
    BD_INCINDEX(bdata, advance_bytes);
    advance_bytes = 0;
    c = BD_GETC(bdata);
    switch (c) {
    case END_STRUCT:
      status = DF_FINISHED;
      break;
    case DL_INCREMENT_TAG:
      advance_bytes += vget_int32((int32_t *) BD_DATA(bdata), 
				 (int32_t *) &DYN_LIST_INCREMENT(dl));
      break;
    case DL_FLAGS_TAG:
      advance_bytes += vget_int32((int32_t *) BD_DATA(bdata), 
				 (int32_t *) &DYN_LIST_FLAGS(dl));
      break;
    case DL_DATA_TAG:
      break;
    case DL_NAME_TAG:
      {
        char *string;
        int n;
        advance_bytes += vget_string((int *) BD_DATA(bdata), 
                                     &n, &string);
        strncpy(DYN_LIST_NAME(dl), string, DYN_LIST_NAME_SIZE-1);
        free((void *) string);
      }
      break;
    case DL_STRING_DATA_TAG:
      {
        char **data;
        int n;
        advance_bytes += vget_strings((int *) BD_DATA(bdata), &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_STRING;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        if (n) DYN_LIST_VALS(dl) = data;
        else DYN_LIST_VALS(dl) = NULL;
      }
      break;
    case DL_FLOAT_DATA_TAG:
      {
        float *data;
        int n;
        advance_bytes += vget_floats((int *) BD_DATA(bdata), &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_FLOAT;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        if (n) DYN_LIST_VALS(dl) = data;
        else DYN_LIST_VALS(dl) = NULL;
      }
      break;
    case DL_INT32_DATA_TAG:
      {
        int32_t *data;
        int n;
        advance_bytes += vget_int32s((int *) BD_DATA(bdata), &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_INT32;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        if (n) DYN_LIST_VALS(dl) = data;
        else DYN_LIST_VALS(dl) = NULL;
      }
      break;
    case DL_SHORT_DATA_TAG:
      {
        short *data;
        int n;
        advance_bytes += vget_shorts((int *) BD_DATA(bdata), &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_SHORT;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        DYN_LIST_VALS(dl) = data;
      }
      break;
    case DL_CHAR_DATA_TAG:
      {
        char *data;
        int n;
        advance_bytes += vget_chars((int *) BD_DATA(bdata), &n, &data);
        DYN_LIST_DATATYPE(dl) = DF_CHAR;
        DYN_LIST_MAX(dl) = n;
        DYN_LIST_N(dl) = n;
        if (n) DYN_LIST_VALS(dl) = data;
        else DYN_LIST_VALS(dl) = NULL;
      }
      break;
    case DL_LIST_DATA_TAG:
      {
        DYN_LIST *newlist, **vals;
        int n, i;
        
        /* Figure out how many there are */
        advance_bytes = vget_int32((int32_t *) BD_DATA(bdata), (int32_t *) &n);
        BD_INCINDEX(bdata, advance_bytes);
        advance_bytes = 0;
        
        /* Set the datatype */
        DYN_LIST_DATATYPE(dl) = DF_LIST;
        
        /* Setup and allocate the appropriate amount of space */
        DYN_LIST_INCREMENT(dl) = 10;
        DYN_LIST_MAX(dl) = n ? n : 1;
        DYN_LIST_N(dl) = n;
        DYN_LIST_VALS(dl) = 
          (DYN_LIST **) calloc(DYN_LIST_MAX(dl), sizeof(DYN_LIST *));
        vals = (DYN_LIST **) DYN_LIST_VALS(dl);
        
        /* Now fill up the list of lists by recursively calling this func */
        for (i = 0; i < n; i++) {
          newlist = (DYN_LIST *) calloc(1, sizeof(DYN_LIST));
          DYN_LIST_INCREMENT(newlist) = 10;
          c = BD_GETC(bdata);
          if (c != DL_SUBLIST_TAG) return(DF_ABORT);
          status = dguBufferToDynList(bdata, newlist);
          vals[i] = newlist;
        }
      }
      break;
    default:
      fprintf(stderr,"unknown event type %d\n", c);
      status = DF_ABORT;
      break;
    }
  }
  if (status != DF_ABORT) return(DF_OK);
  else return(status);
}



/*--------------------------------------------------------------------
  -----                    Output Functions                      -----
  -------------------------------------------------------------------*/

void dguBufferToAscii(unsigned char *vbuf, int bufsize, FILE *OutFP)
{
  int c, dtype;
  int i, advance_bytes = 0;
  
  dgPushStruct(DG_TOP_LEVEL, "DG_TOP_LEVEL");

  if (!vconfirm_magic_number((char *)vbuf)) {
    fprintf(stderr,"dgutils: file not recognized as dg format\n");
    exit(-1);
  }
  
  for (i = DG_MAGIC_NUMBER_SIZE; i < bufsize; i+=advance_bytes) {
    c = vbuf[i++];
    if (c == END_STRUCT) {
      fprintf(OutFP, "END:   %s\n", dgGetCurrentStructName());
      dgPopStruct();
      advance_bytes = 0;
      continue;
    }
    switch (dtype = dgGetDataType(c)) {
    case DF_STRUCTURE:
      fprintf(OutFP, "BEGIN: %s\n", dgGetTagName(c));
      dgPushStruct(dgGetStructureType(c), dgGetTagName(c));
      advance_bytes = 0;
      break;
    case DF_VERSION:
      advance_bytes = vread_version((float *) &vbuf[i], OutFP);
      break;
    case DF_VOID_ARRAY:
      advance_bytes = 0;
      break;
    case DF_FLAG:
      advance_bytes = vread_flag(c, OutFP);
      break;
    case DF_CHAR:
      advance_bytes = vread_char(c, (char *) &vbuf[i], OutFP);
      break;
    case DF_INT32:
      advance_bytes = vread_int32(c, (int32_t *) &vbuf[i], OutFP);
      break;
    case DF_SHORT:
      advance_bytes = vread_short(c, (short *) &vbuf[i], OutFP);
      break;
    case DF_FLOAT:
      advance_bytes = vread_float(c, (float *) &vbuf[i], OutFP);
      break;
    case DF_STRING:
      advance_bytes = vread_string(c, (int *) &vbuf[i], OutFP);
      break;
    case DF_STRING_ARRAY:
      advance_bytes = vread_strings(c, (int *) &vbuf[i], OutFP);
      break;
    case DF_FLOAT_ARRAY:
      advance_bytes = vread_floats(c, (int *) &vbuf[i], OutFP);
      break;
    case DF_INT32_ARRAY:
      advance_bytes = vread_int32s(c, (int *) &vbuf[i], OutFP);
      break;
    case DF_SHORT_ARRAY:
      advance_bytes = vread_shorts(c, (int *) &vbuf[i], OutFP);
      break;
    case DF_LIST_ARRAY:
      advance_bytes = vread_int32(c, (int32_t *) &vbuf[i], OutFP);
      break;
    default:
      fprintf(stderr,"unknown event type %d\n", c);
      break;
    }
  }
}

void dguFileToAscii(FILE *InFP, FILE *OutFP)
{
  int c, dtype;
  
  dgPushStruct(DG_TOP_LEVEL, "DG_TOP_LEVEL");

  if (!confirm_magic_number(InFP)) {
    fprintf(stderr,"dgutils: file not recognized as dg format\n");
    return;
  }
  
  while((c = getc(InFP)) != EOF) {
    if (c == END_STRUCT) {
      fprintf(OutFP, "END:   %s\n", dgGetCurrentStructName());
      dgPopStruct();
      continue;
    }
    switch (dtype = dgGetDataType(c)) {
    case DF_STRUCTURE:
      fprintf(OutFP, "BEGIN: %s\n", dgGetTagName(c));
      dgPushStruct(dgGetStructureType(c), dgGetTagName(c));
      break;
    case DF_VERSION:
      read_version(InFP, OutFP);
      break;
    case DF_VOID_ARRAY:
      break;
    case DF_FLAG:
      read_flag(c, InFP, OutFP);
      break;
    case DF_CHAR:
      read_char(c, InFP, OutFP);
      break;
    case DF_INT32:
      read_int32(c, InFP, OutFP);
      break;
    case DF_SHORT:
      read_short(c, InFP, OutFP);
      break;
    case DF_FLOAT:
      read_float(c, InFP, OutFP);
      break;
    case DF_STRING:
      read_string(c, InFP, OutFP);
      break;
    case DF_STRING_ARRAY:
      read_strings(c, InFP, OutFP);
      break;
    case DF_FLOAT_ARRAY:
      read_floats(c, InFP, OutFP);
      break;
    case DF_INT32_ARRAY:
      read_int32s(c, InFP, OutFP);
      break;
    case DF_CHAR_ARRAY:
      read_chars(c, InFP, OutFP);
      break;
    case DF_SHORT_ARRAY:
      read_shorts(c, InFP, OutFP);
      break;
    case DF_LIST_ARRAY:
      read_int32(c, InFP, OutFP);
      break;
    default:
      fprintf(stderr,"unknown event type %d\n", c);
      break;
    }
  }
}


