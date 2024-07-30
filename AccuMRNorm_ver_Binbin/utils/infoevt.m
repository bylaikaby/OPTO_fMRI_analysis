function infoevt(SESSION,ExpNo)
%INFOEVT - Display Event/Stim Information (Requires dgz and acqp/reco files)
% INFOEVT (SESSION,ExpNo) reads invokes expgetevt to read the event
% file from the network server. It then displays stimulus related
% information. NOTE: This must be updated to reflect all recent
% changes in the stm structure. It also must search for the
% parameter file to avoid problems when the computer is not on the
% netowork.
% NKL, 10.10.00; 12.04.04

Ses = goto(SESSION);
grp = getgrp(Ses, ExpNo);

evt = expgetevt(Ses,ExpNo);
if isimaging(Ses,grp.name),
  pv = getpvpars(Ses,ExpNo);
else
  pv = [];
end;


fprintf('Experiment type: ');
for N=1:length(grp.expinfo),
  fprintf('%s; ', char(grp.expinfo{N}));
end;
fprintf('\n');

fprintf('STIM INFO: %s\n', grp.stminfo);
fprintf('InterVolumeTime:  %dms (by DGZ)\n',evt.interVolumeTime);
if ~isempty(pv),
  fprintf('InterVolumeTime:  %dms (by ParaVision)\n', round(pv.imgtr*1000));
end;
fprintf('NumTrigPerVolume: %d\n',evt.numTriggersPerVolume);
fprintf('NumObsp:          %d\n',evt.nobsp);
trials = [];
for N=1:length(evt.obs),
  trials = cat(1,trials,evt.obs{N}.trialID);
end
conds = unique(trials);

fprintf('NumTrials:        %d\n', length(trials));
fprintf('NumConditions:    %d\n', length(conds));

nreps = [];
prmv = {};

for N=1:length(conds),
  nreps(N) = length(find(trials == conds(N)));
  x = find(evt.obs{1}.trialID == conds(N));
  if length(x) > 0,
	prm = evt.obs{1}.params.prm{x(1)};
	prmv{N} = prm(1:length(evt.prmnames)); 
  else
	prmv{N} = zeros(1,length(evt.prmnames));
  end
end


% Conditions (what they are)
% Repetitions per condition
fprintf('Condition:\t');
for N=1:length(conds),
  fprintf('\t%3d',conds(N));
end
fprintf('\n');
fprintf(' NumRepeats:');
for N=1:length(conds),
  fprintf('\t%3d',nreps(N));
end
fprintf('\n');
for K=1:length(evt.prmnames),
  fprintf(' "%s":',evt.prmnames{K});
  for N=1:length(conds),
	fprintf('\t%.2f',prmv{N}(K));
  end
  fprintf('\n');
end



% Times
stimdt = evt.obs{1}.params.stmdur;
tlen = round(length(stimdt) / length(evt.obs{1}.params.trialid));
fprintf('StimDT:');
for N=1:tlen,
  fprintf(' %d',stimdt(N));
end
fprintf(' (typical in volumes)\n');

if ~isempty(pv),
  DX=pv.imgtr;
  % Trial duration
  fprintf('Trial duration in seconds: %4.2f\n',...
		sum(stimdt(1:tlen)*DX));
end;

fprintf('Trial duration in volumes: %d\n', sum(stimdt(1:tlen)));
