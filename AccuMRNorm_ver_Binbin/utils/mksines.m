function Sig = mksines(amp,freq,phase,samprate,reclen)
%MKSINES - Make sine waves
%   [t,s] = mksines(amp,freq,phase,samprate,reclen)
%   freq in Hz
%   phase in degrees
%   samprate in Hz
%   record length in seconds
%  
%   NKL 10.04.02
%   Last updated: NKL 25.01.11
%  

if ~nargin,
	amp = [1 1];            % A.U.
	freq = [200 220];       % Hz
	phase = [0 180];        % In degrees
	samprate = 10000;       % Hz
	reclen = 1;             % In seconds
end;

Ts = 1 / samprate;
t = [0:Ts:reclen];
t = t(:);

Period = 1./freq;
tPhase = (phase./360) .* Period;
for N=1:length(freq),
  s(:,N) = amp(N) * sin(2*pi*freq(N).*(t+tPhase(N)));
end;

Sig.name = 'sine';
Sig.dat = s;
Sig.dx = Ts;
Sig.args.amp = amp;
Sig.args.freq = freq;
Sig.args.phase = phase;
Sig.args.reclen = reclen;
Sig.dir.dname = 'Cln';

REAL_NOISE = 1;
if REAL_NOISE,
  Cln = sigload('rat4211',1,'Cln');
  Cln.dat = Cln.dat(:,1:2);
  Cln = sigresample(Cln,Sig.dx,size(Sig.dat,1));
  Cln.dat = Cln.dat(1:size(Sig.dat,1),:);
  Cln.dat = Cln.dat./max(Cln.dat,1);
  Sig.dat = Sig.dat + Cln.dat*5;
end;

if ~nargout,
  DSPWIN = [0 0.1];
  COL='krgb'; LW=[1 2];
  subplot(2,2,1);
  hold off;
  t = gettimebase(Sig);
  for N=1:size(Sig.dat,2),
    hd(N) = plot(t, Sig.dat(:,N), 'color',COL(N),'linewidth', LW(N));
    txt{N} = sprintf('f=%dHz, phase (pi) =%g', Sig.args.freq(N),Sig.args.phase(N));
    hold on;
  end;
  set(gca,'xlim',DSPWIN);
  set(gca,'ylim',[-2 2]);
  xlabel('Time in seconds');
  ylabel('A.U.');
  legend(hd,txt);
  
  subplot(2,2,2);
  fsig = sigfft(Sig);
  plot(gettimebase(fsig),fsig.dat);
  set(gca,'xscale','log','yscale','log');
  set(gca,'xlim',[Sig.args.freq(1)*0.9 Sig.args.freq(2)*1.1]);
  xlabel('Frequency in Hz');
  ylabel('Power');
  
  subplot(2,1,2);
  plot(t, sum(Sig.dat,2),'color','b');
  set(gca,'xlim',DSPWIN);
  set(gca,'ylim',[-2 2]);
  xlabel('Time in seconds');
  ylabel('A.U.');
  title('Sum of sinusoids');
end

    

