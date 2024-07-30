function HDR = hdr_read(filename)
%HDR_READ - reads ANALYZE header
%  HDR = HDR_READ(FILENAME) reads a header file of ANALYZE(TM).
%
%  For detail, see http://www.mayo.edu/bir/PDF/ANALYZE75.pdf
%              see nifti1.h
%
%  VERSION :
%    0.90 31.05.05 YM  pre-release.
%    0.91 01.06.05 YM  modified for BRU2ANZ.
%    0.92 06.08.07 YM  bug fix, when big-endian.
%    0.93 29.04.08 YM  filename can be as .img
%    0.94 10.02.11 YM  supports NIfTI (partial).
%    0.95 26.05.15 YM  supports NIfTI extension.
%    0.96 08.11.17 YM  bug fix, when feof() doesn't work.
%
%  See also hdr_write hdr_init nii_init anz_read anz_write

if nargin == 0,  help hdr_read; return;  end

HDR = [];
if isempty(filename),  return;  end


[fp, fn, fe] = fileparts(filename);
if strcmpi(fe,'.img'),
  filename = fullfile(fp,sprintf('%s.hdr',fn));
end


if ~exist(filename,'file'),
  error('%s: ''%s'' not found.',mfilename,filename);
end

% check filesize
tmp = dir(filename);
if tmp.bytes < 4,
  fprintf('\n %s ERROR: invalid file size[%d].',...
          mfilename,tmp.bytes);
  return;
end


BRU2ANZ = 1;

% open the file
fid = fopen(filename,'r');

% read "header_key"
HK.sizeof_hdr = fread(fid, 1, 'int32=>int32');
if HK.sizeof_hdr > hex2dec('01000000'),
  % need to swap bytes, reopen with correct machine-format.
  [f, p, mach] = fopen(fid);
  fclose(fid);
  if strncmpi(mach,'ieee-be',7),
    % reopen as ieee-le
    fid = fopen(filename,'r','ieee-le');
  else
    % reopen as ieee-be
    fid = fopen(filename,'r','ieee-be');
  end
  HK.sizeof_hdr = fread(fid, 1, 'int32=>int32');
end
if tmp.bytes < HK.sizeof_hdr,
  fclose(fid);
  fprintf('\n %s ERROR: file size[%d] is smaller than %dbytes.',...
          mfilename,tmp.bytes,HK.sizeof_hdr);
  return;
end


% Check NIfTI or not
fseek(fid,344,'bof');
m = subConvStr(fread(fid,4,'uint8'));
if any(strcmpi(m,{'ni1','n+1'})),
  IS_NIFTI = 1;
else
  IS_NIFTI = 0;
end

fseek(fid,4,'bof');
HK.data_type     = subConvStr(fread(fid,10, 'uint8'));
HK.db_name       = subConvStr(fread(fid,18, 'uint8'));
HK.extents       = fread(fid, 1, 'int32=>int32');
HK.session_error = fread(fid, 1, 'int16=>int16');
HK.regular       = subConvStr(fread(fid, 1, 'uint8'));
if IS_NIFTI,
HK.dim_info      = fread(fid, 1, 'uint8');
else
HK.hkey_un0      = fread(fid, 1, 'char');
end

fseek(fid, 40,'bof');
if IS_NIFTI,
  [DIME, HIST, EXT] = sub_nifti(fid);
else
  [DIME, HIST] = sub_anz75(fid,BRU2ANZ);
end

% for debug, ftell(fid) should return 348
%ftell(fid)

% close the file
fclose(fid);

% return the structure
HDR.hk   = HK;		% header_key
HDR.dime = DIME;    % image_dimension
HDR.hist = HIST;	% data_history
if IS_NIFTI,
HDR.ext  = EXT;     % NIfTI extension
end


return;




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [DIME, HIST] = sub_anz75(fid,BRU2ANZ)

% read "image_dimension"
DIME.dim         = fread(fid, 8, 'int16=>int16')';
if BRU2ANZ,
DIME.vox_units   = subConvStr(fread(fid, 4, 'uint8'));
DIME.cal_units   = subConvStr(fread(fid, 8, 'uint8'));
else
DIME.unused8     = fread(fid, 1, 'int16=>int16');
DIME.unused9     = fread(fid, 1, 'int16=>int16');
DIME.unused10    = fread(fid, 1, 'int16=>int16');
DIME.unused11    = fread(fid, 1, 'int16=>int16');
DIME.unused12    = fread(fid, 1, 'int16=>int16');
DIME.unused13    = fread(fid, 1, 'int16=>int16');
end
DIME.unused14    = fread(fid, 1, 'int16=>int16');
DIME.datatype    = fread(fid, 1, 'int16=>int16');
DIME.bitpix      = fread(fid, 1, 'int16=>int16');
DIME.dim_un0     = fread(fid, 1, 'int16=>int16');
DIME.pixdim      = fread(fid, 8, 'single=>single')';
DIME.vox_offset  = fread(fid, 1, 'single=>single');
if BRU2ANZ,
DIME.roi_scale   = fread(fid, 1, 'single=>single');
else
DIME.funused1    = fread(fid, 1, 'single=>single');
end
DIME.funused2    = fread(fid, 1, 'single=>single');
DIME.funused3    = fread(fid, 1, 'single=>single');
DIME.cal_max     = fread(fid, 1, 'single=>single');
DIME.cal_min     = fread(fid, 1, 'single=>single');
DIME.compressed  = fread(fid, 1, 'single=>single');
DIME.verified    = fread(fid, 1, 'single=>single');
DIME.glmax       = fread(fid, 1, 'int32=>int32');
DIME.glmin       = fread(fid, 1, 'int32=>int32');

% read "data_history"
HIST.descrip     = subConvStr(fread(fid,80, 'uint8'));
HIST.aux_file    = subConvStr(fread(fid,24, 'uint8'));
HIST.orient      = fread(fid, 1, 'char');
HIST.originator  = subConvStr(fread(fid,10, 'uint8'));
HIST.generated   = subConvStr(fread(fid,10, 'uint8'));
HIST.scannum     = subConvStr(fread(fid,10, 'uint8'));
HIST.patient_id  = subConvStr(fread(fid,10, 'uint8'));
HIST.exp_date    = subConvStr(fread(fid,10, 'uint8'));
HIST.exp_time    = subConvStr(fread(fid,10, 'uint8'));
HIST.hist_un0    = subConvStr(fread(fid, 3, 'uint8'));
HIST.views       = fread(fid, 1, 'int32=>int32');
HIST.vols_added  = fread(fid, 1, 'int32=>int32');
HIST.start_field = fread(fid, 1, 'int32=>int32');
HIST.field_skip  = fread(fid, 1, 'int32=>int32');
HIST.omax        = fread(fid, 1, 'int32=>int32');
HIST.omin        = fread(fid, 1, 'int32=>int32');
HIST.smax        = fread(fid, 1, 'int32=>int32');
HIST.smin        = fread(fid, 1, 'int32=>int32');

return



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [DIME, HIST, EXT] = sub_nifti(fid)

% read "image_dimension"
DIME.dim         = fread(fid, 8, 'int16=>int16')';
DIME.intent_p1   = fread(fid, 1, 'single=>single');  % short unused8/9
DIME.intent_p2   = fread(fid, 1, 'single=>single');  % short unused10/11
DIME.intent_p3   = fread(fid, 1, 'single=>single');  % short unused12/13
DIME.intent_code = fread(fid, 1, 'int16=>int16');    % short unused14
DIME.datatype    = fread(fid, 1, 'int16=>int16');
DIME.bitpix      = fread(fid, 1, 'int16=>int16');
DIME.slice_start = fread(fid, 1, 'int16=>int16');    % short dim_un0
DIME.pixdim      = fread(fid, 8, 'single=>single')';
DIME.vox_offset  = fread(fid, 1, 'single=>single');
DIME.scl_slope   = fread(fid, 1, 'single=>single');  % float funused1
DIME.scl_inter   = fread(fid, 1, 'single=>single');  % float funused2
DIME.slice_end   = fread(fid, 1, 'int16=>int16');    % float funused3
DIME.slice_code  = fread(fid, 1, 'int8=>int8');      % ...
DIME.xyzt_units  = fread(fid, 1, 'uint8=>uint8');    % make this as 'uint8' for bitor/bitand().
DIME.cal_max     = fread(fid, 1, 'single=>single');
DIME.cal_min     = fread(fid, 1, 'single=>single');
DIME.slice_duration = fread(fid, 1, 'single=>single');  % float compressed
DIME.toffset     = fread(fid, 1, 'single=>single');  % float verified
DIME.glmax       = fread(fid, 1, 'int32=>int32');
DIME.glmin       = fread(fid, 1, 'int32=>int32');

% read "data_history"
HIST.descrip     = subConvStr(fread(fid,80, 'uint8'));
HIST.aux_file    = subConvStr(fread(fid,24, 'uint8'));
HIST.qform_code  = fread(fid, 1, 'int16=>int16');
HIST.sform_code  = fread(fid, 1, 'int16=>int16');
HIST.quatern_b   = fread(fid, 1, 'single=>single');
HIST.quatern_c   = fread(fid, 1, 'single=>single');
HIST.quatern_d   = fread(fid, 1, 'single=>single');
HIST.qoffset_x   = fread(fid, 1, 'single=>single');
HIST.qoffset_y   = fread(fid, 1, 'single=>single');
HIST.qoffset_z   = fread(fid, 1, 'single=>single');
HIST.srow_x      = fread(fid, 4, 'single=>single')';  % 1st row affine trans.
HIST.srow_y      = fread(fid, 4, 'single=>single')';  % 2nd row affine trans.
HIST.srow_z      = fread(fid, 4, 'single=>single')';  % 3rd row affine trans.
HIST.intent_name = subConvStr(fread(fid,16, 'uint8'));
HIST.magic       = subConvStr(fread(fid, 4, 'uint8'));

% read "extension"
EXT.extension    = uint8([0 0 0 0]);
EXT.section      = [];
if feof(fid),  return;  end

tmpv             = fread(fid, 4, 'uint8=>uint8')';
if isempty(tmpv),
  % feof(fid) didn't work as supposed to be...
  return;
end
  
%EXT.extension    = fread(fid, 4, 'uint8=>uint8')';
EXT.extension = tmpv;  clear tmpv;
if EXT.extension(1) == 0,  return;  end

while ftell(fid) < DIME.vox_offset,
  tmps.esize     = fread(fid, 1, 'int32=>int32');
  if tmps.esize < 8,
    fprintf('\n WARNING hd_read/sub_nifti(): invalid extention (esize=%d)',tmps.esize);
    break;
  end
  % should be a multiple of 16...
  if mod(double(tmps.esize),16) ~= 0,
    fprintf('\n WARNING hd_read/sub_nifti(): extention.esize=%d is not a multiple of 16.',tmps.esize);
  end
  tmps.ecode     = fread(fid, 1, 'int32=>int32');
  tmps.edata     = fread(fid, tmps.esize-8, 'uint8=>uint8')';
  if isempty(EXT.section),
    EXT.section = tmps;
  else
    EXT.section(end+1) = tmps;
  end
end



return



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = subConvStr(dat)
dat = dat(:)';
if any(dat)
  str = deblank(char(dat));
else
  str = '';
end

return;
