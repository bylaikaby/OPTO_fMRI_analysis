function Xout = belltaper(X,alpha)

% BELLTAPER Apply a cosine-bell taper to a time series
%
% INPUTS:
% X:     input vector
% alpha: proportion of the series to be tapered at each end of the
%        series (try 0.1)
%
% OUTPUTS:
% Xout: tapered vector

% AUTHOR: Patrick Sturm <pasturm@ethz.ch>
%
% COPYRIGHT 2007 Patrick Sturm
% This file is part of Eddycalc.
% Eddycalc is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% For a copy of the GNU General Public License, see
% <http://www.gnu.org/licenses/>.
%
%
%  16.05.14 YM@MPI  vectorized.


if isvector(X)
  n  = length(X);
  m1 = floor(alpha*n);
  m2 = n-m1+1;
  t1 = (1:m1)';
  t2 = (m2:n)';
  Xout = X;
  Xout(1:m1) = 0.5*(1-cos(pi*(t1-0.5)/m1)).*X(1:m1);
  Xout(m2:n) = 0.5*(1-cos(pi*(n-t2+0.5)/m1)).*X(m2:n);
else
  % vectorized version
  xsz = size(X);
  X = reshape(X,[xsz(1), prod(xsz(2:end))]);
  
  n = xsz(1);
  m1 = floor(alpha*n);
  m2 = n-m1+1;
  t1 = (1:m1)';
  t2 = (m2:n)';

  csbf1 = 0.5*(1-cos(pi*(t1-0.5)/m1));
  csbf2 = 0.5*(1-cos(pi*(n-t2+0.5)/m1));
  
  Xout = zeros(xsz,class(X));
  Xout(1:m1,:) = bsxfun(@times, X(1:m1,:), csbf1);
  Xout(m2:n,:) = bsxfun(@times, X(m2:n,:), csbf2);
  
  X = reshape(X,xsz);
  Xout = reshape(Xout,xsz);
end


return
