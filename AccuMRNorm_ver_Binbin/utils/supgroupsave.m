function supgroupsave(FileName,SigNames,varargin)
%SUPGROUPSAVE - Save super group from default directorie (e.g. physmri)
%
% NKL 24.01.2008

if nargin < 3,
  help supgroupsave;
  return;
end;

DIRS = getdirs;

savedir = fullfile(DIRS.matdir,'PhysMri');
if ~exist(savedir,'dir'),
  mkdir(savedir);
end
cd(savedir);
%cd(DIRS.matdir);
%cd('PhysMri');
FileName = strcat(FileName,'.mat');
FileName = fullfile(savedir,FileName);

if ischar(SigNames),
  SigNames = {SigNames};
end;

for N=1:length(SigNames),
  eval(sprintf('%s = varargin{N};', SigNames{N}));
end;

if exist(FileName,'file'),
  save(FileName,'-append',SigNames{:});
else
  save(FileName,SigNames{:});
end;

