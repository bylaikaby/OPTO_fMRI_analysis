function [b, a]  = shelving(G, fc, fs, Q, type)

%
% Derive coefficients for a shelving filter with a given amplitude and
% cutoff frequency.  All coefficients are calculated as described in 
% Zolzer's DAFX book (p. 50 -55).  
%
% Usage:     [B,A] = shelving(G, Fc, Fs, Q, type);
%
%            G is the logrithmic gain (in dB)
%            FC is the center frequency
%            Fs is the sampling rate
%            Q adjusts the slope be replacing the sqrt(2) term
%            type is a character string defining filter type
%                 Choices are: 'Base_Shelf' or 'Treble_Shelf'
%
% EXAMPLE :
%   >> Fs = 1000;
%   >> G = -10:10;  Fc = 100;  Q = 1/sqrt(2);  type='Base_Shelf';
%   >> figure;
%   >> for N = 1:length(G), ...
%        [b,a] = shelving(G(N),Fc,Fs,Q,type); ...
%        [h,f] = freqz(b,a,1024,Fs); ...
%        subplot(2,1,1); plot(f,20*log10(abs(h))); hold on; ...
%        subplot(2,1,2); plot(f,angle(h)/pi*180); hold on; ...
%      end
%   >> subplot(2,1,1);  xlable('Frequency (Hz)');  ylable('Magnitude (dB)');
%   >> subplot(2,1,2);  xlable('Frequency (Hz)');  ylable('Phase (deg)');
%
% Author:    Jeff Tackett 08/22/05


% EXAMPLE :
%   >> infile = 'acoustic.wav';
%   % read in wav sample
%   >> [ x, Fs, N ] = wavread(infile);
%   % set Parameters for Shelving Filter
%   % Change these to experiment with filter
%   >> G = 4; fcb = 300; Q = 3; type = 'Base_Shelf';
%   >> [b a] = shelving(G, fcb, Fs, Q, type);
%   >> yb = filter(b,a, x);
%   % write output wav files
%   >> wavwrite(yb, Fs, N, 'out_bassshelf.wav');
%   % plot the original and equalised waveforms
%   >> figure(1), hold on;
%   >> plot(yb,'b');
%   >> plot(x,'r');
%   >> title('Bass Shelf Filter Equalised Signal');
%   %Do treble shelf filter
%   >> fct = 600; type = 'Treble_Shelf';
%   >> [b a] = shelving(G, fct, Fs, Q, type);
%   >> yt = filter(b,a, x);
%   % write output wav files
%   >> wavwrite(yt, Fs, N, 'out_treblehelf.wav');
%   >> figure(1), hold on;
%   >> plot(yb,'g');
%   >> plot(x,'r');
%   >> title('Treble Shelf Filter Equalised Signal');

%  LICENSE :
%  Copyright (c) 2009, Jeff Tackett
%  All rights reserved.
%
%  Redistribution and use in source and binary forms, with or without
%  modification, are permitted provided that the following conditions are
%  met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%  POSSIBILITY OF SUCH DAMAGE.

if nargin < 5, eval(['help ' mfilename]); return;  end


%Error Check
if((strcmpi(type,'Base_Shelf') ~= 1) && (strcmpi(type,'Treble_Shelf') ~= 1))
    error(['Unsupported Filter Type: ' type]);
end

K = tan((pi * fc)/fs);
V0 = 10^(G/20);
root2 = 1/Q; %sqrt(2)

%Invert gain if a cut
if(V0 < 1)
    V0 = 1/V0;
end

%%%%%%%%%%%%%%%%%%%%
%    BASE BOOST
%%%%%%%%%%%%%%%%%%%%
if(( G > 0 ) & (strcmpi(type,'Base_Shelf')))
   
    b0 = (1 + sqrt(V0)*root2*K + V0*K^2) / (1 + root2*K + K^2);
    b1 =             (2 * (V0*K^2 - 1) ) / (1 + root2*K + K^2);
    b2 = (1 - sqrt(V0)*root2*K + V0*K^2) / (1 + root2*K + K^2);
    a1 =                (2 * (K^2 - 1) ) / (1 + root2*K + K^2);
    a2 =             (1 - root2*K + K^2) / (1 + root2*K + K^2);

%%%%%%%%%%%%%%%%%%%%
%    BASE CUT
%%%%%%%%%%%%%%%%%%%%
elseif (( G < 0 ) & (strcmpi(type,'Base_Shelf')))
    
    b0 =             (1 + root2*K + K^2) / (1 + root2*sqrt(V0)*K + V0*K^2);
    b1 =                (2 * (K^2 - 1) ) / (1 + root2*sqrt(V0)*K + V0*K^2);
    b2 =             (1 - root2*K + K^2) / (1 + root2*sqrt(V0)*K + V0*K^2);
    a1 =             (2 * (V0*K^2 - 1) ) / (1 + root2*sqrt(V0)*K + V0*K^2);
    a2 = (1 - root2*sqrt(V0)*K + V0*K^2) / (1 + root2*sqrt(V0)*K + V0*K^2);

%%%%%%%%%%%%%%%%%%%%
%   TREBLE BOOST
%%%%%%%%%%%%%%%%%%%%
elseif (( G > 0 ) & (strcmpi(type,'Treble_Shelf')))

    b0 = (V0 + root2*sqrt(V0)*K + K^2) / (1 + root2*K + K^2);
    b1 =             (2 * (K^2 - V0) ) / (1 + root2*K + K^2);
    b2 = (V0 - root2*sqrt(V0)*K + K^2) / (1 + root2*K + K^2);
    a1 =              (2 * (K^2 - 1) ) / (1 + root2*K + K^2);
    a2 =           (1 - root2*K + K^2) / (1 + root2*K + K^2);

%%%%%%%%%%%%%%%%%%%%
%   TREBLE CUT
%%%%%%%%%%%%%%%%%%%%

elseif (( G < 0 ) & (strcmpi(type,'Treble_Shelf')))

    b0 =               (1 + root2*K + K^2) / (V0 + root2*sqrt(V0)*K + K^2);
    b1 =                  (2 * (K^2 - 1) ) / (V0 + root2*sqrt(V0)*K + K^2);
    b2 =               (1 - root2*K + K^2) / (V0 + root2*sqrt(V0)*K + K^2);
    a1 =             (2 * ((K^2)/V0 - 1) ) / (1 + root2/sqrt(V0)*K + (K^2)/V0);
    a2 = (1 - root2/sqrt(V0)*K + (K^2)/V0) / (1 + root2/sqrt(V0)*K + (K^2)/V0);

%%%%%%%%%%%%%%%%%%%%
%   All-Pass
%%%%%%%%%%%%%%%%%%%%
else
    b0 = V0;
    b1 = 0;
    b2 = 0;
    a1 = 0;
    a2 = 0;
end

%return values
a = [  1, a1, a2];
b = [ b0, b1, b2];
