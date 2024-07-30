/*
 * NAME
 *   vavifunc.h - avi-interface.
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
 *   0.91 26.07.03 YM,  improved performance.
 *   0.92 27.07.03 YM,  adds functions for matlab.
 *
 */


/************************************************************************
 *                              Headers
 ************************************************************************/

#ifndef _VAVIFUNC_H_INCLUDED
#define _VAVIFUNC_H_INCLUDED

#include <vfw.h>  // video for windows
#pragma comment ( lib, "vfw32.lib" )

#ifdef __cpulsplus
extern "C" {
#endif

typedef struct _moviedata {
  // AVI data to get frames
  PGETFRAME pgf;      // Pointer To A GetFrame Object
  int currframe;      // current frame to draw
  int width;          // Video Width
  int height;         // Video Height
  int numframes;      // Last Frame Of The Stream
  float haspect;      // half of aspect ratio 
  // AVI info/handles: no need for faster access.
  AVISTREAMINFO si;   // A Structure Containing Stream Info
  PAVISTREAM    pavi; // Handle To An Open Stream
  int  mpf;           // Will Hold Rough Milliseconds Per Frame
  char filename[256];
} MOVIE_DATA;


// prototypes
void InitAVILib();
void ExitAVILib();
void FlipBGR2RGB(void *buffer, int len);
int  OpenAVI(MOVIE_DATA *m);
int  GrabAVIFrame(MOVIE_DATA *m, unsigned char *bmpdata);
int  GrabAVIFrameDouble(MOVIE_DATA *m, double *bmpdata);
int  GrabAVIFrameMatlab(MOVIE_DATA *m, double *bmpdata);
void CloseAVI(MOVIE_DATA *m);

#ifdef __cplusplus
}
#endif


#endif // end of _VAVIFUNC_H_INCLUDED
