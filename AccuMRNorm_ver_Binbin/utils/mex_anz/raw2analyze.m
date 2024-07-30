function imgfile = raw2analyze(RAWFILE,varargin)
%RAW2ANALYZE - Convert Photoshop-RAW into ANALYZE format.
%  IMGFILE = RAW2ANALYZE(RAWFILE,...)
%  RAW2ANALYZE(RAWFILE,...) converts the photoshop-raw file as ANALYZE format.
%
%  BRU2ANALYZE usually export Paravision's 2dseq file as "int16" with values
%  ranging from 0 to 32767 (no negative values).  The exported .img file can be
%  opened as photoshop-raw (0 header, width=img_width, height=img_height*img_slice).
%  Once the photoshop saved data as .raw, it becomes "unit8" or "unit16".
%  This program read .raw, backups the original .img as .bak, then overwrites
%  the .img with corrected .raw.
%
%  EXAMPLE :
%    >> bru2analyze('.../2dseq')
%    >> raw2analyze('D:/temp/myimg.raw')
%
%  NOTE :
%    - There should be corresponding .hdr/.img in the same directory.
%    - 0-255 or 0-65535 is mapped as 0-32767 (int16).
%    - The program backups (.bak) of .img then overwrites .img with corrected .raw.
%
%  VERSION :
%    0.90 22.02.11 YM  pre-release
%
%  See also bru2analyze


if nargin < 1,  eval(['help' mfilename]);  return;  end


VERBOSE = 0;
for N = 1:2:length(varargin)
  switch lower(varargin{N})
   case {'verbose'}
    VERBOSE = varargin{N+1};
  end
end



[fp fr fe] = fileparts(RAWFILE);

hdrfile = fullfile(fp,sprintf('%s.hdr',fr));
rawfile = fullfile(fp,sprintf('%s.raw',fr));
imgfile = fullfile(fp,sprintf('%s.img',fr));

if ~exist(RAWFILE,'file'),
  error('\nERROR %s:  raw file not found, ''%s''.\n',mfilename,RAWFILE);
end


if VERBOSE,  fprintf('%s: ',mfilename);  end


bakfile = sprintf('%s.bak',imgfile);
if exist(imgfile,'file'),
  copyfile(imgfile,bakfile,'f');
end



hdr = hdr_read(hdrfile);
imgdim = double(hdr.dime.dim(2:4));

tmpdir = dir(rawfile);
fid = fopen(rawfile,'r');
% PHOTOSHOP CS saves 8bits as uint8 or 16bits as uint16.
if tmpdir.bytes == prod(imgdim),
  % 8bits
  tmpimg = fread(fid,inf,'uint8=>single');
  if VERBOSE, fprintf('%s%s(unit8)->',fr,fe);  end
  % scale 0-255 as 0-1
  tmpimg = tmpimg/255;
else
  % 16bits
  tmpimg = fread(fid,inf,'uint16=>single');
  if VERBOSE, fprintf('%s%s(unit16)->',fr,fe);  end
  % scale 0-65535 as 0-1
  tmpimg = tmpimg/65535;
end
fclose(fid);


switch lower(hdr.dime.datatype)
 %case {1,'binary'}
 % ndatatype = 1;
 % wdatatype = 'int8';
 case {2,'uchar', 'uint8'}
  %ndatatype = 2;
  wdatatype = 'uint8';
  tmpimg = tmpimg*255;
  tmpimg = uint8(tmpimg);
 case {4,'short', 'int16'}
  %ndatatype = 4;
  wdatatype = 'int16';
  tmpimg = tmpimg*32767;
  tmpimg = int16(round(tmpimg));
 otherwise
  if ischar(hdr.dime.datatype),
    fprintf('\n %s: unsupported datatype(=%s).\n',mfilename,hdr.dime.datatype);
  else
    fprintf('\n %s: unsupported datatype(=%d).\n',mfilename,hdr.dime.datatype);
  end
  return
end

if VERBOSE, fprintf('%s.img(%s)',fr,wdatatype);  end

fid = fopen(imgfile,'w');
fwrite(fid,tmpimg,wdatatype);
fclose(fid);

if VERBOSE, fprintf(' done.\n');  end

return

