/*
 * NAME
 *   vavifunc.c - avi-interface.
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
 *   0.91 25.07.03 YM,  potential bug fix.
 *   0.92 27.07.03 YM,  adds functions for matlab.
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

static int vaviInitialized = 0;


void InitAVILib()
{
  // Opens The AVIFile Library.
  if (vaviInitialized == 0) AVIFileInit();
  vaviInitialized = 1;
}

void ExitAVILib() {
	// Release The AVIFile Library.
  if (vaviInitialized)  AVIFileExit();
}


///////////////////////////////////////////////////////////////////////////
// Flips The Red And Blue Bytes
void FlipBGR2RGB(void *buffer, int len)
{
#if 0
  int i, sz = len*3;
  char *buf, tmpv;

  buf = (char *)buffer;
  for (i = 0; i < sz; i+=3) {
    tmpv = buf[i];
    buf[i] = buf[i+2];
    buf[i+2] = tmpv;
  }


#else
	void* b = buffer;						// Pointer To The Buffer
  int sz = len;
	__asm								// Assembler Code To Follow
	{
		mov ecx, sz					// Set Up A Counter (Dimensions Of Memory Block)
    mov ebx, b						// Points ebx To Our Data (b)
		label:							// Label Used For Looping
			mov al,[ebx+0]					// Loads Value At ebx Into al
			mov ah,[ebx+2]					// Loads Value At ebx+2 Into ah
			mov [ebx+2],al					// Stores Value In al At ebx+2
			mov [ebx+0],ah					// Stores Value In ah At ebx
			
			add ebx,3					// Moves Through The Data By 3 Bytes
			dec ecx						// Decreases Our Loop Counter
			jnz label					// If Not Zero Jump Back To Label
	}
#endif
}

// Opens An AVI File
int OpenAVI(MOVIE_DATA *m)
{
  int error;

	// Opens The AVI Stream
  if (AVIStreamOpenFromFile(&m->pavi, m->filename, streamtypeVIDEO, 0, OF_READ, NULL)!= 0)	{
    error = GetLastError();
    printf("\nvavifunc.c: failed to open the AVI stream. error=%d",error);
    goto on_error;
	}
  
  // Reads Information About The Stream Into si
	AVIStreamInfo(m->pavi, &m->si, sizeof(AVISTREAMINFO));
  // Width Is Right Side Of Frame Minus Left
	m->width = m->si.rcFrame.right - m->si.rcFrame.left;
  // Height Is Bottom Of Frame Minus Top
	m->height = m->si.rcFrame.bottom - m->si.rcFrame.top;
  // The Last Frame Of The Stream
	m->numframes = AVIStreamLength(m->pavi);
  // Calculate Rough Milliseconds Per Frame
	m->mpf = AVIStreamSampleToTime(m->pavi,m->numframes)/m->numframes;

  // get half of aspect ratio
  m->haspect = (float)(((double)m->height)/((double)m->width/2.0));


  // Create The PGETFRAME Using Our Request Mode
	m->pgf = AVIStreamGetFrameOpen(m->pavi, NULL);
	if (m->pgf == NULL) {
    error = GetLastError();
    printf("\nvavifunc.c: failed to open the AVI frame. error=%d",error);
    AVIStreamRelease(m->pavi);      // Release The Stream

    goto on_error;
	}

	// Information For The Title Bar (Width / Height / Last Frame)
	//printf ("\navimovie: width: %d, height: %d, frames: %d", m->width, m->height, m->numframes);

  return 0;

 on_error:

  return -1;
}


// Grab Data From The AVI Stream
int GrabAVIFrame(MOVIE_DATA *m, unsigned char *bmpdata)
{
	LPBITMAPINFOHEADER lpbi;					// Holds The Bitmap Header Information
  char *pdata;
  short tmpv, *psdata;
  int status = 0;
  int i,j,n;

	// Grab Data From The AVI Stream
	lpbi = (LPBITMAPINFOHEADER)AVIStreamGetFrame(m->pgf, m->currframe);
  //pdata = (char *)lpbi + sizeof(BITMAPINFOHEADER);

#if 0
  printf("biSize:%d w:%d h:%d planes:%d bitcount:%d biClrUsed:%d Comp:%d\n",
         lpbi->biSize,lpbi->biWidth,lpbi->biHeight,lpbi->biPlanes,
         lpbi->biBitCount, lpbi->biClrUsed,lpbi->biCompression);
#endif

	// Pointer To Data Returned By AVIStreamGetFrame
  // (Skip The Header Info To Get To The Data)
  pdata = (char *)lpbi + lpbi->biSize + lpbi->biClrUsed * sizeof(RGBQUAD);

  n = m->width*m->height*3;
  if (lpbi->biBitCount == 24) {
    memcpy(bmpdata,pdata,n);
    // Swap The Red And Blue Bytes (GL Compatability)
    FlipBGR2RGB(bmpdata, m->width*m->height);
  } else if (lpbi->biBitCount == 16) {
    if (lpbi->biCompression == BI_BITFIELDS) {
      printf(" vavifunc warning: RGB565???, not supportted yet.");
    }
    psdata = (short *)pdata;
    for (i = 0, j = 0; i < n; i+=3, j++) {
      tmpv = psdata[j];
      // RGB555
#if 1
      bmpdata[i]   = (unsigned char)((tmpv>>7) & 0xf9);
      bmpdata[i+1] = (unsigned char)((tmpv>>2) & 0xf9);
      bmpdata[i+2] = (unsigned char)((tmpv<<3) & 0xf9);
      //bmpdata[i]   = (unsigned char)((tmpv>>8) & 0xf9);
      //bmpdata[i+1] = (unsigned char)((tmpv>>3) & 0xfc);
      //bmpdata[i+2] = (unsigned char)((tmpv<<3) & 0xf9);
#else
      bmpdata[i]   = (unsigned char)((tmpv>>10) & 0x1f)*8;
      bmpdata[i+1] = (unsigned char)((tmpv>>5) & 0x1f)*8;
      bmpdata[i+2] = (unsigned char)(tmpv & 0x1f)*8;
#endif
    }
  }

  return status;
}


// Grab Data From The AVI Stream
int GrabAVIFrameDouble(MOVIE_DATA *m, double *bmpdata)
{
	LPBITMAPINFOHEADER lpbi;					// Holds The Bitmap Header Information
  unsigned char *pdata;
  short tmpv, *psdata;
  int status = 0;
  int i, j, n;

	// Grab Data From The AVI Stream
	lpbi = (LPBITMAPINFOHEADER)AVIStreamGetFrame(m->pgf, m->currframe);
  //pdata = (char *)lpbi + sizeof(BITMAPINFOHEADER);

#if 0
  printf("biSize:%d w:%d h:%d planes:%d bitcount:%d biClrUsed:%d Comp:%d\n",
         lpbi->biSize,lpbi->biWidth,lpbi->biHeight,lpbi->biPlanes,
         lpbi->biBitCount, lpbi->biClrUsed,lpbi->biCompression);
#endif

	// Pointer To Data Returned By AVIStreamGetFrame
  // (Skip The Header Info To Get To The Data)
  pdata = (unsigned char *)lpbi + lpbi->biSize + lpbi->biClrUsed * sizeof(RGBQUAD);

  if (lpbi->biBitCount == 24) {
    n = m->height*m->width*3;
    for (i = 0; i < n; i+=3) {
      bmpdata[i]   = (double)pdata[i+2];
      bmpdata[i+1] = (double)pdata[i+1];
      bmpdata[i+2] = (double)pdata[i];
    }
  } else if (lpbi->biBitCount == 16) {
    if (lpbi->biCompression == BI_BITFIELDS) {
      printf(" vavifunc warning: RGB565???, not supportted yet.");
    }
    // RGB555
    psdata = (short *)pdata;
    n = m->height*m->width*3;
    for (i = 0, j = 0; i < n; i+=3, j++) {
        tmpv = psdata[j];
        bmpdata[i]   = (double)((unsigned char)((tmpv>>7) & 0xf9));
        bmpdata[i+1] = (double)((unsigned char)((tmpv>>2) & 0xf9));
        bmpdata[i+2] = (double)((unsigned char)((tmpv<<3) & 0xf9));
    }
  }

  return status;
}


// Grab Data From The AVI Stream for matlab
int GrabAVIFrameMatlab(MOVIE_DATA *m, double *bmpdata)
{
	LPBITMAPINFOHEADER lpbi;					// Holds The Bitmap Header Information
  unsigned char *pdata;
  short tmpv, *psdata;
  int status = 0;
  int i, j, k, c, w, h;

	// Grab Data From The AVI Stream
	lpbi = (LPBITMAPINFOHEADER)AVIStreamGetFrame(m->pgf, m->currframe);
  //pdata = (char *)lpbi + sizeof(BITMAPINFOHEADER);

#if 0
  printf("biSize:%d w:%d h:%d planes:%d bitcount:%d biClrUsed:%d Comp:%d\n",
         lpbi->biSize,lpbi->biWidth,lpbi->biHeight,lpbi->biPlanes,
         lpbi->biBitCount, lpbi->biClrUsed,lpbi->biCompression);
#endif

	// Pointer To Data Returned By AVIStreamGetFrame
  // (Skip The Header Info To Get To The Data)
  pdata = (unsigned char *)lpbi + lpbi->biSize + lpbi->biClrUsed * sizeof(RGBQUAD);

  // Matlab stores image as a three-dimensional
  // (m-by-n-by-3) array of floating-point
  // values in the range [0, 1]...
  if (lpbi->biBitCount == 24) {
#if 1
# if 1
    for (c = 0; c < 3; c++) {
      k = m->height*m->width*c;
      j = 2 - c;  // need to flip Red and Blue
      for (h = 0; h < m->height; h++) {
        i = m->height - h - 1 + k;
        for (w = 0; w < m->width; w++) {
          bmpdata[i] = (double)pdata[j];
          j += 3;
          i += m->height;
        }
      }
    }
# else
    k = m->height*m->width*3;
    for (h = 0; h < k; h++)  bmpdata[h] = (double)pdata[h];
# endif
#else
    j = 0;
    c = m->height*m->width;
    k = c*2;
    for (h = 0; h < m->height; h++) {
      i = m->height - h - 1;
      for (w = 0; w < m->width; w++) {
        // need to flip RED and BLUE
        bmpdata[i+k] = (double)pdata[j];
        bmpdata[i+c] = (double)pdata[j+1];
        bmpdata[i]   = (double)pdata[j+2];
        j += 3;
        i += m->height;
      }
    }
#endif
  } else if (lpbi->biBitCount == 16) {
    if (lpbi->biCompression == BI_BITFIELDS) {
      printf(" vavifunc warning: RGB565???, not supportted yet.");
    }
    // RGB555
    psdata = (short *)pdata;
    j = 0;
    c = m->height*m->width;
    k = c*2;
    for (h = 0; h < m->height; h++) {
      i = m->height - h - 1;
      for (w = 0; w < m->width; w++) {
        tmpv = psdata[j];
        bmpdata[i]   = (double)((unsigned char)((tmpv>>7) & 0xf9));
        bmpdata[i+c] = (double)((unsigned char)((tmpv>>2) & 0xf9));
        bmpdata[i+k] = (double)((unsigned char)((tmpv<<3) & 0xf9));
        j ++;
        i += m->height;
      }
    }
  }

  return status;
}


// Properly Closes The Avi File
void CloseAVI(MOVIE_DATA *m)
{
	AVIStreamGetFrameClose(m->pgf); // Deallocates The GetFrame Resources
	AVIStreamRelease(m->pavi);      // Release The Stream
}

