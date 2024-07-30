
moviefile = 'e:/Mri/Movies/swars1.avi';
FRAMES = [0:100];

% computed by Matlab
img = [];
tic;
for N=1:length(FRAMES),
  %img(:,:,:,N) = vavi_read(moviefile,FRAMES(N));
  img = vavi_read(moviefile,FRAMES(N),1);
  if N == 1,
     m1 = img;
     s1 = img.*img;
   else
     m1 = m1 + img;
     s1 = s1 + img.*img;
   end
end
m1 = m1 / length(FRAMES);
s1 = s1 / length(FRAMES) - m1.*m1;
s1 = s1 * length(FRAMES) / (length(FRAMES) - 1);
s1 = sqrt(s1);
%m1 = squeeze(mean(img,4));
%s1 = squeeze(std(img,0,4));
te = toc;
fprintf('matlab:    %.3fsec\n',te);

% computed by vavi_mean
tic;
[m2, s2] = vavi_mean(moviefile,FRAMES);
te = toc;
fprintf('vavi_mean: %.3fsec\n',te);


% compute difference
dm = m2 - m1;
ds = s2 - s1;

fprintf('mean: maxdiff = %f\n',max(dm(:)));
fprintf('std:  maxdiff = %f\n',max(ds(:)));


figure;
subplot(3,2,1);
n1 = (m1 - min(m1(:)))/(max(m1(:)) - min(m1(:)));
imagesc(n1);
subplot(3,2,2);
imagesc(s1/max(s1(:)));
subplot(3,2,3);
n2 = (m2 - min(m2(:)))/(max(m2(:)) - min(m2(:)));
imagesc(n2);
subplot(3,2,4);
imagesc(s2/max(s2(:)));
subplot(3,2,5);
tmp = (dm - min(dm(:)))/(max(m2(:)) - min(m2(:)));
imagesc(tmp);
subplot(3,2,6);
tmp = (ds - min(ds(:)))/(max(s2(:)) - min(s2(:)));
imagesc(tmp);
