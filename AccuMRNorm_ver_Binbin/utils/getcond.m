function Sig = getcond(Ses,ExpNo,SaveData,SigName)
%GETCOND - Split the file data into trial and observation periods.
% GETCOND splits the data according to the stimulus type
% (Ses.grp.v{}) and the repetition of a single type. Different
% stimulation types are members of a cell arrays (Sig{}) and
% different observation periods are cat along the 3rd Sig.dat
% dimension.
% USAGE : getcond(Ses,ExpNo,[SaveData])
%
% See also
% SESGETCOND 
% SigMAIN SigADF SigADJEVT SigHELP CHECKGRD GETCLOCKERROR GETGRAPAT
% RESHAPEOBSP RESHAPEOBSP_xxxx

Ses = goto(Ses);
grp = getgrp(Ses,ExpNo);
if nargin < 4,
  if isimaging(Ses,grp.name) & ~isrecording(Ses,grp.name),
	SigName = 'tcImg';
  else
	SigName = 'Cln';
  end;
end;

if nargin < 2,
  error('GETCOND: usage: Sig = getcond(Ses,ExpNo,[SaveData]);');
end;

if ~exist('SaveData','var'),  SaveData = 1;  end

if strcmp(SigName,'Cln'),
  name = catfilename(Ses,ExpNo,'cln');
else
  name = catfilename(Ses,ExpNo,'mat');
end

iSig = matsigload(name,SigName);
if length(iSig) > 1, 
  fprintf(' getcond WARNING: %s is already splitted.\n',name);
  return;
end

% check number of observations, sice some scripts may not
% compatible to '.evt.vaildobs'.
if strcmp(SigName,'Cln'),
  if iSig.evt.NoObsp ~= size(iSig.dat,3),
	fprintf(' getcond WARNING: NoObsp differs between .evt and .dat.\n');
	fprintf(' No further processing!\n');
	Sig = iSig;
	return;
  end
else
  iSig.evt.NoObsp  = 1;
end;

nconds = length(iSig.stm.conditions);
fprintf(' getcond: processing %s [%d]...',name,nconds);
if strcmpi(iSig.session,'b01nm3'),
  fprintf('\n getcond: b01nm3 detected: use reshapeobsp_b01nm3.');
  if nconds == 1,
    Sig = reshapeobsp_b01nm3(iSig,iSig.stm.condids(1));
  else
    for N=1:nconds,
	  pack;  % ensure to open up larger contiguous blocks
      %Sig{N} = reshapeobsp(iSig,iSig.stm.conditions{N});
      Sig{N} = reshapeobsp_b01nm3(iSig,iSig.stm.condids(N));
    end;
  end
elseif ~isempty(strfind(iSig.session,'ymfs')),
  fprintf('\n getcond: ymfs detected: use reshapeobsp_ymfs.');
  if nconds == 1,
    Sig = reshapeobsp_ymfs(iSig,iSig.stm.condids(1));
  else
    for N=1:nconds,
      Sig{N} = reshapeobsp_ymfs(iSig,iSig.stm.condids(N));
    end;
  end
else
  % DEFAULT PROCEDURE.
  if nconds == 1,
    %fprintf(' getcond: nconds=1, nothing to be changed.\n');
    %return;
	if strcmp(iSig.dir.dname,'Cln'),
	  Sig = reshapeobsp(iSig,iSig.stm.condids(1));
	else
	  Sig = mreshapeobsp(iSig,iSig.stm.condids(1));
	end;
  else
	% if data will be larger than 400Mbytes,
	% use temporal files to avoid 'Out of memory'.
	% The value of 400M can be changed according to installed RAM.
	if numel(iSig.dat)*8 > 400e+6,
	  fprintf('\n getcond: large data detected, use temporal files(%d). ',nconds);
	  for N=1:nconds,
		pack;  % ensure to open up larger contiguous blocks
		if strcmp(iSig.dir.dname,'Cln'),
		  tmpsiSig= reshapeobsp(iSig,iSig.stm.condids(N));
		else
		  tmpsiSig= mreshapeobsp(iSig,iSig.stm.condids(N));
		end;
		save(sprintf('iSigsigdat_%d.mat',N),'iSigsig');
		clear iSigsig;
		fprintf('w');
	  end;
	  clear iSig;
	  fprintf(' ');
	  for N=1:nconds,
		pack;  % ensure to open up larger contiguous blocks
		iSig = load(sprintf('iSigsigdat_%d.mat',N),'iSigsig');
		Sig{N} = iSig.iSigsig;
		delete(sprintf('iSigsigdat_%d.mat',N));
		fprintf('r');
	  end;
	  fprintf(' done.');
	  clear iSig;
	else
	  for N=1:nconds,
		pack;  % ensure to open up larger contiguous blocks
		if strcmp(iSig.dir.dname,'Cln'),
		  Sig{N} = reshapeobsp(iSig,iSig.stm.condids(N));
		else
		  Sig{N} = mreshapeobsp(iSig,iSig.stm.condids(N));
		end;
	  end;
	end
  end
end

if SaveData > 0,
  eval(sprintf('%s=Sig;',SigName));
  if ~nargout, clear Sig; pack; end;
  save(name,SigName);
  fprintf('\n %s: Saved %s to %s\n', gettimestring,SigName,name);
end

% if nargout == 0, then likely to be called from sesgetcond.
% Let's free 'Sig' for next processing,
% otherwise matlab holds 'Sig' as 'ans' within sesgetcond 
% that will cause 'Out of memory' bussiness...
if nargout == 0, Sig = {};  end




