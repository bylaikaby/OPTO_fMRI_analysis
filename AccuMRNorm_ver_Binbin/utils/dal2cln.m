function dal2cln(dl)
%DAL2CLN - converts DAL' rivalry data to our format
% NKL 29.05.03

if nargin < 1,
  cdws;
  load spikes;
end;

global VOLDT;
VOLDT = 0.100;

Ses = goto('dalsp1');
grp = getgrp(Ses,1);

for ExpNo=1:20,
  [Cln,LfpFlt,MuaFlt] = getCLN(Ses,grp,ExpNo,dl);
  ClnSpc = getCLNSPC(Cln);
  save(Cln.dir.matfile,'Cln','LfpFlt','MuaFlt','ClnSpc');
  fprintf('Saved file %s\n', Cln.dir.matfile);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ClnSpc = getCLNSPC(Cln)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global VOLDT;
T = VOLDT;						% 75msec hanning window
len = T / Cln.dx;
NFFT = 2048;
ClnSpc = sigspc(Cln, T, T, NFFT, 'hanning');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Cln,Lfp,Mua] = getCLN(Ses,grp,ExpNo,dl)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  global VOLDT;

  dl.adfdata{ExpNo} = dl.adfdata{ExpNo}(:);
  dl.lfpdata{ExpNo} = dl.lfpdata{ExpNo}(:);
  dx	= dl.raw_sampt/1000.0;
  lfpdx	= dl.lfp_sampt/1000.0;
  LROW = length(dl.adfdata{ExpNo})*dx;
  LLFP = length(dl.adfdata{ExpNo})*lfpdx;

  Cln.session = 'dalsp1';
  Cln.grpname = 'riv';
  Cln.ExpNo   = ExpNo;

  Cln.dir.dname = 'Cln';
  Cln.dir.physfile	= catfilename(Ses,ExpNo,'phys');
  Cln.dir.evtfile	= catfilename(Ses,ExpNo,'evt');
  Cln.dir.stmfile	= catfilename(Ses,ExpNo,'stm');
  Cln.dir.pdmfile	= catfilename(Ses,ExpNo,'pdm');
  Cln.dir.hstfile	= catfilename(Ses,ExpNo,'hst');
  Cln.dir.matfile	= catfilename(Ses,ExpNo,'mat');
  Cln.dir.adxfile	= catfilename(Ses,ExpNo,'adx');

  Cln.grp = Ses.grp.riv;
  Cln.grp.NoObsp	 = 1;
  Cln.grp.NoChan	 = 1;
  Cln.grp.adfoffset  = 0;
  Cln.grp.adflen	 = LROW;


  Cln.dsp.func	= 'dspsig';
  Cln.dsp.args	= {'color';'k';'linestyle';'-';'linewidth';0.5};
  Cln.dsp.label	= {'Time in sec'; 'ADC Units'};

  Cln.evt.NoObsp	 = 1;
  Cln.evt.NoChan	 = 1;
  Cln.evt.dx		 = dx;
  Cln.evt.lfpdx		 = lfpdx;
  Cln.evt.prmnames	 = {};
  Cln.evt.obslen	 = LROW;
  Cln.evt.lfpobslen	 = LLFP;
  Cln.evt.validobsp  = -1;
  Cln.evt.numTriggersPerVolume = {};
  Cln.evt.adfoffset  = 0;
  Cln.evt.adflen	 = LROW;
  Cln.evt.rawBW = dl.rawBW;
  Cln.evt.lfpBW = dl.lfpBW;
  
  Cln.stm.labels		= {};
  Cln.stm.condids		= {};
  Cln.stm.conditions	= {};
  Cln.stm.voldt			= VOLDT;
  if isempty(dl.stimont{ExpNo}),
	dl.stimonv{ExpNo} = [0; 0];
	dl.stimont{ExpNo} = [0; LROW];
  end;
  Cln.stm.v				= {[0; dl.stimonv{ExpNo}; 0]};
  Cln.stm.t				= {[0; dl.stimont{ExpNo}/1000; LROW]};
  Cln.stm.dt			= {diff(Cln.stm.t{1})};
  Cln.stm.stmpars		= {};
  Cln.stm.pdmpars		= {};
  Cln.stm.sortedByStimulus = 0;	    % Whether or not sorted by stimulus

  Cln.dat	= [];
  Cln.dx	= dl.raw_sampt/1000.0;
  Cln.lfpdx	= dl.lfp_sampt/1000.0;

  if isfield(grp,'hardch'),
	Cln.chan = grp.hardch;
	Cln.chan(grp.softch) = [];
  end;


  L=length(dl.adfdata{ExpNo});
  R = floor(L / length(dl.lfpdata{ExpNo}));
  dl.lfpdata{ExpNo} = interp(dl.lfpdata{ExpNo},R);
  MIN = min(length(dl.adfdata{ExpNo}),length(dl.lfpdata{ExpNo}));
  dl.lfpdata{ExpNo} = dl.lfpdata{ExpNo}(1:MIN);
  dl.adfdata{ExpNo} = dl.adfdata{ExpNo}(1:MIN);

  Cln.dat = dl.adfdata{ExpNo} + dl.lfpdata{ExpNo};

  Lfp = Cln;
  Lfp.dir.dname = 'Lfp';
  Lfp.dat = dl.lfpdata{ExpNo};

  Mua = Cln;
  Lfp.dir.dname = 'Mua';
  Mua.dat = dl.adfdata{ExpNo};
