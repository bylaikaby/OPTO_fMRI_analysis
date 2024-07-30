function str = datetime
    
% DATETIME Returns current date and time.
%
% This fucntion returns current date and time in the format 'yyyy mmm
% dd - HH.MM.SS'.  This format can be used for directories and file
% names since it does not contain punctuation.
%
% EXAMPLE
% 
%     str = datetime;
%
% produces
%
%     str =
%
%     2010 Jan 01 - 00.00.00
%
% See also DATESTR, MKBAK.
    
% Copyright (C) 2010 Cesare Magri
% Version 1.0.0    
    
str = datestr(clock, 'yyyy mmm dd - HH.MM.SS');