function infodims(SesName,GrpName)
%INFODIMS - Check dimensions of GRPSIGS in case of "Matrix dimensions must agree" error!
% INFODIMS(SesName,GrpName) occasionally we have dimension mismatch during grouping, that
% typically leads to the error:

% Matrix dimensions must agree.
%
% Error in ==> catsig at 172
%           oSig{R}.dat = oSig{R}.dat + Sig{R}.dat;
%
% Error in ==> grpmake at 67
%       Sig = catsig(Ses,GrpName,SIGS{S});
%
% Error in ==> sesgrpmake at 88
%     grpmake(Ses,GrpNames{GrpNo},tmpSigName);
%
% Error in ==> xprocess>subProcess at 225
%     sesgrpmake(SesName, GrpName);
%
% Error in ==> xprocess at 138
%   subProcess(SesName,GrpName,ARGS);  
%
% Use this function to check the dimensions of the signals for different experiments.
%
% NKL 5.5.07

Ses = goto(SesName);
grp = getgrpbyname(Ses,GrpName);

for ExpNo = grp.exps,
  for N=1:length(grp.grpsigs),
    Sig = sigload(Ses,ExpNo,grp.grpsigs{N});
    fprintf('ExpNo=%d, DIMS(%s.dat) = ',ExpNo,grp.grpsigs{N});
    if iscell(Sig),
      fprintf('%d ',size(Sig{1}.dat));
    else
      fprintf('%d ',size(Sig.dat));
    end;
    fprintf('\n');
  end;
end;

  
  
