function Z = linkage3(Y, method)
%LINKAGE Hierarchical cluster information.
%   LINKAGE(Y) computes the hierarchical cluster information, using the
%   single linkage algorithm, from a given distance matrix Y generated
%   by PDIST. Y is also commonly known as similarity or
%   dissimilarity matrix.
%
%   LINKAGE(Y, method) computes the hierarchical cluster information using
%   the specified algorithm. The available methods are:
%
%      'single'   --- nearest distance
%      'complete' --- furthest distance
%      'average'  --- average distance
%      'centroid' --- center of mass distance
%      'ward'     --- inner squared distance
%
%   Cluster information will be returned in the matrix Z with size m-1
%   by 3.  Column 1 and 2 of Z contain cluster indices linked in pairs
%   to form a binary tree. The leaf nodes are numbered from 1 to
%   m. They are the singleton clusters from which all higher clusters
%   are built. Each newly-formed cluster, corresponding to Z(i,:), is
%   assigned the index m+i, where m is the total number of initial
%   leaves. Z(i,1:2) contains the indices of the two component
%   clusters which form cluster m+i. There are n-1 higher clusters
%   which correspond to the interior nodes of the output clustering
%   tree. Z(i,3) contains the corresponding linkage distances between
%   the two clusters which are merged in Z(i,:), e.g. if there are
%   total of 30 initial nodes, and at step 12, cluster 5 and cluster 7
%   are combined and their distance at this time is 1.5, then row 12
%   of Z will be (5,7,1.5). The newly formed cluster will have an
%   index 12+30=42. If cluster 42 shows up in a latter row, that means
%   this newly formed cluster is being combined again into some bigger
%   cluster.
%
%   See also PDIST, INCONSISTENT, COPHENET, DENDROGRAM, CLUSTER, CLUSTERDATA

%   ZP You, 3-10-98
%   Copyright (c) 1993-98 by The MathWorks, Inc.
%   $Revision: 1.4 $

[k, n] = size(Y);

if n < 3
  error('You have to have at least three distances to do a linkage.');
end
  

m = (1+sqrt(1+8*n))/2;
if k ~= 1 | m ~= fix(m)
  error('The first input has to match the output of the PDIST function in size.');   
end

if nargin == 1 % set default switch to be 's' 
   method = 'si';
end

if length(method) < 2
   error('The switch given by the second argument is not defined.');
end

method = lower(method(1:2)); % simplify the switch string.

Z = zeros(m-1,3); % allocate the output matrix.

% during updating clusters, cluster index is constantly changing, R is
% a index vector mapping the original index to the current (row
% column) index in X.  N denotes how many points are contained in each
% cluster.

N = zeros(1,2*m-1);
N(1:m) = 1;
n = m; % since m is changing, we need to save m in n. 
R = 1:n;

if method == 'ce'  % square the X so that it is easier to update.
   Y = Y .* Y;
elseif method == 'wa'
   Y = Y .* Y/2;
end

if method == 'si'  % single linkage
	for s = 1:(n-1)
%	for s = 1:10
		[v, k] = min(Y);

		i = floor(m+1/2-sqrt(m^2-m+1/4-2*(k-1)));
   	j = k - (i-1)*(m-i/2)+i;
      
      %a = length(Y);
      %fprintf(' s=%3d i=%4d j=%4d k=%4d v=%.3f Yn=%4d', s, i, j, k, v, a);
      
   	Z(s,:) = [R(i) R(j) v]; % update one more row to the output matrix A
   
   	% update X, in order to vectorize the computation, we need to compute
   	% all the index corresponds to cluster i and j in X, denoted by I and J.
   	I1 = 1:(i-1); I2 = (i+1):(j-1); I3 = (j+1):m; % these are temp variables.
   	I = [I1.*(m-(I1+1)/2)-m+i i*(m-(i+1)/2)-m+I2   i*(m-(i+1)/2)-m+I3];
	   J = [I1.*(m-(I1+1)/2)-m+j I2.*(m-(I2+1)/2)-m+j j*(m-(j+1)/2)-m+I3];
   
      %It = I'; Jt = J';
      %a = m-12:m-2;
      %[a' It(a, :) Jt(a, :)]
      
      Y(I) = min(Y(I),Y(J));
      
      J = [J i*(m-(i+1)/2)-m+j];
      %fprintf(' nj=%3d jidx=%.2f\n', length(J), i*(m-(i+1)/2)-m+j);
  		Y(J) = []; % no need for the cluster information about j.
   
   	% update m, N, R
   	m = m-1; 
   	N(n+s) = N(R(i)) + N(R(j));
   	R(i) = n+s;
   	R(j:(n-1))=R((j+1):n); 
	end
elseif method == 'av'  % average linkage
	for s = 1:(n-1)
%	for s = 1:31
      p = (m-1):-1:2;
      I = zeros(m*(m-1)/2,1);
      I(cumsum([1 p])) = 1;
      I = cumsum(I);
      J = ones(m*(m-1)/2,1);
      J(cumsum(p)+1) = 2-p;
      J(1)=2;
      J = cumsum(J);
      W = N(R(I)).*N(R(J));
      X = Y./W;   
      
      xt=X';
      yt=Y';
      [I J]
      [R(I) R(J)]
      [N(R(I)) N(R(J))]
      [ xt, yt]
       
    
	   [v, k] = min(X);
   
	   i = floor(m+1/2-sqrt(m^2-m+1/4-2*(k-1)));
  		j = k - (i-1)*(m-i/2)+i;
        
      a = length(Y);
      fprintf(' s=%3d i=%4d j=%4d k=%4d v=%.3f Yn=%4d\n', s, i, j, k, v, a);
   
   	Z(s,:) = [R(i) R(j) v]; % update one more row to the output matrix A
   
  		% update X, in order to vectorize the computation, we need to compute
   	% all the index corresponds to cluster i and j in X, denoted by I and J.
   	I1 = 1:(i-1); I2 = (i+1):(j-1); I3 = (j+1):m; % these are temp variables.
   	I = [I1.*(m-(I1+1)/2)-m+i i*(m-(i+1)/2)-m+I2 i*(m-(i+1)/2)-m+I3];
   	J = [I1.*(m-(I1+1)/2)-m+j I2.*(m-(I2+1)/2)-m+j j*(m-(j+1)/2)-m+I3];
   
      Y(I) = Y(I) + Y(J);
	%	 Y(I(1:10))'
      
      J = [J i*(m-(i+1)/2)-m+j];
   	Y(J) = []; % no need for the cluster information about j.
   
   	% update m, N, R
   	m = m-1; 
   	N(n+s) = N(R(i)) + N(R(j));
   	R(i) = n+s;
   	R(j:(n-1))=R((j+1):n); 
	end
elseif method == 'co'  % complete linkage
	for s = 1:(n-1)
      X = Y;
      [v, k] = min(X);
   
	   i = floor(m+1/2-sqrt(m^2-m+1/4-2*(k-1)));
   	j = k - (i-1)*(m-i/2)+i;
   
   	Z(s,:) = [R(i) R(j) v]; % update one more row to the output matrix A
   
   	% update X, in order to vectorize the computation, we need to compute
   	% all the index corresponds to cluster i and j in X, denoted by I and J.
   	I1 = 1:(i-1); I2 = (i+1):(j-1); I3 = (j+1):m; % these are temp variables.
   	I = [I1.*(m-(I1+1)/2)-m+i i*(m-(i+1)/2)-m+I2 i*(m-(i+1)/2)-m+I3];
   	J = [I1.*(m-(I1+1)/2)-m+j I2.*(m-(I2+1)/2)-m+j j*(m-(j+1)/2)-m+I3];
      
      Y(I) = max(Y(I),Y(J));
      
      J = [J i*(m-(i+1)/2)-m+j];
  		Y(J) = []; % no need for the cluster information about j.
   
   	% update m, N, R
   	m = m-1; 
   	N(n+s) = N(R(i)) + N(R(j));
   	R(i) = n+s;
   	R(j:(n-1))=R((j+1):n); 
   end
elseif method == 'ce'  % centroid linkage
	for s = 1:(n-1)
   	X = Y;
	   [v, k] = min(X);
      v = sqrt(v);
   
	   i = floor(m+1/2-sqrt(m^2-m+1/4-2*(k-1)));
  		j = k - (i-1)*(m-i/2)+i;
   
   	Z(s,:) = [R(i) R(j) v]; % update one more row to the output matrix A
   
   	% update X, in order to vectorize the computation, we need to compute
   	% all the index corresponds to cluster i and j in X, denoted by I and J.
   	I1 = 1:(i-1); I2 = (i+1):(j-1); I3 = (j+1):m; % these are temp variables.
   	I = [I1.*(m-(I1+1)/2)-m+i i*(m-(i+1)/2)-m+I2 i*(m-(i+1)/2)-m+I3];
   	J = [I1.*(m-(I1+1)/2)-m+j I2.*(m-(I2+1)/2)-m+j j*(m-(j+1)/2)-m+I3];
   
      K = N(R(i))+N(R(j));
      Y(I) = (N(R(i)).*Y(I)+N(R(j)).*Y(J)-(N(R(i)).*N(R(j))*v^2)./K)./K;
      
      J = [J i*(m-(i+1)/2)-m+j];
   	Y(J) = []; % no need for the cluster information about j.
   
   	% update m, N, R
   	m = m-1; 
   	N(n+s) = N(R(i)) + N(R(j));
   	R(i) = n+s;
   	R(j:(n-1))=R((j+1):n); 
	end
elseif method == 'wa'
	for s = 1:(n-1)
%	for s = 1:1
      X = Y;
	   [v, k] = min(X);
   
	   i = floor(m+1/2-sqrt(m^2-m+1/4-2*(k-1)));
   	j = k - (i-1)*(m-i/2)+i;
   
   	Z(s,:) = [R(i) R(j) v]; % update one more row to the output matrix A
   
	%fprintf(' s=%4d  i=%4d  j=%4d  k=%4d  v=%.4f\n', s, i, j, k, v);

   	% update X, in order to vectorize the computation, we need to compute
   	% all the index corresponds to cluster i and j in X, denoted by I and J.
   	I1 = 1:(i-1); I2 = (i+1):(j-1); I3 = (j+1):m; % these are temp variables.
   	U = [I1 I2 I3];
   	I = [I1.*(m-(I1+1)/2)-m+i i*(m-(i+1)/2)-m+I2 i*(m-(i+1)/2)-m+I3];
   	J = [I1.*(m-(I1+1)/2)-m+j I2.*(m-(I2+1)/2)-m+j j*(m-(j+1)/2)-m+I3];
   
	%nt = N(R(U))';
    %ru = R(U)';
    %[nt ru]

      Y(I) = ((N(R(U))+N(R(i))).*Y(I) + (N(R(U))+N(R(j))).*Y(J) - ...
		  N(R(U))*v)./(N(R(i))+N(R(j))+N(R(U)));

    %idx=1:length(Y);
    %idx=idx';
    %Yt = Y';
    %[idx Yt]
     
   	J = [J i*(m-(i+1)/2)-m+j];
   	Y(J) = []; % no need for the cluster information about j.
   
   	% update m, N, R
   	m = m-1; 
   	N(n+s) = N(R(i)) + N(R(j));
  		R(i) = n+s;
   	R(j:(n-1))=R((j+1):n); 
	end
   Z(:,3) = sqrt(Z(:,3));
else
   error('method not recognized.');
end
