function vmk_whitenoise(filename,nframes,pixres,type)
% scripts to make the avi movie of white noise.
% USAGE : vmk_whitenoise(filename,nframes,[pixres],[type])
%          pixres : pixel size of elements.
%          type    : types, 'bw','gray' or 'color'
%
% NOTE :
%  1) 'pixres' of 2^x helps file to be smaller, otherwise file size
%     is almost the same whether gray or colored (indeo5).
%  2) 'quality' of 100 for indeo5 gives good images although the file
%     became 30 % larger than that of 75.
%  3) distribution of random value is quite uniform by Matlab,
%     but CODEC will make it juggy.
%      indeo5:  juggy but better than others
%      indeo3:  sparse
%      cinepak: bellshaped
%
% VERSION/DATE/AUTHOR
%  0.90 17.09.03 YM  pre-release
%

% usage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0,
  fprintf('usage: vmk_whitenoise(filename,nframes,[pixres],[type])');
  return;
end


% variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3,  pixres = 1;    end  % pixel resolution.
if nargin < 4,  type = 'col';  end  % Black/White or Color.
width   = 240;
height  = 180;
width   = 320;
height  = 240;
fps     =  30;  % frame per sec. for AVI.
quality = 100;  % compression quality. Matlab's default is 75.
vcodec  = 'indeo5';

FRAME_DURATION = 3;

% Create a Matlab movie %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch lower(type),
 case { 'bw', 'blackwhite' }
  subMkBlackWhite(width,height,nframes,FRAME_DURATION,pixres,...
                  filename,vcodec,quality,fps);
 case { 'gr', 'gray' }
  subMkGray(width,height,nframes,FRAME_DURATION,pixres,...
            filename,vcodec,quality,fps);
 case { 'color', 'col' }
  subMkColor(width,height,nframes,FRAME_DURATION,pixres,...
             filename,vcodec,quality,fps);
 case { 'white square', 'wsquare' }
  subMkWhiteSquare(width,height,nframes,FRAME_DURATION,pixres,...
                   filename,vcodec,quality,fps);
 case { 'polar','ncpolar' }
  subMkPolar(nframes,FRAME_DURATION,pixres,type,...
             filename,vcodec,quality,fps);
 otherwise
  fprintf(' NOT SUPPORTED YET...');
end
fprintf(' done.\n');

% no need to keep 'mov' as 'ans'. %%%%%%%%%%%%%%%%%%%%%%%%%%
if nargout == 0,  clear mov;  end


return;




% Save the movie as AVI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subSaveMovie(filename,mov,vcodec,quality,fps)
if isempty(filename), return; end
fprintf('saving to ''%s''...',filename);
[fp,fn,fe] = fileparts(filename);
namestr = sprintf('%s%s Video',fn,fe);  % no longer than 64.
movie2avi(mov,filename,'compression',vcodec,'quality',quality,...
          'fps',fps,'videoname',namestr);

return


% sub-function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  subMkBlackWhite(width,height,nframes,FRAME_DURATION,pixres,filename,vcodec,quality,fps)
fprintf('vmk_whitenoise: BW[%dx%dx%d]',width,height,nframes);
[fp,fn,fe] = fileparts(filename);
namestr = sprintf('%s%s Video',fn,fe);  % no longer than 64.
aviobj = avifile(filename,'compression',vcodec,'quality',quality,...
                 'fps',fps,'videoname',namestr);
if pixres <= 1,
  for N = 1:nframes,
    if mod(N,FRAME_DURATION) == 1,
      img = uint8(round(rand(height,width)));
      img = cat(3,img,img,img);
    end
    aviobj = addframe(aviobj,im2frame(img));
    %mov(N) = im2frame(img);
    if mod(N,200) == 0,  fprintf('.');  end
  end
else
  hl = ceil(height/pixres);
  wl = ceil(width/pixres);
  hi = floor([0:height-1]/pixres) + 1;
  wi = floor([0:width-1]/pixres) + 1;
  for N = 1:nframes,
    if mod(N,FRAME_DURATION) == 1,
      tmpimg = rand(hl,wl);
      img    = uint8(round(tmpimg(hi,wi))*255.0);
      img    = cat(3,img,img,img);
    end
    aviobj = addframe(aviobj,im2frame(img));
    %mov(N) = im2frame(img);
    if mod(N,200) == 0,  fprintf('.');  end
  end
end
aviobj = close(aviobj);

return;


% sub-function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subMkGray(width,height,nframes,FRAME_DURATION,pixres,filename,vcodec,quality,fps)
fprintf('vmk_whitenoise: GR[%dx%dx%d]',width,height,nframes);
%cmap = gray(236);  % gray scale of 236 levels for INDEO
[fp,fn,fe] = fileparts(filename);
namestr = sprintf('%s%s Video',fn,fe);  % no longer than 64.
aviobj = avifile(filename,'compression',vcodec,'quality',quality,...
                 'fps',fps,'videoname',namestr);
if pixres <= 1,
  for N = 1:nframes,
    if mod(N,FRAME_DURATION) == 1,
      img = uint8(round(rand(height,width)*255.0));
      img = cat(3,img,img,img);
    end
    aviobj = addframe(aviobj,im2frame(img));
    %mov(N) = im2frame(img);
    %img = uint8(round(rand(height,width)*235.0));
    %mov(N) = im2frame(img,cmap);
    if mod(N,200) == 0,  fprintf('.');  end
  end
else
  hl = ceil(height/pixres);
  wl = ceil(width/pixres);
  hi = floor([0:height-1]/pixres) + 1;
  wi = floor([0:width-1]/pixres) + 1;
  for N = 1:nframes,
    if mod(N,FRAME_DURATION) == 1,
      tmpimg = rand(hl,wl);
      img    = uint8(round(tmpimg(hi,wi)*255.0));
      img = cat(3,img,img,img);
    end
    aviobj = addframe(aviobj,im2frame(img));
    %mov(N) = im2frame(img);
    %img    = uint8(tmpimg(hi,wi)*235.0);
    %mov(N) = im2frame(img,cmap);
    if mod(N,200) == 0,  fprintf('.');  end
  end
end
aviobj = close(aviobj);

return;


% sub-function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subMkColor(width,height,nframes,FRAME_DURATION,pixres,filename,vcodec,quality,fps)
fprintf('vmk_whitenoise: CL[%dx%dx%d]',width,height,nframes);

[fp,fn,fe] = fileparts(filename);
namestr = sprintf('%s%s Video',fn,fe);  % no longer than 64.
aviobj = avifile(filename,'compression',vcodec,'quality',quality,...
                 'fps',fps,'videoname',namestr);
if pixres <= 1,
  for N = 1:nframes,
    if mod(N,FRAME_DURATION) == 1,
      img = uint8(round(rand(height,width,3)*255.0));
    end
    aviobj = addframe(aviobj,im2frame(img));
    %mov(N) = im2frame(img);
    if mod(N,200) == 0,  fprintf('.');  end
    end
else
  hl = ceil(height/pixres);
  wl = ceil(width/pixres);
  hi = floor([0:height-1]/pixres) + 1;
  wi = floor([0:width-1]/pixres) + 1;
  for N = 1:nframes,
    if mod(N,FRAME_DURATION) == 1,
      tmpimg = rand(hl,wl,3);
      img    = uint8(round(tmpimg(hi,wi,:)*255.0));
    end
    aviobj = addframe(aviobj,im2frame(img));
    %mov(N) = im2frame(img);
    if mod(N,200) == 0,  fprintf('.');  end
  end
end
aviobj = close(aviobj);

return;


% sub-function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subMkWhiteSquare(width,height,nframes,FRAME_DURATION,pixres,filename,vcodec,quality,fps)
fprintf('vmk_whitenoise: WS[%dx%dx%d]',width,height,nframes);
nf   = ceil(nframes/FRAME_DURATION);
nx   = floor(width/pixres);
ny   = floor(height/pixres);
if nf < nx*ny,
  pseg = randperm(nx*ny);
  pseg = pseg(1:nf);
  else
    pseg = randperm(nf);
end
pseg = mod(pseg,nx*ny);
ph = floor(pseg/nx)*pixres;
pw = mod(pseg,nx)*pixres;

prgn = 1:pixres;
k = 0;

[fp,fn,fe] = fileparts(filename);
namestr = sprintf('%s%s Video',fn,fe);  % no longer than 64.
aviobj = avifile(filename,'compression',vcodec,'quality',quality,...
                 'fps',fps,'videoname',namestr);
for N = 1:nframes,
  if mod(N,FRAME_DURATION) == 1,
    k = k + 1;
    tmpimg = zeros(height,width,3);
    %ph = floor(pseg(k)/nx)*pixres;
    %pw = mod(pseg(k),nx)*pixres;
    tmpimg(prgn+ph(k),prgn+pw(k),:) = 1.0;
    tmpimg = uint8(tmpimg*255.0);
  end
  aviobj = addframe(aviobj,im2frame(tmpimg));
  %mov(N) = im2frame(tmpimg);
  if mod(N,200) == 0,  fprintf('.');  end
end
aviobj = close(aviobj);

return;


% sub-function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subMkPolar(nframes,FRAME_DURATION,pixres,type,filename,vcodec,quality,fps)
width = 320;  height = 240;  psz = 32;
fprintf('vmk_whitenoise: PL[%dx%dx%d]',width,height,nframes);
% read a small polar stimulus
if strcmpi(type,'ncpolar')
  fid = fopen(sprintf('./ncpolar%dx%d.raw',psz,psz));
else
  fid = fopen(sprintf('./polar%dx%d.raw',psz,psz));
end
simg = fread(fid,psz*psz*3,'uint8');
fclose(fid);
simg = reshape(simg,3,psz,psz);
simg = permute(simg,[3 2 1]);
nf   = ceil(nframes/FRAME_DURATION);
nx   = floor((width-psz)/pixres)+1;
ny   = floor((height-psz)/pixres)+1;
if nf < nx*ny,
  pseg = randperm(nx*ny);
  pseg = pseg(1:nf);
else
  pseg = randperm(nf);
end
pseg = mod(pseg,nx*ny);
ph = floor(pseg/nx)*pixres;
pw = mod(pseg,nx)*pixres;

prgn = 1:psz;
k = 0;

[fp,fn,fe] = fileparts(filename);
namestr = sprintf('%s%s Video',fn,fe);  % no longer than 64.
aviobj = avifile(filename,'compression',vcodec,'quality',quality,...
                 'fps',fps,'videoname',namestr);
for N = 1:nframes,
  if mod(N,FRAME_DURATION) == 1,
    k = k + 1;
    tmpimg = uint8(zeros(height,width,3));
    %ph = floor(pseg(k)/nx)*pixres;
    %pw = mod(pseg(k),nx)*pixres;
    tmpimg(prgn+ph(k),prgn+pw(k),:) = simg;
  end
  aviobj = addframe(aviobj,im2frame(tmpimg));
  if mod(N,200) == 0,  fprintf('.');  end
end
aviobj = close(aviobj);


return;
