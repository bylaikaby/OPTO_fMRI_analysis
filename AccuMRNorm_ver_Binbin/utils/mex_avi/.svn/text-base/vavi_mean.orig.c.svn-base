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

// mex function
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] );




// mex function /////////////////////////////////////////////////
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[] )
{
  char *filename;
  MOVIE_DATA mdata;
  int dims[3], status, i, c, w, h, k, j, wh, wh2;
  double *pframes, *pimg;
  double *imgmean, *imgstd;
  unsigned char *bmpdata;
  int nframes, npts;

  // Check for proper number of arguments
  if (nrhs != 2) {
    mexPrintf("Usage: [imgmean imgstd width heigth] = vavi_mean(filename,frames)\n");
    mexPrintf("Notes: frames>=0,  ver.0.90 Jul-2003\n");
    return;
  }

  memset(&mdata, 0, sizeof(MOVIE_DATA));
  bmpdata = NULL;  imgmean = NULL;  imgstd = NULL;

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

  // open the stream
  if (OpenAVI(&mdata) != 0) {
    mexPrintf("\nvavi_mean: avifile=%s,frame=%d\n",
              mdata.filename,mdata.currframe);
    mexErrMsgTxt("vavi_mean: OpenAVI() failed."); 
  }

  if (nframes == 0)  nframes = mdata.numframes;
  // allocate memory
  npts = mdata.width*mdata.height*3;
  bmpdata = (unsigned char *)calloc(npts,sizeof(unsigned char));
  imgmean = (double *)calloc(npts,sizeof(double));
  if (nlhs > 1) {
    imgstd  = (double *)calloc(npts,sizeof(double));
  }

  k = -1000;
  for (j = 0; j < nframes; j++) {
    mdata.currframe = (int)(pframes[j] + 0.5);
    if (mdata.currframe < 0 || mdata.currframe >= mdata.numframes) continue;
    if (mdata.currframe != k) {
      if (GrabAVIFrame(&mdata,bmpdata) != 0) {
        // release AVI resources.
        CloseAVI(&mdata);
        if (bmpdata != NULL) { free(bmpdata);  bmpdata = NULL; }
        if (imgmean != NULL) { free(imgmean);  imgmean = NULL; }
        if (imgstd  != NULL) { free(imgstd);   imgstd = NULL;  }
        mexPrintf("\nvavi_mean: avifile=%s,frame=%d\n",
                  mdata.filename,mdata.currframe);
        mexErrMsgTxt("vavi_mean: GrabAVIFrame() failed."); 
      }
      k = mdata.currframe;
    }
    // add bmpdata
    for (i = 0; i < npts; i++) {
      imgmean[i] = imgmean[i] + (double)bmpdata[i]/255.0;
    }
    // add bmpdata^2, 255*255=65025
    if (imgstd == NULL)  continue;
    for (i = 0; i < npts; i++) {
      imgstd[i]  = imgstd[i] + (double)bmpdata[i]*(double)bmpdata[i]/65025.0;
    }

  }
  CloseAVI(&mdata);  // release AVI resources.
  if (bmpdata != NULL) { free(bmpdata);  bmpdata = NULL; }


  // get a mean image
  for (i = 0; i < npts; i++) imgmean[i] = imgmean[i] / (double)nframes;
  // get a std image
  if (imgstd != NULL) {
    double tmpv, tmpn, tmpn2;
    tmpn  = (double)nframes;
    tmpn2 = 0;
    if (nframes > 1) tmpn2 = tmpn / (tmpn - 1.0);
    for (i = 0; i < npts; i++) {
      tmpv = imgstd[i] / tmpn - imgmean[i]*imgmean[i];
      imgstd[i] = sqrt(tmpv * tmpn2);
    }
  }


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
