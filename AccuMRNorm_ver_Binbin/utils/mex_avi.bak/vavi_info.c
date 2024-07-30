/*
 * NAME
 *   vavi_info.c - mex DLL to get AVI info.
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
 *   0.91 21.07.03 YM,  potential bug fix.
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

/* Output Arguments */
#define	WIDTH_OUT		plhs[0]
#define HEIGHT_OUT	plhs[1]
#define NFRAMES_OUT	plhs[2]

// mex function
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] );


// mex function /////////////////////////////////////////////////
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[] )
{
  char *filename;
  MOVIE_DATA mdata;
  int dims[3], status, i, c, w, h, k, j;
  double *pimg;

  // Check for proper number of arguments
  if (nrhs != 1) {
    mexPrintf("Usage: [width height nframes] = vavi_info(filename)\n");
    mexPrintf("Notes:            ver.0.91 Jul-2003\n");
    return;
  }

  // Get the filename
  if (mxIsChar(FILE_IN) != 1 || mxGetM(FILE_IN) != 1) {
    mexErrMsgTxt("vavi_info: first arg must be filename string."); 
  }
  i = (mxGetM(FILE_IN) * mxGetN(FILE_IN)) + 1;
  filename = mxCalloc(i, sizeof(char));
  status = mxGetString(FILE_IN, filename, i);
  if (status != 0) {
    mexWarnMsgTxt("vavi_info: not enough space, filename string is truncated.");
  }
  sprintf(mdata.filename,"%s",filename);


  // get info
  if (OpenAVI(&mdata) != 0) {
    mexErrMsgTxt("vavi_info: OpenAVI() failed."); 
  }
  // release AVI resources.
  CloseAVI(&mdata);

  if (nlhs == 0) {
    char codecstr[32];
    double fps;
    memcpy(codecstr,&(mdata.si.fccHandler),4);  codecstr[4] = '\0';
    if (mdata.si.dwScale == 0) {
      fps = 1000.0/(double)mdata.mpf;
    } else {
      fps = (double)mdata.si.dwRate/(double)mdata.si.dwScale;
    }
    mexPrintf("file:    %s\n",mdata.filename);
    mexPrintf("width:   %d\n",mdata.width);
    mexPrintf("height:  %d\n",mdata.height);
    mexPrintf("nframes: %d\n",mdata.numframes);
    mexPrintf("codec:   \'%s\'\n",codecstr);
    mexPrintf("quality: %u\n",mdata.si.dwQuality);
    mexPrintf("fps:     %.2lf\n",fps);
    mexPrintf("stream:  \'%s\'\n",mdata.si.szName);
    //mexPrintf("datarate: %d\n",mdata.si.dwRate);
    // mexPrintf("datascale: %d\n",mdata.si.dwScale);
  }

  // width
  if (nlhs >= 1) {
    WIDTH_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetPr(WIDTH_OUT) = (double)mdata.width;
  }
  // height
  if (nlhs >= 2) {
    HEIGHT_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetPr(HEIGHT_OUT) = (double)mdata.height;
  }
  // number of frames
  if (nlhs >= 3) {
    NFRAMES_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetPr(NFRAMES_OUT) = (double)mdata.numframes;
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
