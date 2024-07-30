function supgroupload(FileName)
%SUPGROUPLOAD - Load super group from default directorie (e.g. physmri)
%
% NKL 24.01.2008
  
DIRS = getdirs;
cd(DIRS.matdir);
cd('PhysMri');
FileName = strcat(FileName,'.mat');
if exist(FileName,'file'),
  s = load(FileName);
else
  fprintf('./PhysMri/%s does not exist\n', FileName);
end;

SigName = fieldnames(s);
for N = 1:length(SigName),
  Sig{N} = getfield(s,SigName{N});
  assignin('caller', SigName{N}, Sig{N});
end

  
  