function RES = run_mds(X,varargin)
%RUN_MDS - Run MDS (multi-dimensional scaling)
%  RES = run_mds(X,...) runs MDS (multi-dimensional scaling) of X.
%  'X' must be (observations,variable).
%
%  Supported options are :
%    'Distance'  : see pdist()
%    'MDSOrder'  : order of MDS
%    'iteration' : max. iteration (default=100)
%    'recenter'  : 'none', 'mean' or 'median'
%    'Verbose'   : 0|1
%    'Plot'      : 0|1
%    'axes'      : a handle of axes to plot
%
%  VERSION :
%    0.90 13.12.09 YM  pre-release
%
%  See also order_mds mds pdist

if nargin < 1,  eval(sprintf('help %s',mfilename)); return;  end


% OPTIONS
Distance      = 'euclidean';
MDSOrder      = 2;
MaxIterations = 100;
VERBOSE       = 0;
DoPlot        = 1;
DoRecenter    = 'none';
hAxes         = [];
for N=1:2:length(varargin),
  switch lower(varargin{N}),
   case {'distance' 'dist'}
    Distance = varargin{N+1};
   case {'order' 'mdsorder'}
    MDSOrder = varargin{N+1};
   case {'maxiteration' 'iteration' 'iter' 'maxiter' 'replicates'}
    MaxIterations = varargin{N+1};
   case {'verbose'}
    VERBOSE = varargin{N+1};
   case {'plot' 'doplot'}
    DoPlot = varargin{N+1};
   case {'recenter'}
    DoRecenter = varargin{N+1};
   case {'axes'}
    hAxes = varargin{N+1};
  end
end

%fprintf('pdist.');
tmpdist = pdist(X,Distance);
%fprintf('squareform.');
tmpdist = squareform(tmpdist);

%fprintf('mds.');
[mdscoords,mdsrs] = order_mds(tmpdist,MDSOrder,...
                              'iteration',MaxIterations,...
                              'verbose',VERBOSE,'plot',DoPlot,'axes',hAxes);


RES.distance  = Distance;
RES.order     = MDSOrder;
RES.iteration = MaxIterations;
%RES.pdist     = tmpdist;  % might be a memory-problem for big data.
RES.mdscoords = mdscoords;
RES.mdsrs     = mdsrs;
RES.recenter  = 'none';


if any(DoRecenter)
  switch lower(DoRecenter)
   case {'mean' 'nanmean'}
    RES.mdscoords = bsxfun(@minus, RES.mdscoords, nanmean(RES.mdscoords,1));
    RES.recenter  = 'mean';
   case {'median' 'nanmedian'}
    RES.mdscoords = bsxfun(@minus, RES.mdscoords, nanmedian(RES.mdscoords,1));
    RES.recenter  = 'median';
  end
end


return



