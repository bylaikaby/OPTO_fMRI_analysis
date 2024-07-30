#ifndef _INCLUDE_FLIP_H
#define _INCLUDE_FLIP_H


#if defined(_MSC_VER) && (_MSC_VER <= 1500)
typedef __int32  int32_t;
#else
#include <stdint.h>
#endif


#ifdef __cplusplus
extern "C" {
#endif


float  flipfloat(float oldf);
double flipdouble(double oldd);
int    flipint32(int32_t oldl);
short  flipshort(short olds);

void   flipint32s(int n, int32_t *vals);
void   flipshorts(int n, short *vals);
void   flipfloats(int n, float *vals);


#ifdef __cplusplus
}
#endif

#endif  // end of _INCLUDE_FLIP_H
