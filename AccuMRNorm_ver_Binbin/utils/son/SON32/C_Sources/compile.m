% COMPILE Script file to compile c-code sources and generate the DLLs
% To compile the files, you will need copies of CED's machine.h and son.h.
% These are proprietory and not included in the distribution. Contact CED.
%

mex -v -I"../../SON Library" SONGetADCData.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONGetRealData.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONGetMarkData.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONGetExtMarkData.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONGetEventData.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONGetVersion.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONFEqual.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONFActive.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONFControl.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONFMode.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONFilter.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONLastTime.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONLastPointsTime.c GetFilterMask.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONSetMarker.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONTimeDate.c SONLoadLibrary.c
mex -v -I"../../SON Library" SONAppID.c SONLoadLibrary.c
mex -v -I"../../SON Library" gatewaySONWriteExtMarkBlock.c SONLoadLibrary.c

mex -v -I"../../SON Library" SONWriteMarkBlock.c SONLoadLibrary.c

