function fixup(SESSION,EXPS)
%FIXUP - Fixing/Replacing/Adding new pars/vars
%	fixup(SESSION)
%	This function must be always re-edited as needed
%	Added ExpNo info in every signal structure
%	Removed dummies from stm.t
%
%	Basic Signals for Alert Monkey Experiments:
%	Cln    
%	ClnSpc 
%	Spkt   
%	em     
%	tcImg  
%	NKL, 24.10.02


UPDATE.STM = 0;
UPDATE.TCIMG = 0;
UPDATE.CLN = 1;

Ses = goto(SESSION);
if nargin < 2,
	EXPS = validexps(Ses);
end;



%  Cln            1x6                 27632052  cell array
%  ClnSpc         1x6                 17800116  cell array
%  LfpH           1x6                  3658272  cell array
%  LfpL           1x6                  3658272  cell array
%  LfpM           1x6                  3658272  cell array
%  Mua          

for ExpNo=EXPS,
	name = catfilename(Ses,ExpNo,'mat');
	fprintf('Loading %s\n', name);
	load(name);
	if length(Cln)>1,
	  for C=1:length(Cln),
		Cln{C}.chan = [1 2];
		ClnSpc{C}.chan = [1 2];
		LfpH{C}.chan = [1 2];
		LfpM{C}.chan = [1 2];
		LfpL{C}.chan = [1 2];
		Mua{C}.chan = [1 2];
	  end;
	else
		Cln.chan = [1 2];
		ClnSpc.chan = [1 2];
		LfpH.chan = [1 2];
		LfpM.chan = [1 2];
		LfpL.chan = [1 2];
		Mua.chan = [1 2];
	end;	  

	fprintf('Saving %s\n\n', name);
	save(name,'-append','Cln','ClnSpc','LfpH','LfpL','LfpM','Mua');
end;

	

return;
for ExpNo=EXPS,
	name = catfilename(Ses,ExpNo,'mat');
	grp = getgrp(Ses,ExpNo);
	load(name,'Cln');

	Cln = rmfield(Cln,'stm');
	Cln.stm.dt = grp.t;
	Cln.stm.v = grp.v;

	for N=1:length(Cln.stm.v),
		Cln.stm.v{N} = [Cln.stm.v{N} 0];
		Cln.stm.dt{N} = Cln.stm.dt{N} * Cln.evt.voltr;
		Cln.stm.dt{N}(1) = Cln.stm.dt{N}(1) - Cln.evt.adfofs;
		Cln.stm.t{N} = [0 cumsum(Cln.stm.dt{N})];
		Cln.stm.t{N}(end) = Cln.evt.adflen;
	end;
	save(name,'Cln');
end;

return;


for ExpNo=EXPS,
	if UPDATE.CLN,
		name = catfilename(Ses,ExpNo,'mat');
		load(name,'Cln');
		tmp = Cln;
		clear Cln;
		Cln.session = tmp.session;
		Cln.grpname = 'base';
		Cln.ExpNo = tmp.ExpNo;
		Cln.dir = tmp.dir;
		Cln.dsp = tmp.dsp;
		Cln.grp = tmp.grp;
		Cln.usr = tmp.usr;
		Cln.evt = tmp.evt;
		Cln.stm = tmp.stm;
		Cln.dx = tmp.dx;
		Cln.dat = tmp.dat;
		save(name,'Cln');	
		fprintf('fixup: %s done!\n',name);
	end;

	if UPDATE.STM,
		name = catfilename(Ses,ExpNo,'mat');
		load(name);

		tcImg.stm = ep{ExpNo}.stm;
		brPts.stm = ep{ExpNo}.stm;
		v1Pts.stm = ep{ExpNo}.stm;
		v2Pts.stm = ep{ExpNo}.stm;
		v4Pts.stm = ep{ExpNo}.stm;
		mtPts.stm = ep{ExpNo}.stm;
		save(name,'tcImg','brPts','v1Pts','v2Pts','v4Pts','mtPts');
		fprintf('fixup: %s done!\n',name);
	end;

	if UPDATE.TCIMG,
		name = catfilename(Ses,ExpNo,'mat');
        name2 = catfilename(Ses,ExpNo,'tcimg');
		load(name,'v1Pts','v2Pts','v4Pts');
        load(name2,'tcImg');
		tmp = tcImg;
		clear tcImg;
		grp = getgrp(Ses,ExpNo);
		ep = sesparload(Ses);

		tcImg.session	= tmp.session;
		tcImg.grpname	= grp.name;
		tcImg.ExpNo		= tmp.ExpNo;

		tcImg.dir.dname	= 'tcImg';
		tcImg.dir.scantype	= 'EPI';
		tcImg.dir.scanreco	= Ses.expp(ExpNo).scanreco;
		tcImg.dir.name		= tmp.name;
		tcImg.dir.matfile	= tmp.matfile;

		tcImg.dsp		= tmp.dsp;
		tcImg.grp		= tmp.grp;
		tcImg.usr		= tmp.usr;
		tcImg.usr.pvpar	= ep{ExpNo}.img;
		tcImg.evt		= tmp.evt;
		tcImg.stm		= tmp.stm;
		tcImg.ds		= tmp.ds;
		tcImg.dx		= tmp.dx;
		tcImg.dat		= tmp.dat;
		save(name,'v1Pts','v2Pts','v4Pts','-append');
		save(name2,'tcImg');
		fprintf('saved %s\n',name);
	end;

end;



