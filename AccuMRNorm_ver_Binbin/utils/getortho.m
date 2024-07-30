function p = getortho(p1, p2, d)
%GETORTHO - compute orthogonal line to p1-p2 segements with length d
%	p = GETORTHO(p1, p2, d)
%	NKL, 16.11.02

alpha = -90;
alph = alpha*pi/180;
m = [cos(alph) sin(alph); -sin(alph) cos(alph)];
d12 = norm(p2-p1);
v = m * [p2 - p1];
p = v * d/d12 + p1;
return;
