function dat2model(Sig,DataType)
%DAT2MODEL - Makes model from .pts and dumps in filename
% DAT2MODEL is meant to be used in experiments comparing activation
% in one area with activation in other areas etc. One can run
% mcorana (or mcorimg) and create the xcor structure with
% correlation maps and time series (pts/nts); The mean pts can be
% then dumped in filename and used as model.
%
% NKL 31.08.03

if nargin < 2,
  error('usage: dat2model(Sig,DataType)');
end;

if isstruct(Sig),
  tmp=Sig;
  clear Sig;
  Sig{1}=tmp;
  clear tmp;
end;

if strcmp(Sig{1}.dir.dname,'tcImg'),
  error('dat2model: can"t create model from tcImg structures');
end;

tmp = Sig{1}.dir.dname;
if strcmp(tmp,'xcor'),
  TYPE = 'mri';
else
  TYPE = 'neuro';
end;

for N=1:length(Sig),
  tmp = Sig{N};
  eval(sprintf('v=tmp.%s;',DataType));
  mdlsct{N}.mdl = mean(v,2);
  mdlsct{N}.dname = tmp.dir.dname;
  mdlsct{N}.type = TYPE;
end;

name=sprintf('%s_%s',Sig{1}.session,Sig{1}.grpname);
eval(sprintf('%s=mdlsct;',name));
if exist('models.mat','file'),
  save('models.mat','-append',name);
else
  save('models.mat',name);
end;


