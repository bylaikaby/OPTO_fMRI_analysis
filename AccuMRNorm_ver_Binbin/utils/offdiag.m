function xoff=offdiag(x,dim1,dim2)
%
%
%
% syntax	xoff=offdiag(x,dim1,dim2)
%
%  inputs
%
%	x - 
%
%	dim1 - 
%
%	dim2 - 
%
%
%  outputs
%
%	xoff - 
%
%
% Author : Michel Besserve, MPI for Biological Cybernetics, Tuebingen, GERMANY

if dim2<dim1
    tmpdim=dim2;
    dim2=dim1;
    dim1=tmpdim;
end
dims=1:length(size(x));
if size(x,dim1)~=size(x,dim2)
warning('matrix not square; returning original value')
xoff=x;
return
end
orgdim=size(x,dim1);
tmpdim=dims(dim2);
dims(dim2)=dims(dim1+1);
dims(dim1+1)=tmpdim;

if any(dims~=1:length(size(x)))
x=permute(x,dims);
end
siz_x=size(x);
siz_x(dim1)=siz_x(dim1)*siz_x(dim1+1);
siz_x=[siz_x(1:(dim1)) 1 siz_x((dim1+2):end)];
x=reshape(x,siz_x);
ind='';
for kdim=1:length(siz_x)
    if kdim~=1
        ind=[ind ','];
    end
     if kdim==dim1
        ind=[ind 'setdiff(1:size(x,dim1),' num2str(1) ':' num2str(orgdim+1) ':' num2str(orgdim^2) ')'];
     else
        ind=[ind ':'];
     end
   
end
eval(['xoff=x(' ind ');']);





