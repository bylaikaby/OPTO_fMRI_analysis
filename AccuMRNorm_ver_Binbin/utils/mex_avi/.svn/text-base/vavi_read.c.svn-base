/*
 * NAME
 *   vavi_read.c - mex DLL to read AVI.
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
 *   0.90 21.07.03 YM,  pre-release, supports windows only.
 *   0.91 26.07.03 YM,  potential bug fix, improved performance 8~15%.
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
#define FRAME_IN		prhs[1]
#define SCALE_IN    prhs[2]

/* Output Arguments */
#define	IMAGE_OUT  	plhs[0]
#define	WIDTH_OUT		plhs[1]
#define HEIGHT_OUT	plhs[2]

// mex function
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] );


// mex function /////////////////////////////////////////////////
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[] )
{
  char *filename;
  MOVIE_DATA mdata;
  int dims[3], status, i, c, w, h, k, j, wh, wh2;
  int scale;
  double *bmpdata;

  // Check for proper number of arguments
  if (nrhs < 2) {
    mexPrintf("Usage: [img width height] = vavi_read(filename,frame,[scale=1])\n");
    mexPrintf("Notes: frame>=0,  ver.0.92 Sep-2003\n");
    return;
  }

  memset(&mdata, 0, sizeof(MOVIE_DATA));

  // Get the filename
  if (mxIsChar(FILE_IN) != 1 || mxGetM(FILE_IN) != 1) {
    mexErrMsgTxt("vavi_read: first arg must be filename string."); 
  }
  i = (mxGetM(FILE_IN) * mxGetN(FILE_IN)) + 1;
  filename = mxCalloc(i, sizeof(char));
  status = mxGetString(FILE_IN, filename, i);
  if (status != 0) {
    mexWarnMsgTxt("vavi_read: not enough space, filename string is truncated.");
  }
  sprintf(mdata.filename,"%s",filename);


  // Get frame index
  mdata.currframe = (int) mxGetScalar(FRAME_IN);

  // Get Scale
  scale = 1;
  if (nrhs > 2) scale = (int)mxGetScalar(SCALE_IN);

  // get the frame
  if (OpenAVI(&mdata) != 0) {
    mexPrintf("\nvavi_read: avifile=%s,frame=%d\n",
              mdata.filename,mdata.currframe);
    mexErrMsgTxt("vavi_read: OpenAVI() failed."); 
  }
  if (mdata.currframe < 0) {
    mdata.currframe = 0;
    mexPrintf("vavi_read: frame was set to 0.\n");
  } else if (mdata.currframe >= mdata.numframes) {
    mdata.currframe = mdata.numframes - 1;
    mexPrintf("vavi_read: frame was set to the end.\n");
  }

  // set dimenstion
  dims[0] = mdata.height;  // height
  dims[1] = mdata.width;   // width
  dims[2] = 3;             // color: RGB

  // Create images for the return argument
  IMAGE_OUT = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
  bmpdata = (double *)mxGetPr(IMAGE_OUT);

  // Matlab stores image as a three-dimensional
  // (m-by-n-by-3) array of floating-point
  if (GrabAVIFrameMatlab(&mdata,bmpdata) != 0) {
    // release AVI resources.
    CloseAVI(&mdata);
    mexPrintf("\nvavi_read: avifile=%s,frame=%d\n",
              mdata.filename,mdata.currframe);
    mexErrMsgTxt("vavi_read: GrabAVIFrame() failed."); 
  }
  CloseAVI(&mdata);  // release AVI resources.

  if (scale > 0) {
    for (i = 0; i < mdata.height*mdata.width*3; i++) {
      bmpdata[i] = bmpdata[i] / 255.0;
    }
  }

#if 0
# if 1
  wh = mdata.height*mdata.width;
  wh2 = 2*wh;
  j = 0;
  for (h = mdata.height-1; h >= 0; h--) {
    i = h;
    for (w = 0; w < mdata.width; w++) {
      pimg[i]     = (double)bmpdata[j];
      pimg[i+wh]  = (double)bmpdata[j+1];
      pimg[i+wh2] = (double)bmpdata[j+2];
      j += 3;
      i += mdata.height;
    }
  }
# else
#  if 1
  for (c = 0; c < 3; c++) {
    k = mdata.height*mdata.width*c;
    j = c;
    for (h = 0; h < mdata.height; h++) {
      i = mdata.height - h - 1 + k;
      for (w = 0; w < mdata.width; w++) {
        pimg[i] = (double)bmpdata[j];
        j += 3;
        i += mdata.height;
      }
    }
  }
#  else
  i = 0;
  wh = mdata.width*mdata.height;
  wh2 = 3*mdata.width;
  for (c = 0; c < 3; c++) {
    for (w = 0; w < mdata.width; w++) {
      j = (wh - mdata.width -1 + w)*3 + c;
      for (h = mdata.height-1; h>=0; h--) {
        pimg[i] = (double)bmpdata[j];
        i++;
        j -= wh2;
      }
    }
  }
#  endif
# endif

#endif

  // width
  if (nlhs >= 2) {
    WIDTH_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetPr(WIDTH_OUT) = (double)mdata.width;
  }
  // height
  if (nlhs >= 3) {
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
