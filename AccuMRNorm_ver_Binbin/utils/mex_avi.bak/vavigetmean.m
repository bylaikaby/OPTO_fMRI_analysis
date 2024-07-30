function [oImgAvr, oImgStd] = vavigetmean(iAvifile,iFrames)
%  PURPOSE : To get mean images from avifile.
%  USAGE :   [oImgAvr,oImgStd] = vavigetmean(iAvifile,[iFrames]);
%  NOTES :   USE 'vavi_mean.dll' FOR BETTER PERFORMANCE.
%            'iFrames' must be from 0 to max-frames-1.
%            'iFrames < 0' are treated as blank (black) images.
%             if 'iFrames' is empty, then compute mean/std image across
%             whole frames in the 'iAvifile'.
%  SEEALSO : vavi_read.dll, vavi_info.dll, vavi_mean.dll
%  VERSION : 0.90 22.07.03 YM  pre-release
%          : 0.91 25.07.03 YM  improved performace a little.

if nargin == 0,
  help vavigetmean;
  return;
end

% initialize outputs.
oImgAvr = [];  oImgStd = [];

% get info of avifile.
[width, height, maxframes] = vavi_info(iAvifile);
if ~exist('iFrames','var'),  iFrames = 0:maxframes-1;  end

if length(iFrames) == 0,
  % return black image.
  oImgAvr = zeros(height, width, 3);
  oImgStd = zeros(height, width, 3);
  return;
end

% get num. frames to be added.
nframes = length(iFrames);

img1 = zeros(height, width, 3);
img2 = zeros(height, width, 3);

% k < 0 is treated as a blank(black).
tmpFrames = iFrames(find(iFrames >= 0));
% make sure tmpFrames is 1xN matrix.
tmpFrames = reshape(tmpFrames,1,length(tmpFrames));
oldk = -1000;
% compute sums of X and X^2 by frame.
for k = tmpFrames,
  if k ~= oldk,
    tmpimg = vavi_read(iAvifile,k);
    oldk = k;
  end
  img1 = img1 + tmpimg;
  img2 = img2 + tmpimg.*tmpimg;
end

% get mean image.
oImgAvr = img1 / nframes;

% get std of image.
if nframes == 1,
  oImgStd = zeros(height, width, 3);
else
  oImgStd = img2 / nframes - oImgAvr.*oImgAvr;
  oImgStd = oImgStd * nframes / (nframes - 1);
  oImgStd = sqrt(oImgStd);
end






