#include <stdio.h>
#include <windows.h>

main() {
  HANDLE waitHandle=NULL;
  
  if ((waitHandle=OpenEvent(EVENT_MODIFY_STATE,FALSE,"Sock_Close"))) SetEvent(waitHandle);

}

