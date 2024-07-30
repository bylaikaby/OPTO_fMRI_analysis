clear all;
clear pdist2 linkage2 linkage3

% make data
n_data = 200;  n_dim  = 40;
X = rand(n_data, n_dim);
fprintf('\n data = %d x %d', n_data, n_dim);
fprintf('\n Type ''X'' to see data.\n');

% change recursive limit
def_rec = get(0, 'RecursionLimit');
set(0, 'RecursionLimit', 5000);


% compute distance
% run pdist
metric = 'ci';   % euclid, seuclid, cityblock, mahal, minkowski
fprintf('\n pdist: metric = ''%s''',metric);
Y1 = [];  Y2 = [];  Y = [];
if n_data*n_dim <= 10000, 
  fprintf('\n  pdist()... ');
  t_s = clock;
  Y1 = pdist(X,metric);
  %size(Y1)
  t_e = etime(clock, t_s);
  fprintf(' %.3f s', t_e);
end
% run pdist2
fprintf('\n  pdist2()... ');
t_s = clock;
Y2 = pdist2(X,metric);
%size(Y2)
t_e = etime(clock, t_s);
fprintf(' %.3f s', t_e);

if length(Y1) ~= 0,
  Y  = [Y1, Y2];
  dY = Y1 - Y2;
  nZero = find(dY ~= 0);
  fprintf('\n  not the same: %d/%d',length(nZero),length(dY));
  if length(nZero) ~= 0,
    err = dY(nZero) / Y1(nZero) * 100.;
    fprintf('\n  error(%%): %.2e+-%.2e (%.2e to %.2e)',...
	    mean(err(:)), std(err(:)), min(err(:)), max(err(:)));
  end
  fprintf('\n Type ''Y'' to see the result of pdist(s).\n');
end

% get linkage
method = 'ce';   % single, complete, average, centroid, ward
fprintf('\n linkage: method = ''%s''',method);
Z1 = [];  Z2 = [];  Z3 = [];  Z = [];
% run linkage
fprintf('\n  linkage()... ');
t_s = clock;
Z1 = linkage(Y2, method);
%size(Z)
t_e = etime(clock, t_s);
fprintf(' %.3f s', t_e);

% run linkage2
fprintf('\n  linkage2()... ');
t_s = clock;
Z2 = linkage2(Y2, method);
%size(Z)
t_e = etime(clock, t_s);
fprintf(' %.3f s', t_e);

% run linkage3
%fprintf('\n  linkage3()... ');
%t_s = clock;
%Z3 = linkage3(Y2, method);
%size(Z)
%t_e = etime(clock, t_s);
%fprintf(' %.3f s', t_e);

%Z = [Z3, Z2];

Z = [Z1, Z2];
%dZ = Z1 - Z2;
%nZero = find(dZ ~= 0);
%fprintf('\n  not the same: %d/%d',length(nZero),length(dZ));
fprintf('\n Type ''Z'' to see the result of linkage(s).\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'RecursionLimit', def_rec);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

