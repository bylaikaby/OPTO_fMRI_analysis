function p = distcomp_path(varargin)
%DISTCOMP_PATH - Get paths for parallel computing.
%  P = DISTCOMP_PATH() gets paths for parallel computing.
%
%  NOTE :
%    Set 'PathDependencies' by using this function for 'REMOTE' clusters.
%    Otherwise, use 'FileDependencies' like
%    J = batch(...,'FileDependencies','\\winXX\D\%YOUR_PATH%\startup.m')
%
%  REQUIREMENT :
%    Parallel computing toolbox
%
%  EXAMPLE :
%    J = batch(...,'PathDependencies',distcomp_path());
%    J = batch(...,'FileDependencies','\\winXX\D\%YOUR_PATH%\startup.m')
%
%  VERSION :
%    0.90 21.02.12 YM  pre-release
%
%  See also batch java.net


HOSTNAME = '';
for N = 1:2:length(varargin)
  switch lower(varargin{N})
   case {'host' 'hostname'}
    HOSTNAME = varargin{N+1};
  end
end

if strncmpi(computer,'PC',2)
  ps = ';';
else
  ps = ':';
end

mpath = path;
mroot = matlabroot;
n = length(mroot);

p = {};
while 1
  [str mpath] = strtok(mpath,ps);
  if isempty(str),  break;  end
  % skip the standard path...
  if any(strncmpi(str,mroot,n)),  continue;  end
  p{end+1} = str;
end


if strncmpi(computer,'PC',2),
  if isempty(HOSTNAME),
    lhost = java.net.InetAddress.getLocalHost;
    HOSTNAME = char(lhost.getHostName);
  end
  lpath = ['\\' HOSTNAME '\'];
  for N = 1:length(p),
    if strcmp(p{N}(2),':'),
      p{N} = [lpath p{N}(1) p{N}(3:end)];
    end
  end
end


return
