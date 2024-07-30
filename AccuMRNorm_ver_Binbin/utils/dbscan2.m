function [clust,ctype] = dbscan(x,k,Eps)
% -------------------------------------------------------------------------
% Function: [clust,ctype] = dbscan(x,k,Eps)
% -------------------------------------------------------------------------
% Aim: 
% Clustering the data with Density-Based Scan Algorithm with Noise (DBSCAN)
% -------------------------------------------------------------------------
% Input: 
% x - data set (m,n); m-objects, n-variables
% k - number of objects in a neighborhood of an object 
% (minimal number of objects considered as a cluster)
% Eps - neighborhood radius, if not known avoid this parameter or put []
% -------------------------------------------------------------------------
% Output: 
% clust - vector specifying assignment of the i-th object to certain 
% cluster (1,m)
% ctype - vector specifying type of the i-th object 
% (core: 1, border: 0, outlier: -1)
% -------------------------------------------------------------------------
% Example of use:
% x=[randn(30,2)*.4;randn(40,2)*.5+ones(40,1)*[4 4]];
% [clust,ctype]=dbscan(x,5,[])
% clusteringfigs('Dbscan',x,[1 2],clust,ctype)
% -------------------------------------------------------------------------
% References:
% [1] M. Ester, H. Kriegel, J. Sander, X. Xu, A density-based algorithm for 
% discovering clusters in large spatial databases with noise, proc. 
% 2nd Int. Conf. on Knowledge Discovery and Data Mining, Portland, OR, 1996, 
% p. 226, available from: 
% www.dbs.informatik.uni-muenchen.de/cgi-bin/papers?query=--CO
% [2] M. Daszykowski, B. Walczak, D. L. Massart, Looking for 
% Natural Patterns in Data. Part 1: Density Based Approach, 
% Chemom. Intell. Lab. Syst. 56 (2001) 83-92 
% -------------------------------------------------------------------------
% Written by Michal Daszykowski
% Department of Chemometrics, Institute of Chemistry, 
% The University of Silesia
% December 2004
% http://www.chemometria.us.edu.pl

m = size(x,1);

if nargin<3 || isempty(Eps)
  [Eps]=epsilon(x,k);
end

x = [(1:m)' x];
[m,n] = size(x);
touched = zeros(1,m);
clust   = zeros(1,m);
ctype   = zeros(1,m);
no = 1;
for i = 1:m
  if touched(i) > 0,  continue;  end

  ob = x(i,:);
  D = dist(ob(2:n),x(:,2:n));
  ind = find(D <= Eps);
    
  if length(ind) > 1 && length(ind) < k+1       
    ctype(i) = 0;
    clust(i) = 0;
  end
  if length(ind) == 1
    ctype(i)   = -1;
    clust(i)   = -1;  
    touched(i) =  1;
  end

  if length(ind) >= k+1; 
    ctype(i)   = 1;
    clust(ind) = ones(length(ind),1) * max(no);

    while ~isempty(ind)
      ob = x(ind(1),:);
      touched(ind(1)) = 1;
      ind(1) = [];
      D = dist(ob(2:n),x(:,2:n));
      i1 = find(D <= Eps);
     
      if length(i1) > 1
        clust(i1) = no;
        if length(i1) >= k+1;
          ctype(ob(1)) = 1;
        else
          ctype(ob(1)) = 0;
        end

        for j = 1:length(i1)
          if touched(i1(j)) > 0,  continue;  end
          touched(i1(j)) = 1;
          %ind = [ind i1(j)];   
          ind = cat(2,ind,i1(j));
          clust(i1(j)) = no;
        end
      end
    end
    no = no + 1; 
  end
end

i1 = (clust == 0);
clust(i1) = -1;
ctype(i1) = -1;

return



%...........................................
function Eps = epsilon(x,k)

% Function: Eps = epsilon(x,k)
%
% Aim: 
% Analytical way of estimating neighborhood radius for DBSCAN
%
% Input: 
% x - data matrix (m,n); m-objects, n-variables
% k - number of objects in a neighborhood of an object
% (minimal number of objects considered as a cluster)



[m,n] = size(x);

Eps = ((prod(max(x)-min(x))*k*gamma(.5*n+1))/(m*sqrt(pi.^n))).^(1/n);

return


%............................................
function D = dist(i,x)

% function: D = dist(i,x)
%
% Aim: 
% Calculates the Euclidean distances between the i-th object and all objects in x	 
%								    
% Input: 
% i - an object (1,n)
% x - data matrix (m,n); m-objects, n-variables	    
%                                                                 
% Output: 
% D - Euclidean distance (1,m)


[m,n] = size(x);

if n == 1,
  D = abs((ones(m,1)*i-x))';
else
  %D = sqrt(sum((((ones(m,1)*i)-x).^2)'));
  D = sqrt(sum((ones(m,1)*i-x).^2,2)');
end

return
