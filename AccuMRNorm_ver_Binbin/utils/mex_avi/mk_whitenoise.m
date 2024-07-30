function mov = mk_whitenoise(filename,nframes,pixres,bw)
% scripts to make the avi movie of white noise.
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
  fprintf('usage: mov = mk_whitenoise(filename,nframes,[pixres],[bw])');
  return;
end


% variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3,  pixres = 1;  end  % pixel resolution.
if nargin < 4,  bw     = 0;  end  % Black/White or Color.
width   = 240;
height  = 180;
fps     =  30;  % frame per sec. for AVI.
quality = 100;  % compression quality. Matlab's default is 75.
vcodec  = 'indeo5';

% Create a Matlab movie %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if bw,
  fprintf('mk_whitenoise: BW[%dx%dx%d]',width,height,nframes);
  %cmap = gray(236);  % gray scale of 236 levels for INDEO
  if pixres <= 1,
    for N = nframes:-1:1,
      img = uint8(round(rand(height,width)*255.0));
      mov(N) = im2frame(cat(3,img,img,img));
      %img = uint8(round(rand(height,width)*235.0));
      %mov(N) = im2frame(img,cmap);
      if mod(N,200) == 0,  fprintf('.');  end
    end
  else
    hl = round(height/pixres);
    wl = round(width/pixres);
    hi = floor([0:height-1]/pixres) + 1;
    wi = floor([0:width-1]/pixres) + 1;
    for N = nframes:-1:1,
      tmpimg = rand(hl,wl);
      img    = uint8(tmpimg(hi,wi)*255.0);
      mov(N) = im2frame(cat(3,img,img,img));
      %img    = uint8(tmpimg(hi,wi)*235.0);
      %mov(N) = im2frame(img,cmap);
      if mod(N,200) == 0,  fprintf('.');  end
    end
  end
else
  fprintf('mk_whitenoise: COL[%dx%dx%d]',width,height,nframes);
  if pixres <= 1,
    for N = nframes:-1:1,
      img = uint8(round(rand(height,width,3)*255.0));
      mov(N) = im2frame(img);
      if mod(N,200) == 0,  fprintf('.');  end
    end
  else
    hl = round(height/pixres);
    wl = round(width/pixres);
    hi = floor([0:height-1]/pixres) + 1;
    wi = floor([0:width-1]/pixres) + 1;
    for N = nframes:-1:1,
      tmpimg = rand(hl,wl,3);
      img    = uint8(round(tmpimg(hi,wi,:)*255.0));
      mov(N) = im2frame(img);
      if mod(N,200) == 0,  fprintf('.');  end
    end
  end
end
fprintf(' done.\n');


% Save the movie as AVI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('saving to ''%s''...',filename);
movie2avi(mov,filename,'compression',vcodec,'fps',fps,'quality',quality);
fprintf(' done.\n');


% no need to keep 'mov' as 'ans'. %%%%%%%%%%%%%%%%%%%%%%%%%%
if nargout == 0,  clear mov;  end
