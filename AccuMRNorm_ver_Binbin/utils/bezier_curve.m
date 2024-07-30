function BEZ = bezier_curve(CI,CP)
%BEZIER_CURVE - Create a Bezier curve.
%  BEZ = BEZIER_CURVE(CI,CPS) creats a Bezier curve.
%    CI as normalized positions on the curve (0~1).
%    CP as (dim,points)
%
%  EXAMPLE :
%    cps = [[0;0],[2;3],[3;4],[4;1]];
%    bps = bezier_curve([0:1/100:1],cps);
%    plot(bps(1,:),bps(2,:),'b-');
%    hold on;
%    plot(cps(1,:),cps(2,:),'r-o');
%
%  NOTE :
%    see http://sach1o.blog80.fc2.com/blog-entry-36.html
%
%  VERSION :
%    0.90 05.01.12 YM  pre-release
%
%  See also diag rot90 pascal

if nargin < 2, eval(sprintf('help %s',mfilename)); return;  end

if isscalar(CI),  CI = [0:1/(CI-1):1];  end

BEZ = CP * sub_bernstein(size(CP,2)-1,CI);


return


function BE = sub_bernstein(NN,TT)
onest = ones(1, length(TT));
II = [0:NN]'*onest;
BI = diag(rot90(pascal(NN+1)))*onest;
TT = ones(NN+1,1)*TT;

BE = (1 - TT).^(NN - II).*BI.*(TT.^II);

return


