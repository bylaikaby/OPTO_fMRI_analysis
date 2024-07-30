function val = vecside(x,y,px1,py1,px2,py2)
%VECSIDE - Determine sides of points relative to the given vector.
%  VAL = VECSIDE(X,Y,PX1,PY1,PX2,PY2) determines sides of points relative
%  to the given vector.
%
%
%  VERSION :
%    0.90 05.02.10 YM  pre-release
%
%  See also

% compute exterior product
v = x * (py1 - py2) + px1 * (py2 - y) + px2 * (y - py1);

if isvector(v),
  val = zeros(size(v));
  val(v(:) > 0)  =  1;  % right side
  val(v(:) < 0)  = -1;  % left  side
  val(v(:) == 0) =  0;  % on the line
else
  if v > 0,
    % right side
    val = 1;
  elseif v < 0,
    % left side
    val = -1;
  else
    % on-line
    val = 0;
  end
end

return
