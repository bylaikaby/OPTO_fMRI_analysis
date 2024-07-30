function [status msgstr] = mmkdir(fpath)
%MMKDIR -  Make new directory.
%    [STATUS MSGSTR] = MMKDIR(FPATH) makes new directory somehow.
%
%  NOTE :
%    try to make the directory somehow...
%
%  EXAMPLE :
%    mmkdir('d:/aaaa')
%
%  VERSION :
%    0.90 30.01.12 YM  pre-release
%
%  See also mkdir

if nargin < 1, help mmkdir; return;  end

status = 1;
msgstr = '';

if ~exist(fpath,'dir')
  % try with fullpath...
  [status, msgstr] = mkdir(fpath);
  if ~status,
    % try again with separated path....
    [fp fr fe] = fileparts(fpath);
    [status, msgstr] = mkdir(fp,sprintf('%s%s',fr,fe));
  end
  if ~status && ~nargout,
    error('''%s'': mkdir error, %s',fpath,msgstr);
  end
end


return

