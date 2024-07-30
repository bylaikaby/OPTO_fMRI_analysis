%RM_NEIGHBORS - Removes neighboring values within the given distance.
%   [locs indx] = rm_neighbors(locs,min_distance)  removes neighboring values 
%   within "min_distance" from "locs".  Combining with findpeaks(), this provides 
%   much faster processing (see EXAMPLE).  "indx" has a array of indices selected.
% 
%  COMPILE :
%   mex rm_neighbors.c
%   mex -largeArrayDims rm_neighbors.c
%
%  EXAMPLE :
%    x = rand(1,100000);
%    tic
%    [vals locs] = findpeaks(x,'sortstr','descend');
%    [locs indx] = rm_neighbors(locs,3.0);
%    vals = vals(indx);
%    toc
%    tic
%    [vals2 locs2] = findpeaks(x,'sortstr','descend','minpeakdistance',3.0);
%    toc
%    isequal(locs, locs2)    % R2007b may have a bug(s) of findpeaks(), while R2011b ok.
%
%  VERSION :
%    1.00 13-02-2013 YM  pre-release
%    1.01 14-02-2013 YM  improved memory usage.
%
%  See also findpeaks test_rm_neighbors
