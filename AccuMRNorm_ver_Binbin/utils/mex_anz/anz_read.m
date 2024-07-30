function [IMG HDR] = anz_read(filename,varargin)
%ANZ_READ - reads ANALYZE image/header
%  [IMG HDR] = ANZ_READ(IMGFILE) reads ANALYZE(TM) image.
%
%  VERSION :
%    0.90 12.01.07 YM  pre-release
%    0.91 28.02.07 YM  use uigetfile()
%    0.92 06.08.07 YM  bug fix when big-endian
%    0.93 07.04.08 YM  filename can be as .raw
%    0.94 10.02.11 YM  no need of utlswapbytes().
%    0.95 11.05.11 YM  supports 'mach'.
%    0.96 08.01.12 YM  supports 'rgb' as [x y rgb z].
%    0.97 26.05.15 YM  supports '.nii' NIfTI-1.
%    0.98 29.07.17 YM  updates for 'rgb' as [rgb x y z].
%
%  See also anz_write hdr_read

if nargin == 0 && nargout == 0,  help anz_read; return;  end

IMG = [];  HDR = [];
if ~exist('filename','var'),  filename = '';  end

if isempty(filename),
  [tmpf,tmpp] = uigetfile({'*.img;*.hdr','ANALYZE-7.5 data (*.img/*hdr)';'*.nii','NIfTI-1 data (*.nii)';'*.*','All Files (*.*)'},...
                          'Pick an ANALYZE-7.5/NIfTI-1 file');
  if tmpf == 0,  return;  end
  filename = fullfile(tmpp,tmpf);
  clear tmpf tmpp;
end

[fp,fr,fe] = fileparts(filename);

switch lower(fe)
 case {'.hdr'}
  % filename as 'header' file.
  imgfile = fullfile(fp,sprintf('%s.img',fr));
  hdrfile = filename;
 case {'.nii'}
  % NifTI-1 file: file=hdr+img
  imgfile = filename;
  hdrfile = filename;
 otherwise
  % filename as 'image' file, can be like *.raw or so.
  imgfile = filename;
  hdrfile = fullfile(fp,sprintf('%s.hdr',fr));
end


if ~exist(hdrfile,'file'),
  error('%s: ''%s'' not found.',mfilename,hdrfile);
end


MACH_FORMAT = '';
for N = 1:length(varargin),
  switch lower(varargin{N}),
   case {'mach'}
    MACH_FORMAT = varargin{N+1};
  end
end


HDR = hdr_read(hdrfile);
if isempty(HDR),  return;  end

if isempty(MACH_FORMAT),
  % checks need to swap bytes or not
  fid = fopen(hdrfile,'r');
  hsize = fread(fid, 1, 'int32=>int32');
  [f, p, mach] = fopen(fid);
  fclose(fid);
  if hsize > hex2dec('01000000'),
    % need to swap bytes, open with correct machine-format.
    if strncmpi(mach,'ieee-be',7),
      mach = 'ieee-le';
    else
      mach = 'ieee-be';
    end
  end
else
  mach = MACH_FORMAT;
end


if ~exist(imgfile,'file'),
  error('%s: ''%s'' not found.',mfilename,imgfile);
end
fid = fopen(imgfile,'rb',mach);

if strcmpi(fe,'.nii'),
  fseek(fid,HDR.dime.vox_offset,'bof');
end

% /* Acceptable values for datatype */
% #define DT_NONE 0
% #define DT_UNKNOWN 0
% #define DT_BINARY 1
% #define DT_UNSIGNED_CHAR 2
% #define DT_SIGNED_SHORT 4
% #define DT_SIGNED_INT 8
% #define DT_FLOAT 16
% #define DT_COMPLEX 32
% #define DT_DOUBLE 64
% #define DT_RGB 128
% #define DT_ALL 255
if HDR.dime.datatype == 2,
  IMG = fread(fid,inf,'uint8=>uint8');
elseif HDR.dime.datatype == 4,
  IMG = fread(fid,inf,'int16=>int16');
elseif HDR.dime.datatype == 8,
  IMG = fread(fid,inf,'int32=>int32');
elseif HDR.dime.datatype == 16,
  IMG = fread(fid,inf,'float=>float');
elseif HDR.dime.datatype == 64,
  IMG = fread(fid,inf,'double=>double');
elseif HDR.dime.datatype == 128,
  IMG = fread(fid,inf,'uint8=>uint8');
else
  fprintf('\n %s: unsupported datatype(=%d).\n',mfilename,HDR.dime.datatype);
  IMG = NaN(HDR.dime.dim((1:HDR.dime.dim(1))+1));
end
fclose(fid);

imsz = HDR.dime.dim((1:HDR.dime.dim(1))+1);
if HDR.dime.datatype == 128,
  imsz = imsz(:)';
  %imsz = [imsz(1:2) 3 imsz(3:end)];
  imsz = [3 imsz];
end
IMG = reshape(IMG,imsz);


return
