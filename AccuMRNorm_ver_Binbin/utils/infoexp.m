function s = infoexp(SESSION,EXPS)
%INFOEXP - Displays exp/grp information (protocol, physiology & MR parameters)
% INFOEXP (SESSION,EXPS) displays information regarding an
% experiment by looking into both the expp and the grp structures.
%
%      daqver: 2
%       expinfo: {'imaging'  'stimulation'  'recording'}
%        hwinfo: ''
%        hardch: 1
%        softch: []
%        grproi: 'RoiDef'
%       grpsigs: {'troiTs'}
%          anap: [1x1 struct]
%      groupcor: 'before cor'
%        corana: {[1x1 struct]  [1x1 struct]  [1x1 struct]}
%      groupglm: 'before glm'
%        glmana: {[1x1 struct]}
%      glmconts: {[1x1 struct]  [1x1 struct]  [1x1 struct]}
%          exps: 1
%       stminfo: '0.5mA, 10Hz (4/4/16 sec)x10'
%     condition: {'normal'}
%         label: {'default epi'}
%        refgrp: [1x1 struct]
%           ana: {3x1 cell}
%       imgcrop: [14 7 36 56]
%          name: 'estim1'
%      physfile: 'ratRq1_001.adfw'
%      scanreco: [6 1]
%
% NKL, 10.10.00; 12.04.04

if nargin < 2,
  help infoexp;
  return;
end;

Ses = goto(SESSION);
if ischar(EXPS),
  grp = getgrpbyname(Ses,EXPS);
  EXPS = grp.exps;
end;

for ExpNo = 1:length(EXPS),
  sc = Ses.expp(EXPS(ExpNo)).scanreco(1);
  grp = getgrp(Ses, EXPS(ExpNo));
  par = expgetpar(Ses,EXPS(ExpNo));
  pv = par.pvpar;
  TE = pv.effte * 1000;
  TR = pv.segtr * 1000;
  if isfield(pv,'fa'),
    imgFA = pv.fa;
  else
    fprintf('WARNING: No flip angle value was found - assuming 30 deg\n');
    imgFA = 30;
  end;

  img{ExpNo}.sesname = SESSION;
  img{ExpNo}.grpname = grp.name;
  img{ExpNo}.ExpNo = EXPS(ExpNo);
  img{ExpNo}.sc = sc;
  img{ExpNo}.stminfo = grp.stminfo;
  img{ExpNo}.TE = TE;
  img{ExpNo}.TR = TR;
  img{ExpNo}.FA = imgFA;
  img{ExpNo}.dims = sprintf('<%3d %3d %2d %3d>',pv.nx, pv.ny, pv.nsli, pv.nt);
  img{ExpNo}.fov = sprintf('<%3d,%3d>', pv.fov);
  img{ExpNo}.res = sprintf('<%3.1f,%3.1f,%3.1f>', pv.res(1),pv.res(2), pv.slithk);
  img{ExpNo}.seg = pv.nseg;
  img{ExpNo}.voldx = pv.imgtr * 1000;
end;

if ~nargout,
  for E = 1:length(img),
    fprintf('[%s,%s,%d]: STM[%s]\n',...
            upper(img{E}.sesname), upper(img{E}.grpname), img{E}.ExpNo, img{E}.stminfo);
  end;
  
  for E = 1:length(img),
    fprintf('[%s,%s,%d,sc:%d]: VTR/TR/TE:%.1f/%.1f/%.1f, %s, %s, %s\n',...
            upper(img{E}.sesname), upper(img{E}.grpname), img{E}.ExpNo, img{E}.sc,...
            img{E}.voldx,img{E}.TR, img{E}.TE, img{E}.dims, img{E}.fov, img{E}.res);
  end;
else
  for E = 1:length(img),
    s{1}{E} = sprintf('STM[%s]', img{E}.stminfo);
  end;
  
  for E = 1:length(img),
    s{2}{E} = sprintf('[%s,%3d,Scan=%3d]: VTR/TR/TE=(%.1f %.1f %.1f) %s, %s, %s',...
            upper(img{E}.grpname), img{E}.ExpNo, img{E}.sc,...
            img{E}.voldx,img{E}.TR, img{E}.TE, img{E}.dims, img{E}.fov, img{E}.res);
  end;
end;

return;
  
