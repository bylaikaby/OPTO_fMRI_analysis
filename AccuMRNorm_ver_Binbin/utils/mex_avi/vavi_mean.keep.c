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

// prototypes
void addRaw2Image(unsigned long *, const unsigned char *, const int);
void addRawRawImage(unsigned long *, const unsigned char *, const int);
void procRaw2Image(unsigned long *, unsigned long *, const unsigned char *, const int);


// mex function
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] );


#define GO_BY_FLOATS


// local functions
void addRaw2Image(unsigned long *buf, const unsigned char *raw, const int npts)
{
  int i;
#if 1
  // int j;
  //unsigned long *raw4;
  //unsigned long tmpv;
  unsigned long tmpv[4];
  for (i = 0; i < npts; i+=2) {
    //buf[i] = buf[i] + raw[i];
    tmpv[0] = raw[i];
    tmpv[1] = raw[i+1];
    //tmpv[2] = raw[i+2];
    //tmpv[3] = raw[i+3];
    //tmpv[4] = raw[i+4];
    //tmpv[5] = raw[i+5];
    //tmpv[6] = raw[i+6];
    //tmpv[7] = raw[i+7];
    buf[i]   = buf[i]   + tmpv[0];
    buf[i+1] = buf[i+1] + tmpv[1];
    //buf[i+2] = buf[i+2] + tmpv[2];
    //buf[i+3] = buf[i+3] + tmpv[3];
    //buf[i+4] = buf[i+4] + tmpv[4];
    //buf[i+5] = buf[i+5] + tmpv[5];
    //buf[i+6] = buf[i+6] + tmpv[6];
    //buf[i+7] = buf[i+7] + tmpv[7];
  }
#else
  unsigned long tmpv[8];
  __asm {
		mov ecx, npts
    shr ecx, 1
    mov ebx, buf
    mov edx, raw
    label:
      xor   eax, eax
      mov   al, byte ptr [edx]
      mov   [buf+0], eax
      mov   al, byte ptr [edx+1]
      mov   [buf+2], eax
      movq  mm0, [ebx]
      movq  mm1, [buf]
      paddd mm0, mm1
      movq  [ebx], mm0
			add		ebx,8
			add		edx,2
			dec		ecx
			jnz		label
    emms
	}
# if 0
  __asm {
		mov ecx,npts
    mov ebx,buf
    mov edx,raw
    label:
			xor		eax, eax
			mov		al, byte ptr [edx]
			//add		eax, [ebx]
			//mov		[ebx], eax
			add		[ebx],eax
			add		ebx,4
			add		eax,1
			dec		ecx
			jnz		label
    emms
	}
# endif
#endif
  return;
}
void addRawRaw2Image(unsigned long *buf, const unsigned char *raw, const int npts)
{
  int i;
#if 1
  unsigned long tmpv[4];
  for (i = 0; i < npts; i+=2) {
    tmpv[0] = (unsigned long)raw[i];
    tmpv[1] = (unsigned long)raw[i+1];
    buf[i]   = buf[i]   + tmpv[0]*tmpv[0];
    buf[i+1] = buf[i+1] + tmpv[1]*tmpv[1];
  }
#else
  __asm {
		mov ecx,npts
    mov ebx,buf
    mov edx,raw
    label:
			xor		eax, eax
			mov		al, byte ptr [edx]
			//add		eax, [ebx]
			//mov		[ebx], eax
			add		[ebx],eax
			add		ebx,4
			add		eax,1
			dec		ecx
			jnz		label
	}
#endif
  return;
}


void procRaw2Image(unsigned long *bufm, unsigned long *bufs, const unsigned char *raw, const int npts)
{
  int i;

  unsigned long tmpv[4];
  for (i = 0; i < npts; i+=2) {
    //buf[i] = buf[i] + raw[i];
    tmpv[0] = raw[i];
    tmpv[1] = raw[i+1];
    //tmpv[2] = raw[i+2];
    //tmpv[3] = raw[i+3];
    //tmpv[4] = raw[i+4];
    //tmpv[5] = raw[i+5];
    //tmpv[6] = raw[i+6];
    //tmpv[7] = raw[i+7];
    bufm[i]   = bufm[i]   + tmpv[0];
    bufm[i+1] = bufm[i+1] + tmpv[1];
    //buf[i+2] = buf[i+2] + tmpv[2];
    //buf[i+3] = buf[i+3] + tmpv[3];
    //buf[i+4] = buf[i+4] + tmpv[4];
    //buf[i+5] = buf[i+5] + tmpv[5];
    //buf[i+6] = buf[i+6] + tmpv[6];
    //buf[i+7] = buf[i+7] + tmpv[7];
    bufs[i]   = bufs[i]   + tmpv[0]*tmpv[0];
    bufs[i+1] = bufs[i+1] + tmpv[1]*tmpv[1];
  }
  
}

// mex function /////////////////////////////////////////////////
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[] )
{
  char *filename;
  double *pframes, *pimg;
  unsigned long *imgmeanL, *imgstdL;
  unsigned char *bmpdata;
  unsigned long *imgm,*imgs;
  unsigned char *imgr;
  double *imgmean, *imgstd;
  int i, j, nframes, npts;
  MOVIE_DATA mdata;
  int dims[3], status, w, h, k, wh, wh2;

  // Check for proper number of arguments
  if (nrhs != 2) {
    mexPrintf("Usage: [imgmean imgstd width heigth] = vavi_mean(filename,frames)\n");
    mexPrintf("Notes: frames>=0, length(frames)<66051.  ver.0.91 Sep-2003\n");
    return;
  }

  memset(&mdata, 0, sizeof(MOVIE_DATA));
  bmpdata = NULL;
  imgmeanL = NULL;  imgstdL = NULL;
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


  // Get frame indices
  nframes = mxGetN(FRAMES_IN) * mxGetM(FRAMES_IN);
  pframes = (double *)mxGetPr(FRAMES_IN);
  if (nframes >= 66051) {
    mexPrintf("\nvavi_mean: num.frames[%d] should be < 66051.",nframes);
  }

  // open the stream
  if (OpenAVI(&mdata) != 0) {
    mexPrintf("\nvavi_mean: avifile=%s,frame=%d\n",
              mdata.filename,mdata.currframe);
    mexErrMsgTxt("vavi_mean: OpenAVI() failed."); 
  }

  if (nframes == 0)  nframes = mdata.numframes;
  // allocate memory, 8byte alignment for faster access
  npts = mdata.width*mdata.height*3;
  bmpdata = (unsigned char *)calloc(npts,sizeof(unsigned char));
  //imgr = (unsigned char *)(((unsigned)bmpdata + 7) &~ 7);
  imgr = bmpdata;
  imgmeanL = (unsigned long *)calloc(npts,sizeof(unsigned long));
  //imgm = (unsigned long *)(((unsigned)imgmeanL + 7) &~ 7);
  imgm = imgmeanL;
  if (nlhs > 1) {
    imgstdL  = (unsigned long *)calloc(npts,sizeof(unsigned long));
    //imgs = (unsigned long *)(((unsigned)imgstdL + 7) &~ 7);
    imgs = imgstdL;
  }

  k = -1000;
  for (j = 0; j < nframes; j++) {
    mdata.currframe = (int)(pframes[j] + 0.5);
    if (mdata.currframe < 0 || mdata.currframe >= mdata.numframes) continue;
    if (mdata.currframe != k) {
      if (GrabAVIFrame(&mdata,imgr) != 0) {
        // release AVI resources.
        CloseAVI(&mdata);
        if (bmpdata  != NULL) { free(bmpdata);   bmpdata = NULL;  }
        if (imgmeanL != NULL) { free(imgmeanL);  imgmeanL = NULL; }
        if (imgstdL  != NULL) { free(imgstdL);   imgstdL = NULL;  }
        mexPrintf("\nvavi_mean: avifile=%s,frame=%d\n",
                  mdata.filename,mdata.currframe);
        mexErrMsgTxt("vavi_mean: GrabAVIFrame() failed."); 
      }
      k = mdata.currframe;
    }
    // add bmpdata, must be devided by 255 later.
    // add bmpdata^2, must be devided by 255*255(=65025).
    if (imgstdL == NULL) {
      addRaw2Image(imgm,imgr,npts);
    } else {
      //addRaw2Image(imgm,imgr,npts);
      //addRawRaw2Image(imgs,imgr,npts);
      procRaw2Image(imgm,imgs,imgr,npts);
    }
  }
  CloseAVI(&mdata);  // release AVI resources.
  if (bmpdata != NULL) { free(bmpdata);  bmpdata = NULL; }


  // get a mean image
  imgmean = (double *)calloc(npts,sizeof(double));
  for (i = 0; i < npts; i++) {
    imgmean[i] = (double)imgm[i] / (double)nframes / 255.0;
  }
  // get a std image
  if (nlhs > 1) {
    double tmpv, tmpn, tmpn2;
    imgstd  = (double *)calloc(npts,sizeof(double));
    tmpn  = (double)nframes;
    tmpn2 = 0;
    if (nframes > 1) tmpn2 = tmpn / (tmpn - 1.0);
    tmpn = tmpn * 65025.0;        // 255*255=65025.
    for (i = 0; i < npts; i++) {
      tmpv = (double)imgs[i] / tmpn - imgmean[i]*imgmean[i];
      imgstd[i] = sqrt(tmpv * tmpn2);
    }
  }
  if (imgmeanL != NULL) { free(imgmeanL);  imgmeanL = NULL; }
  if (imgstdL  != NULL) { free(imgstdL);   imgstdL = NULL;  }


  // set dimenstion
  dims[0] = mdata.height;  // height
  dims[1] = mdata.width;   // width
  dims[2] = 3;             // color: RGB

  IMGMEAN_OUT = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
  pimg = (double *)mxGetPr(IMGMEAN_OUT);

  // Matlab stores image as a three-dimensional
  // (m-by-n-by-3) array of floating-point
  // values in the range [0, 1]...
  wh = mdata.height*mdata.width;
  wh2 = 2*wh;
  j = 0;
  for (h = mdata.height-1; h >= 0; h--) {
    i = h;
    for (w = 0; w < mdata.width; w++) {
      pimg[i]     = imgmean[j];
      pimg[i+wh]  = imgmean[j+1];
      pimg[i+wh2] = imgmean[j+2];
      j += 3;
      i += mdata.height;
    }
  }
  if (imgmean != NULL) { free(imgmean);  imgmean = NULL; }

  if (nlhs > 1) {
    IMGSTD_OUT = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
    pimg = (double *)mxGetPr(IMGSTD_OUT);
    wh = mdata.height*mdata.width;
    wh2 = 2*wh;
    j = 0;
    for (h = mdata.height-1; h >= 0; h--) {
      i = h;
      for (w = 0; w < mdata.width; w++) {
        pimg[i]     = imgstd[j];
        pimg[i+wh]  = imgstd[j+1];
        pimg[i+wh2] = imgstd[j+2];
        j += 3;
        i += mdata.height;
      }
    }
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
