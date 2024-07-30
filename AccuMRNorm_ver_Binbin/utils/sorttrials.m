function oSig = sorttrials(Sig)
%SORTTRIALS - sort randomly presented trials
% SORTTRIALS uses Sig.stm.t/dt information to detect trial onset
% and sort all trials according to conditions. It is used to
% compute stimulus-related PSDs, integrals, etc. The integrals can
% be then used to asses site-selectivity.
%
% LfpM = 
%    [1x1 struct]    [1x1 struct]    [1x1 struct]  
%
% LfpM{1} = 
%    session: 'b01nm4'
%    grpname: 'pwcont'
%      ExpNo: [71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90]
%        dir: [1x1 struct]
%        dsp: [1x1 struct]
%        grp: [1x1 struct]
%        usr: {}
%        evt: [1x1 struct]
%        stm: [1x1 struct]
%       chan: [1 3 4 5 6 16 8 9 10 11 12 13 14 15]
%        dat: [96x14x20 double]		% Time X Chan X Obsp
%         dx: 0.2500
%       cond: [1x1 struct]
%      range: [31 100]
%      tosdu: [1x1 struct]
%	  
% lfp = sorttrials(LfpM);
% lfp.dat = [12    14    20     7     6]
%		Time X Chan X Obsp X Conditions X Epoch
% e.g. for contrast:
%		Time X Chan X Obsp X [0 1 3 4 | 2 1 0 3 ...] [1 0.5 0.25 ...]
%
% To obtain the time series corresponding to an epoch for all
% observation periods and all conditions use
% getepoch(sorttrials(Sig)), which actually returns the reshaped
% array in the form: [Time X Chan X Epoch X Trials].
%
% NKL 11.05.03

if length(Sig) == 1,
  tmp = Sig; clear Sig;
  Sig{1} = tmp; clear tmp;
end;

% STIMULUS TIMING IS ASSUMED TO BE ALWAYS THE SAME
if iscell(Sig{1}.stm.conditions),
	stmt = Sig{1}.stm.dt{1}(1:length(Sig{1}.stm.conditions{1}));
else
	stmt = Sig{1}.stm.dt{1}(1:length(Sig{1}.stm.conditions));
end;
sumt = [0 cumsum(stmt)];
sumt = round(sumt(:)/Sig{1}.dx(1));

oSig = Sig{1};
oSig.dat = [];

% MAKE SURE ALL SIGNAL PORTIONS WILL BE OF THE SAME LENGTH
K=1;
NoCond = length(Sig);
for CondNo = 1:NoCond,
  for E=1:length(sumt)-1,
	len(K) = length(sumt(E)+1:sumt(E+1)); K=K+1;
  end;
end;
len = min(len);

NoChan = size(Sig{1}.dat,2);
NoObsp = size(Sig{1}.dat,3);
NoEpoch = length(sumt)-1;

oSig.dat = zeros(len,NoChan,NoObsp,NoEpoch,NoCond);
oSig.time = zeros(len,NoEpoch,NoCond);

% SORT STIMULUS TYPE IN EACH CONDITION
for CondNo = 1:NoCond,
  if iscell(Sig{1}.stm.conditions),
	[dummy,ix]=sort(Sig{CondNo}.stm.conditions{1});
  else
	[dummy,ix]=sort(Sig{CondNo}.stm.conditions);
  end;

  for E=1:NoEpoch,
	% PICK UP THE RIGHT PORTION OF THE RESPONSE
	IDX = [sumt(ix(E))+1:sumt(ix(E))+len];	% Correct segment as stim-cond
	oSig.time(:,E,CondNo) = (IDX(:)-1) * oSig.dx(1);
	oSig.dat(:,:,:,E,CondNo) = Sig{CondNo}.dat(IDX,:,:);
  end;
end;

DEBUG=0;
if DEBUG,
  COL={'r';'g';'b';'w';'y';'m';[.4 .4 .4]};
  show(Sig);
  tmpchld = get(gcf,'children');
  K=1;
  for N=1:length(tmpchld),
	lab = get(tmpchld(N),'tag');
	for L=1:length(oSig.stm.labels),
	  if strcmp(lab,oSig.stm.labels{L}),
		chld(K)=tmpchld(N);
		K=K+1;
	  end;
	end;
  end;

  dat = mean(oSig.dat,2);
  dat = squeeze(mean(dat,3));
  for CondNo=1:NoCond,
	axes(chld(CondNo)); hold on;
	for SEG=1:size(oSig.dat,4),
	  plot(oSig.time(:,SEG,CondNo),dat(:,SEG,CondNo),'color', ...
		 COL{SEG},'linestyle',':','linewidth',2);
	end
  end;
end;

  

