function fname = SONFindSON32DLL()
%SONFINDSON32DLL - returns fullpath of son32.dll found in the PC.
%  FNAME = SONFINDSON32DLL() returns fullpath of son32.dll found in the PC.
%
%  VERSION :
%    0.90 17.01.07 YM  pre-release
%
%  See also SONLOAD

  
DLLPATH{1} = 'c:\spike5';
DLLPATH{2} = fullfile(fileparts(fileparts(mfilename('fullpath'))),'CED SON Library');
  
fname = '';
for N = 1:length(DLLPATH),
  tmppath = fullfile(DLLPATH{N},'son32.dll');
  if exist(tmppath,'file'),
    fname = tmppath;
    fp = fileparts(tmppath);
    % remove the pass of son32.dll to avoid conflict with son32.m 
    if ~isempty(findstr(path,fp)),
      rmpath(fp);
    end
    break;
  end
end

return
