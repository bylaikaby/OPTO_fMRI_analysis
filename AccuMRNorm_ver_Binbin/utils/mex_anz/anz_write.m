function anz_write(filename,HDR,IMGDAT)
%ANZ_WRITE - writes ANALYZE image/header
%  ANZ_WRITE(HDRFILE,HDR,IMGDAT)
%  ANZ_WRITE(HDRFILE,IMGDAT,HDR) writes ANALYZE(TM) image.
%
%  VERSION :
%    0.90 27.02.07 YM  pre-release.
%    0.91 10.02.11 YM  can be anz_write(fname,img,hdr).
%    0.92 08.01.12 YM  supports RGB as [x y rgb z].
%    0.93 26.05.15 YM  supports .nii (NIfTI-1).
%    0.99 27.07.17 YM  updates for DT_RGB as [rgb x y z].
%
%  See also hdr_write anz_read hdr_init nii_init

if nargin == 0,  help anz_write; return;  end

if isempty(filename),
  fprintf('\n ERROR %s: no filename specified.\n',mfilename);
  return
end

if isstruct(IMGDAT),
  % called like anz_write(filename,IMG,HDR)
  tmp = IMGDAT;
  IMGDAT = HDR;
  HDR = tmp;
  clear tmp;
end


% check 'filename'
[fp,fr,fe] = fileparts(filename);
if isfield(HDR.hist,'magic'),
  if strcmpi(HDR.hist.magic,'n+1'),
    % NIfTI-1: nii
    hdrfile = fullfile(fp,sprintf('%s.nii',fr));
    imgfile = hdrfile;
    fe = '.nii';
  elseif strcmpi(HDR.hist.magic,'ni1'),
    % NIfTI-1: hdr+img
    hdrfile = fullfile(fp,sprintf('%s.hdr',fr));
    imgfile = fullfile(fp,sprintf('%s.img',fr));
  else
    error(' ERROR anz_write(): invalid HDR.hist.magic(%s).\n',HDR.hist.magic);
  end
else
  % ANALYZE-7.5
  hdrfile = fullfile(fp,sprintf('%s.hdr',fr));
  imgfile = fullfile(fp,sprintf('%s.img',fr));
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

switch lower(HDR.dime.datatype)
 %case {1,'binary'}
 % ndatatype = 1;
 % wdatatype = 'int8';
 case {2,'uchar', 'uint8'}
  ndatatype = 2;
  wdatatype = 'uint8';
 case {4,'short', 'int16'}
  ndatatype = 4;
  wdatatype = 'int16';
 case {8,'int', 'int32', 'long'}
  ndatatype = 8;
  wdatatype = 'int32';
 case {16,'float', 'single'}
  ndatatype = 16;
  wdatatype = 'single';
 %case {32,'complex'}
 % ndatatype = 32;
 % wdatatype = 'complex';
 case {64,'double'}
  ndatatype = 64;
  wdatatype = 'double';
 case {128,'rgb'}
  ndatatype = 128;
  wdatatype = 'uint8';
 otherwise
  if ischar(HDR.dime.datatype),
    fprintf('\n %s: unsupported datatype(=%s).\n',mfilename,HDR.dime.datatype);
  else
    fprintf('\n %s: unsupported datatype(=%d).\n',mfilename,HDR.dime.datatype);
  end
  return
end

% check image size
nvox = prod(double(HDR.dime.dim((1:HDR.dime.dim(1))+1)));
if ndatatype == 128,
  nvox = nvox*3;
  % if size(IMGDAT,3) ~= 3,
  %   error(' ERROR %s: IMGDAT must be (x,y,rgb,slice) for DT_RGB\n',mfilename);
  % end
  if size(IMGDAT,1) ~= 3,
    % supported in 3D-Slicer 4
    error(' ERROR %s: IMGDAT must be (rgb,x,y,slice) for DT_RGB\n',mfilename);
  end
end
if numel(IMGDAT) ~= nvox,
  fprintf('\n ERROR %s: dimensional mismatch, ',mfilename);
  fprintf(' HDR.dime.dim=[%s], size(IMGDAT)=[%s]\n', ...
          strtrim(sprintf('%d ',HDR.dime.dim)),...
          strtrim(sprintf('%d ',size(IMGDAT))));
  return
end

hdr_write(hdrfile,HDR);

if strcmpi(fe,'.nii'),
  fid = fopen(imgfile,'ab');
else
  fid = fopen(imgfile,'wb');
end
fwrite(fid,IMGDAT,wdatatype);
fclose(fid);


return
