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
  elseif any(strcmpi(SigName,{'Spktblp','SpktCln','Brsttblp','BrsttCln',...
                        'SpktGamma','SpktLfp','BrsttGamma','BrsttLfp'})), EXT = SigName;
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
    
   case { 'tblp','blp'},
    if iExp == 1,
      oSig = Sig;
      DIM = length(size(Sig{1}.dat))+1;
      for K = 1:length(oSig),  oSig{K}.ExpNo = grp.exps;  end;
    else
      for K = 1:length(oSig),
        if size(oSig{K}.dat,1) > size(Sig{K}.dat,1),
          oSig{K}.dat = oSig{K}.dat(1:size(Sig{K}.dat,1),:,:,:);
          if isfield(oSig{K},'org'),
            oSig{K}.org = oSig{K}.org(1:size(Sig{K}.org,1),:,:,:);
          end;
        elseif size(oSig{K}.dat,1) < size(Sig{K}.dat,1),
          Sig{K}.dat = Sig{K}.dat(1:size(oSig{K}.dat,1),:,:,:);
          if isfield(oSig{K},'org'),
            Sig{K}.org = Sig{K}.org(1:size(oSig{K}.org,1),:,:,:);
          end;
        end
        oSig{K}.dat = cat(DIM,oSig{K}.dat,Sig{K}.dat);
        if isfield(oSig{K},'org'),
          oSig{K}.org = cat(DIM,oSig{K}.org,Sig{K}.org);
        end;
      end;
    end;
    
   case {'troiTs'}
    % .r/.p will be filled with 0/1 if it is not selected.
    if ~isempty(RoiNames), Sig = mroitsget(Sig,[],RoiNames); end
    anap = getanap(Ses,ExpNo);
    
    Pthr = 0.15;
    Rthr = 0.01;

    if iExp == 1,
      % Initialize all fields with the first roiTs; Set group-experiments
      oSig = Sig;
      for RoiNo = 1:length(oSig),
        for TrialNo = 1:length(oSig{RoiNo}),
          oSig{RoiNo}{TrialNo}.ExpNo = grp.exps;
          for M = 1:length(oSig{RoiNo}{TrialNo}.r),
            tmpidx = (oSig{RoiNo}{TrialNo}.r{M} > Rthr) & (oSig{RoiNo}{TrialNo}.p{M} < Pthr);
            ORSEL{RoiNo}{TrialNo}{M} = tmpidx;
          end
        end;
      end;
    else
      % Keep adding data fields to obtain the average in the last experiment
      for R = 1:length(oSig), % R == RoiNo,
        for T = 1:length(oSig{R}), % T == TrialNo,
          oSig{R}{T}.dat = oSig{R}{T}.dat + Sig{R}{T}.dat;
          for M = 1:length(oSig{R}{T}.r),
            oSig{R}{T}.r{M} = oSig{R}{T}.r{M} + Sig{R}{T}.r{M};
            oSig{R}{T}.p{M} = oSig{R}{T}.p{M} + Sig{R}{T}.p{M};
            tmpidx = (Sig{R}{T}.r{M} > Rthr) & (Sig{R}{T}.p{M} < Pthr);
            ORSEL{R}{T}{M} = ORSEL{R}{T}{M} | tmpidx;
          end
        end;
      end;
    end;

    if iExp == length(EXPS),
      for R = 1:length(oSig),
        for T = 1:length(oSig{R}),
          oSig{R}{T}.dat = oSig{R}{T}.dat / length(EXPS);
          for M=1:length(oSig{R}{T}.r),
            oSig{R}{T}.r{M} = oSig{R}{T}.r{M} / length(EXPS);
            oSig{R}{T}.p{M} = oSig{R}{T}.p{M} / length(EXPS);
            tmpidx = find(ORSEL{R}{T}{M} == 0);
            oSig{R}{T}.r{M}(tmpidx) = 0;
            oSig{R}{T}.p{M}(tmpidx) = 1;
          end;
        end;
      end;
    end;
    
   case {'roiTs'}
    %%%%%%%%%%%??????????????????????????? HERE WE ARE
    % DEFAULT IS EMPTY (all ROIs)
    if ~isempty(RoiNames), Sig = mroitsget(Sig,[],RoiNames); end
    if iExp == 1,
      oSig = Sig; for K = 1:length(oSig), oSig{K}.ExpNo = grp.exps; end;
      for M = 1:length(oSig{RoiNo}{TrialNo}.r),
        tmpidx = (oSig{RoiNo}.r{M} > Rthr) & (oSig{RoiNo}.p{M} < Pthr);
        ORSEL{RoiNo}{M} = tmpidx;
      end
    else
      for R = 1:length(oSig), oSig{R}.dat = oSig{R}.dat + Sig{R}.dat; end;
      tmpidx = (Sig{R}.r{M} > Rthr) & (Sig{R}.p{M} < Pthr);
      ORSEL{R}{M} = ORSEL{R}{M} | tmpidx;
    end;
    if iExp == length(EXPS),
      for R = 1:length(oSig),
        oSig{R}.dat = oSig{R}.dat / length(EXPS);
        tmpidx = find(ORSEL{R}{T}{M} == 0);
        oSig{R}{T}.r{M}(tmpidx) = 0;
        oSig{R}{T}.p{M}(tmpidx) = 1;
      end;
    end;

    
   case {'pcaTs','pcasTs','plsTs','plssTs','pls2Ts','mrsTs'} % Time series of ROIs
    % DEFAULT IS EMPTY (all ROIs)
    if ~isempty(RoiNames),
      Sig = mroitsget(Sig,[],RoiNames);
    end

    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig),       % For all ROIs
        oSig{K}.ExpNo = grp.exps;
      end;
      DIM = ndims(Sig{1}.dat)+1;
    else
      
      for K = 1:length(oSig),
        oSig{K}.dat = cat(DIM,oSig{K}.dat,Sig{K}.dat);
        oSig{K}.coords = cat(1,oSig{K}.coords,Sig{K}.coords);
        
        for ModelNo=1:length(oSig{K}.r),
          % ---------------------------------------------------------
          % NKL 31.12.2005
          % DO NOT CHANGE THE CAT DIM WITHOUT TALKING WITH ME
          % ---------------------------------------------------------
          oSig{K}.r{ModelNo} = cat(1,oSig{K}.r{ModelNo},Sig{K}.r{ModelNo});
          if isfield(oSig{K},'p'),
            oSig{K}.p{ModelNo} = cat(1,oSig{K}.p{ModelNo},Sig{K}.p{ModelNo});
          end;
          if isfield(oSig{K},'f'),
            oSig{K}.f{ModelNo}    = cat(1,oSig{K}.f{ModelNo},Sig{K}.f{ModelNo});
          end;
          if isfield(oSig{K},'rcos'),
            oSig{K}.rcos{ModelNo} = cat(1,oSig{K}.rcos{ModelNo},Sig{K}.rcos{ModelNo});
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
          'atSpktblp', 'atSpktCln', 'atBrsttblp', 'atBrsttCln',...
        'SpktGamma','SpktLfp','BrsttGamma','BrsttLfp'}
    % spike triggered average of 'blp' or 'Cln'
    if iExp == 1,
      oSig = Sig;
      for K = 1:length(oSig),
        oSig{K}.ExpNo = grp.exps;
        oSig{K}.var = oSig{K}.dat .^2;
        if isfield(oSig{K},'shuffled') & ~isempty(oSig{K}.shuffled),
          oSig{K}.shuffled.var = oSig{K}.shuffled.dat .^2;
        end
      end
    else
      for K = 1:length(oSig),
        if size(oSig{K}.dat,1) > size(Sig{K}.dat,1),
          Sig{K}.dat(end+1:size(oSig{K}.dat,1),:,:,:,:) = 0;
          Sig{K}.shuffled.dat(end+1:size(oSig{K}.dat,1),:,:,:,:) = 0;
        elseif size(oSig{K}.dat,1) < size(Sig{K}.dat,1),
          Sig{K}.dat = Sig{K}.dat(1:size(oSig{K}.dat,1),:,:,:,:);
          Sig{K}.shuffled.dat = Sig{K}.shuffled.dat(1:size(oSig{K}.dat,1),:,:,:,:);
        end
        oSig{K}.dat   = oSig{K}.dat   + Sig{K}.dat;
        oSig{K}.spc   = oSig{K}.spc   + Sig{K}.spc;
        oSig{K}.nspk  = oSig{K}.nspk  + Sig{K}.nspk;
        oSig{K}.spkHz = oSig{K}.spkHz + Sig{K}.spkHz;
        oSig{K}.var   = oSig{K}.var + Sig{K}.dat .^2;
        
        if isfield(oSig{K},'shuffled') & ~isempty(oSig{K}.shuffled),
          oSig{K}.shuffled.dat   = oSig{K}.shuffled.dat   + Sig{K}.shuffled.dat;
          oSig{K}.shuffled.spc   = oSig{K}.shuffled.spc   + Sig{K}.shuffled.spc;
          oSig{K}.shuffled.nspk  = oSig{K}.shuffled.nspk  + Sig{K}.shuffled.nspk;
          oSig{K}.shuffled.spkHz = oSig{K}.shuffled.spkHz + Sig{K}.shuffled.spkHz;
          oSig{K}.shuffled.var   = oSig{K}.shuffled.var + Sig{K}.shuffled.dat.^2;
        end
      end
    end
    if iExp == length(EXPS),
      for K = 1:length(oSig),
        oSig{K}.dat   = oSig{K}.dat   / length(EXPS);
        oSig{K}.spc   = oSig{K}.spc   / length(EXPS);
        oSig{K}.nspk  = oSig{K}.nspk  / length(EXPS);
        oSig{K}.spkHz = oSig{K}.spkHz / length(EXPS);
        oSig{K}.var=(oSig{K}.var/length(EXPS) - oSig{K}.dat.^2) * length(EXPS) / (length(EXPS)-1);
        if isfield(oSig{K},'shuffled') & ~isempty(oSig{K}.shuffled),
          oSig{K}.shuffled.dat   = oSig{K}.shuffled.dat   / length(EXPS);
          oSig{K}.shuffled.spc   = oSig{K}.shuffled.spc   / length(EXPS);
          oSig{K}.shuffled.npsk  = oSig{K}.shuffled.nspk  / length(EXPS);
          oSig{K}.shuffled.spkHz = oSig{K}.shuffled.spkHz / length(EXPS);
          oSig{K}.shuffled.var   = (oSig{K}.shuffled.var/length(EXPS)...
                                    - oSig{K}.shuffled.dat.^2)*length(EXPS)/(length(EXPS)-1);
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

