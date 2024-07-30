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
void procRaw2Image(unsigned long *, const unsigned char *, const int);
void alignImage4Matlab(double *,const double *, const int, const int);

// mex function
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] );



// local functions
void addRaw2Image(unsigned long *buf, const unsigned char *raw, const int npts)
{
  int i, j;
  unsigned long tmpv[4];
  for (i = 0, j = 0; i < npts; i+=2, j+=4) {
    tmpv[0] = raw[i];
    tmpv[1] = raw[i+1];
    buf[j]   = buf[j]   + tmpv[0];
    //buf[j+1] = buf[j+1] + tmpv[0]*tmpv[0];
    buf[j+2] = buf[j+2] + tmpv[1];
    //buf[j+3] = buf[j+3] + tmpv[1]*tmpv[1];
  }
  return;
}

void procRaw2Image(unsigned long *buf, const unsigned char *raw, const int npts)
{
  int i, j;
#if 0
  unsigned long tmpv;
  for (i = 0, j = 0; i < npts; i++, j+=2) {
    tmpv = raw[i];
    buf[j]   = buf[j]   + tmpv;
    buf[j+1] = buf[j+1] + tmpv*tmpv;
  }
#else
  unsigned long tmpv[8];
  for (i = 0, j = 0; i < npts; i+=4, j+=8) {
    tmpv[0] = raw[i];
    tmpv[1] = raw[i+1];
    tmpv[2] = raw[i+2];
    tmpv[3] = raw[i+3];
    //tmpv[4] = raw[i+4];
    //tmpv[5] = raw[i+5];
    //tmpv[6] = raw[i+6];
    //tmpv[7] = raw[i+7];
    buf[j]   = buf[j]   + tmpv[0];
    buf[j+1] = buf[j+1] + tmpv[0]*tmpv[0];
    buf[j+2] = buf[j+2] + tmpv[1];
    buf[j+3] = buf[j+3] + tmpv[1]*tmpv[1];
    buf[j+4] = buf[j+4] + tmpv[2];
    buf[j+5] = buf[j+5] + tmpv[2]*tmpv[2];
    buf[j+6] = buf[j+6] + tmpv[3];
    buf[j+7] = buf[j+7] + tmpv[3]*tmpv[3];
/*     buf[j]   = buf[j]   + raw[i]; */
/*     buf[j+1] = buf[j+1] + raw[i]*raw[i]; */
/*     buf[j+2] = buf[j+2] + raw[i+1]; */
/*     buf[j+3] = buf[j+3] + raw[i+1]*raw[i+1]; */
/*     buf[j+4] = buf[j+4] + raw[i+2]; */
/*     buf[j+5] = buf[j+5] + raw[i+2]*raw[i+2]; */
/*     buf[j+6] = buf[j+6] + raw[i+3]; */
/*     buf[j+7] = buf[j+7] + raw[i+3]*raw[i+3]; */
    //buf[j+8] = buf[j+8] + tmpv[4];
    //buf[j+9] = buf[j+9] + tmpv[4]*tmpv[4];
    //buf[j+10] = buf[j+10] + tmpv[5];
    //buf[j+11] = buf[j+11] + tmpv[5]*tmpv[5];
    //buf[j+12] = buf[j+12] + tmpv[6];
    //buf[j+13] = buf[j+13] + tmpv[6]*tmpv[6];
    //buf[j+14] = buf[j+14] + tmpv[7];
    //buf[j+15] = buf[j+15] + tmpv[7]*tmpv[7];
    // force to prefetch
    //tmpv[0] = raw[i+4];
    //tmpv[0] = buf[i+8];
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
  unsigned long *imgbuff;
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
  iframes = NULL;
  bmpdata = NULL;   imgbuff = NULL;
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

  // allocate memory, 8byte alignment for faster access
  npts = mdata.width*mdata.height*3;
  bmpdata = (unsigned char *)calloc(npts + 7,sizeof(unsigned char));
  // imgbuff store both values for mean/std at even/odd locations.
  // this is an attempt to improve memory access....
  imgbuff = (unsigned long *)calloc(npts*2 + 7,sizeof(unsigned long));

  k = -1000;
  for (j = 0; j < nframes; j++) {
    mdata.currframe = iframes[j];
    if (mdata.currframe < 0 || mdata.currframe >= mdata.numframes) continue;
    if (mdata.currframe != k) {
      if (GrabAVIFrame(&mdata,bmpdata) != 0) {
        // release AVI resources.
        CloseAVI(&mdata);
        if (iframes != NULL) { free(iframes);  iframes = NULL; }
        if (bmpdata != NULL) { free(bmpdata);  bmpdata = NULL; }
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
      addRaw2Image(imgbuff,bmpdata,npts);
    } else {
      procRaw2Image(imgbuff,bmpdata,npts);
    }
  }
  CloseAVI(&mdata);  // release AVI resources.
  if (bmpdata != NULL) { free(bmpdata);  bmpdata = NULL; }


  // get a mean image
  imgmean = (double *)calloc(npts,sizeof(double));
  for (i = 0, j = 0; i < npts; i++, j+=2) {
    imgmean[i] = (double)imgbuff[j] / (double)nframes / 255.0;
  }
  // get a std image
  if (nlhs > 1) {
    double tmpv, tmpn, tmpn2;
    imgstd  = (double *)calloc(npts,sizeof(double));
    tmpn  = (double)nframes;
    tmpn2 = 0;
    if (nframes > 1) tmpn2 = tmpn / (tmpn - 1.0);
    tmpn = tmpn * 65025.0;        // 255*255=65025.
    for (i = 0, j = 0; i < npts; i++, j+=2) {
      tmpv = (double)imgbuff[j+1] / tmpn - imgmean[i]*imgmean[i];
      imgstd[i] = sqrt(tmpv * tmpn2);
    }
  }
  if (iframes != NULL) { free(iframes);  iframes = NULL; }
  if (imgbuff != NULL) { free(imgbuff);  imgbuff = NULL; }


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
