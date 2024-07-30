function stmimages = getstmimages(stmobjs)
%GETSTMIMAGES - generate images of stimuli from 'stmobj' structure.
% STMIMAGES = GETSTMIMAGES(STMOBJS)
% USAGE :   stmimages = getstmimages(stmobj)
%           stmimages: (nstimuli,128,128,3) ranging 0-1
% VERSION : 1.00 27-Apr-03  YM
%         : 1.01 17-May-03  YM  improved processing speed.
%         : 1.02 29-Apr-05  YM  supports orientation for sines/sqwaves.
%
% See also STM_READ, GETDIRS

width = 128;  height = 128;  depth = 3;

Dirs = getdirs;
stimhome = Dirs.stimhome(1:end-1);     % remove '/'
bitmap_dir = Dirs.bitmapdir(1:end-1);  % remove '/'

fprintf('getstmimages:stimhome:   %s\n',stimhome);
fprintf('getstmimages:bitmap_dir: %s\n',bitmap_dir);


imgdirs{1} = sprintf('%s/stimuli/CorelRaw/',stimhome);
imgdirs{2} = sprintf('%s/stimuli/images/',stimhome);
imgdirs{3} = sprintf('%s/stimuli/objects/',stimhome);
imgdirs{4} = '';


fprintf('making images: ');
nimages = length(stmobjs);
stmimages = zeros(nimages,width,height,depth);
for k=1:nimages,
  if mod(k,10) == 0, fprintf('.');  end
  gobj = stmobjs{k};
  switch gobj.type
   case { 'blank' }
	tmpimg = ones(width,height,depth)*0.5;
   case { 'ditto' }
	src = k - 1;
	tmpimg = squeeze(stmimages(src,:,:,:));
   case { 'alias' }
	src = gobj.stmidsrc + 1;  % since matlab array index starts from 1.
	tmpimg = squeeze(stmimages(src,:,:,:));
   case { 'image', 'polar' }
	tmpimg = subLoadRawImage(imgdirs,gobj.imgfile,gobj.width, ...
							 gobj.height,gobj.depth);
	tmpimg = tmpimg(:,:,1:3);  % need only RGB, nor A
   case { 'movie' }
	imgfile = sprintf('%s/movies.gif',bitmap_dir);
	tmpimg = subLoadGifImage(imgfile);
   case { 'sines' }
	imgfile = sprintf('%s/sinewaves.gif',bitmap_dir);
	tmpimg = subLoadGifImage(imgfile,gobj.ori);
   case { 'sqwaves' }
	imgfile = sprintf('%s/sqwaves.gif',bitmap_dir);
	tmpimg = subLoadGifImage(imgfile,gobj.ori);
   case { 'pinwheel' }
	imgfile = sprintf('%s/pinwheel.gif',bitmap_dir);
	tmpimg = subLoadGifImage(imgfile);
   case { 'randots' }
	imgfile = sprintf('%s/randots.gif',bitmap_dir);
	tmpimg = subLoadGifImage(imgfile);
   case { 'ransqrs' }
	switch gobj.subtype
	 case { 'bw' }
	  imgfile = sprintf('%s/bwransqrs.gif',bitmap_dir);
	 case { 'gray' }
	  imgfile = sprintf('%s/grayransqrs.gif',bitmap_dir);
	 case { 'color' }
	  imgfile = sprintf('%s/colransqrs.gif',bitmap_dir);
	end
	tmpimg = subLoadGifImage(imgfile);
   case { 'cphase' }
	switch gobj.cptype
	 case { 'sines' }
	  imgfile = sprintf('%s/cpsines.gif',bitmap_dir);
	 case { 'randots' }
	  imgfile = sprintf('%s/cprandots.gif',bitmap_dir);
	 case { 'pairdots' }
	  imgfile = sprintf('%s/cppairdots.gif',bitmap_dir);
	end
	tmpimg = subLoadGifImage(imgfile);
   case { 'masdots' }
	imgfile = sprintf('%s/masdots.gif',bitmap_dir);
	tmpimg = subLoadGifImage(imgfile);
   otherwise
	fprintf('getstmimages: %s not supported yet...\n',gobj.type);
	imgfile = sprintf('%s/notsupported.gif',bitmap_dir);
	tmpimg = subLoadGifImage(imgfile);
  end
  tmpimg = imresize(tmpimg,[width,height]);
  stmimages(k,:,:,:) = tmpimg(:,:,:);
end
fprintf(' done.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imgraw = subLoadRawImage(imgdirs,imgfile,w,h,d)

found = 0;
for k=1:length(imgdirs),
  filename = sprintf('%s%s',imgdirs{k},imgfile);
  if length(dir(filename)),
    found = 1;
    break;
  end
end

if found == 0,
  % could not find the imgfile
  imgraw = zeros(w,h,d);
  fprintf('getstmimages.subLoadRawImage: can not find %s.\n',imgfile);
  return;
end

fid = fopen(filename,'rb');
if fid == -1,
  imgraw = zeros(w,h,d);
  fprintf('getstmimages.subLoadRawImage: can not open %s.\n',imgfile);
  return;
end

imgraw = fread(fid,d*h*w,'uint8');
fclose(fid);

imgraw = reshape(imgraw,[d,h,w]);
imgraw = permute(imgraw,[3 2 1])/255.;  % imgraw(w,h,d), scaled to 0-1.

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imgraw = subLoadGifImage(imgfile,angle)

if ~exist('angle','var'),  angle = 0;  end

[tmpimg,map] = imread(imgfile,'gif',1);
imgraw = ind2rgb(tmpimg,map);  % RGB, no alpha

if angle == 0,  return; end

origsize = size(imgraw);

imgraw = imrotate(imgraw,angle,'bilinear');

sely = [1:origsize(1)] + round((size(imgraw,1)-origsize(1))/2);
selx = [1:origsize(2)] + round((size(imgraw,2)-origsize(2))/2);
imgraw = imgraw(sely,selx,:);

return;
