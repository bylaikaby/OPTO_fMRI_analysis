function [NumK J TDIS idx, C, sumd, D] = jump_kmeans(X, MaxK, varargin)
%JD_KMEANS - Estimates the number of clusters by Jain-Dubes/kmeans
%    [NumK j idx, C, sumd, D] = jd_kmeans(X,MaxK,...) estimates the number of 
%    clusters by Jain-Dubes/kmeans.
%
%  NOTE :
%
%  EXAMPLE :
%   X = [randn(30,2)*.4;randn(40,2)*.5+ones(40,1)*[4 4];rand(50,2)*0.6+ones(50,1)*[0 1.5]];
%   [NumK p idx, C, sumd, D] = jump_kmeans(X, 10);
%
%  REFERENCE :
%  [1] Jain, A.K. and Dubes, R.C. (1988): Algorithms for clustering data, 
%      Englewood Cliffs, NJ:Prentice-Hall.
%  [2] Ngo, C.W., Pong, T.C. and Zhang H.J. (2002): On clustering and retrieval of video
%      shots through temporal slices analysis, IEEE Trans. Mlt., 4(4), 446-458.
%
%  VERSION :
%    0.90 20.02.12 YM  pre-release
%
%  See also kmeans

if nargin == 0,  eval(['help ' mfilename]); return;  end

if nargin < 2,  MaxK = [];  end

dist = 'sqEuclidean';
args = varargin;
for N = 1:2:length(varargin)
  switch lower(varargin{N})
   case {'distance' 'dist'}
    dist = varargin{N+1};
    args(N:N+1) = [];
  end
end


if ~any(MaxK),  MaxK = round(1+log2(size(X,1)));  end


p = size(X,2);  % dimension of X
Y = p/2;
vinv = cov(X) \ eye(p);


TDIS = zeros(1,MaxK);
J = zeros(1,MaxK);
[idx C sumd D] = kmeans(X,1,'Distance',dist, args{:});
NumK = 1;
TDIS(1) = sub_distort(X,p,vinv,1,idx,C)^(-Y);
J(1) = TDIS(1);
for K = 2:MaxK,
  [tmpi tmpC tmpS tmpD] = kmeans(X,K,'Distance',dist, args{:});
  TDIS(K) = sub_distort(X,p,vinv,K,tmpi,tmpC)^(-Y);
  J(K) = TDIS(K) - TDIS(K-1);
  if J(K) < J(NumK),  continue;  end
  NumK = K;
  idx  = tmpi;
  C    = tmpC;
  sumd = tmpS;
  D    = tmpD;
end


return


% ====================================================
function d = sub_distort(X,p,m,K,idx,C)
% ====================================================

d = NaN(1,K);
for N = 1:K,
  tmpx = X((idx==N),:);
  if isempty(tmpx),  continue;  end
  tmpx = tmpx - ones(size(tmpx,1),1)*C(N,:);
  d(N) = nanmean(diag(tmpx*m*(tmpx')));
end
d = min(d)/p;

return

