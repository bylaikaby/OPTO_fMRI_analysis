function varargout = mkwhitenoise(T_SEC,MINMAX_F, WAVFILE)
%MKWHITENOISE - makes white noise data.
%  MKWHITENOISE(T_SEC,MINMAX_F,WAVFILE) make white noise data and
%  dumps into 'WAVFILE'.  Sampling frequency is 44.1kHz,
%  and waveform by RANDN() is band-pass filtered at MINMAX_F Hz.
%
%  EXAMPLE :
%    >> mkwhitenoise(5,[15 20000],'flat_noise(15-20k)_5s.wav');
%
%  VERSION 
%    0.90 16.06.06 YM  pre-release
%    0.91 21.06.06 YM  use upsampling if required.
%
%  See also RANDN FILTFILT WAVWRITE PWELCH


if nargin < 1,  eval(sprintf('help %s;',mfilename)); return;  end

if ~exist('WAVFILE','var'),   WAVFILE = '';   end
if ~exist('MINMAX_F','var'),  MINMAX_F = [];  end

if isempty(T_SEC),    T_SEC = 10;  end
if isempty(MINMAX_F), MINMAX_F = [15 20000];  end
if isempty(WAVFILE),  WAVFILE = 'white_noise.wav';  end


WAV_SAMPF = 44.1 * 1000;    % in Hz
%if max(MINMAX_F) < 10000,
%  WAV_SAMPF = WAV_SAMPF / 2;
%end

DEC  = nextpow2(WAV_SAMPF/max(MINMAX_F)/2);
decf = WAV_SAMPF / DEC;

n = round(T_SEC*decf);
decwv = randn(n+2*50,1);

% suppress possible spikes
idx = find(abs(decwv) > 3);
decwv(idx) = decwv(idx)/10;

% low-pass filter
nyqf = decf/2;
[b, a] = butter(4,MINMAX_F/nyqf);
%[b, a] = cheby2(4,30,MINMAX_F/nyqf);
decwv = filtfilt(b,a,decwv);
decwv = decwv([1:n]+50);

%length(decwv)/decf

if DEC == 1,
  wv = decwv;
else
  wv = resample(decwv,DEC,1);
end

wv = wv / max(abs(wv));  % must be -1 to 1
wv = wv * 0.999;

%length(wv)/WAV_SAMPF

%max(wv), min(wv)

if nargout,
  Sig.dx = 1/WAV_SAMPF;
  Sig.dat = wv;
  Sig.info.sampf  = WAV_SAMPF;
  Sig.info.filter = MINMAX_F;
  
  varargout{1} = Sig;
  return;
end


% dump to the file
wavwrite(wv,WAV_SAMPF,16,WAVFILE);


% plot statistics
CONV2DB = 1;
NFFT    = 4096*4;
figure;
[Pxx,f] = pwelch(wv,NFFT,round(NFFT/2),NFFT,WAV_SAMPF);
%[Pxx,f] = pwelch(decwv,NFFT,round(NFFT/2),NFFT,decf);
if CONV2DB,
  plot(f,10*log10(Pxx+eps));
  ylabel('Power Spectral Density (dB/Hz)');
else
  plot(f,Pxx);
  ylabel('Power Spectral Density (power/Hz)');
end
xlabel('Frequency in Hz');
set(gca,'xscale','log');
grid on;


return;
