function acqp = getacqp(varargin)
%GETACQP - get default parameters for data acquisition.
% parameters may not be the same if setting was changed somehow.
%
%
% VERSION : 1.00 13.03.04 YM  moved from getses.m
%
% See also GETSES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ACQP - ACQUISITION PARAMETERS:	(common to (all) sessions)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPIKE-STREAMER'S ADC PARAMETERS
acqp.win30.p	 = 7.0;
acqp.win30.c	 = 4.0;
acqp.win30.n	 = 16.0;					% Channels
acqp.adfrate	 = 10000000.0/...
	(acqp.win30.p*acqp.win30.c*acqp.win30.n);
acqp.adfinterval = 1.0 / acqp.adfrate;	% seconds

% PCL818 (EYE MOVEMENT) ADC PARAMETERS
acqp.monchan(1) = cellstr('ecg');
acqp.monchan(2) = cellstr('respflow');
acqp.monchan(3) = cellstr('resppres');
acqp.monchan(4) = cellstr('none');
acqp.monchan	= acqp.monchan';

% EVENTS USED IN THE MRI & PHYSIOLOGY EXPERIMENTS
acqp.evt = getevtcodes;

% IMAGING PARAMETERS
acqp.tc.nsegments	= 8;				% 8-Shot images
acqp.tc.imgacqt		= 20.48;			% mri acquisition window in ms
acqp.tc.deadt		= 40;				% rephasing,sl-sel,and imgacqt

acqp.epi13.nsegments= 8;				% 8-Shot images
acqp.epi13.imgacqt	= 20.48;			% mri acquisition window in ms
acqp.epi13.deadt	= 40;				% rephasing,sl-sel,and imgacqt

acqp.mdeft.nsegments= 8;				% 8-Shot images
acqp.mdeft.imgacqt	= 20.48;			% mri acquisition window in ms
acqp.mdeft.deadt	= 40;				% rephasing,sl-sel,and imgacqt

acqp.ir.nsegments= 8;					% 8-Shot images
acqp.ir.imgacqt	= 20.48;				% mri acquisition window in ms
acqp.ir.deadt	= 40;					% rephasing,sl-sel,and imgacqt
