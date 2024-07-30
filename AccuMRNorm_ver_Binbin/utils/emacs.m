function emacs(varargin)
%EMACS - invokes emcas editor
%  EMACS filename
%  EMACS filename LineNumber
%  EMACS filename Token
%
%  VERSION : 0.90 21.04.05 YM  pre-release
%
%  See also


if exist('C:\Usr\local\emacs\bin\runemacs.exe','file'),
  RUNEMACS = 'C:\Usr\local\emacs\bin\runemacs.exe';
elseif exist('D:\Usr\local\emacs\bin\runemacs.exe','file'),
  RUNEMACS = 'D:\Usr\local\emacs\bin\runemacs.exe';
elseif exist('E:\Usr\local\emacs\bin\runemacs.exe','file'),
  RUNEMACS = 'E:\Usr\local\emacs\bin\runemacs.exe';
else
  error('%s: not found "runemacs.exe", edit "emacs.m" for your environment.',mfilename);
end

if nargin == 0,
  eval(sprintf('!"%s"&',RUNEMACS));
  return;
elseif nargin == 1,
  FILE = subGetFullpath(varargin{1});
  LineNumber = [];
elseif nargin == 2,
  FILE = subGetFullpath(varargin{1});
  if ischar(varargin{2}),
    LineNumber = str2num(varargin{2});
    if isempty(LineNumber),
      LineNumber = subSearchToken(FILE,varargin{2});
    end
  else
    LineNumber = varargin{2};
  end
end

if isempty(LineNumber),
  eval(sprintf('!"%s" "%s"&',RUNEMACS,FILE));
else
  eval(sprintf('!"%s" +%d "%s"&',RUNEMACS,LineNumber,FILE));
end

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Fullpath = subGetFullpath(filename)

Fullpath = which(filename);
if isempty(Fullpath),
  Fullpath = filename;
end

return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LineNumber = subSearchToken(txtfile,token)

nocomment = 1;

LineNumber = [];
if ~exist(txtfile,'file'),  return;  end


% load text lines
try,
  fid = fopen(txtfile,'r');
catch
  error(' %s.subSearchToken() : faild to open ''%s''.\n',mfilename,txtfile);
end
lines = {};  n = 1;
while 1
  if feof(fid), break;  end
  lines{n} = fgetl(fid);
  n = n + 1;
end
fclose(fid);

%token

% get the corresponding line number.
found = 0;
for n = 1:length(lines),
  idx = strfind(lines{n},token);
  if ~isempty(idx),
    if ~nocomment | (lines{n}(1) ~= '%' & lines{n}(1) ~= '#'),
      %lines{n}
      found = 1;
      break;
    end
  end
end

if found, LineNumber = n;  end
