%
% mextetrode.m : batch file to make all mex DLLs.
%
%
% EXAMPLE :
%  >>cd utils/mex_tetrode    % for example
%  >>mextetrode
%
% VERSION : 1.00  26-Jan-2005  YM


if ispc,
  % clear read_xx to avoid error.
  clear read_cr read_tt;
  mex  -D_WIN32 read_cr.c iolib.c mxlib.c
  mex  -D_WIN32 read_tt.c iolib.c mxlib.c
else
  fpritnf(' %s: don''t know how to compile...\n');
end
