function infoglm(SesName, GrpName, SigName)
%INFOGLM - List models and contrasts for GrpName of SesName
%  INFOGLM (SesName,GrpName) shows all designs and contrast functions of the group.
%  INGOGLM (SesName,GrpName,SigName) shows GLM designs/contrasts for the given signal.
%
%  EXAMPLE :
%    >> infoglm('ratiM2','spont')
%    >> infoglm('ratiM2','spont','roiTs')
%
%  VERSION :
%    1.00 06.10.06 NKL
%    1.10 15.04.13 YM  supports 'SigName'.
%
%  See also glm_getgrp

if nargin < 2, GrpName = 'spont'; end;
if naring < 3, SigName = '';      end


Ses = goto(SesName);
%grp = getgrp(Ses,GrpName);
grp = glm_getgrp(Ses,GrpName,SigName);

if isempty(SigName),
  fprintf('%s(%s): Sig=(generic)\n',Ses.name,grp.name);
else
  fprintf('%s(%s): Sig=%s\n',Ses.name,grp.name,SigName);
end


mdl = grp.glmana;
for N=1:length(mdl),
  fprintf('Design(%d):\n',N);
  fprintf('Model: ');
  fprintf('%s ', mdl{N}.mdlsct{:});
  fprintf('\n');
end;

glm = grp.glmconts;
for N=1:length(glm),
  fprintf('Contrast: %s, %s, pVal: %1.4f\n',glm{N}.type, glm{N}.name,glm{N}.pVal);
end





    


