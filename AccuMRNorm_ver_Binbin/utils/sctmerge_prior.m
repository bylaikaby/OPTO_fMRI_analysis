function [ prior ] = sctmerge_prior( varargin )
%SCTMERGE_PRIOR - replaces/adds sub-fields of the input strucure/cell
%                 array N with those of N-1. If one of the inputs is a cell
%                 array it must follow the format:
%                 {'FieldName1', Value1,'FieldName2', Value2,...} or
%                 {'FieldName1.SubFieldName1 ...', Value1,...}.
%
%   C = SCTMERGE_PRIOR(sct/cell-1,sct/cell-2,...)
%
%  VERSION :
%    0.90 12.10.15 RMN  pre-release
%
%  See also SCTMERGE

prior = varargin{end};
if iscell(prior), prior = sub_cell2stc(prior); end

for a = length(varargin)-1:-1:1
    
    curr = varargin{a};  
    if iscell(curr),  curr  = sub_cell2stc(curr); end    
    
    prior = sctmerge(prior, curr);
end
end

function stc = sub_cell2stc(icell)

stc = [];
if isempty(icell),return;end
if isstruct(icell{1}), stc = icell{1}; return;end

for a=1:2:length(icell)    
    eval(sprintf('stc.%s = icell{a+1};', icell{a}))
end
end