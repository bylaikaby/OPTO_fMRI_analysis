/* compile with: "mex <-DCOOKED> read_console.c user32.lib ws2_32.lib"
		  pref. use 'DCOOKED' as it handles backspaces correctly */
#include <stdio.h>
/*
#define _WIN32_WINNT 0x0500
#define WINVER 0x0500
*/
#define _WINNT
#include<windows.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <mex.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int *sock_array;
  double d;
  int *j;
  int i,iknk;
  int blocking=0;
  double knk;

  char *inbuf;
  char *outbuf;
  FILE *hf0,*hf1,*hf2;
  char ret_buf[256];

  int ctr,cooked;
  int inp;
  char inpc;
  //INPUT_RECORD inrec[255];
  INPUT_RECORD inrec[1];
  
  if (nrhs != 3) {
    mexErrMsgTxt("usage: output = read_console (handle[returned from open_console or open_conn],max byte number per call[1...255,0 for cooked],blocking_mode[0=non-blocking,1=blocking])"); return;
  }
  if (nlhs > 1) {
    mexErrMsgTxt("output is exactly one string (empty if no input)"); return;
  }
  d=mxGetScalar(prhs[0]);
  j=&d;
  //printf("%d\n",(int *)*j); return;
  sock_array=*j;
  if(!*j || !sock_array[0] || sock_array[12]) mexErrMsgTxt("Console not initialized!");
  hf0=(FILE *)sock_array[0];hf1=(FILE *)sock_array[1];
  inbuf=(char *)sock_array[2];outbuf=(char *)sock_array[3];
  // printf("%d::%d:%d:%d:%d\n",sock_array,hf0,hf1,inbuf,outbuf);return;

  knk = mxGetScalar(prhs[1]); iknk=knk;
  if (iknk>255)iknk=255;
  // if(iknk == 0) {ret_buf[0]=0; goto _end;} //instead:
  if (iknk == 0) {iknk=255; cooked=1;} else cooked=0;

  ctr=0;

  if (mxGetScalar(prhs[2]) == 1.) blocking=1; else blocking=0;

  // while (sock_array[11] /* main loop blocked by some other routine, can't normally happen */) SwitchToThread;
  if (sock_array[10] >= 0) {
    sock_array[10]=1; // block the thread main loop if necessary (debug=1)
    SetEvent(sock_array[8]); // break the wait function
    // wait for ACK
    while (!sock_array[11]) {_sleep(1);/* SwitchToThread();*/ } // this shouldn't take longer than 10 ms and, therefore, not cause heavy system load
  } else {
    if (sock_array[10] == -2) {
      sock_array[10] = -3;
      while (!sock_array[11]) _sleep(1);
    }
  }
  /*
  check the input buffer for old entries first
  this is not really necessary if you only want the 'current' key presses,
  so one could really skip this
  */
  start_over:
  if (inbuf[0]) { // take a maximum of iknk or available chars from inbuf and check
    ctr=strlen(inbuf);
    if (cooked) {
      iknk=0;
#ifdef COOKED
      for(;;) {if (inbuf[iknk]==10) {if(iknk==255) /* no space for \0 */ {inbuf[0]=0;goto start_over;} iknk++;break;} if (++iknk==256) break;}
#else
      for(;;) {if (inbuf[iknk]==13) {if(iknk==255) /* no space for \0 */ {inbuf[0]=0;goto start_over;} iknk++;break;} if (++iknk==256) break;}
#endif
      if(iknk==256) {
        iknk--;
        if (blocking) {
          memcpy(ret_buf,inbuf,ctr);ret_buf[ctr]=0;
          memset(inbuf,0,ctr);
          goto read_blocking;
        } else { /* no crlf yet */
          PeekConsoleInput(sock_array[9],inrec,1,&inp);
          if (inp) {
            memcpy(ret_buf,inbuf,ctr);ret_buf[ctr]=0;
            memset(inbuf,0,ctr);
            goto read_blocking;
          }
          ret_buf[0]=0; goto _end;
        }
      }
    } else {
    if (iknk>ctr)iknk=ctr;
    }
    ctr-=iknk;
    memcpy(ret_buf,inbuf,iknk);ret_buf[iknk]=0;
    memmove(inbuf,inbuf+iknk,ctr);memset(inbuf+ctr,0,256-ctr);
    goto _end;
  }

  ctr=0;
  if (blocking) {
  read_blocking:
    // if (sock_array[10] == -2 /* network socket: inbuf only, we never block here! */) {_sleep(10); goto start_over;}
    try_again:
    if (ReadConsoleInput(sock_array[9],inrec,1,&inp)) { // return on failure
      if (inrec[0].EventType == KEY_EVENT && inrec[0].Event.KeyEvent.bKeyDown) {
          inpc=inrec[0].Event.KeyEvent.uChar.AsciiChar;
	  if(inpc) { // otherwise Control Key
            if(inpc==4) {sock_array[12]=-1;ret_buf[ctr]=0;goto _end;}
	    fputc(inpc,hf1);
            if(inpc==13){inpc=10;fputc(inpc,hf1);if(cooked) {ret_buf[ctr++]=inpc;ret_buf[ctr]=0; goto _end;}}
            ret_buf[ctr++]=inpc;
#ifdef COOKED
            //if(inpc==13){fputc(10,hf1);if(ctr<iknk){ret_buf[ctr++]=10; if(cooked) ret_buf[ctr]=0; goto _end;}}
            //else
                if(inpc==8){fputc(32,hf1);fputc(inpc,hf1);ctr--;if(ctr)ctr--;ret_buf[ctr]=0;}
#else
            //if(inpc==13) {fputc(10,hf1); if(cooked) {ret_buf[ctr]=0; goto _end;}}
            //else
                if(inpc==8){fputc(32,hf1);fputc(inpc,hf1);}
#endif
	  }
      }
      if(ctr<iknk) {
	PeekConsoleInput(sock_array[9],inrec,1,&inp);
	if(inp) goto try_again;
        if (!blocking) {ret_buf[ctr]=0; if(cooked) {memcpy(inbuf+strlen(inbuf),ret_buf,ctr+1);ret_buf[0]=0;} goto _end;}
        if (!ctr || cooked) goto try_again;
      }
      if (cooked) /* no crlf yet and buffer full (cooked:iknk=255): */ {
        if (!blocking) {
          inbuf[0]=0; ret_buf[0]=0; goto _end;
        } else {
          ctr=0;ret_buf[0]=0; goto try_again;
        }
      }
      ret_buf[ctr]=0;
    }
  } else {
    if (sock_array[10] == -1) { // the only case where there is something to do
      // if (inbuf[0]) goto start_over; // can this ever happen?
      PeekConsoleInput(sock_array[9],inrec,1,&inp);
      if(inp) goto try_again;
    }
    ret_buf[0]=0;
  }
    
  _end:
  sock_array[11]=2; // readjust inbuf counter in open_conxxx
  if(sock_array[10] > 0) {sock_array[10]=0;}
  if(sock_array[10] == -3) {sock_array[10]=-2;}
  plhs[0] = mxCreateString(ret_buf);

}
