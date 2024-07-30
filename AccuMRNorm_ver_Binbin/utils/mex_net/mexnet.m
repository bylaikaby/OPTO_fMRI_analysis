%
% mexnet.m : batch file to make mex DLLs.
%
% VERSION : 1.00  05-Aug-2002  YM
%         : 1.01  15-Oct-2002  YM, fix problem under Matlab R13
%         : 1.02  11-May-2003  YM, add netstimctrl

% network
mex neterror.c       essnetapi.c
mex neteventlog.cpp  essnetapi.c
mex netstreamer.cpp  essnetapi.c
mex netstimctrl.cpp  essnetapi.c
mex nethostname.cpp  essnetapi.c

% for matlab R12
%mex neterror.c       essnetapi.c
%mex neteventlog.cpp  essnetapi.c libcmt.lib -D_MT
%mex netstreamer.cpp  essnetapi.c libcmt.lib -D_MT

% tests
%mex neteventlog.cpp  essnetdll.lib libcmt.lib -D_MT
%mex netstreamer.cpp  essnetdll.lib libcmt.lib -D_MT
%mex testthread.cpp   winmm.lib libcmt.lib -D_MT
