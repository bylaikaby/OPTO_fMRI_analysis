#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <matrix.h>
#include "mex.h"

#include "son.h"
#include "machine.h"
#include "SONDef.h"

HINSTANCE hinstLib;
BOOL fFreeResult, fRunTimeLinkSuccess = FALSE;
char * function_name;

typedef int (*TFUNC)(short);


int _SONGetVersion(short fh)
{
    int j;
	TFUNC func;
    
    func = (TFUNC) GetProcAddress(hinstLib, "SONGetVersion");
    j= func(fh);
    return j;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
const mxArray *prhs[])
{
    
    int *p;
    int j;
    short fh;
    int dims[2]={1, 1};
    
    
//Load and get pointer to the library SON32.DLL//
    hinstLib = SONLoadLibrary(SON32);
    if (hinstLib == NULL)
    {
        plhs[0]=mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
        p=mxGetPr(plhs[0]);
        p[0]=SON_BAD_PARAM;
        mexPrintf("%s NOT FOUND", SON32);
        return;
    }
    
    {
        p=mxGetPr(prhs[0]);
        fh=*p;
        j=_SONGetVersion(fh);
        plhs[0]=mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
        p=mxGetPr(plhs[0]);
        p[0]=j;
        fFreeResult = FreeLibrary(hinstLib);
    }
    
}




