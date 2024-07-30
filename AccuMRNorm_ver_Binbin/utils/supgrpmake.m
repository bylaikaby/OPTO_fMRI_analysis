function supgrpmake(SesName)
%SUPGRPMAKE - Makes super-averages from the groups defined in Ses.CTG.SG 
%   SUPGRPMAKE (SesName) - Makes super-averages from the groups defined in Ses.CTG.SG. The
%   function is used for the Glass Pattern project, but it can be used for any project that
%   averages similar groups.
%
%   In the GP the averages are between non-chaning and changing stimulation conditions
%   respectively.
%
%     session: 'j02x31'
%       grpname: 'gpatrr2'
%         ExpNo: [7 15 23 31 39 47 55 63 71 79 87 95 103]
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
%        coords: [270946x3 double]
%     roiSlices: [1 2 3 4 5]
%           dat: [128x270946 double]
%             r: {[20842x13 double]  [20842x13 double]  [20842x13 double]}
%             p: {[20842x13 double]  [20842x13 double]  [20842x13 double]}
%           mdl: {[128x1 double]  [128x1 double]  [128x1 double]}
%          info: [1x1 struct]
%
%   NKL 11.08.05
  
Ses = goto(SesName);

sgrp = Ses.ctg.SG;

for N=1:length(sgrp),
  roiTs = {};
  for K=1:length(sgrp{N}{2}),
    fprintf('SUPGRPMAKE: Processing session: %s, group %s\n', Ses.name, sgrp{N}{2}{K});
    iroiTs = sigload(Ses,sgrp{N}{2}{K},'roiTs');
    roiTs = mycat(sgrp{N}{1},roiTs,iroiTs);
  end;

  for A=1:length(roiTs),
    roiTs{A}.dat = roiTs{A}.dat / length(roiTs);
    for M=1:length(roiTs{A}.r),
      roiTs{A}.r{M} = roiTs{A}.r{M}/length(roiTs);
      roiTs{A}.p{M} = roiTs{A}.p{M}/length(roiTs);
    end;
    roiTs{A}.groups = sgrp{N}{2};
  end;
  save(sgrp{N}{1},'roiTs');
  fprintf('SUPGRPMAKE: Saved session: %s, supergroup %s\n', Ses.name, sgrp{N}{1});
end;
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function ots = mycat(sgrpname, savts, ts)
%       grpname: 'gpatrr2'
%         ExpNo: [7 15 23 31 39 47 55 63 71 79 87 95 103]
%           dat: [128x270946 double]
%             r: {[20842x13 double]  [20842x13 double]  [20842x13 double]}
%             p: {[20842x13 double]  [20842x13 double]  [20842x13 double]}
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if isempty(savts),
  ots = ts;
  return;
end;

ots = savts;
for A=1:length(savts),
  ots{A}.grpname = sgrpname;
  ots{A}.ExpNo = cat(2,savts{A}.ExpNo,savts{A}.ExpNo);
  ots{A}.dat = savts{A}.dat + ts{A}.dat;
  for M=1:length(ts{A}.r),
    ots{A}.r{M} = savts{A}.r{M} + ts{A}.r{M}; 
    ots{A}.p{M} = savts{A}.p{M} + ts{A}.p{M}; 
  end;
end;

    
  
  
    

