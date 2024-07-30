function rn = inforoi(SesName,GrpName,Detailed)
%INFOROI - Display name, slice, mask-dims and size of each ROI (e.g. brain, V1)
% INFOROI (SesName,GrpName) displays all fields of DefRoi.roi{}
%
% ======================================
% Structure in the Roi.mat
% ======================================
%        session: 'f05gp1'
%        grpname: 'visesmix'
%           exps: [1x50 double]
%        anainfo: {3x1 cell}
%       roinames: {10x1 cell}
%            dir: [1x1 struct]
%            dsp: [1x1 struct]
%            grp: [1x1 struct]
%            ana: [128x180x12 double]
%            img: [64x90x12 double]
%             ds: [0.7500 0.7500 2 2]
%             dx: 2
%          gamma: [1.8000 1.8000 1.8000 1.8000 1.8000 1.8000 1.8000 1.8000 1.8000 1.8000 1.8000 1.8000]
%            roi: {1x87 cell}
%            ele: {[1x1 struct]}
%        midline: {}
%     acommisure: {}
%
% ======================================
% Group RoiDef
% ======================================
% GRP.GrpName.grproi  = 'RoiDef2';
% 
% CURRENT ROIS in GRPROI
%  'ACC' 'Amy' 'DB' 'DB+MS' 'DCbN' 'DS' 'Ent' 'GP' 'HP' 'HTh'
%  'InfCol' 'Ins' 'IntHemCb' 'LC' 'LC+CGn' 'LGN' 'LatHemCb' 'Motor' 'Olf'
%  'PAG' 'PCC' 'ParIntra' 'ParLat' 'ParPrec' 'PirFo' 'PontReg' 'Premotor'
%  'Raphe' 'RetroSp' 'S1' 'S2+' 'SC' 'SN' 'Septum' 'Striatum' 'Tha'
%  'TmpAu' 'TmpPol' 'TmpSTS' 'TmpVis' 'V1' 'V2-V3' 'V4' 'V5' 'VS' 'VTA'
%  'Vermis' 'aIns' 'alCb' 'basalAmy' 'dACC' 'dlPFC' 'medPFC' 'orbPFC' 'pflCb'
%
% NKL 16.05.04
%

if nargin < 2, GrpName = 'spont'; end;

Ses = goto(SesName);
grp = getgrp(SesName, GrpName);

ROI = Ses.roi;
rn = ROI.names;
if ~nargout, fprintf('%s ', rn{:}); fprintf('\n'); end;
return;



return

% DEBUG OR DELETE.......  NKL 01.08.2015
if nargin == 2 & strcmpi(GrpName,'netblp'),
  GrpName = 'spont';
  anap = getanap(SesName);
  selroi = anap.NETBLP.SELROI;
  Ses = goto(SesName);
  grp = getgrp(SesName, GrpName);
  RoiFile = mroi_file(Ses,grp.grproi);
  ROI = load(RoiFile,grp.grproi);
  ROI = ROI.(grp.grproi);
  tmpNames = ROI.roinames;
  misROI = {};
  for N=1:length(selroi),
    fprintf('%s\n', selroi{N});
    if isempty(find(strcmpi(tmpNames,selroi{N}))),  misROI{end+1} = selroi{N}; end;
  end;
  if isempty(misROI), fprintf('No missing ROIs in sessions %s\n', SesName);
  else
    fprintf('MISSING ROIS:\n');
    fprintf('{'); fprintf('''%s'' ', misROI{:}); fprintf('}');
    fprintf('\n');
  end;
  return;
end;
    keyboard
  
if nargin == 1 & strcmpi(SesName,'selroi'),
   names = paxroigroups('ROI','rat');
   fprintf('ANAP.SELROI = {');
   for N=1:length(names),
     fprintf('''%s''', names{N});
     if N<length(names), fprintf(',');  end;
   end;
   fprintf('};\n');
   return;
end;
   
if nargin < 3, Detailed = 0; end;
if nargin < 2, GrpName = 'spont'; end;
if nargin < 1, help inforoi;  return; end;

if iscell(SesName),
  fprintf('Checking electrode-ROIs\n');
  SES = rpsessions(SesName{:});
  for N=1:length(SES),
    SesName = SES{N};
    Ses = goto(SesName);
    grp = getgrp(SesName, GrpName);
    RoiFile = mroi_file(Ses,grp.grproi);
    ROI = load(RoiFile,grp.grproi);
    ROI = ROI.(grp.grproi);
    tmpNames = ROI.roinames;
    ELEROI = {'hele','thele','cele'};
    for J=1:length(ELEROI),
      nvox(J) = subGetNumVoxels(ROI, ELEROI{J});
    end;
    nroi = sprintf('%d ', nvox);
    fprintf('%s(hele,thele,cele) = [%s]\n', SesName, nroi);
  end;
  return;
end;

Ses = goto(SesName);
grp = getgrp(SesName, GrpName);
RoiFile = mroi_file(Ses,grp.grproi);
ROI = load(RoiFile,grp.grproi);
ROI = ROI.(grp.grproi);
tmpNames = ROI.roinames;

EXCLUDE = {'brain','norm','etc','left','right'};
RoiNames = {};
for N=1:length(tmpNames),
  if find(strcmpi(EXCLUDE, tmpNames{N})),
    continue;
  end;
  RoiNames{end+1} = tmpNames{N};
end;
RoiNames = sort(RoiNames);

for N=1:length(RoiNames),
  nvox = subGetNumVoxels(ROI,RoiNames{N});
  fprintf('%s(%s/%s) nvox=%5d  %s\n',...
          Ses.name, grp.name, grp.grproi,nvox,RoiNames{N});
end;
rn = RoiNames;
return;

% ----------------------------------------------------
function nvox = subGetNumVoxels(ROI,roiname)
% ----------------------------------------------------
nvox = 0;
for N = 1:length(ROI.roi)
  if any(strcmp(ROI.roi{N}.name,roiname)),
    nvox = nvox + length(find(ROI.roi{N}.mask(:) > 0));
  end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subInfoRoi(Ses,CurRoi,RoiName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roi=Ses.roi;
ALLVOX=0;
for N=1:length(roi.names),
  if nargin > 2,
    if ~strcmpi(roi.names{N},RoiName),
      continue;
    end;
  end;
  
  tmp = mroiget(CurRoi,[],roi.names{N});
  nvox = 0;
  for S=1:length(tmp.roi)
    nvox = nvox + length(find(tmp.roi{S}.mask(:)));
  end;
  fprintf('%8s[%2d] - %16s: %6d\n', Ses.name, N, upper(roi.names{N}), nvox);
  ALLVOX=ALLVOX+nvox;
end;
if nargin <= 2,
  fprintf('ALL VOXELS = %d\n', ALLVOX);
end;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subDetailedInfoRoi(CurRoi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALLVOX=0;
for J=1:length(CurRoi.roi),
  roi = CurRoi.roi{J};
  nvox = size(find(roi.mask(:)));
  ALLVOX=ALLVOX+nvox;
  fprintf('%9s:\tSlice:%3d, Mask: [%3d x %3d], Area: %4d\n',...
          upper(roi.name), roi.slice, size(roi.mask), nvox(1));
end;
fprintf('ALL VOXELS = %d\n', ALLVOX);
return;
  

