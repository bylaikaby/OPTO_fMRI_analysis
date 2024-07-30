/* compile with: "mex fg_console.c user32.lib" */
#include <stdio.h>
#include<windows.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#ifndef STANDALONE
#include <mex.h>
#endif

char buffer[256];
HWND hWnd;
RECT rect;

/*
BOOL CALLBACK
MyEnumWindowsProc(
  HWND hwnd,      // handle to parent window
  LPARAM lParam   // application-defined value
)
{
 LPTSTR title[65];

   GetWindowText(hwnd,title,64);
   if (!strcmp(title,buffer)) {
     // nope SetFocus(hwnd);
     // works SwitchToThisWindow(hwnd,TRUE);
     ShowWindow(hwnd,SW_SHOW);
     return 0;
   }
   return 1; // always continue (up to the last window), a '0' would stop enumeration
}
*/

#ifdef STANDALONE
main()
#else
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
#endif
{
  double d;
  int *i;
  char *c;
  int buflen;
  
  /*
  if (nrhs != 1) {
    mexErrMsgTxt("usage: output = fg_console('window title') [as shown in the console title bar]");
  }
  memset(buffer,0,256);
  buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
  mxGetString(prhs[0], buffer, buflen);
  */
  /*
  sprintf(buffer,"MATLAB Console");
  EnumWindows(
    (WNDENUMPROC) MyEnumWindowsProc,  // pointer to callback function
    NULL            // application-defined value
  );
  */

  hWnd=FindWindow("ConsoleWindowClass","MATLAB Console");
  GetWindowRect(hWnd,(LPRECT)&rect);
  MoveWindow(hWnd,10,10,rect.right-rect.left,rect.bottom-rect.top,TRUE);
  ShowWindow(hWnd,SW_RESTORE);
  SetForegroundWindow(hWnd);

}
