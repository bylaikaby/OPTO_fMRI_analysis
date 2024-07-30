function oSig = catsig(SESSION, GrpName, SigName, RoiNames)
%CATSIG - Concatanate signals from mat files
% CATSIG is a subroutine called by the group-maker grpmake.m.
%
%  SIG = CATSIG(SESSION,GRPNAME/EXPS,SIGNAME) returns a concatinated
%  "SIGNAME" of specified "SESSION" and "GRPNAME" or "EXPS".
%
% NKL, 28.04.03
% YM,  11.07.04 supports signals of dependency analysis
% YM,  10.09.04 supports "RoiNames" for roiTs etc.
% AB,  12.09.04 supports depsignals
% YM,  09.01.05 supports spike-triggered averages,'spkBlp' and 'spkCln'.
%
% See also GRPMMAKE, SESGRPMAKE, SESSUPGRP

if nargin < 3,  help catsig; return;  end
if nargin < 4,  RoiNames = {};  end

Ses = goto(SESSION);
if ischar(GrpName),
  grp = getgrpbyname(Ses,GrpName);
  EXPS = grp.exps;
else
  EXPS = GrpName;
  grp = getgrp(Ses,EXPS(1));
end

fprintf(' catsig: %s %s "%s", ExpNo: ',Ses.name,grp.name,SigName);

for iExp = 1:length(EXPS),
  clear Sig; pack;
  
  ExpNo = EXPS(iExp);

  fprintf('%d.',ExpNo);
  
  % The following signals are in SIGS directory; ...so check
  if strcmp(SigName,'Cln'), EXT = SigName;
  elseif strcmpi(SigName,'ClnSpc'), EXT = SigName;
  elseif strcmpi(SigName,'tcImg'), EXT = SigName;
  elseif any(strcmpi(SigName,Ses.ctg.GrpDEPSigs)), EXT = 'contrasts';
  elseif any(strcmpi(SigName,{'Spktblp','SpktCln','Brsttblp','BrsttCln'})), EXT = SigName;
  elseif any(strcmpi(SigName,{'atSpktblp','atSpktCln','atBrsttblp','atBrsttCln'})), EXT = SigName;
  else EXT = 'mat'; end;

  filename = catfilename(Ses,ExpNo,EXT);
  tmp = who('-file',filename,SigName);
  if isempty(tmp),
	fprintf('!! catsig WARNING: %s was not found in %s\n',SigName,filename);
	oSig = {};
	return;
  end;
  
  Sig = sigload(Ses,ExpNo,SigName);

  if isempty(Sig),
    fprintf('CATSIG: Skipping empty signal %s\n', SigName);
    oSig = Sig;
    return;
  end;

  if isstruct(Sig), % make it cell array even if a single condition...
    Sig = { Sig };
  end;

  % PROCESS ACCORDING TO SIGNAL STRUCTURE
  switch SigName,

    
%       session: 'j02x31'
%       grpname: 'gpatcr1'
%         ExpNo: [2 10 18 26 34 42 50 58 66 74 82 90 98]
%           dir: [1x1 struct]
%           dsp: [1x1 struct]
%           grp: [1x1 struct]
%           evt: [1x1 struct]
%           stm: [1x1 struct]
%           ele: {}
%            ds: [0.7500 0.7500 2]
%            dx: 1
%           ana: [90x64x5 double]
%          name: 'Brain'
%         slice: -1
%        coords: [20842x3x37 double]
%     roiSlices: [1 2 3 4 5]
%           dat: [128x20842x13 double]
%             r: {[20842x13 double]  [20842x13 double]  [20842x13 double]}
%             p: {[20842x13 double]  [20842x13 double]  [20842x13 double]}
%           mdl: {[128x1 double]  [128x1 double]  [128x1 double]}
%          info: [1x1 struct]

%     session: 'j02x31'
%       grpname: 'gpatcr1'
%         ExpNo: 2
%           dir: [1x1 struct]
%           dsp: [1x1 struct]
%           grp: [1x1 struct]
%           evt: [1x1 struct]
%           stm: [1x1 struct]
%           ele: {}
%            ds: [0.7500 0.7500 2]
%            dx: 1
%           ana: [90x64x5 double]
%          name: 'Brain'
%         slice: -1
%        coords: [20842x3 double]
%     roiSlices: [1 2 3 4 5]
%           dat: [128x20842 double]
%             r: {[20842x1 double]  [20842x1 double]  [20842x1 double]}
%             p: {[20842x1 double]  [20842x1 double]  [20842x1 double]}
%           mdl: {[128x1 double]  [128x1 double]  [128x1 double]}
%          info: [1x1 struct]

    
    
   case {'roiTs','troiTs','pcaTs','pcasTs','plsTs','plssTs','pls2Ts','mrsTs'} % Time series of ROIs
    if ~isempty(RoiNames),
      Sig = mroitsget(Sig,[],RoiNames);
    end
    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig),
        oSig{K}.ExpNo = grp.exps;
      end;
      DIM = ndims(Sig{1}.dat)+1;
    else
      for K = 1:length(oSig),
        oSig{K}.dat = cat(DIM,oSig{K}.dat,Sig{K}.dat);
        oSig{K}.coords = cat(1,oSig{K}.coords,Sig{K}.coords);
        for ModelNo=1:length(oSig{K}.r),
          oSig{K}.r{ModelNo} = cat(2,oSig{K}.r{ModelNo},Sig{K}.r{ModelNo});
          if isfield(oSig{K},'p'),
            oSig{K}.p{ModelNo} = cat(2,oSig{K}.p{ModelNo},Sig{K}.p{ModelNo});
          end;
          if isfield(oSig{K},'f'),
            oSig{K}.f{ModelNo}    = cat(2,oSig{K}.f{ModelNo},Sig{K}.f{ModelNo});
          end;
          if isfield(oSig{K},'rcos'),
            oSig{K}.rcos{ModelNo} = cat(2,oSig{K}.rcos{ModelNo},Sig{K}.rcos{ModelNo});
          end;
        end;
     end;
    end;
    if iExp == length(EXPS),
      for K = 1:length(oSig),
        s = size(oSig{K}.dat);
        oSig{K}.dat = reshape(oSig{K}.dat,[s(1) prod(s(2:end))]);
      end;
    end;
   
   case { 'blp'},
    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig),  oSig{K}.ExpNo = grp.exps;  end;
    else
      for K = 1:length(oSig),
        if size(oSig{K}.dat,1) > size(Sig{K}.dat,1),
          oSig{K}.dat = oSig{K}.dat(1:size(Sig{K}.dat,1),:,:,:);
        elseif size(oSig{K}.dat,1) < size(Sig{K}.dat,1),
          Sig{K}.dat = Sig{K}.dat(1:size(oSig{K}.dat,1),:,:,:);
        end
        oSig{K}.dat = cat(4,oSig{K}.dat,Sig{K}.dat);
      end;
    end;
    if iExp == length(EXPS),
      for K = 1:length(oSig),
        oSig{K} = sigmedian(oSig{K},4);
      end;
    end;
    
   case { 'cblp'},
    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig),  oSig{K}.ExpNo = grp.exps;  end;
    else
      for K = 1:length(oSig),
        oSig{K}.dat = cat(4,oSig{K}.dat,Sig{K}.dat);
      end;
      if isfield(oSig{K},'r'),
        oSig{K}.r = cat(2,oSig{K}.r,Sig{K}.r);
        oSig{K}.p = cat(2,oSig{K}.p,Sig{K}.p);
        oSig{K}.lag = cat(2,oSig{K}.lag,Sig{K}.lag);
      end;
    end;
    if iExp == length(EXPS),
      for K = 1:length(oSig),
        oSig{K} = sigmedian(oSig{K},4);
      end;
    end;
    
   case {'troiTsOLD'}             % Time series of ROIs
    if iExp == 1,
      oSig = Sig;
      for Tr = 1:length(oSig),
        for K = 1:length(oSig{Tr}), oSig{Tr}{K}.ExpNo = grp.exps; end;
      end;
    else
      for Tr = 1:length(oSig),
        for K = 1:length(oSig{Tr}),
          oSig{Tr}{K}.dat     = cat(2,oSig{Tr}{K}.dat,Sig{Tr}{K}.dat);
          oSig{Tr}{K}.coords  = cat(1,oSig{Tr}{K}.coords,Sig{Tr}{K}.coords);
          for M=1:length(roiTs{Tr}{K}.r),
            oSig{Tr}{K}.r{ModelNo}    = cat(1,oSig{Tr}{K}.r{ModelNo}(:),Sig{Tr}{K}.r{ModelNo}(:));
            if isfield(oSig{Tr}{K},'p'),
              oSig{Tr}{K}.p{ModelNo}=cat(1,oSig{Tr}{K}.p{ModelNo}(:),Sig{Tr}{K}.p{ModelNo}(:));
            end
          end;
        end;
      end;
    end;
	  
   case {'Cln'}    %  Neural data/spectrogramws
                            % =============================
	for K=1:length(Sig),
      Sig{K}.dat = abs((Sig{K}.dat));
	  if iExp == 1,
		oSig = Sig;
        for K = 1:length(oSig),
          oSig{K}.ExpNo = grp.exps;
          oSig{K}.dat   = oSig{K}.dat / length(EXPS);
        end;
	  else
        for K = 1:length(oSig),
          oSig{K}.dat = oSig{K}.dat + Sig{K}.dat / length(EXPS);
        end;
	  end;
	end;
	
   case {'ClnSpc'}    %  Neural data/spectrogramws
	for K=1:length(Sig),
	  if iExp == 1,
		oSig = Sig;
        for K = 1:length(oSig),
          oSig{K}.ExpNo = grp.exps;
          oSig{K}.dat   = oSig{K}.dat / length(EXPS);
        end;
	  else
        for K = 1:length(oSig),
          oSig{K}.dat = oSig{K}.dat + Sig{K}.dat / length(EXPS);
        end;
	  end;
	end;
	
   case {'Gamma' 'Mua' 'Lfp' 'LfpL' 'LfpM' 'LfpH' 'Sdf' ...
         'tGamma' 'tMua' 'tLfp' 'tLfpL' 'tLfpM' 'tLfpH' ...
         'cGamma' 'cMua' 'cLfp' 'cLfpL' 'cLfpM' 'cLfpH' ...
         'tcGamma' 'ctMua' 'ctLfp' 'ctLfpL' 'ctLfpM' 'ctLfpH' ...
         'pLfpL' 'pLfpM' 'pLfpH' 'pMua' 'pSdf'}
    
    if iExp == 1,
	  oSig = Sig;
      for K = 1:length(oSig), oSig{K}.ExpNo = grp.exps;  end;
	else
      for K = 1:length(oSig),
        if length(Sig{K}.dat) > length(oSig{K}.dat),
          if length(size(Sig{K}.dat)) == 2,
            Sig{K}.dat = Sig{K}.dat(1:length(oSig{K}.dat),:);
          elseif length(size(Sig{K}.dat)) == 3,
            Sig{K}.dat = Sig{K}.dat(1:length(oSig{K}.dat),:,:);
          end;
        elseif length(Sig{K}.dat) < length(oSig{K}.dat),
          l = zeros(length(oSig{K}.dat)-length(Sig{K}.dat),size(Sig{K}.dat,2));
          Sig{K}.dat = cat(1,Sig{K}.dat,l);
        end
        oSig{K}.dat = cat(3,oSig{K}.dat,Sig{K}.dat);
      end;
    end;
	
   case 'Spkt',			% Spikes
                        % ================================
    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig), oSig{K}.ExpNo = grp.exps;  end
      LEN = size(Sig{1}.dat, 1);
    else
      for K = 1:length(oSig),
		if size(Sig{K}.dat,1) > LEN,
		  Sig{K}.dat = Sig{K}.dat(1:LEN,:,:);
		elseif size(Sig{K}.dat,1) < LEN,
		  DLEN = LEN-size(Sig{K}.dat,1);
		  Sig{K}.dat = cat(1,Sig{K}.dat,...
						   repmat(Sig{K}.dat(end,:,:),[DLEN 1 1]));
		end;
		oSig{K}.dat = cat(DIM,oSig{K}.dat,Sig{K}.dat);
		oSig{K}.times = cat(2,oSig{K}.times,Sig{K}.times);
	  end;
	end;

   case Ses.ctg.GrpDEPSigs   % DEPENDENCE SIGNALS
                             % ==================================
    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig),
        oSig{K}.ExpNo = grp.exps;
      end
    else
      for K = 1:length(oSig),
        tmpdat = Sig{K}.dat;
        tmperr = Sig{K}.err;
		tmporigdat  = Sig{K}.origdat;
		if isfield(Sig{K},'elepos')
		  tmpdist     = Sig{K}.dist;
		  tmpchanpairs= Sig{K}.chanpairs;
		  tmpelepos   = Sig{K}.elepos;
		end
        oSig{K}.dat       = cat(3,oSig{K}.dat,tmpdat);
        oSig{K}.err       = cat(3,oSig{K}.err,tmperr);
		oSig{K}.origdat   = cat(3,oSig{K}.origdat,tmporigdat);
		if isfield(Sig{K},'elepos'),
          oSig{K}.dist      = cat(3,oSig{K}.dist,tmpdist);
          oSig{K}.chanpairs = cat(3,oSig{K}.chanpairs,tmpchanpairs);
          oSig{K}.elepos    = cat(3,oSig{K}.elepos,tmpelepos);
        end
      end
    end
    
   case { 'Spktblp', 'SpktCln', 'Brsttblp', 'BrsttCln',...
          'atSpktblp', 'atSpktCln', 'atBrsttblp', 'atBrsttCln' }
    % spike triggered average of 'blp' or 'Cln'
    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig),  oSig{K}.ExpNo = grp.exps;  end
    else
      for K = 1:length(oSig),
        oSig{K}.dat   = oSig{K}.dat   + Sig{K}.dat;
        oSig{K}.spc   = oSig{K}.spc   + Sig{K}.spc;
        oSig{K}.nspk  = oSig{K}.nspk  + Sig{K}.nspk;
        oSig{K}.spkHz = oSig{K}.spkHz + Sig{K}.spkHz;
        if isfield(oSig{K},'shuffled') & ~isempty(oSig{K}.shuffled),
          oSig{K}.shuffled.dat   = oSig{K}.shuffled.dat   + Sig{K}.shuffled.dat;
          oSig{K}.shuffled.spc   = oSig{K}.shuffled.spc   + Sig{K}.shuffled.spc;
          oSig{K}.shuffled.nspk  = oSig{K}.shuffled.nspk  + Sig{K}.shuffled.nspk;
          oSig{K}.shuffled.spkHz = oSig{K}.shuffled.spkHz + Sig{K}.shuffled.spkHz;
        end
      end
    end
    if iExp == length(EXPS),
      for K = 1:length(oSig),
        oSig{K}.dat   = oSig{K}.dat   / length(EXPS);
        oSig{K}.spc   = oSig{K}.spc   / length(EXPS);
        oSig{K}.nspk  = oSig{K}.nspk  / length(EXPS);
        oSig{K}.spkHz = oSig{K}.spkHz / length(EXPS);
        if isfield(oSig{K},'shuffled') & ~isempty(oSig{K}.shuffled),
          oSig{K}.shuffled.dat   = oSig{K}.shuffled.dat   / length(EXPS);
          oSig{K}.shuffled.spc   = oSig{K}.shuffled.spc   / length(EXPS);
          oSig{K}.shuffled.npsk  = oSig{K}.shuffled.nspk  / length(EXPS);
          oSig{K}.shuffled.spkHz = oSig{K}.shuffled.spkHz / length(EXPS);
        end
      end;
    end;
    
   case { 'VMua3', 'VLfpH3' 'VSdf3' }
    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig),  oSig{K}.ExpNo = grp.exps;  end
    else
      for K = 1:length(oSig),
        oSig{K}.dat = oSig{K}.dat + Sig{K}.dat;
      end
      if iExp == length(EXPS),
        for K = 1:length(oSig),
          oSig{K}.dat = oSig{K}.dat / length(EXPS);
        end
      end
    end
   otherwise,
    fprintf(' CATSIG: Unknown Signal\n');
    return;
  end;
end;
fprintf(' done.\n');

