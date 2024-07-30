function DIRS = getdirs_def(FIELD_NAME)
%GETDIRS_DEF - Returns the platform-dependent directory structure
%  DIRS = GETDIRS_DEF returns the platform-dependent directory structure.
%  DIR = GETDIRS_DEF(FIELD_NAME) returns the given directory.
%
%  NOTE
%    If need to change, update "preferences/getdirs.m".
%    DO NOT CALL THIS FUNCTION DIRECLTY, USE "getdirs" INSTEAD.
%
%  VERSION :
%    0.90 29.01.12 YM  pre-release
%    0.91 16.04.12 YM  adds rat16t_atlas, ratses_atlas, rhesus_atlas.
%    0.92 05.07.13 YM  use 'atlas_root', no *_atlas for each atlas, see mbrain_defs().
%    0.93 05.09.13 YM  .TMP as a local disk for cluster machines.
%    0.94 22.01.16 YM  workaround on cluster worker.
%    0.95 30.05.16 YM  supports getdirs_(HOSTNAME).
%
%  See also fullfile getHostName preferences/getdirs


DIRS.HOSTNAME = getHostName();

% default settings
DIRS.home        = fileparts(which('startup.m'));
if isempty(DIRS.home)
  % likely running on the cluster...
  DIRS.home = fileparts(fileparts(mfilename('fullpath')));
end
if strcmpi(DIRS.home(2),':'),
  % PC/AT
  search_drv = { 'Y:' 'E:' 'D:' };
  drv = DIRS.home(1:2);
  for N = 1:length(search_drv),
    if exist(fullfile(search_drv{N},'DataMatlab'),'dir'),
      drv = search_drv{N};  break;
    end
  end
else
  drv = fileparts(fileparts(DIRS.home));
end
DIRS.DataMri     = fullfile(drv,'DataMri');
%DIRS.DataMri     = '//wks8/guest';
DIRS.DataNeuro   = fullfile(drv,'DataNeuro');
DIRS.DataMatlab  = fullfile(drv,'DataMatlab');
%DIRS.DataMatlab  = '//wks20/Data/DataMatlab';

DIRS.TMP         = fullfile(DIRS.DataMatlab,'tmp');
DIRS.WORKSPACE   = fullfile(DIRS.DataMatlab,'workspace');
DIRS.STIMULATION = fullfile(DIRS.DataMatlab,'stimulation');
DIRS.unconv_dir  = DIRS.TMP;  % for ADF/ADFW conversion
DIRS.session     = fullfile(DIRS.home,'sessions');
% for MriStim
DIRS.bitmapdir   = fullfile(DIRS.home,'stim/bitmaps');
DIRS.stimhome    = fullfile(fileparts(DIRS.home),'MriStim');
DIRS.movdir      = fullfile(fileparts(DIRS.home),'Movies');
% for High-Resolution anatomy of mrVista
%DIRS.mrvista_anatomy = fullfile(DIRS.DataMatlab,'Anatomy');
DIRS.mrvista_anatomy = fullfile(drv,'DataAnatomy');


% ATLAS ROOT DIRECTORY
% 2016.04.21 changed as XX/DataAnatomy from XX/DataMatlab/Anatomy
%DIRS.atlas_root  = fullfile(DIRS.DataMatlab,'Anatomy');
DIRS.atlas_root  = fullfile(drv,'DataAnatomy');

% THIS IS WORK-AROUND FOR CLUSTER MACHINE
if strncmpi(DIRS.HOSTNAME,'clust',5)
  %DIRS.TMP = tempdir();
  DIRS.TMP = 'd:\temp';
end


% set host specific settings.
dirs_host = sprintf('getdirs_%s',lower(DIRS.HOSTNAME));
if exist(dirs_host,'file'),
  DIRS = sctmerge(DIRS,eval(dirs_host));
end



% return only required value
if exist('FIELD_NAME','var') && ~isempty(FIELD_NAME),
  try,
    DIRS = DIRS.(FIELD_NAME);
  catch
    fnames = fieldnames(DIRS);
    idx = find(strcmpi(fnames,FIELD_NAME));
    if length(idx) == 1,
      DIRS = DIRS.(fnames{idx});
    else
      error(' ERROR %s: ''%s'' not found as directory.\n',mfilename,FIELD_NAME);
    end
  end
end


return
