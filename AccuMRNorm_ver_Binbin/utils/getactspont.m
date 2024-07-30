function [act, spo] = getactspont(SESSION)
%GETACTSPONT - Returns the experiments of action and spontaneous activity supergroups
% EXPS = GETACTSPONT(SESSION), gets valid experiments from 
%
% Example (Session = n03qv1):
%           SUPERGROUP-NAME    GROUPS BELONGING TO SUPERGROUP
%
% CTG.imgActGrps = {'actgrp';{'rivalryleft';'rivalrysimu';'norivalry';'polarflash'}};
% CTG.imgSpoGrps = {'spogrp';{'spont'}};
%
% NKL, 08.08.04

Ses = goto(SESSION);
SpecialGroups = {'autoplot';'test';'misc'};
if isfield(Ses,'SpecialGroups'),
  SpecialGroups = Ses.SpecialGroups;
end;

if ~isfield(Ses.ctg,'imgActGrps') | ~isfield(Ses.ctg,'imgSpoGrps'),
  fprintf('GETACTSPONT: imgActGrps/imgSpoGrps Supergroups were not found\n');
  fprintf('GETACTSPONT: Edit description file; then re-run\n');
  keyboard;
end;

actnames = Ses.ctg.imgActGrps{2};
sponames = Ses.ctg.imgSpoGrps{2};

EXPS = [];
for N=1:length(actnames),
  SpecialStatus = 0;
  for S=1:length(SpecialGroups),
	if strcmp(SpecialGroups{S},actnames{N}),
	  SpecialStatus = 1;
	end;
  end;
  if ~SpecialStatus,
	eval(sprintf('exps = Ses.grp.%s.exps;', actnames{N}));
	EXPS = cat(2,EXPS,exps);
  end;
end;
act = EXPS;

EXPS = [];
for N=1:length(sponames),
  SpecialStatus = 0;
  for S=1:length(SpecialGroups),
	if strcmp(SpecialGroups{S},sponames{N}),
	  SpecialStatus = 1;
	end;
  end;
  if ~SpecialStatus,
	eval(sprintf('exps = Ses.grp.%s.exps;', sponames{N}));
	EXPS = cat(2,EXPS,exps);
  end;
end;
spo = EXPS;





