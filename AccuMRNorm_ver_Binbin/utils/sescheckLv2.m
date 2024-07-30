function IsOK = sescheckLv2(Ses,EXPS)
%SESCHECKLV2 - Check the data length of SES/EXPNO
%  SESCHECKLV2(SES)
%  SESCHECKLV2(SES,EXPS)
%  SESCHECKLV2(SES,GRPNAME) checks data length of 2dseq/dgz/adf
%
%  VERSION : 
%    0.90 29.04.04 YM  first release
%    0.91 17.07.13 YM  uses expfilename() instead of catfilename().
%
%  See also SESCHECK, SESDUMPPAR, EXPFILENAME

if nargin == 0,  help sescheckLv2;  return;  end

if ischar(Ses),  Ses = getses(Ses);  end
if ~exist('EXPS','var'),  EXPS = validexps(Ses);  end

if ischar(EXPS),
  grp = getgrp(Ses,EXPS);
  EXPS = grp.exps;
end

%IsOK = zeros(1,length(EXPS));
IsOK = 0;


fprintf('sescheckLv2: %s\n',Ses.name);

% check anatomy scan
if isfield(Ses,'ascan') & ~isempty(Ses.ascan),
  fnames = fieldnames(Ses.ascan);
  for N = 1:length(fnames),
    eval(sprintf('scan = Ses.ascan.%s;',fnames{N}));
    fprintf(' ASCAN.%s:',fnames{N});
    for K = 1:length(scan),
      fprintf(' %d.',K);
      pvpar = getpvpars(Ses,fnames{N},K);
      if ~subCheckImgcrop(scan{K},pvpar),
        fprintf('\n ASCAN.%s{%d}.scanreco = [%d %d]\n',...
                fnames{N},K,scan{K}.scanreco(1),scan{K}.scanreco(2));
        return;
      end
      if pvpar.nt ~= 1,
        fprintf(' Warning: %s{%d}=%dvols\n',fnames{N},K,pvpar.nt);
      end
    end
    fprintf(' OK.\n');
  end
end

% check epi13
if isfield(Ses,'cscan') & isfield(Ses.cscan,'epi13'),
  fprintf(' CSCAN.epi13:');
  for N = 1:length(Ses.cscan.epi13),
    fprintf(' %d.',N);
    scan = Ses.cscan.epi13{N};
    pvpar = getpvpars(Ses,'epi13',N);
    if ~subCheckImgcrop(scan,pvpar),
      fprintf('\n CSCAN.epi13{%d}.scanreco = [%d %d]\n',...
              N,scan.scanreco(1),scan.scanreco(2));
      return;
    end
    if pvpar.nt == 1,
      fprintf(' Warning: epi13{%d}=%dvols ',N,pvpar.nt);
    end
  end
  fprintf(' OK.\n');
end


% check individual groups.
grpnames = fieldnames(Ses.grp);

for N = 1:length(grpnames),
  eval(sprintf('grp = Ses.grp.%s;',grpnames{N}));
  grp.name = grpnames{N};
  fprintf(' GRP.%s:',grp.name);

  if isfield(grp,'catexps'), continue;  end
  
  % data info
  pvpar = {};  evt = {};  adf = {};  stmpar = {};
  
  for K = 1:length(grp.exps),
    ExpNo = grp.exps(K);
    fprintf(' %d',ExpNo);
    % imaging stuff
    if isimaging(grp),
      ExpNo = grp.exps(K);
      pvpar{K} = getpvpars(Ses,ExpNo);
      if ~subCheckImgcrop(grp,pvpar{K}),
        fprintf('\n EXPP(%d).scanreco = [%d %d]\n',...
                ExpNo,Ses.expp(ExpNo).scanreco(1),Ses.expp(ExpNo).scanreco(2));
        return;
      end
    end
    % recording stuff
    if isrecording(grp),
      % set event
      dg = dg_read(expfilename(Ses,grp.exps(K),'dgz'));
      evt{K}.nobs   = length(dg.e_types);
      evt{K}.obslen = zeros(1,evt{K}.nobs);
      evt{K}.mri    = cell(1,evt{K}.nobs);
      for Obs = 1:evt{K}.nobs,
        % 19 as E_BEGINOBS
        % 20 as E_ENDOBS
        % 46 as E_MRI
        idx = find(dg.e_types{Obs} == 20);
        evt{K}.obslen(Obs) = dg.e_times{Obs}(idx) / 1000.;  % in sec
        idx = find(dg.e_types{Obs} == 46);
        evt{K}.mri{Obs}    = dg.e_times{Obs}(idx) / 1000.;  % in sec
      end
      % set "adf"
      [nchan nobs sampt obslens] = adf_info(expfilename(Ses,ExpNo,'phys'));
      adf{K}.nchan  = nchan;
      adf{K}.nobs   = nobs;
      adf{K}.dx     = sampt/1000.;       % in sec
      adf{K}.obslen = obslens(:)' * adf{K}.dx;  % in sec

      % now check obsp length, between EVT/ADF
      if ~isfield(grp,'validobsp') | isempty(grp.validobsp),
        if ~subCheckObspLen(evt{K},adf{K}),
          fprintf('\n EXPP(%d).physfile = ''%s''.\n',ExpNo,Ses.expp(ExpNo).physfile);
          return
        end
      end
    end
  end

  fprintf('  OK.\n');
end

IsOK = 1;
fprintf('sescheck2Lv2 done.\n');


return;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checks imgcrop with pvpar
function IsOK = subCheckImgcrop(info,pvpar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IsOK = 1;

if ~isfield(info,'imgcrop') | isempty(info.imgcrop),
  return;
end


if info.imgcrop(1) + info.imgcrop(2) -1 > pvpar.nx,
  fprintf('\nERROR: imgcrop(1)+imgcrop(2)-1 exceeds %d.',pvpar.nx);
  IsOK = 0;
end
if info.imgcrop(2) + info.imgcrop(4) -1 > pvpar.ny,
  fprintf('\nERROR: imgcrop(2)+imgcrop(4)-1 exceeds %d.',pvpar.ny);
  IsOK = 0;
end

if IsOK == 0,
  fprintf('\n imgcrop = ['); fprintf(' %d',info.imgcrop); fprintf(']');
  fprintf('\n 2dseq nx=%d,ny=%d,nslice=%d,nt=%d',...
          pvpar.nx,pvpar.ny,pvpar.nsli,pvpar.nt);
  return;
end
  
return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checks obsp length of dgz/adf
function IsOK = subCheckObspLen(evt,adf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IsOK = 1;

if evt.nobs ~= adf.nobs,
  fprintf('\nERROR: nobs[%d!=%d]',evt.nobs,adf.nobs);
  IsOK = 0;
else
  dlens = abs((adf.obslen - evt.obslen)./evt.obslen*100.);
  if ~isempty(find(dlens > 0.1)),
    fprintf('\nERROR: significant difference of obsp[%.2f%%]',max(dlens));
  end
end

if IsOK == 0,
  fprintf('\n dgz:');  fprintf(' %.3f',evt.obslen); fprintf('\n');
  fprintf('\n adf:');  fprintf(' %.3f',adf.obslen); fprintf('\n');
end

return
