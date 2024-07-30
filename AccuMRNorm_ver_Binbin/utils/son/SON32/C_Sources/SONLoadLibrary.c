/* SONLoadLibrary.c
 *
 * Load SON32.dll either by SONDef.h or SONFindSON32DLL.m
 *
 *
 * VERSION
 *   0.90 03.03.2010 YM  pre-release
 *
 * See also SONDef.h SONFindSON32DLL.m
 */



#include <string.h>
#include <windows.h>
#include <matrix.h>
#include <mex.h>

#include "SONDef.h"




HINSTANCE SONLoadLibrary(char *libname)
{
  char fname[1024];
  int n;
  mxArray *pl[2];
  HINSTANCE hinst;

  if (libname == NULL || strlen(libname) == 0) {
	hinst = LoadLibrary(SON32);
  } else {
	hinst = LoadLibrary(libname);
  }
  if (hinst != NULL)  return hinst;

  mexCallMATLAB(1,pl,0,NULL,"SONFindSON32DLL");
  n = mxGetM(pl[0])*mxGetN(pl[0]);
  //mexPrintf(" AAAAA n=%d",n);
  if (n == 0)  return NULL;
  mxGetString(pl[0],fname,n+1);
  //mexPrintf("\nDLL=%s\n",fname);
  
  return LoadLibrary(fname);
}
