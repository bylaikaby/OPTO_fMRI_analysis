function [x, S] = order_mds(gdist,L,varargin)
% function [x, S] = order_mds(gdist,L,...)
% Compute an ordinal MDS of dimension L from the distance data gdist
%
% gdist is an n x n symmetric matrix of distances between n input
%   points
% L is the dimension of target space
% epsilon is an offset threshold --- once the combined offset of the 
%   point-location estimates move less than this, the recursion stops
%
% x is an n x L matrix of point coordinates in an L-D space
%   that maintain the relative-distance ordering between the input
%   points, while minimizing the strain in that space
% S is the residual strain
%
%
%  Supported options are :
%    'iteration' : maximum iteration for scaling
%    'epsilon'   : minimum scaling update to break the while-loop
%    'plot'      : 0|1, plot the figure
%    'verbose'   : 0|1, turn on/off the verbose mode
%
%  VERSION :
%    0.91 14.12.09 YM  modified to supports some options.
%    0.92 16.02.12 YM  can use mex subfunction, ~50% faster.
%
%  See also mds run_mds

% Malcolm Slaney and Michele Covell, "Matlab Multidimensional Scaling Tools,"
% Interval Technical Report #2000-025, 2000 (also available at
% http://web.interval.com/papers/2000-025/).

% This routine written by Michele Covell - Interval Research Corporation - 
% May 1998. (c) Copyright Interval Research, May 1998.

% This is experimental software and is being provided to Licensee
% 'AS IS.'  Although the software has been tested on Macintosh, SGI, 
% Linux, and Windows machines, Interval makes no warranties relating
% to the software's performance on these or any other platforms.
%
% Disclaimer
% THIS SOFTWARE IS BEING PROVIDED TO YOU 'AS IS.'  INTERVAL MAKES
% NO EXPRESS, IMPLIED OR STATUTORY WARRANTY OF ANY KIND FOR THE
% SOFTWARE INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY OF
% PERFORMANCE, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
% IN NO EVENT WILL INTERVAL BE LIABLE TO LICENSEE OR ANY THIRD
% PARTY FOR ANY DAMAGES, INCLUDING LOST PROFITS OR OTHER INCIDENTAL
% OR CONSEQUENTIAL DAMAGES, EVEN IF INTERVAL HAS BEEN ADVISED OF
% THE POSSIBLITY THEREOF.
%
%   This software program is owned by Interval Research
% Corporation, but may be used, reproduced, modified and
% distributed by Licensee.  Licensee agrees that any copies of the
% software program will contain the same proprietary notices and
% warranty disclaimers which appear in this software program.
%


% OPTIONS
VERBOSE  = 0;
EPSILON  = 1e-7;
MAX_ITER = 100;
DoPlot   = 0;
hAxes    = [];
for N = 1:2:length(varargin),
  switch lower(varargin{N})
   case {'verbose'}
    VERBOSE = varargin{N+1};
   case {'epsilon'}
    EPSILON = varargin{N+1};
   case {'maxiteration' 'iteration' 'iter' 'maxiter' 'replicates'}
    MAX_ITER = varargin{N+1};
   case {'doplot','plot'}
    DoPlot = varargin{N+1};
   case {'axes'}
    hAxes = varargin{N+1};
  end
end



if (nargin < 1)
  % no arguments --- generate a small test example
  N = 30; L = 2;
  x_true = rand(N,L);
  x_true = x_true - ones(N,1)*mean(x_true);
  x_true = x_true / sqrt(sum(sum(x_true.^2/N)));
  gdist = zeros(N,N);
  for i = 1:N
    gdist(:,i) = sqrt(sum((x_true-ones(N,1)*x_true(i,:)).^2,2));
  end
  % apply a non-linear, monotonic mapping
  gdist = log(100*gdist+1)/3;
elseif (nargin < 2)
  error('too few arguments');
end

[N,i] = size(gdist);
if (i ~= N)
  error('expected gdist to be square');
end

% force gdist to be symmetric, with zeros on the diagonal
gdist = (gdist + gdist')/2;
gdist = gdist - diag(diag(gdist));

% initialize original estimates using metric MDS
x = mds(gdist,L); x = x';
if (nargin < 1 && L > 1)
  % offset, rotate, & scale x to "align" to x_true
  % these are factors that we can't recover from order MDS
  % removing them makes it easier to evaluate the results

  x_plot = x - ones(N,1)*mean(x);
  [Ux,Sx,Vx] = svd(x_plot \ x_true); Sx = mean(diag(Sx));
  x_plot = Sx*x_plot*Ux*Vx';

  figure('Name',sprintf('%s : demo',mfilename));
  plot(x_plot(:,1),x_plot(:,2),'bx'); hold on;
  plot(x_true(:,1),x_true(:,2),'r+'); hold off;
  title('results of metric MDS'); drawnow;
% keyboard
end


% label each entry with its orginating row/column
gdist = [gdist(:) kron([1:N]',ones(N,1)) kron(ones(N,1),[1:N]')];
% remove lower-triangular entries
gdist((gdist(:,2) >= gdist(:,3)),:) = [];
M = size(gdist,1);
M_vec = (1:M)';

% sort distances into increasing order
[v,i] = sort(gdist(:,1)); gdist = gdist(i,:);


if L > 1 && DoPlot > 0,
  if any(ishandle(hAxes)),
    axes(hAxes);
  else
    figure('NumberTitle','off',...
           'Name',sprintf('%s: %s order=%d',datestr(now,'HH:MM:SS'),mfilename,L))
  end
end

iter_count = 0; len_dS_dx = EPSILON + 1; len_update = 1;
dS_dx = zeros(N,L);  % allocate first
while (len_dS_dx > EPSILON && iter_count < MAX_ITER)

  % normalize
  x = x - ones(N,1)*mean(x);
  x = x / sqrt(sum(sum(x.^2))/N);

  % compute distances between current coordinates
  % in same order as current (sorted) order for gdist
  dist_x = sqrt(sum((x(gdist(:,2),:)-x(gdist(:,3),:)).^2,2));

  % compute cumulative distances over the ordered set
  cavg_dist_x = filter(1,[1 -1],dist_x);

  % if these coordinates were correct,
  % then cavg_dist_x/i would be monotonic increasing
  % enforce this monotonicity by estimating hat_dist_x values
  % by their "minimum bound" using cavg_dist_x values

  %[v,s] = sort(cavg_dist_x ./ [1:M]');
  [v,s] = sort(cavg_dist_x ./ M_vec);


  i = find(s(2:end) < s(1:(end-1))); j = M+2;
  while (~isempty(i))
    j = min(j,min(s(i+1)));
    s(i+1) = [];
    i = find(s(2:end) < s(1:(end-1)));
  end

  hat_dist_x = dist_x;

  % j indicates which is the lowest, out-of-place index
  % if the first entry is out of place, do that entry here
  %    since its form is different
  % if the second entry is the first out-of-place index,
  %    no change, since hat_dist_x(1) should remain unchanged
  %    and since s(1) gives the 'starting' index of the first
  %    interval to be changed
  % if the first out-of-place index is after the second index,
  %    remove the earlier values, s, since for all those indices
  %    hat_dist_x = dist_x
  if (j == 1)
    hat_dist(1:s(1)) = cavg_dist_x(s(1))/s(1);
  elseif (j > 2)
    s(1:(j-2)) = [];
  end

  if (length(s) > 1)
    % change to be s = [(beginnings-1) ends]
    s = [s(1:end-1) s(2:end)];

    % remove rows where s(i,1) = s(i,2)-1
    % since in these rows, hat_dist_x = dist_x
    s((s(:,1) == s(:,2)-1),:) = [];
    for i = 1:size(s,1)
      hat_dist_x((s(i,1)+1):s(i,2)) = ...
	(cavg_dist_x(s(i,2))-cavg_dist_x(s(i,1)))/(s(i,2)-s(i,1));
    end
  end

  % compute the strain between the monotonic increasing distances
  % and tha actual distances for the current coordinates

  Sstar = sum((dist_x-hat_dist_x).^2); Tstar = sum(dist_x.^2);
  S = sqrt(Sstar/Tstar);

  if (Sstar <= EPSILON^2)
    len_dS_dx = 0;
  else
    % compute best offset direction for each coordinate of each point
    % to minimize the strain
    % want U(k,:) = sum_r sum_s { (delta(k-r)-delta(k-s)) *
    %		((dist_x[r,s]-hat_dist_x[r,s])/Sstar - dist_x[r,s]/Tstar) *
    %		(x(r,:)-x(s,:))/dist_x[r,s]
    %
    % easiest to do by indexing over valid [r,s] pairs, and accumulating
    % those into all applicable points, {k}

    %dS_dx = zeros(N,L);
    dS_dx(:) = 0;
    hat_dist_x = hat_dist_x ./ max(dist_x,EPSILON.^2);

    % use hat_dist_x to hold the scale factor...
    hat_dist_x = ((1-hat_dist_x)/Sstar - 1/Tstar);

    % ORIGINAL : 30.11s ==========================================
    % for m = 1:M
    %   r = gdist(m,2); s = gdist(m,3);
    %   v = (x(r,:)-x(s,:)) * hat_dist_x(m);
    %   dS_dx(r,:) = dS_dx(r,:) + v;
    %   dS_dx(s,:) = dS_dx(s,:) - v;
    % end

    % MEX 1 : 15.86s =============================================
    sub_order_mds(M,dS_dx,gdist,x,hat_dist_x);
    
    % MEX 2 : 17.62s =============================================
    % r = gdist(1:M,2);  s = gdist(1:M,3);
    % v = (x(r,:) - x(s,:)) .* repmat(hat_dist_x(1:M),[1 size(x,2)]);
    % % for m = 1:M,
    % %   dS_dx(r(m),:) = dS_dx(r(m),:) + v(m,:);
    % %   dS_dx(s(m),:) = dS_dx(s(m),:) - v(m,:);
    % % end
    % sub_order_mds2(M,dS_dx,r,s,v);
    

    dS_dx = S * dS_dx;
    len_dS_dx = sqrt(sum(sum(dS_dx.^2)));
  end

  if (len_dS_dx > EPSILON)

    dS_dx = dS_dx/len_dS_dx;

    if (iter_count < 1)
      dS_dx_prev = dS_dx; S_prev = S * ones(1,5);

      % you know that, for this round, f1*f2*f3 = 2.6
      % set it up so that len_update = S/len_dS_dx
      % to minimize overshoot
      len_update = min(1,S/(2.6*len_dS_dx));
    end

    % do not know why these factors are used...
    f1 = sum(sum(dS_dx.*dS_dx_prev))^3; f1 = 4.0^f1;
    f2 = 1.3/(1 + min(1,S/S_prev(5))^5);
    f3 = min(1,S/S_prev(1));
    len_update = len_update*f1*f2*f3;

    if VERBOSE,
      disp(['(' int2str(iter_count) ') len_dS_dx = ' ...
            num2str(len_dS_dx) ' len_update = ' ...
            num2str(len_update) ' S = ' num2str(S)]);
      disp(['f1 = ' num2str(f1) ' f2 = ' num2str(f2) ...
            ' f3 = ' num2str(f3)]);
    end
    if L > 1 && DoPlot > 0,
      if (nargin > 1)
        plot(x(:,1),x(:,2),'o');
        line([1;1]*x(:,1)'-[0;1]*len_update*dS_dx(:,1)', ...
             [1;1]*x(:,2)'-[0;1]*len_update*dS_dx(:,2)');
      else
        % use ground truth to shift, scale & rotate
        x_plot = x - ones(N,1)*mean(x);
        [Ux,Sx,Vx] = svd(x_plot \ x_true); Sx = mean(diag(Sx));
        x_plot = Sx*x_plot*Ux*Vx';
        plot(x_plot(:,1),x_plot(:,2),'bx'); hold on;
        plot(x_true(:,1),x_true(:,2),'r+'); hold off;
        line([1;1]*x_plot(:,1)'-[0;1]*len_update*dS_dx(:,1)', ...
             [1;1]*x_plot(:,2)'-[0;1]*len_update*dS_dx(:,2)');
        % keyboard;
      end
      text(0.02,0.95,sprintf('iter=%d/%d',iter_count+1,MAX_ITER),'units','normalized');
      drawnow;
    end
    
    x = x - len_update*dS_dx;

    dS_dx_prev = dS_dx;
    S_prev = [S S_prev(1:4)];
  end

  iter_count = iter_count + 1;
end



if L > 1 && DoPlot > 0,
  tmpv = get(gca,'xlim');  tmpv = max(abs(tmpv));  set(gca,'xlim',[-tmpv tmpv]);
  tmpv = get(gca,'ylim');  tmpv = max(abs(tmpv));  set(gca,'ylim',[-tmpv tmpv]);
  grid on;
  xlabel('MDS Dim 1');
  ylabel('MDS Dim 2');
  title('Original (red) and MDS output results (blue)');
  drawnow;
end


return
