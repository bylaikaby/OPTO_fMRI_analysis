clear all;


data = rand(1,10000);
data = abs(data);

MIN_DIST = 3.0;

[val loc] = findpeaks(abs(data),'minpeakheight',0.5);
[val ix] = sort(val,'descend');
loc = loc(ix);

locx = sort(rm_neighbors(loc,MIN_DIST));

[val2 loc2] = findpeaks(abs(data),'minpeakheight',0.5,'minpeakdistance',MIN_DIST);


% MATLAB R2007b seems to have a bug(s) in findpeaks()....
% MATLAB R2011b seems to be fine.

fprintf(' isequal(locx,loc2)   = %g\n',isequal(locx,loc2));



tmpspk = loc;
nspk = length(tmpspk);
for ispk = 1:nspk
  if tmpspk(ispk) == 0,  continue;  end
  is = tmpspk(ispk) - MIN_DIST;
  ie = tmpspk(ispk) + MIN_DIST;
  for jspk = ispk+1:nspk,
    if tmpspk(jspk) >= is && tmpspk(jspk) <= ie
      tmpspk(jspk) = 0;
    end
  end
end
tmpspk = sort(tmpspk(tmpspk > 0));
clear ispk jspk nspk is ie;

fprintf(' isequal(locx,tmpspk) = %g\n',isequal(locx,tmpspk));

