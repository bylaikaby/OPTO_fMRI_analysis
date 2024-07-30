function varargout = xsigdim(Sig, Dim)
%XSIGDIM - Creates a vector of size length(Dim) and appropriate units
%	XSIGDIM(Sig, Dim) is used to convert the typical
%	[0:size(Sig.dat,Dim)-1] vector into something meaningful, such as
%	time, frequency etc. It does so by using the unit information included
%	in the Sig structure, commonly Sig.dx(), where by each element is the
%	sampling rate in the time or frequency domain.
%	We use this often with spectrograms to extract the time/frequency
%	bases for both computing and plotting.
%	HM, 11.01.00
%	NKL, 02.01.03

if nargin < 2,
   Dim = length(Sig.dx(:));
end;

x0 = zeros(size(Sig.dx));
try,
   if length(Sig.dx) > length(Sig.x0),
      Sig.x0(length(Sig.dx))= 0;
   end;
catch,
   Sig.x0 = zeros(size(Sig.dx));
end;

for n= 1:length(Dim(:)),
   varargout{n} = Sig.x0(Dim) + Sig.dx(Dim)*[0:size(Sig.dat,Dim)-1]';
end;

return;
