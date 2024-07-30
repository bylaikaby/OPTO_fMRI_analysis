function Y = pdist3(X,s,t)
%PDIST Pairwise distance between observations.
%   Y = PDIST(X,METRIC) returns a vector which contains all the
%   distances between each pair of observations in X computed using
%   the given METRIC.  X is a M by N matrix, treated as M observations
%   of N variables. Since there are M*(M-1)/2 pairs of observations in
%   X, the size of Y is M*(M-1)/2 by 1.  The default metric is
%   'EUCLID'.  The available metrics are:
%
%      'euclid'    --- Euclidean metric
%      'seuclid'   --- Standardized Euclid metric
%      'cityblock' --- City Block metric
%      'mahal'     --- Mahalanobis metric
%      'minkowski' --- Minkowski metric
%
%   Y = PDIST(X, 'minkowski', p) specifies the exponents in the
%   'Minkowski' computation. When p is not given, p is set to 2.
%
%   The output Y is arranged in the order of ((1,2),(1,3),..., (1,M),
%   (2,3),...(2,M),.....(M-1,M)).  i.e. the upper right triangle of
%   the M by M square matrix. To get the distance between observation
%   i and observation j, either use the formula Y((i-1)*(M-i/2)+j-i)
%   or use the helper function Z = SQUAREFORM(Y), which will return a
%   M by M symmetric square matrix, with Z(i,j) equaling the distance
%   between observation i and observation j.
%
%   See also SQUAREFORM, LINKAGE

%   ZP You, 3-10-98
%   Copyright (c) 1993-98 by The MathWorks, Inc.
%   $Revision: 1.2 $

if nargin >= 2
   if length(s) < 2
      error('Unrecognized metric');
   else 
      s = lower(s(1:2));
   end
else
   s = 'eu';
end

if s == 'mi' % Minkowski distance need a third argument
   if nargin < 3
      t = 2; 
   elseif t <= 0
      error('The third argument has to be positive.');
   end
end

[m, n] = size(X);

if m < 2
   error('The first argument has to be a numerical matrix with at least two rows');
end

   
p = (m-1):-1:2;
I = zeros(m*(m-1)/2,1);
I(cumsum([1 p])) = 1;
I = cumsum(I);
J = ones(m*(m-1)/2,1);
J(cumsum(p)+1) = 2-p;
J(1)=2;
J = cumsum(J);

%Y = (X(I,:)-X(J,:))';
%I = []; J = []; p = [];  % no need for I J p any more.

n_data = m*(m-1)/2;
Y = zeros(1, n_data);
p = [];

tmp_d = zeros(1, n);
switch s
case 'eu' % Euclidean
   for i=1:n_data
      tmp_d = X(I(i), :) - X(J(i), :);
      Y(i) = sum(tmp_d.^2);
   end
   Y = sqrt(Y);
case 'se' % Standadized Euclidean
   D = diag(var(X));
   for i=1:n_data
      tmp_d = (X(I(i), :) - X(J(i), :))';
      Y(i) = sum(D*(tmp_d.^2));
   end
%   Y = sum(D*(Y.^2));
   Y = sqrt(Y);
case 'ci' % City Block
   for i=1:n_data
      tmp_d = X(I(i), :) - X(J(i), :);
      Y(i) = sum(abs(tmp_d))
   end
case 'ma' % Mahalanobis
   v = inv(cov(X));
   for i=1:n_data
      tmp_d = (X(I(i), :) - X(J(i), :))';
      Y(i) = sum((v*tmp_d).*tmp_d);
   end
%   Y = sqrt(sum((v*Y).*Y));
	Y = sqrt(Y);
case 'mi' % Minkowski
   for i= 1:n_data
      tmp_d = X(I(i), :) - X(J(i), :);
      Y(i) = sum(abs(tmp_d).^t);
   end
   Y = Y.^(1/t);
otherwise
   error('no such method.');
end




