function Sig = tosdu(Sig,datname,epoch,ModelNo)
%TOSDU - convert signal values to SD units computed over baseline activity
%	Sig = TOSDU(Sig) computes the mean and standard deviation of
%	either the prestimulus or all the bacground/control epochs, centalizes
%	the signal and converts it into SD units by dividing by SD.
%	Defining of the control-epoch is done by
%	stat = getbaseline(Sig, datname, epoch, ModelNo)
%	NKL 7.09.02
%
% See also GETBASELINE, GETSTIMINDICES, XFORM

if nargin == 0, help tosdu;  return;  end  

if nargin < 4,
  ModelNo = 1;
end;
if nargin < 3,
  epoch = 'prestm';
end;
if nargin < 2,
  datname = 'dat';
end;

Sig.dsp.label{2} = 'Power in SD Units';
stat = getbaseline(Sig,datname,epoch,ModelNo);

DIM = 1;							% All arrays have time as dim=1
if	strcmp(Sig.dir.dname,'tcImg'),
  DIM = 4;							% Except tcImg and Xcor (dim=4)
end;
eval(sprintf('dims = size(Sig.%s);',datname));

dims(:) = 1;
eval(sprintf('dims(%d) = size(Sig.%s,%d);',DIM,datname,DIM));
mdat = repmat(stat.m, dims);
sdat = repmat(stat.s, dims);
eval(sprintf('Sig.%s = (Sig.%s - mdat) ./ sdat;',datname,datname));

stat.func{1} = sprintf('dims(%d) = size(Sig.%s,%d);',DIM,datname,DIM);
stat.func{2} = 'repmat(stat.m, dims)';
stat.func{3} = 'repmat(stat.s, dims)';
stat.func{4} = sprintf('Sig.%s = (Sig.%s - mdat) ./ sdat;',datname,datname);
Sig.tosdu = stat;

