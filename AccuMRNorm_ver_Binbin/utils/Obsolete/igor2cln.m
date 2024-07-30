function igor2cln
%IGOR2CLN - converts Igor's chronic recording data to our format
% NKL 29.05.03

cdws;
load spikes;

global VOLDT;
VOLDT = 0.100;

Ses = goto('igor01');
grp = getgrp(Ses,1);

for ExpNo=1:20,
  Cln = getCLN(Ses,grp,ExpNo,ibit1,ibit2,'it',0);
  ClnSpc = getCLNSPC(Cln);
  LfpFlt = getlfp(Cln,[20 120]);
  MuaFlt = getmua(Cln,[120 3000]);
  save(Cln.dir.matfile,'Cln','ClnSpc');
  fprintf('Saved file %s\n', Cln.dir.matfile);
end;

for ExpNo=1:20,
  Cln = getCLN(Ses,grp,ExpNo,ibmt1,ibmt2,'mt',20);
  ClnSpc = getCLNSPC(Cln);
  LfpFlt = getlfp(Cln,[20 120]);
  MuaFlt = getmua(Cln,[120 3000]);
  save(Cln.dir.matfile,'Cln','ClnSpc','LfpFlt','MuaFlt');
  fprintf('Saved file %s\n', Cln.dir.matfile);
end;

sesgetlfpmua(Ses,[1:40]);
sesgetspk(Ses,[1:40]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Cln = getCLN(Ses,grp,ExpNo,ch1,ch2,area,ofs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  global VOLDT;
  ch1.stimonv{ExpNo}=[1 0 2 0]';
  ch1.stimont{ExpNo}=[ch1.stimonA{ExpNo} ch1.stimoffA{ExpNo} ...
					  ch1.stimonB{ExpNo}  ch1.stimoffB{ExpNo} ]';
  
  
  ch1.adfdata{ExpNo} = ch1.adfdata{ExpNo}(:);
  dx	= ch1.raw_sampt/1000.0;
  LROW = length(ch1.adfdata{ExpNo})*dx;

  EXPNO = ExpNo + ofs;
  Cln.session = 'igor01';
  Cln.grpname = 'it';
  Cln.ExpNo   = EXPNO;

  Cln.dir.dname		= 'Cln';
  Cln.dir.physfile	= catfilename(Ses,EXPNO,'phys');
  Cln.dir.evtfile	= catfilename(Ses,EXPNO,'evt');
  Cln.dir.stmfile	= catfilename(Ses,EXPNO,'stm');
  Cln.dir.pdmfile	= catfilename(Ses,EXPNO,'pdm');
  Cln.dir.hstfile	= catfilename(Ses,EXPNO,'hst');
  Cln.dir.matfile	= catfilename(Ses,EXPNO,'mat');
  Cln.dir.adxfile	= catfilename(Ses,EXPNO,'adx');

  eval(sprintf('group = Ses.grp.%s;',area));
  Cln.grp			= group;
  Cln.grp.NoObsp	= 1;
  Cln.grp.NoCh	= 1;
  Cln.grp.adfoffset = 0;
  Cln.grp.adflen	= LROW;


  Cln.dsp.func	= 'dspsig';
  Cln.dsp.args	= {'color';'k';'linestyle';'-';'linewidth';0.5};
  Cln.dsp.label	= {'Time in sec'; 'ADC Units'};

  Cln.evt.NoObsp	 = 1;
  Cln.evt.NoCh	 = 1;
  Cln.evt.dx		 = dx;
  Cln.evt.prmnames	 = {};
  Cln.evt.obslen	 = LROW;
  Cln.evt.validobsp  = -1;
  Cln.evt.numTriggersPerVolume = {};
  Cln.evt.adfoffset  = 0;
  Cln.evt.adflen	 = LROW;
  Cln.evt.rawBW = ch1.rawBW;
  
  Cln.stm.labels		= {};
  Cln.stm.condids		= {};
  Cln.stm.conditions	= {};
  Cln.stm.voldt			= VOLDT;
  if isempty(ch1.stimont{ExpNo}),
	ch1.stimonv{ExpNo} = [0; 0];
	ch1.stimont{ExpNo} = [0; LROW];
  end;
  Cln.stm.v				= {[0; ch1.stimonv{ExpNo}; 0]};

  Cln.stm.t				= {[0; ch1.stimont{ExpNo}/1000; LROW]};
  Cln.stm.dt			= {diff(Cln.stm.t{1})};
  Cln.stm.stmpars		= {};
  Cln.stm.pdmpars		= {};
  Cln.stm.sortedByStimulus = 0;	    % Whether or not sorted by stimulus

  Cln.dat(:,1,:) = ch1.adfdata{ExpNo};
  Cln.dat(:,2,:) = ch2.adfdata{ExpNo};
  Cln.dx	= ch1.raw_sampt/1000.0;

  if isfield(grp,'hardch'),
	Cln.chan = grp.hardch;
	Cln.chan(grp.softch) = [];
  end;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ClnSpc = getCLNSPC(Cln)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global VOLDT;
T = VOLDT;						% 75msec hanning window
len = T / Cln.dx;
NFFT = 2048;
ClnSpc = sigspc(Cln, T, T, NFFT, 'hanning');

