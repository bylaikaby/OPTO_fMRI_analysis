function [NumK p idx, C, sumd, D] = jd_kmeans(X, MaxK, varargin)
%JD_KMEANS - Estimates the number of clusters by Jain-Dubes/kmeans
%    [NumK p idx, C, sumd, D] = jd_kmeans(X,MaxK,...) estimates the number of 
%    clusters by Jain-Dubes/kmeans.
%
%  NOTE :
%    'NumK' gives minumum of 'p', the cost function.
%    p(K) = sum(max((IntraDist(i)+IntraDist(j))/InterDist(i,j)));
%    where IntraDist(j)   : intra-cluster distance of 'j'.
%          InterDist(i,j) : inter-cluster distance between 'i' and 'j'.
%
%  EXAMPLE :
%   X = [randn(30,2)*.4;randn(40,2)*.5+ones(40,1)*[4 4];rand(50,2)*0.6+ones(50,1)*[0 1.5]];
%   [NumK p idx, C, sumd, D] = jd_kmeans(X, 10);
%
%  REFERENCE :
%  [1] Jain, A.K. and Dubes, R.C. (1988): Algorithms for clustering data, 
%      Englewood Cliffs, NJ:Prentice-Hall.
%  [2] Ngo, C.W., Pong, T.C. and Zhang H.J. (2002): On clustering and retrieval of video
%      shots through temporal slices analysis, IEEE Trans. Mlt., 4(4), 446-458.
%
%  VERSION :
%    0.90 17.02.12 YM  pre-release
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
p    = NaN(1,MaxK);
  
[idx C sumd D] = kmeans(X,1,'Distance',dist, args{:});
%p(1) = nanmean(D);
p(1) = Inf;
NumK = 1;
for K = 2:MaxK,
  [tmpi tmpC tmpS tmpD] = kmeans(X,K,'Distance',dist, args{:});
  % for j = 1:K,
  %   tmpdist = X - ones(size(X,1),1)*tmpC(j,:);
  %   tmpD2(:,j) = sum(tmpdist.^2,2);
  % end
  % isequal(tmpD,tmpD2)

  % compute intra-cluster distance
  intra_clust = NaN(1,K);
  %ndata = zeros(1,K);
  for j = 1:K,
    %intra_clust(j) = nanmedian(tmpD((tmpi == j),j),1);
    intra_clust(j) = nanmean(tmpD((tmpi == j),j),1);
    % ndata(j) = length(find(tmpi == j));
  end
  % compute inter-cluster distance
  if strcmpi(dist,'sqEuclidean'),
    intra_clust = sqrt(intra_clust);
    inter_clust = pdist(tmpC,'euclidean');
  else
    inter_clust = pdist(tmpC,dist);
  end
  inter_clust = squareform(inter_clust);
  inter_clust = inter_clust + eye(size(inter_clust)); % prevent zero-div.
  % compute the cost function
  tmpv = 0;
  tmpx = zeros(1,K);
  for m = 1:K,
    for j = 1:K,
      tmpx(j) = (intra_clust(m) + intra_clust(j))/inter_clust(m,j);
    end
    tmpx(m) = 0;
    tmpv = tmpv + max(tmpx);
  end
  p(K) = tmpv / K;
  
  if p(K) > p(NumK),  continue;  end
  NumK = K;
  idx  = tmpi;
  C    = tmpC;
  sumd = tmpS;
  D    = tmpD;
end


return

