function hdr_write(filename, HDR)
%HDR_WRITE - create a ANALYZE header file.
%  HDR_WRITE(FILENAME,HDR) writes a header file of ANALYZE(TM).
%  Input HDR can be given by HDR_INIT.
%
%  For detail, see http://www.mayo.edu/bir/PDF/ANALYZE75.pdf
%              see nifti1.h
%
%  VERSION :
%    0.90 01.06.05 YM  pre-release.
%    0.91 01.06.05 YM  mofified for BRU2ANZ.
%    0.92 10.02.11 YM  supports for NIfTI (partial).
%    0.95 26.05.15 YM  supports NIfTI extension.
%    0.96 09.11.17 YM  bug fix of DIME.dim.
%
%  See also hdr_read hdr_init nii_init anz_read anz_write

if nargin ~= 2,  help hdr_write; return;  end

if ~ischar(filename) || isempty(filename),
  fprintf('\n %s ERROR: first arg must be a filename string.',mfilename);
  return;
end
if ~isstruct(HDR) || ~isfield(HDR,'hk') || ~isfield(HDR,'dime') || ~isfield(HDR,'hist'),
  fprintf('\n %s ERROR: second arg must be a strucure by hdr_init().',mfilename);
  return;
end


if isfield(HDR.hist,'magic') && any(strcmpi(HDR.hist.magic,{'ni1','n+1'})),
  IS_NIFTI = 1;
else
  IS_NIFTI = 0;
end


BRU2ANZ = 1;

% update HDR.dime.datatype if it is a string
if ischar(HDR.dime.datatype),
  switch lower(HDR.dime.datatype)
   case {'binary'}
    HDR.dime.datatype = 1;
   case {'uchar','uint8'}
    HDR.dime.datatype = 2;
   case {'short', 'int16'}
    HDR.dime.datatype = 4;
   case {'int', 'int32', 'long'}
    HDR.dime.datatype = 8;
   case {'float', 'single'}
    HDR.dime.datatype = 16;
   case {'complex'}
    HDR.dime.datatype = 32;
   case {'double'}
    HDR.dime.datatype = 64;
   case {'rgb'}
    HDR.dime.datatype = 128;
  end
end

% update HDR.dime.bitpix according to HDR.dime.datatype
switch HDR.dime.datatype
 case 1
  HDR.dime.bitpix =  1;
 case 2
  HDR.dime.bitpix =  8;
 case 4
  HDR.dime.bitpix = 16;
 case 8
  HDR.dime.bitpix = 32;
 case 16
  HDR.dime.bitpix = 32;
 case 32
  HDR.dime.bitpix = 64;
 case 64
  HDR.dime.bitpix = 64;
 case 128
  HDR.dime.bitpix = 24;
end

% open the file
fid = fopen(filename,'wb');
if fid < 0,
  error(' ERROR %s: cannot open ''%s''.\n',mfilename,filename);
end


% write "header_key"
HK = HDR.hk;
fwrite(fid, HK.sizeof_hdr(1),    'int32');
fwrite(fid, subGetChar(HK.data_type,10),    'uint8');
fwrite(fid, subGetChar(HK.db_name,18),      'uint8');
fwrite(fid, HK.extents(1),       'int32');
fwrite(fid, HK.session_error(1), 'int16');
fwrite(fid, subGetChar(HK.regular,1),       'uint8');
if IS_NIFTI,
fwrite(fid, HK.dim_info(1),      'uint8');
else
fwrite(fid, HK.hkey_un0(1),      'int8');
end

if IS_NIFTI
  sub_nifti(fid,HDR.dime,HDR.hist,HDR.ext);
else
  sub_anz75(fid,HDR.dime,HDR.hist,BRU2ANZ);
end

% close the file
fclose(fid);

return;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sub_anz75(fid,DIME,HIST,BRU2ANZ)

% write "image_dimension"
fwrite(fid, subGetValue(DIME.dim,8),        'int16');
if BRU2ANZ,
fwrite(fid, subGetChar(DIME.vox_units,4),   'uint8');
fwrite(fid, subGetChar(DIME.cal_units,8),   'uint8');
else
fwrite(fid, DIME.unused8(1),     'int16');
fwrite(fid, DIME.unused9(1),     'int16');
fwrite(fid, DIME.unused10(1),    'int16');
fwrite(fid, DIME.unused11(1),    'int16');
fwrite(fid, DIME.unused12(1),    'int16');
fwrite(fid, DIME.unused13(1),    'int16');
end
fwrite(fid, DIME.unused14(1),    'int16');
fwrite(fid, DIME.datatype(1),    'int16');
fwrite(fid, DIME.bitpix(1),      'int16');
fwrite(fid, DIME.dim_un0(1),     'int16');
fwrite(fid, subGetValue(DIME.pixdim,8),     'single');
fwrite(fid, DIME.vox_offset(1),  'single');
if BRU2ANZ,
fwrite(fid, DIME.roi_scale(1),   'single');
else
fwrite(fid, DIME.funused1(1),    'single');
end
fwrite(fid, DIME.funused2(1),    'single');
fwrite(fid, DIME.funused3(1),    'single');
fwrite(fid, DIME.cal_max(1),     'single');
fwrite(fid, DIME.cal_min(1),     'single');
fwrite(fid, DIME.compressed(1),  'single');
fwrite(fid, DIME.verified(1),    'single');
fwrite(fid, DIME.glmax(1),       'int32');
fwrite(fid, DIME.glmin(1),       'int32');

% write "data_history"
fwrite(fid, subGetChar(HIST.descrip,80),    'uint8');
fwrite(fid, subGetChar(HIST.aux_file,24),   'uint8');
fwrite(fid, HIST.orient(1),       'int8');
fwrite(fid, subGetChar(HIST.originator,10), 'uint8');
fwrite(fid, subGetChar(HIST.generated,10),  'uint8');
fwrite(fid, subGetChar(HIST.scannum,10),    'uint8');
fwrite(fid, subGetChar(HIST.patient_id,10), 'uint8');
fwrite(fid, subGetChar(HIST.exp_date,10),   'uint8');
fwrite(fid, subGetChar(HIST.exp_time,10),   'uint8');
fwrite(fid, subGetChar(HIST.hist_un0,3),    'uint8');
fwrite(fid, HIST.views(1),       'int32');
fwrite(fid, HIST.vols_added(1),  'int32');
fwrite(fid, HIST.start_field(1), 'int32');
fwrite(fid, HIST.field_skip(1),  'int32');
fwrite(fid, HIST.omax(1),        'int32');
fwrite(fid, HIST.omin(1),        'int32');
fwrite(fid, HIST.smax(1),        'int32');
fwrite(fid, HIST.smin(1),        'int32');

return


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sub_nifti(fid,DIME,HIST,EXT)

% update "DIME.vox_offset"
if isfield(EXT,'section') && ~isempty(EXT.section),
  voxoffs = 352;
  for K = 1:length(EXT.section),
    tmps = EXT.section(K);
    if tmps.esize < 8,
      error(' ERROR hdr_write/sub_nifti(): invalid extention (esize=%d)\n',tmps.esize);
    end
    if mod(double(tmps.esize),16) ~= 0,
      fprintf('\n WARNING hd_write/sub_nifti(): EXT.section(%d).esize=%d is not a multiple of 16.',K,tmps.esize);
    end
    voxoffs = voxoffs + double(tmps.esize);
  end
  DIME.vox_offset = voxoffs;
end

% write "image_dimension"
DIME.dim(DIME.dim(1)+2:8) = 1;  % to be compatible with SPM.
fwrite(fid, subGetValue(DIME.dim,8),    'int16');
fwrite(fid, DIME.intent_p1(1),          'single');
fwrite(fid, DIME.intent_p2(1),          'single');
fwrite(fid, DIME.intent_p3(1),          'single');
fwrite(fid, DIME.intent_code(1),        'int16');
fwrite(fid, DIME.datatype(1),           'int16');
fwrite(fid, DIME.bitpix(1),             'int16');
fwrite(fid, DIME.slice_start(1),        'int16');
fwrite(fid, subGetValue(DIME.pixdim,8), 'single');
fwrite(fid, DIME.vox_offset(1),         'single');
fwrite(fid, DIME.scl_slope(1),          'single');
fwrite(fid, DIME.scl_inter(1),          'single');
fwrite(fid, DIME.slice_end(1),          'int16');
fwrite(fid, DIME.slice_code(1),         'int8');
fwrite(fid, DIME.xyzt_units(1),         'uint8');    % make this as 'uint8' for bitor/bitand().
fwrite(fid, DIME.cal_max(1),            'single');
fwrite(fid, DIME.cal_min(1),            'single');
fwrite(fid, DIME.slice_duration(1),     'single');
fwrite(fid, DIME.toffset(1),            'single');
fwrite(fid, DIME.glmax(1),       'int32');
fwrite(fid, DIME.glmin(1),       'int32');

% write "data_history"
fwrite(fid, subGetChar(HIST.descrip,80),    'uint8');
fwrite(fid, subGetChar(HIST.aux_file,24),   'uint8');
fwrite(fid, HIST.qform_code(1),             'int16');
fwrite(fid, HIST.sform_code(1),             'int16');
fwrite(fid, HIST.quatern_b(1),              'single');
fwrite(fid, HIST.quatern_c(1),              'single');
fwrite(fid, HIST.quatern_d(1),              'single');
fwrite(fid, HIST.qoffset_x(1),              'single');
fwrite(fid, HIST.qoffset_y(1),              'single');
fwrite(fid, HIST.qoffset_z(1),              'single');
fwrite(fid, subGetValue(HIST.srow_x,4),     'single');
fwrite(fid, subGetValue(HIST.srow_y,4),     'single');
fwrite(fid, subGetValue(HIST.srow_z,4),     'single');
fwrite(fid, subGetChar(HIST.intent_name,16),'uint8');
fwrite(fid, subGetChar(HIST.magic,4),       'uint8');

% write "extension"
fwrite(fid,  subGetValue(EXT.extension,4),  'int8');
for K = 1:length(EXT.section),
  tmps = EXT.section(K);
  fwrite(fid, tmps.esize(1),                'int32');
  fwrite(fid, tmps.ecode(1),                'int32');
  fwrite(fid, subGetValue(tmps.edata,tmps.esize(1)-8), 'uint8');
end

return




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = subGetChar(x,n)
v = x;
if ischar(v),  v = uint8(v);  end
if length(v) > n,
  v = v(1:n);
elseif length(v) < n,
  v(end+1:n) = 0;
end

return;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = subGetValue(x,n)
v = x;
if length(v) > n,
  v = v(1:n);
elseif length(v) < n,
  v(end+1:n) = 0;
end

return;

