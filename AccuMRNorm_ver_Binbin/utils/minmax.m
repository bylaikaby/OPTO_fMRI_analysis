function pr=minmax(p)
%MINMAX - Ranges of matrix rows.
%	pr=MINMAX(p)
%	Syntax
%	  pr = range(P)
%	Description
%	  MINMAX(P) takes one argument,
%	    PR - RxQ matrix.
%	  and returns the Rx2 matrix PR of minimum and maximum values
%	  for each row of M.
%	Examples
%	  p = [0 1 2; -1 -2 -0.5]
%	  pr = minmax(p)
%	Mark Beale, 11-31-97
%	Copyright (c) 1992-1998 by The MathWorks, Inc.
%	$Revision: 1.3 $

pr = [min(p,[],2) max(p,[],2)];
