dim1=120000;
dim2=120000;
a=floor(100000*rand(dim1,1));
b=floor(100000*rand(dim2,1));
% now a nad b are  monodimensional array of double
tic;v1=conv(a,b);t1=toc         %----> matlab conv
tic;v2=mcgo_conv(a,b);t2=toc    %---->our function : mcgo_conv 
tic;v3=conv_1d(a,b);t3=toc      %----> our optimized function: conv_1d



disp('variazione tempo');       %---> speed improvement for mcgo_conv
(t2-t1)/t1*100
disp('nnz (v1 - v2)');
nnz(v1-v2)                     %----> to verify accuracy  :-)

disp('variazione tempo');       %---> speed improvement for conv_1d
(t3-t1)/t1*100
disp('nnz (v1 - v2)');
nnz(v1-v3)                     
