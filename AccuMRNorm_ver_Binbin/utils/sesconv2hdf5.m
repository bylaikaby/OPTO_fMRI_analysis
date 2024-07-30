function sesconv2hdf5(Ses,varargin)
%SESCONV2HDF5 - Convert old matfiles to HDF5 matfiles.
%  SESCONV2HDF5(SESSION) converts old matfiles to HDF5 matfiles.
%
%  EXAMPLE :
%    sesconv2hdf5(Session)
%
%  VERSION :
%    0.90 05.06.13 YM  pre-release
%
%  See also mat2h5mat is_hdf5file sesconvert

if nargin < 1,  eval(['help ' mfilename]); return; end

Ses = goto(Ses);

fprintf('%s %s begin -------------------------------------------\n',...
        datestr(now,'HH:MM:SS'),mfilename);
sub_convert(pwd);
fprintf('%s %s done --------------------------------------------\n',...
        datestr(now,'HH:MM:SS'),mfilename);

return


% -----------------------------------------------
function sub_convert(fpath)
% -----------------------------------------------

files = dir(fpath);
for N = 1:length(files)
  if strcmp(files(N).name,'.') || strcmp(files(N).name,'..'),  continue;  end
  tmpname = fullfile(fpath,files(N).name);
  if files(N).isdir
    fprintf('%s %s dir=''%s''  -------------------\n',...
            datestr(now,'HH:MM:SS'),mfilename,tmpname);
    sub_convert(tmpname);
  else
    [fp fr fe] = fileparts(tmpname);
    if strcmpi(fe,'.mat')
      mat2h5mat(tmpname);
    end
  end
end

return
