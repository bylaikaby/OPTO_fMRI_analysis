function t = gettimebase(Sig)
%GETTIMEBASE - Use Sig.dx and size(Sig.dat,1) to create time base
% GETTIMEBASE(Sig) is for plotting. It provides the time base
% for the plots computed from the sampling rate and size of the
% data.
% NKL, 31.05.03

t = [0:size(Sig.dat,1)-1] * Sig.dx(1);
t = t(:);

