a=rand(1,30000000);

% matlab covariance
tic;v1=cov(a);toc
% our function
tic;v2=cov_1d(a);toc
