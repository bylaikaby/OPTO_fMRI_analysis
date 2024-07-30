/*
 * uipickfiles.c
 * an altnative for MATLAB linkage() function 
 *
 * This is much faster than MATLAB native function.
 *
 * ver. 1.00  16-12-1999  Yusuke MURAYAMA
 *
 */

#include "mex.h"
#include "matrix.h"

#include <math.h>
#include <memory.h>
#include <string.h>


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
  int status,nfiles;

  /* Check for proper number of arguments. */
  if (nrhs == 0 || nlhs > 2) {
		mexErrMsgTxt(" USAGE: [filename pathname] = uipickfiles('filterSpec','dialogTitle')");
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
  uigetfiles(filtSpec,dlgTitle,&nfiles,pathname,fnames);

  /* Get dimension of an input matrix */
  n_vars = (int) mxGetM(prhs[0]);
  n_dist = (int) mxGetN(prhs[0]);
  if (n_dist < 3) {
		mexErrMsgTxt(" You have to have at least 3 distances to do a linkage.");
  }
  
  n_datad = (1 + sqrt(1. + 8.* n_dist)) / 2.;
  n_datai = (int)n_datad;
  n_datad = fabs(n_datad - (double)n_datai);
  if ((n_vars != 1) || (n_datad >= 1.0e-10)) {
		mexErrMsgTxt(" Tthe 1st input has to match the output of pdist() in size.");
  }

  /* Get a method to compute distance, if possible. */
  if (nrhs >= 2) {
		status = mxGetString(prhs[1], ch_method, 2+1); 
		if (!stricmp(ch_method, "SI"))      method = SINGLE;
		else if (!stricmp(ch_method, "CO")) method = COMPLETE;
		else if (!stricmp(ch_method, "AV")) method = AVERAGE;
		else if (!stricmp(ch_method, "CE")) method = CENTROID;
		else if (!stricmp(ch_method, "WA")) method = WARD;
		else mexErrMsgTxt(" Unknown metric method.");
  }

  /* Call uipickfiles(). */
  y = mxGetPr(prhs[0]);
  mx_tmp[0] = mxCreateDoubleMatrix(3, n_datai-1, mxREAL);
  z = mxGetPr(mx_tmp[0]);
  uipickfiles(z, y, n_dist, n_datai, method);
	
  /* Get a matrix for the return argument. */
  mexCallMATLAB(1, plhs, 1, mx_tmp, "transpose");
  mxDestroyArray(mx_tmp[0]);

  return;

}
