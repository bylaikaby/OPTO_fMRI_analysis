function rename_dll(SEARCH_DIR)
%RENAME_DLL - renames .dll as .dll.bak if .mexw32/64 is found.
%  RENAME_DLL(SEARCH_DIR) renames .dll as .dll.bak if .mexw32/64 is found
%  to avoid Matlab's warning.
%
%  EXAMPLE :
%    >> rename_dll('y:/mri/matlab/spm5');
%    >> rename_dll(genpath('y:/mri/matlab/spm5'));
%
%  VERSION :
%    0.90 18.04.08 YM   pre-release
%
%  See also movefile

if nargin == 0,  eval(sprintf('help %s',mfilename)); return;  end


% need to run only for WINDOWS
if ~ispc,  return;  end
% if mex as DLL then, no need to run
if strcmpi(mexext,'dll'),  return;  end


if isempty(SEARCH_DIR),  SEARCH_DIR = '.';  end


if iscell(SEARCH_DIR),
  for N = 1:length(SEARCH_DIR),  rename_dll(SEARCH_DIR{N});  end
  return
end


remain = SEARCH_DIR;
while true,
  [tmpdir, remain] = strtok(remain,';');
  if isempty(tmpdir),  break;  end
  tmpfiles = dir(fullfile(tmpdir,'*.dll'));
  for N = 1:length(tmpfiles),
    dllfile = fullfile(tmpdir,tmpfiles(N).name);
    mexfile = sprintf('%s.%s',dllfile(1:end-4),mexext);
    if exist(mexfile,'file'),
      srcfile = dllfile;
      dstfile = sprintf('%s.bak',srcfile);
      fprintf(' %s --> %s',srcfile,dstfile);
      movefile(srcfile,dstfile,'f');
      fprintf('\n');
    end
  end
end

return



