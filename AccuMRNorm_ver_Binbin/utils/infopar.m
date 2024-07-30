function info = infopar(SesName,GrpName,FieldName)
%INFOPAR - Display Group Parameters (stim/acquisition)
% INFOPAR (SESSION,ExpNo,FieldName) displays stimulus related information.
%
% Possible Fields in the INFO structure
%
%       session: 'j02cq1'
%        grpname: 'estim3'
%         refgrp: 'estim3'
%           exps: [8 9 10 11]
%          scans: [29 30 31 32]
%      condition: {'bicuculline recovery'}
%         grproi: 'RoiDef'
%       roinames: {'Brain'  'LGN'  'SC'  'Pul'  'V1'  'V2'  'MT'  'XC'}
%        stminfo: 'microstim biph-500Hz-250uA + bicuculline'
%      trialreps: 15
%     triallabel: 'stat(1).tria(1).Xmet(perc).Xepo(blan).sort(tria).RefC(2).Aver(1)'
%      trialpars: [1x1 struct]
%     trialtypes: 1
%      triallist: 'biph=500Hz-250uA(0 1 0 /4 4 12 )'
%         trials: {[1x1 struct]}
%         hemodt: [2 2]
%            img: [1x1 struct]
%         glmgrp: 'before glm'
%         glmreg: {'hemo'  'fhemo'}
%        glmcont: {'fVal'  'pbr'  'nbr'}
%      glmmatrix: {'all'  '1 1 0 '  '-1 -1 0 '}
%        glmpval: [0.1000 1 1]
%
% NKL 09.07.2007
%  
%  See also
%       EXPMKMODEL SESPAR GETANAP GETGRP
%

if nargin < 1, eval(sprintf('help %s;',mfilename)); return;  end
if nargin < 3, FieldName = []; end;

Ses = goto(SesName);

if ~exist('GrpName') | isempty(GrpName),
  grps = getgrpnames(Ses);
else
  grps = GrpName;
end;

if ischar(grps),
  grps = {grps};
end;

for N=1:length(grps),
  tmp = subGetInfo(Ses, grps{N});
  if isempty(FieldName),
    info{N} = tmp;
  else
    eval(sprintf('info{N} = tmp.%s;',FieldName));
  end;    
end;
if length(info)==1,
  info=info{1};
end;

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = subGetInfo(SesName,ExpNo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VERBOSE = 0; % Display only absolutely necessary info

Ses = goto(SesName);

if nargin < 2,
  s = load('SesPar.mat');
  sn = fieldnames(s);
  for N=1:length(sn),
    eval(sprintf('tmp = s.%s;', sn{N}));
    tmp.stm.stmtypes
  end;
  return;
end;

if ischar(ExpNo),
  grp = getgrpbyname(Ses,ExpNo);
  ExpNo = grp.exps(1);
end;

grp = getgrp(Ses,ExpNo);
anap = getanap(Ses,ExpNo);
par = expgetpar(Ses,ExpNo);

if isempty(grp),
  error('\nERROR %s: no group for ExpNo=%d.\n',mfilename,ExpNo);
end

if VERBOSE,
  fprintf('=========================================================\n');
  fprintf('SESSION: %s  ExpNo:%d(%s)\n',Ses.name,ExpNo,grp.name);
  fprintf('=========================================================\n');
  
  % PRINTS STIMULUS INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  stm = par.stm;
  
  STMFILE = 'none';  PDMFILE = 'none';  RFPFILE = 'none';
  if grp.daqver >= 2,
    if isfield(Ses.expp(ExpNo),'physfile') & ~isempty(Ses.expp(ExpNo).physfile),
      STMFILE = expfilename(Ses,ExpNo,'stm');
      PDMFILE = expfilename(Ses,ExpNo,'pdm');
      RFPFILE = expfilename(Ses,ExpNo,'rfp');
    elseif isfield(Ses.expp(ExpNo),'dgzfile') & ~isempty(Ses.expp(ExpNo).dgzfile),
      STMFILE = expfilename(Ses,ExpNo,'stm');
      PDMFILE = expfilename(Ses,ExpNo,'pdm');
      RFPFILE = expfilename(Ses,ExpNo,'rfp');
    end
  end
  
  fprintf(' STMFILE: %s\n',STMFILE);
  fprintf(' PDMFILE: %s\n',PDMFILE);
  fprintf(' RFPFILE: %s\n',RFPFILE);
  
  fprintf('Note: RFPFILE may not be saved, since it is up to the experimenter.\n');
  fprintf('      As default it is (session).rfp, but you can set as GRP.xxx.rfpfile.\n');

  fprintf('\n=========================================================\n');
  fprintf('Detailed Timing of Current Stimulation Protocol\n');
  fprintf('=========================================================\n');
end;



if ~anap.gettrial.status,
  tmp = expgetstm(Ses,ExpNo);
  fprintf('Label: ');
  for N=1:length(tmp.labels)
    fprintf('%s.', tmp.labels{N});
  end;
  fprintf('\nNTrial: %d\n', tmp.ntrials);
  
  fprintf('Label: ');
  for N=1:length(tmp.labels)
    fprintf('%s.', tmp.stmtypes{N});
  end;
  fprintf('\nVoldt: %3.2f\n', tmp.voldt);
  
  for N=1:length(tmp.val),
    fprintf('Values: ');
    fprintf('%d ', tmp.val{N});
    fprintf('\nDT (sec): ');
    fprintf('%d ', tmp.dt{N});
    fprintf('\nTimes (sec): ');
    fprintf('%d ', tmp.t{N});
  end;
  fprintf('\n');
  return;
end;

% GROUP PARAMETERS
%          name: 'estim1'
%     condition: {'normal'}
%         label: {'biph=500Hz-250uA'}
%          exps: [1 2 3 4]
%        grproi: 'RoiDef'
%      roinames: {'Brain'  'LGN'  'SC'  'Pul'  'V1'  'V2'  'MT'  'XC'}
%       expinfo: {2x1 cell}
%       stminfo: 'microstim biph-500Hz-250uA'
%          anap: gettrial
%          anap: mareats
%        refgrp: [1x1 struct]
%     HemoDelay: 2
%      HemoTail: 2
%      groupglm: 'before glm'
%        glmana: {[1x1 struct]}
%      glmconts: {[1x1 struct]  [1x1 struct]  [1x1 struct]}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET IMAGE PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pv = par.pvpar;
% PV.ACQP structure:
%              EPI_TE_eff: 14.5000
%                            EPI_nr: 150
%                 EPI_zero_phase_ms: 4.6080
%                  EPI_seg_acq_time: 23.0400
%                EPI_slice_rep_time: 41
%                EPI_image_rep_time: 500
%TE = pv.acqp.EPI_TE_eff;
%TR = pv.acqp.EPI_image_rep_time;
TE = pv.effte * 1000;
TR = pv.segtr * 1000;

for N=1:length(grp.exps),
  p = expgetpar(Ses,grp.exps(N));
  scans(N) = p.pvpar.reco.expno;
end;

img.TE = TE;
img.TR = TR;
if isfield(pv,'fa'),
  img.FA = pv.fa;
else
  img.FA = 30;
end;

img.dims = [pv.nx pv.ny pv.nsli pv.nt];
img.fov = pv.fov;
img.res = [pv.res pv.slithk];
img.seg = pv.nseg;
img.voldx = pv.imgtr;

imgpar = sprintf('TE/TR=%.1f/%d msec, FA=%d deg', TE,TR,img.FA);
fov = sprintf('FOV=[%dx%d]mm',img.fov);
dims = sprintf('M=[%dx%dx%d]',img.dims(1:3));
res = sprintf('Vox=[%.2fx%.2f]mm, Slice: %dmm', img.res(1:2), img.res(3));
volt = sprintf('Vol TR = %dmsec', 1000*img.voldx);
img.descr = sprintf('%s, %s, %s, %s, %s', imgpar, fov, dims, res, volt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET GENERAL GROUP PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info.session = Ses.name;
info.grpname = grp.name;
info.refgrp = grp.refgrp.grpexp;
info.exps = grp.exps;
info.scans = scans;
info.condition = grp.condition;
info.grproi = grp.grproi;
info.sesrois = Ses.roi.names;
if isfield(grp,'roinames'),
  info.grprois = grp.roinames;
else
  info.grprois = info.sesrois;
end;
info.stminfo = grp.stminfo;
info.trialreps = par.stm.ntrials;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET GENERAL GROUP PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nam = fieldnames(anap.gettrial);
for N=1:length(nam),
  x = getfield(anap.gettrial,nam{N});
  if ischar(x),
    tmp = sprintf('%s(%s)',nam{N}(1:4),x(1:4));
  else
    tmp = sprintf('%s(%d)',nam{N}(1:4),x);
  end;
  if N==1,
    txt = tmp;
  else
    txt = strcat(txt,'.',tmp);
  end
end
info.triallabel = txt;
info.trialpars = anap.gettrial;
info.trialtypes = 0;

info.triallist = '';
info.trials = {};

if ~isfield(grp,'HemoDelay'),
  grp.HemoDelay = anap.HemoDelay;
  grp.HemoTail = anap.HemoTail;
end;
  
info.hemodt = [grp.HemoDelay grp.HemoTail];
info.img = img;

info.glmgrp = grp.groupglm;
for N=1:length(grp.glmana),
  info.glmreg{N} = grp.glmana{N}.mdlsct;
end;
if length(info.glmreg) == 1,
  info.glmreg = info.glmreg{1};
end;

for N=1:length(grp.glmconts),
  info.glmcont{N} = grp.glmconts{N}.name;
  if N==1,
    info.glmmatrix{N} = 'all';
  else
    info.glmmatrix{N} = sprintf('%d ',grp.glmconts{N}.contrastmatrix);
  end;
  info.glmpval(N) = grp.glmconts{N}.pVal;
end;

mdl = expmkmodel(Ses,ExpNo,grp.glmana{1}.mdlsct{1},...
                 'HemoDelay',grp.HemoDelay,'HemoTail',grp.HemoTail);

mdl = gettrial(mdl);
if isstruct(mdl),
  mdl = {mdl};
end;

info.trialtypes = length(mdl);

%      labels: {'obsp1'}
%      ntrials: 1
%     stmtypes: {'blank'  'tactile'  'blank'}
%        voldt: 0.2500
%            v: {[0 1 2]}
%          val: {[0 1 0]}
%           dt: {[5 45 10]}
%            t: {[0 5 50 60]}
%         tvol: {[0 20 200 240]}
%         time: {[0.0250 5.0230 50.0460]}
%         date: 'Thu Aug 10 22:23:27 2006'
%      stmpars: [1x1 struct]
%      pdmpars: [1x1 struct]
%      hstpars: [1x1 struct]
for N=1:length(mdl),
  info.trials{N}.label = mdl{N}.stm.labels;
  info.trials{N}.epochs = mdl{N}.stm.stmtypes;
  info.trials{N}.dt = mdl{N}.stm.voldt;
  info.trials{N}.v = mdl{N}.stm.v;
  info.trials{N}.val = mdl{N}.stm.val;
  info.trials{N}.dt = mdl{N}.stm.dt;
  info.trials{N}.t = mdl{N}.stm.t;
  info.trials{N}.time = mdl{N}.stm.time;
  tr1 = sprintf('%d ', info.trials{N}.val{1});
  tr2 = sprintf('%d ', info.trials{N}.dt{1});
  tmp = sprintf('%s(%s/%s)', info.trials{N}.label{1},tr1,tr2);
  if N==1,
    lst = tmp;
  else
    lst = catstr(lst,'.',tmp);
  end;
  if length(mdl)>1,
    lst = catstr(lst,'||');
  end
end;
info.triallist = lst;



% 14.08.07 YM: Get microstimulation info from STM/PDM
stmpars = par.stm.stmpars;
pdmpars = par.stm.pdmpars;
tmpobj  = [];
for N=1:length(stmpars.stmobj),
  if strcmpi(stmpars.stmobj{N}.type,'microstim'),
    tmpobj = stmpars.stmobj{N};
    tmpobj = rmfield(tmpobj,{'eye','xsize','ysize','xpos','ypos','ori'});
    % update values by PDM
    for K=1:length(pdmpars.prmNames),
      switch lower(pdmpars.prmNames{K}),
       case {'pulsedur'}
        tmpobj.pulsedur = pdmpars.prmVars{K};
       case {'freq'}
        tmpobj.freq     = pdmpars.prmVars{K};
       case {'current'}
        tmpv = pdmpars.prmVars{K};
        idx = find(tmpv > 0);
        if ~isempty(idx),  tmpv = tmpv(idx);  end
        tmpobj.current  = tmpv;
       case {'pulseon'}
        tmpobj.pulseon  = pdmpars.prmVars{K};
       case {'pulseoff'}
        tmpobj.pulseoff = pdmpars.prmVars{K};
       case {'config','contrast'}
        % do nothing.
        %continue;
       otherwise
        fprintf('%s: unknown PDM par ''%s''\n',mfilename,pdmpars.prmNames{K});
      end
    end
    % get stimulus duration
    tmpobj.dur = [];
    for K=1:length(stmpars.StimIDs),
      if any(stmpars.StimIDs{K} == N-1),
        tmpobj.dur(end+1) = stmpars.StimDurations(K) * par.stm.voldt;
      end
    end
    break;
  end
end
info.microstim = tmpobj;
%if VERBOSE & ~isempty(tmpobj),
if 1,
  fprintf(' dur:');      fprintf(' %g',tmpobj.dur);       fprintf('sec');
  fprintf(' pulsedur:');  fprintf(' %g',tmpobj.pulsedur);  fprintf('usec');
  fprintf(' freq:');      fprintf(' %g',tmpobj.freq);      fprintf('Hz');
  fprintf(' current:');   fprintf(' %g',tmpobj.current);   fprintf('uA');
  fprintf(' pulseon:');   fprintf(' %g',tmpobj.pulseon);   fprintf('usec');
  fprintf(' pulseoff:');  fprintf(' %g',tmpobj.pulseoff);  fprintf('usec');
  fprintf('\n');
end


return;
