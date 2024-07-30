/*
 * uigetfiles.c
 *
 * ver. 1.00  04-04-2001  Yusuke MURAYAMA
 *
 */

#include <windows.h>
#include <math.h>
#include <stdio.h>
#include <memory.h>
#include <string.h>

#include "mex.h"
#include "matrix.h"

#define MI_FILTSPEC   prhs[0]
#define MI_DLGTITLE   prhs[1]
#define MO_FILENAMES  plhs[0]
#define MO_FILEPATH   prhs[1]


void uipickfiles(char *filtSpec, char *dlgTitle,
                 int *nfiles, char *fpath, char **fnames)
{
  OPENFILENAME ofn;
  char szFileName[MAX_PATH];
  char szFileNameBuffer[MAX_PATH*64];
  char szInitialDir[MAX_PATH];
  char szFilter[MAX_PATH];
  char ctmp[256];
  int  n;

  // initialize output
  *nfiles = 0;
  // initialize some vars.
  n = strstr(filtSpec,"*");
  strncpy(szInitialDir, filtSpec, n);
  sprintf(szFilter,"%s File (*.%s)\0*.%s\0\0",&filtSpec[n],&filtSpec[n]);

  // initialize ofn struct
  ZeroMemory((LPVOID)&ofn, sizeof(OPENFILENAME));
  ofn.lStructSize = sizeof(OPENFILENAME);
  ofn.hwndOwner = hwnd;
  ofn.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | 
    OFN_EXPLORER | OFN_ALLOWMULTISELECT;
  ofn.lpstrTitle = dlgTitle;
  ofn.lpstrInitialDir = szInitialDir;
  ofn.lpstrFilter = szFilter;
  ofn.lpstrFile = szFileNameBuffer;
  ofn.nMaxFile = 64;
  // create a dialog
  if (GetOpenFileName(&ofn) == TRUE) {
    fpath = (char *)malloc(sizeof(char)*MAX_PATH);
    LPTSTR lpEnd = strchr(szFileNameBuffer, '\0');
    LPTSTR lpszNextString = lpEnd + 1;
    if (lpEnd) {
      if (*(lpszNextString) == '\0') {  // single file selected
        fnames[*nfiles] = (char *)malloc(sizeof(char)*lstrlen(lpszNextString)+1);
        lpEnd = strchr(szFileNameBuffer, '\\');
        lpszNextString = lpEnd + 1;
        do {
          lpEnd = strchr(lpszNextString,'\\');
          lpszNextString = lpEnd + 1;
        } while (*(lpszNextString) != '\0');
        lstrcpy(fpath, szFileNameBuffer);
        (*nfiles)++;
      } else {                          // lots of files selected
        // get a folder name
        lstrcpy(fpath, szFileNameBuffer);
        if (szFolder[lstrlen(szFolder)] != '\\') lstrcat(szFolder, '\\');
        // get filenames
        szBuffer[0] = '\0';
        while (*(lpszNextString) != '\0') {
          fnames[*nfiles] = (char *)malloc(sizeof(char)*lstrlen(lpszNextString)+1);
          lstrcpy(fnames, lpszNextString);
          lpEnd = strchr(lpszNextString, '\0');
          lpszNextString = lpEnd + 1;
          (*nfiles)++;
        }
      }
    }
  }
  return;
}


/* MEX function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char filtSpec[MAX_PATH], dlgTitle[64];
  char *pathname, *fnames[64];
  int status,buflen,nfiles;

  /* Check for proper number of arguments. */
  if (nrhs == 0) {
		mexPrintf(" USAGE: [filenames pathname] = uigetfiles('filterSpec','dialogTitle')");
    return;
  }
  /* get the input args */
  if (mxIsChar(MI_FILTSPC)) {
    buflen = (mxGetM(MI_FILTSPEC) * mxGetN(MI_FILTSPEC)) + 1;
    filtSpec = mxCalloc(buflen,sizeof(char));
    status = mxGetString(MI_FILTSPEC,filtSpec,buflen);
  }

  /* initialization */
  GetCurrentDirectory(MAX_PATH-1,filtSpec);
  strcat(filtSpec, "\\*.*");
  sprintf(dlgTitle, "Select files");
  if (nrhs > 0) {
    if (!mxIsString(prhs[0])) {
      mexErrMsgTxt(" Input must be a string.");
    } else {
      sprintf(filtSpec,"%s",prhs[0]);
    }
    if (nrhs == 2) {
      if (!mxIsString(prhs[1])) {
        mexErrMsgTxt(" Input must be a string.");
      } else {
        sprintf(dlgTitle,"%s",prhs[1]);
      }
    }
  }
  /* Call uipickfiles(). */
  uigetfiles(filtSpec,dlgTitle,&nfiles,pathname,fnames);

  /* set outputs */
  


  return;

}
