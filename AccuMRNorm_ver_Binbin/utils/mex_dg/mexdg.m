%
% mexdg.m : batch file to make all mex DLLs
%
% VERSION :
%   1.00  24-Nov-2001  YM
%   1.01  02-Mar-2010  YM
%   1.02  29-Jun-2012  YM  use zlib-1.2.7
%   1.03  17-Jul-2013  YM  use zlib-1.2.8, -compatibleArrayDims,-largeArrayDims
%   1.04  07-Oct-2015  YM  supports Linux-x64 (Ubuntu)
%

% c = input('Link with static zlib? Y/N[N]: ','s');
% if isempty(c), c = 'N';  end

% fprintf('making dg_read... ');
% switch lower(c)
%  case 'y'
%   % link with static zlib, no need of zlib.dll
%   mex -L. -I. dg_read.c dynio.c df.c dfutils.c flip.c zlibstatmt.lib
%   %mex dg_read.c zlibstat.lib
%   fprintf(' done.\n');
%  case 'n'
%   % link with zlibdll.lib, requires zlib.dll somwhere
%   mex -L. -I. dg_read.c dynio.c df.c dfutils.c flip.c zlib.lib
%   fprintf(' done.\n');
%   fprintf('Make sure you have zlib.dll somewhere in your PATH.\n');
%  otherwise
%   fprintf('not supported yet\n');
% end




switch lower(mexext)
 case {'mexw64'}
  mex -compatibleArrayDims -L. -I. dg_read.c dynio.c df.c dfutils.c flip.c zlibstat-1.2.8_win64.lib
  %mex -largeArrayDims -L. -I. dg_read.c dynio.c df.c dfutils.c flip.c zlibstat-1.2.8_win64.lib
 case {'mexw32','dll'}
  mex -compatibleArrayDims -L. -I. dg_read.c dynio.c df.c dfutils.c flip.c zlibstat-1.2.8.lib
  %mex -largeArrayDims -L. -I. dg_read.c dynio.c df.c dfutils.c flip.c zlibstat-1.2.8.lib
 case {'mexa64'}
  % use local libz.a
  % %mex -compatibleArrayDims -L. -I. CFLAGS="\$CFLAGS -std=c99 -fPIC" dg_read.c dynio.c df.c dfutils.c flip.c libz.a
  % mex -compatibleArrayDims -L. -I. CFLAGS='-std=c99 -fPIC' dg_read.c dynio.c df.c dfutils.c flip.c libz.a
  % %mex -largeArrayDims -L. -I. CFLAGS='-std=c99 -fPIC' dg_read.c dynio.c df.c dfutils.c flip.c libz.a

  % use installed libz.a (or libz.so)
  %mex -compatibleArrayDims -I. CFLAGS="\$CFLAGS -std=c99 -fPIC" dg_read.c dynio.c df.c dfutils.c flip.c libz.a
  %mex -compatibleArrayDims -I. -L/usr/lib/x86_64-linux-gnu CFLAGS='-std=c99 -fPIC' dg_read.c dynio.c df.c dfutils.c flip.c libz.a
  mex -compatibleArrayDims -I. -L. CFLAGS='-std=c99 -fPIC' dg_read.c dynio.c df.c dfutils.c flip.c libz-ubuntu-x64.a
  %mex -largeArrayDims -I. CFLAGS='-std=c99 -fPIC' dg_read.c dynio.c df.c dfutils.c flip.c libz.a
 
 otherwise
  fprintf(' %s: mexext=''%s'' not supported yet.\n',mfilename,mexext);
end

