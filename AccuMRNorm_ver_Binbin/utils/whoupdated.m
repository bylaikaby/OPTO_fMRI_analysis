function varargout = whoupdated(iDate)
%WHOUPDATED - Lists all recently updated Matlab scripts.
%
% WHOUPDATED(X) prints all m-files that were updated in the last X
%   days.
%
% WHOUPDATED(DATE_STRING) prints all mfiles that were updated since
%   the date defined in DATE_STRING. The format of the string
%   DATE_STRING is "01-Jun-2004".
%
% list = WHOUPDATE(...) returns a list of updated m-files.
%
% Examples :
%   WHOUPDATED(5)              : lists files updated in last 5 days.
%   WHOUPDATED('28-May-2004')  : lists files updated since 28-May-2004.
%
% VERSION : 0.90 01.06.04 YM  first release
%
% See also DATENUM, DATESTR, CLOCK, DIR

if nargin == 0,  help whoupdated;  return;  end

if isnumeric(iDate),
  % iDate as 'DaysBefore'
  ttick = datenum(datestr(clock,0));
  DaysBefore = iDate;
else
  % iDate as a date string
  ttick = datenum(iDate);
  DaysBefore = 0;
end

% get matlab home directory
[fdir,froot] = fileparts(mfilename('fullpath'));
matdir = fileparts(fdir);

% get directories in matlab-home dir.
dirList = dir(matdir);

% search updated files in 'dirList'.
UPDATED_FILE = {};
for N = 1:length(dirList),
  if dirList(N).isdir ~= 1, continue;  end
  tmpdir = sprintf('%s%s%s',matdir,filesep,dirList(N).name);
  mfileList = dir(strcat(tmpdir,filesep,'*.m'));

  for K = 1:length(mfileList),
    mfile = mfileList(K);
    tfile = datenum(mfile.date);
    if ttick - tfile <= DaysBefore,
      if nargout == 0,
        fprintf('%s\t\t\t%s\n',mfile.name,mfile.date);
      else

        fname = strcat(tmpdir,filesep,mfile.name);
        if isempty(UPDATED_FILE),
          UPDATED_FILE{1} = struct(...
              'name', mfile.name,...
              'fullpath',fname,...
              'date', mfile.date,...
              'firstline', subGetFirstLine(fname) );
        else
          UPDATED_FILE{end+1} = struct(...
              'name', mfile.name,...
              'fullpath',fname,...
              'date', mfile.date,...
              'firstline', subGetFirstLine(fname) );
        end;
      
      end
    end
  end
end

if nargout,
  varargout{1} = UPDATED_FILE;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function line = subGetFirstLine(fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
line = '';
fid = fopen(fname,'r');
if ~feof(fid),
  line = fgetl(fid);
  if isempty(line),
    fprintf('whoupdated: m-file %s does not have a "first line"\n',...
            fname);
    fclose(fid);
    line = [];
    return;
  end;
  
  if ~strcmp(line(1),'%'),  % It's a function, get the next line...
    line = fgetl(fid);
  end;
end;
fclose(fid);
return;

