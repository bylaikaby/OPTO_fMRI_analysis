/*
 * NAME
 *   vavi_mean.c - mex DLL to compute mean/std image from AVI.
 *   frame<0,frame>=maxframe are treated as blanks (black).
 *
 * NOTES:
 *   This includes many codes by found at
 *   http://nehe.gamedev.net/data/lessons/lesson.asp?lesson=35.
 *   GREAT THANKS to that author.
 *
 * REQUIREMENT:
 *   vfw32.lib (standard video-for-windows library)
 *
 * VERSION/DATE/AUTHOR
 *   0.90 27.07.03 YM,  pre-release, supports windows only.
 *   0.91 17.09.03 YM,  improved performance (x1.8), buf fix for empty frames. 
 *   0.92 25.09.03 YM,  improved performance (x1.1).
 *
 */


/************************************************************************
 *                              Headers
 ************************************************************************/

#if defined (_WIN32) || defined (_WIN64)
#define WIN32_LEAN_AND_MEAN
#define WIN64_LEAN_AND_MEAN
#include <windows.h>
#undef  WIN32_LEAN_AND_MEAN
#undef  WIN64_LEAN_AND_MEAN
#endif

#include "amd3dx.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "matrix.h"
#include "mex.h"

#include "vavifunc.h"

/* Input Arguments */
#define	FILE_IN			prhs[0]
#define FRAMES_IN		prhs[1]

/* Output Arguments */
#define	IMGMEAN_OUT	plhs[0]
#define	IMGSTD_OUT 	plhs[1]
#define	WIDTH_OUT		plhs[2]
#define HEIGHT_OUT	plhs[3]
#define NFRAMES_OUT	plhs[4]

// prototypes
void addRaw2Image(unsigned long *, const unsigned char *, const int);
void addRaw2ImageAsm(unsigned long *, const unsigned char *, const int);
void procRaw2Image(unsigned long *, const unsigned char *, const int);
void alignImage4Matlab(double *,const double *, const int, const int);

// mex function
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] );



// local functions
void addRaw2Image(unsigned long *buf, const unsigned char *raw, const int npts)
{
  int i, j;
#if 1
  unsigned long tmpv[4];
  for (i = 0; i < npts; i+=4) {
    buf[i]   = buf[i]   + raw[i];
    buf[i+1] = buf[i+1] + raw[i+1];
    buf[i+2] = buf[i+2] + raw[i+2];
    buf[i+3] = buf[i+3] + raw[i+3];
  }
#else
  for (i = 0; i < npts; i+=4) {
    tmpv[0] = raw[i];
    tmpv[1] = raw[i+1];
    tmpv[2] = raw[i+2];
    tmpv[3] = raw[i+3];
    buf[i]   = buf[i]   + tmpv[0];
    buf[i+1] = buf[i+1] + tmpv[1];
    buf[i+2] = buf[i+2] + tmpv[2];
    buf[i+3] = buf[i+3] + tmpv[3];
    //buf[j]   = buf[j]   + tmpv[0]*tmpv[0];
    //buf[j+1] = buf[j+1] + tmpv[1]*tmpv[1];
    //buf[j+2] = buf[j+2] + tmpv[2]*tmpv[2];
    //buf[j+3] = buf[j+3] + tmpv[3]*tmpv[3];
  }

  unsigned long *lraw, tmpv;
  lraw = raw;
  for (j = 0; j < npts*2; j+=8) {
    tmpv = lraw[j/2];
    buf[j]   = buf[j]   + tmpv & 0xff;
    buf[j+2] = buf[j+2] + (tmpv >>  8) & 0xff;
    buf[j+4] = buf[j+4] + (tmpv >> 16) & 0xff;
    buf[j+6] = buf[j+6] + (tmpv >> 24) & 0xff;
  }
#endif
  return;
}

void addRaw2ImageAsm(unsigned long *buf, const unsigned char *raw, const int npts)
{
#if 1
  __asm {
    //prefetcht0 raw;
    //prefetcht0 buf;
    mov ecx, npts;  // u
    mov esi, raw;   // v
    shr ecx, 1;     // u: divide by 2
    //xor eax, eax;
    mov edi, buf;   // v
  label:
    xor eax, eax;
    xor ebx, ebx;
    mov al, [esi+0];
    mov bl, [esi+1];

    add [edi+0], eax;
    add [edi+4], ebx;

    //prefetcht0 [esi+2];
    //prefetcht0 [edi+8];
    add esi, 2;
    add edi, 8;

    dec ecx;
    jnz label;

  }
#else
    //prefetcht0 raw;
    //prefetcht0 buf;
    mov ecx, npts;  // u
    mov esi, raw;   // v
    shr ecx, 1;     // u: divide by 2
    mov edi, buf;   // v
    xor eax, eax;
    xor ebx, ebx;
  label:
    mov al, [esi+0];
    mov bl, [esi+1];

    add [edi+0], eax;
    add [edi+4], ebx;

    //prefetcht0 [esi+2];
    //prefetcht0 [edi+8];
    xor eax, eax;
    xor ebx, ebx;
    add esi, 2;
    add edi, 8;

    dec ecx;
    jnz label;


  unsigned long tmpv[2];
  __asm {
    //prefetcht0 raw;
    //prefetcht0 buf;
    xor eax, eax;
    lea edx, [tmpv];
    mov ecx, npts;  // u
    mov esi, raw;   // v
    shr ecx, 1;     // u: divide by 2
    mov edi, buf;   // v
  label:
    //prefetcht0 [edi]
    xor eax, eax;
    xor ebx, ebx;
    mov al, [esi+0];
    mov bl, [esi+1];

    mov [edx+0], eax;
    mov [edx+4], ebx;

    movq mm1, [edx+0];
    movq mm0, [edi+0];
 
    paddd mm0, mm1;
    movq [edi+0], mm0;

    //prefetcht0 [esi+4]
    add esi, 2;
    add edi, 8;

    //lea esi, [esi+2];
    //lea edi, [edi+16];

    dec ecx;
    jnz label;

    emms;
  }
#endif

  return;
}

void procRaw2Image(unsigned long *buf, const unsigned char *raw, const int npts)
{
#if 0
  int i;
  unsigned long tmpv;
  for (i = 0; i < npts; i++) {
    tmpv = raw[i];
    buf[i] = buf[i] + tmpv;
    buf[i+npts] = buf[i+npts] + tmpv*tmpv;
  }
#else
  int i, j;
  unsigned long tmpv[8];
  for (i = 0, j = npts; i < npts; i+=4, j+=4) {
    tmpv[0] = raw[i];
    tmpv[1] = raw[i+1];
    tmpv[2] = raw[i+2];
    tmpv[3] = raw[i+3];
    //tmpv[4] = raw[i+4];
    //tmpv[5] = raw[i+5];
    //tmpv[6] = raw[i+6];
    //tmpv[7] = raw[i+7];
    buf[i]   = buf[i]   + tmpv[0];
    buf[i+1] = buf[i+1] + tmpv[1];
    buf[i+2] = buf[i+2] + tmpv[2];
    buf[i+3] = buf[i+3] + tmpv[3];
    buf[j]   = buf[j]   + tmpv[0]*tmpv[0];
    buf[j+1] = buf[j+1] + tmpv[1]*tmpv[1];
    buf[j+2] = buf[j+2] + tmpv[2]*tmpv[2];
    buf[j+3] = buf[j+3] + tmpv[3]*tmpv[3];
    // force to prefetch
    //tmpv[0] = raw[i+4];
  }
#endif
  return;
}

void procRaw2ImageAsm(unsigned long *buf, const unsigned char *raw, const int npts)
{
#if 1
  __asm {
    mov esi, raw;
    mov edi, buf;
    mov ecx, npts;
    shr ecx, 2;   // divide by 4
    
    mov eax, 0;
  label:
    prefetcht0 [edi];
    movd mm0, [esi];
    movd mm1, eax;
    punpcklbw mm0, mm1;
    //movq mm1, mm0;
    movq mm3, [edi];
    //movq mm4, [edi+4]
    
    paddd mm3, mm0;
    //pmuludq mm1,mm0;
    //paddd mm4, mm1;
    prefetcht0 [esi+4];
    movntq [edi], mm3;       // movntq is faster than movq
    //movntq [edi+4],mm4;
    //movq [edi], mm2

    //add esi, 4;
    //add edi, 32;
    lea esi, [esi+4];
    lea edi, [edi+32];

    dec ecx;
    jnz label;

    emms;
  }
#else
  int i, j;
  unsigned long tmpv;
  for (i = 0, j = 0; i < npts; i++, j+=2) {
    tmpv = raw[i];
    buf[j]   = buf[j]   + tmpv;
  }
#endif
  return;
}

// Matlab stores image as a three-dimensional (m-by-n-by-3) array
void alignImage4Matlab(double *mimg, const double *iimg, const int width, const int height)
{
  int i, j, w, h, wh, wh2;
  wh = height*width;
  wh2 = 2*wh;
  j = 0;
  for (h = height-1; h >= 0; h--) {
    i = h;
    for (w = 0; w < width; w++) {
      mimg[i]     = iimg[j];
      mimg[i+wh]  = iimg[j+1];
      mimg[i+wh2] = iimg[j+2];
      j += 3;
      i += height;
    }
  }
  return;
}


// mex function /////////////////////////////////////////////////
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[] )
{
  char *filename;
  double *pframes;
  int *iframes;
  void *imgbuff;
  unsigned long *sumbuff;
  unsigned char *bmpdata;
  double *imgmean, *imgstd;
  int i, j, k, nframes, npts;
  MOVIE_DATA mdata;
  int dims[3], status;

  // Check for proper number of arguments
  if (nrhs != 2) {
    mexPrintf("Usage: [imgmean imgstd width heigth nframes] = vavi_mean(filename,frames)\n");
    mexPrintf("Notes: frames>=0, length(frames)<66051.  ver.0.91 Sep-2003\n");
    mexPrintf("     : frame of -1 is treated as a blank(black).\n");
    mexPrintf("     : if 'frames' is empty, then compute across all frames in the moviefile.\n");
    return;
  }

  memset(&mdata, 0, sizeof(MOVIE_DATA));
  iframes = NULL;   imgbuff = NULL;
  imgmean = NULL;   imgstd = NULL;

  // Get the filename
  if (mxIsChar(FILE_IN) != 1 || mxGetM(FILE_IN) != 1) {
    mexErrMsgTxt("vavi_mean: first arg must be filename string."); 
  }
  i = (mxGetM(FILE_IN) * mxGetN(FILE_IN)) + 1;
  filename = mxCalloc(i, sizeof(char));
  status = mxGetString(FILE_IN, filename, i);
  if (status != 0) {
    mexWarnMsgTxt("vavi_mean: not enough space, filename string is truncated.");
  }
  sprintf(mdata.filename,"%s",filename);

  // open the stream
  if (OpenAVI(&mdata) != 0) {
    mexPrintf("\nvavi_mean: avifile=%s,frame=%d\n",
              mdata.filename,mdata.currframe);
    mexErrMsgTxt("vavi_mean: OpenAVI() failed."); 
  }

  // Get frame indices
  nframes = mxGetN(FRAMES_IN) * mxGetM(FRAMES_IN);
  if (nframes == 0) {
    nframes = mdata.numframes;
    iframes = (int *)calloc(nframes,sizeof(int));
    for (i = 0; i < nframes; i++)  iframes[i] = i;
    mexPrintf("\nvavi_mean: empty 'frames' detected, now compute across all frames [%d].",nframes);
  } else {
    pframes = (double *)mxGetPr(FRAMES_IN);
    iframes = (int *)calloc(nframes,sizeof(int));
    for (i = 0; i < nframes; i++) {
      if (pframes[i] >= 0) {
        iframes[i] = (int)(pframes[i] + 0.5);
      } else {
        iframes[i] = (int)(pframes[i] - 0.5);
      }
    }
  }
  if (nframes >= 66051) {
    mexPrintf("\nvavi_mean: num.frames[%d] should be < 66051 to avoid overflow.",nframes);
  }

  // allocate memory
  npts = mdata.width*mdata.height*3;
  imgbuff = (void *)calloc(npts+64,sizeof(char)+2*sizeof(long));
  // 16byte alignment for faster access
  bmpdata = (unsigned char *)(((unsigned)imgbuff + 15) & ~15);
  // sumbuff store both values for mean/std.
  // this is an attempt to improve memory access....
  sumbuff = (unsigned long *)(((unsigned)&bmpdata[npts] + 15) & ~15);
  //sumbuff = (unsigned long *)calloc(npts+64,sizeof(long)*2);
#if 0
  mexPrintf("imgbuff=%x, bmpdata=%x, sumbuff=%x\n",imgbuff,bmpdata,sumbuff);
#endif

  k = -1000;
  for (j = 0; j < nframes; j++) {
    mdata.currframe = iframes[j];
    if (mdata.currframe < 0 || mdata.currframe >= mdata.numframes) continue;
    if (mdata.currframe != k) {
      if (GrabAVIFrame(&mdata,bmpdata) != 0) {
        // release AVI resources.
        CloseAVI(&mdata);
        if (iframes != NULL) { free(iframes);  iframes = NULL; }
        if (imgbuff != NULL) { free(imgbuff);  imgbuff = NULL; }
        mexPrintf("\nvavi_mean: avifile=%s,frame=%d\n",
                  mdata.filename,mdata.currframe);
        mexErrMsgTxt("vavi_mean: GrabAVIFrame() failed."); 
      }
      k = mdata.currframe;
    }
    // add bmpdata, must be devided by 255 later.
    // add bmpdata^2, must be devided by 255*255(=65025).
    if (nlhs == 1) {
      addRaw2Image(sumbuff,bmpdata,npts);
    } else {
      procRaw2Image(sumbuff,bmpdata,npts);
    }
  }
  CloseAVI(&mdata);  // release AVI resources.

  // get a mean image
  imgmean = (double *)calloc(npts,sizeof(double));
  for (i = 0; i < npts; i++) {
    imgmean[i] = (double)sumbuff[i] / (double)nframes / 255.0;
  }
  // get a std image
  if (nlhs > 1) {
    double tmpv, tmpn, tmpn2;
    imgstd  = (double *)calloc(npts,sizeof(double));
    tmpn  = (double)nframes;
    tmpn2 = 0;
    if (nframes > 1) tmpn2 = tmpn / (tmpn - 1.0);
    tmpn = tmpn * 65025.0;        // 255*255=65025.
    for (i = 0, j = npts; i < npts; i++, j++) {
      tmpv = (double)sumbuff[j] / tmpn - imgmean[i]*imgmean[i];
      imgstd[i] = sqrt(tmpv * tmpn2);
    }
  }
  if (iframes != NULL) { free(iframes);  iframes = NULL; }
  if (imgbuff != NULL) { free(imgbuff);  imgbuff = NULL; }
  //free(sumbuff);


  // set dimenstion
  dims[0] = mdata.height;  // height
  dims[1] = mdata.width;   // width
  dims[2] = 3;             // color: RGB

  IMGMEAN_OUT = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
  // Matlab stores image as a three-dimensional (m-by-n-by-3) array
  alignImage4Matlab((double *)mxGetPr(IMGMEAN_OUT),
                    imgmean,mdata.width,mdata.height);
  if (imgmean != NULL) { free(imgmean);  imgmean = NULL; }

  if (nlhs > 1) {
    IMGSTD_OUT = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
    alignImage4Matlab((double *)mxGetPr(IMGSTD_OUT),
                      imgstd,mdata.width,mdata.height);
  }
  if (imgstd  != NULL) { free(imgstd);   imgstd = NULL;  }
  
  // width
  if (nlhs >= 3) {
    WIDTH_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetPr(WIDTH_OUT) = (double)mdata.width;
  }
  // height
  if (nlhs >= 4) {
	  HEIGHT_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
	  *mxGetPr(HEIGHT_OUT) = (double)mdata.height;
  }
  // num. of frames added.
  if (nlhs >= 5) {
	  NFRAMES_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
	  *mxGetPr(NFRAMES_OUT) = (double)nframes;
  }

  return;
}


#if defined (_WINDOWS_)
BOOL APIENTRY
DllMain(hInst, reason, reserved)
    HINSTANCE hInst;
    DWORD reason;
    LPVOID reserved;
{
  switch (reason) {
  case DLL_PROCESS_ATTACH:
    //printf("process_attach\n");
    InitAVILib();
    break;
  case DLL_THREAD_ATTACH:
    //printf("thread_attach\n");
    break;
  case DLL_THREAD_DETACH:
    //printf("thread_detach\n");
    break;
  case DLL_PROCESS_DETACH:
    //printf("process_detach\n");
    ExitAVILib();
    break;
  }
	return TRUE;
}
#endif
