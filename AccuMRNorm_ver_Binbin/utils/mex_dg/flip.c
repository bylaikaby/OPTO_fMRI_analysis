/************************************************************************/
/*                                                                      */
/*                              utilc.c                                 */
/*                    (general utility routines)                        */
/*                                                                      */
/*  This module includes functions for:                                 */
/*         Flipping bytes                                               */
/*                                                                      */
/*  NOTE :                                                              */
/*    To support 64bit *nux/mac system, fliplong*() as flipint32*().    */
/*                win32  win64   *nix32  *nix64                         */
/*  sizeof(int)     4      4        4       4                           */
/*  sizeof(long)    4      4        4       8                           */
/*                                                                      */
/************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "flip.h"

/*
 * Routines for flipping bytes
 */

float
flipfloat(float oldf)
{
  float newf;
  char *old, *new;

  old = (char *) &oldf;
  new = (char *) &newf;

  new[0] = old[3];
  new[1] = old[2];
  new[2] = old[1];
  new[3] = old[0];
  
  return(newf);
}


double
flipdouble(double oldd)
{
  double newd;
  char *old, *new;

  old = (char *) &oldd;
  new = (char *) &newd;

  new[0] = old[7];
  new[1] = old[6];
  new[2] = old[5];
  new[3] = old[4];
  new[4] = old[3];
  new[5] = old[2];
  new[6] = old[1];
  new[7] = old[0];

  return(newd);
}


int
flipint32(int32_t oldl)
{
  int32_t newl;
  char *old, *new;

  old = (char *) &oldl;
  new = (char *) &newl;

  new[0] = old[3];
  new[1] = old[2];
  new[2] = old[1];
  new[3] = old[0];
  
  return(newl);
}

short
flipshort(short olds)
{
  short news;
  char *old, *new;

  old = (char *) &olds;
  new = (char *) &news;

  new[0] = old[1];
  new[1] = old[0];
  
  return(news);
}

void flipint32s(int n, int32_t *vals)
{
  int i;
  for (i = 0; i < n; i++) vals[i] = flipint32(vals[i]);
}

void flipshorts(int n, short *vals)
{
  int i;
  for (i = 0; i < n; i++) vals[i] = flipshort(vals[i]);
}

void flipfloats(int n, float *vals)
{
  int i;
  for (i = 0; i < n; i++) vals[i] = flipfloat(vals[i]);
}
