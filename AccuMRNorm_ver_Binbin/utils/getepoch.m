function Sig = getepoch(Sig)
%GETEPOCH - Reshapes and permutes the output of the sorttrials.m
% GETEPOCH is used to examine the time course or the PDS of
% individual epochs. With epoch we mean a single stimulation
% condition. For example in the contrast experiments one conditions
% is a sequence of presentation of stimuli with different
% contrasts, e.g. 1 0.3 0.5 0.1 etc. Because every condition will
% have different sequence of contrast to average we have to get the
% activity for a single epoch (e.g. 100%) only.
% Typical usage of getepoch is: Sig = getepoch(sorttrials(Mua));
% NKL 03.06.03

% Time X Chan X Obsp X Epoch X Condition
s = size(Sig.dat);
if length(s) > 4,
	% Time X Chan X Obsp X Condition X Epoch
	Sig.dat = permute(Sig.dat,[1 2 3 5 4]);
	
	% Time X Chan X (ObspXCondition) X Epoch
	s = size(Sig.dat);
	Sig.dat = squeeze(reshape(Sig.dat,[s(1) s(2) s(3)*s(4) s(5)]));
	
	Sig.dat = permute(Sig.dat,[1 2 4 3]);
end;
Sig.dsp.func = 'dspepoch';
