function [ str ] = cell2str(c1,varargin)
%CELL2STR: Concatenate the String elements of a Cell array into a single
%           String.
%
% [ str ] = cell2str(cellarray1)
% [ str ] = cell2str(cellarray1,delimiter)
% [ str ] = cell2str(cellarray1,cellarray2,...,delimiter)
%
% RMN:27.07.13

% Function called with no arguments ---------------------------------------
if nargin==0,  help cell2str; return; end

str='';
det='';
has_skiped=0;
if ~isempty(varargin)
    
    if ~ischar(det)
        fprintf('\nRMN<cell2str> Delimiter must be a String! It was set to empty!\n')
    else
        det =varargin{end};
    end
end

if ischar(c1),c1={c1};end

if ~iscell(c1)
    has_skiped=1;
else
    for aa=1:length(c1)
        if ~ischar(c1{aa})&&~isempty(c1{aa})
            has_skiped=1;
        else
            str=[str det c1{aa}];
        end
    end
end

for aa=1:length(varargin)
    
    C = varargin{aa};
    if ischar(C), C={C}; end
    
    if ~iscell(C)
        has_skiped=1;
    else
        for bb=1:length(C)
            
            if ischar(C{bb})
                str=[str det C{bb}];
            else
                has_skiped=1;
            end
        end
    end
end
str=regexprep(str,sprintf('^%s|(%s)+$',det,det),'');

if has_skiped
    fprintf('\nRMN<cell2str> Some input was not a cell array or string and it was skiped!\n')
end
end

