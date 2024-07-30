function xm=graph_clust(Smat,Nclust) 
%compute graph clustering using normalized cuts
%
%
% syntax	xm=graph_clust(Smat,Nclust)
%
%  inputs
%
%	Smat - connectivity matrix (can be sparse)
%
%	Nclust - number of clusters
%
%
%  outputs
%
%	xm - cluster labels
%
%
% Author : Michel Besserve, MPI for Intelligent Systems, MPI for Biological Cybernetics, Tuebingen, GERMANY


        V=cncut(1*sparse(Smat),[],Nclust);
        X=getbinsol(V);
        [tmp,xm]=max(X,[],2);