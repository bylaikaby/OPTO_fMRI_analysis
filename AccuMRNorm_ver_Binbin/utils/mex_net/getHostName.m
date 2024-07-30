function hname = getHostName(host)
% PURPOSE :  To get host name
% USAGE :    hname = getHostName([host])
% NOTES :    If no argin, then returns name of local host
% VERSION :  1.00  24-Jul-02  YM, MPI
%            1.01  29-Feb-04  YM, MPI  supports no java environment.
% See also NETHOSTNAME

try,
  if nargin ~= 0,
    tmphost = java.net.InetAddress.getByName(host);
  else
    tmphost = java.net.InetAddress.getLocalHost;
  end
  hname = char(tmphost.getHostName);
catch
  if nargin ~= 0,
    hname = nethostname(host);
  else
    hname = nethostname;
  end
  hname = strtok(hname,'.');  % take out network postfix.
end
