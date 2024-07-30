function mhelp2html(varargin)
%MHELP2HTML - Dumps help discription as html file with minimum tags.
%  MHELP2HTML(DIRNAME,MODE) dumps all help discripton
%    of matlab scripts in DIRNAME directory.
%  MHELP2HTML(SCRIPTNAME,MODE) dumps help discripton of SCRIPTNAME.
%
%  MODE can be '-update' or '-replace'.
%  If MODE=='-update', then the program checks modified date between
%  the script and corresponding html and will replace only when 
%  date of scripts is newer than that of html.
%  Default is '-update'.
%
%  Note that html will be saved in script's subdirecoty, "html_files".
%
%  EXAMPLE :
%    mhelp2html('io');      % dumps all help discription in 'io' directory.
%    mhelp2html('sigload','-replace')  % dumps 'sigload' help as html_files/sigload.html.
%
%  VERSION :
%    0.90 15.11.05 YM  pre-release
%    0.91 17.11.05 YM  supports '-update', 'replace' modes.
%    0.92 22.11.07 YM  bug fix when what() returns a structure array
%    0.93 10.12.07 YM  renamed to mhelp2html to avoid collesion in Matlab 7.5.
%
%  See also EXIST, WHAT, WHICH

if nargin == 0, help mhelp2html; return;  end

if ~ischar(varargin{1}) & ~ischar(varargin{2}),
  fprintf('%s ERROR: argument(s) must be a string\n',mfilename);
  return;
end

SUB_DIRECTORY = 'html_files';
MODE = '-update';


if exist(varargin{1},'dir'),
  scripts = what(varargin{1});
elseif exist(varargin{1},'file'),
  [fp,fr,fe] = fileparts(which(varargin{1}));
  scripts.path = fp;
  scripts.m    = {};
  scripts.mat  = {};
  scripts.mex  = {};
  scripts.mdl  = {};
  scripts.p    = {};
  scripts.classes = {};
  switch lower(fe)
   case {'.m'}
    scripts.m{1}   = sprintf('%s%s',fr,fe);
   case {'.dll'}
    scripts.mex{1} = sprintf('%s%s',fr,fe);
   otherwise
  end
else
  fprintf('%s WARNING: no program found for ''%s''\n',mfilename,varargin{1});
  return;
end

if nargin > 1,
  switch lower(varargin{2}),
   case {'-update','update'}
    MODE = '-update';
   case {'-replace','replace','overwrite'}
    MODE = '-replace';
   otherwise
    fprintf('%s ERROR: MODE must be either ''-update'' or ''-replace''.\n',mfilename);
    return;
  end
end


for N = 1:length(scripts),
  subHelp2Html(scripts(N),SUB_DIRECTORY,MODE);
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to do stuff
function subHelp2Html(scripts,SUB_DIRECTORY,MODE)
if ~exist(fullfile(scripts.path,SUB_DIRECTORY),'dir'),
  mkdir(scripts.path, SUB_DIRECTORY);
else
end


% dump help discription for .m/.mex files
scripts.m = cat(1,scripts.m(:), scripts.mex(:));  % merge .mex to .m
scripts.m = unique(scripts.m);
for N = 1:length(scripts.m),
  matfile = scripts.m{N};
  fprintf('[%3d/%d] %s:',N,length(scripts.m),matfile);
  [fp fr fe] = fileparts(matfile);
  htmfile = fullfile(scripts.path,SUB_DIRECTORY,sprintf('%s.html',fr));
  if strcmpi(MODE,'-update') & exist(htmfile,'file'),
    dmat = dir(fullfile(scripts.path,matfile));
    dhtm = dir(htmfile);
    % if html is newer than m-script, then skip.
    if datenum(dmat.date)-datenum(dhtm.date) < 0,
      fprintf(' skipped, newer ''%s''.\n',htmfile);
      continue;
    end
  end
  txt = help(fr);
  if isempty(txt),
    fprintf(' skipped, no help discription in ''%s''.\n',matfile);
  else
    subSaveAsHtml(htmfile,txt);
    fprintf(' ''%s'' saved.\n',htmfile);
  end
end

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCITON to save 'text' as HTML format.
function subSaveAsHtml(htmfile,txt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make a backup file, if already exists.
if exist(htmfile,'file'),
  copyfile(htmfile,sprintf('%s~',htmfile),'f');
end
  
[fp fr fe] = fileparts(htmfile);

% find out "new line, \n" characters to put a line with "<br>".
if txt(end) ~= 10,  txt(end+1) = 10;  end
lines = find(txt == 10);

fid = fopen(htmfile,'wt');
fprintf(fid,'<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">\n');
fprintf(fid,'<html>\n');
fprintf(fid,'<head>\n');
fprintf(fid,'  <meta content="text/html; charset=ISO-8859-1"\n');
fprintf(fid,' http-equiv="content-type">\n');
fprintf(fid,'  <title>%s</title>\n',fr);
fprintf(fid,'</head>\n');
fprintf(fid,'<body>\n');

i0 = 1;  iK = 0;
for K = 1:length(lines),
  if iK >= length(txt), break;  end
  iK = lines(K);
  tmptxt = txt(i0:iK-1);
  % replace multiple spaces as "&nbsp".
  tmptxt = strrep(tmptxt,'  ','&nbsp;&nbsp;');
  fprintf(fid,'%s<br>\n',tmptxt);
  i0 = iK+1;
end

fprintf(fid,'<br>\n');
fprintf(fid,'</body>\n');
fprintf(fid,'</html>\n');

fclose(fid);

return;
