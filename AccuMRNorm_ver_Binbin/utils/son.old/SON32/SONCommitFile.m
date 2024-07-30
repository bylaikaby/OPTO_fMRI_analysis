function ret = SONCommitFile(fh, bDelete)
% SONCOMMITFILE flushes data to disc
% FH is the SON file handle
% BDELETE ,if non-zero, causes the data buffers to be deleted
%     
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

ret = calllib('son32','SONCommitFile', fh, bDelete);
return;
