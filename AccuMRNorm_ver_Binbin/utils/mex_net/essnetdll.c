/*
 *  essnetdll.c : 
 *
 *  PURPOSE : To dispatch event message via TCP/IP network
 *  NOTES   : This is simply a DLL interface.
 *  SEEALSO : essnetapi.c, essnetapi.h
 *
 *  VERSION : 1.00  10-Aug-02  Yusuke MURAYAMA, MPI
 *
 */


#define NETAPI_EXPORT

#include "essnetapi.h"

#if defined (_WIN32)
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved )
{
  switch (ul_reason_for_call)  {
  case DLL_PROCESS_ATTACH:
    enet_startup();
    break;
  case DLL_THREAD_ATTACH:
    break;
  case DLL_THREAD_DETACH:
    break;
  case DLL_PROCESS_DETACH:
    enet_cleanup();
    break;
  }
  return TRUE;
}
#else
int main(int argc, char *argv[])
{
  return 0;
}
#endif

