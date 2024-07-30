function tstvideo
%TSTVIDEO - Test Video routine which makes our matlab movies
% TSTVIDEO used for the sfn2003

  Ses = goto('g02nm1');
load('g02nm1_16.mat');
[Lfp, Mua] = getlfpmuaflt(Ses,16);
keyboard

moviefile = strcat('y:/mri/movies/',Cln.movie.name);

offsets = 0.0;
if 0,
  T = 0.125;
  len = T / Cln.dx;
  NFFT = getpow2(len,'ceiling');
  ClnSpc = sigspc(Cln, T, T, NFFT, 'hanning');
  keyboard
  
  Lfp = DoGetlfpmua(ClnSpc, Ses.anap.bands.lfpM, 'LfpM');
  Mua = DoGetlfpmua(ClnSpc, Ses.anap.bands.mua, 'Mua');
  Lfp.dat = mean(Lfp.dat,2);
  Mua.dat = mean(Mua.dat,2);
end;

m = mean(Lfp.dat(:));
s = std(Lfp.dat(:));
threshold = m+2*s;

% Raw data points
responseIndex = find(Lfp.dat > threshold);
fprintf('length = %d\n',length(responseIndex));

rIndex = ceil((responseIndex * Lfp.dx + offsets)/Cln.movie.dx);
frames = Cln.movie.dat(rIndex);
[imgmean, imgstd] = vavigetmean(moviefile,frames);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SigPow = DoGetlfpmua(Spc, lims, SigName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = xsigdim(Spc,2);
if isempty(lims),	lims = [f(1) f(end)];	end;

names.LfpL  = {'LfpL';  {'color';'b';'linestyle';'-';'linewidth';0.6}};
names.LfpM  = {'LfpM';  {'color';'r';'linestyle';'-';'linewidth';0.6}};
names.LfpH  = {'LfpH';  {'color';'m';'linestyle';'-';'linewidth';0.6}};
names.Mua   = {'Mua';  {'color';'k';'linestyle';'-';'linewidth';0.6}};

eval(sprintf('CurName = names.%s;',SigName));
SigPow				= Spc;
SigPow.dir.dname	= char(CurName{1});
SigPow.dsp.func		= 'dspsigpow';
SigPow.dsp.args		= CurName{2};
SigPow.dsp.label	= {'Time in sec'; 'SD Units'};
SigPow.range		= lims;

SigPow.dat = zeros(size(Spc.dat,1),size(Spc.dat,3),size(Spc.dat,4));
SigPow.dx = SigPow.dx(1);

pnts = find(f >= lims(1) & f <= lims(2));
NoChan = size(Spc.dat,3);
NoObsp = size(Spc.dat,4);
for ObspNo = 1:NoObsp,
  for ChanNo = 1:NoChan,
	SigPow.dat(:,ChanNo,ObspNo) = hnanmean(Spc.dat(:,pnts,ChanNo,ObspNo),2);
  end;
end;

%
% SigPow = sigdetrend(SigPow);
%
SigPow = tosdu(SigPow,'dat','prestm');
return;

