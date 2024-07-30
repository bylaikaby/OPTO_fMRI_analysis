function infostat(SesName)
%INFOSTAT - Information from ROISTATS.MAT file
% INFOSTAT (SesName) shows all structures in the roistats.mat file
%
% NKL 06.10.06

if nargin < 1,
  help infostat;
  return;
end;

Ses = goto(SesName);
anap = getanap(Ses);
if ~isfield(anap,'anagroups'),
  fprintf('INFOSTAT: Description file %s does not have an ANAP.anagroups entry!\n', ...
          SesName);
  return
end;

if ~exist('roistats.mat','file'),
  fprintf('INFOSTAT: RoiStats.mat file was not found\n');
  return;
end;

s = load('roistats.mat');
names=fieldnames(s);

for N=1:length(names);
  eval(sprintf('s.%s', names{N}));
end;



