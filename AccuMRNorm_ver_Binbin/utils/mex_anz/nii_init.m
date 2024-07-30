function HDR = nii_init(varargin)
%NII_INIT - initializes NIfTI header structure.
%  HDR = NII_INIT() returns a NIfTI header structure.
%  HDR = NII_INIT(NAME1,VALUE1,NAME2,VALUE2,...) returns
%  NIfTI header initialized by given arguments.
%
%  EXAMPLE :
%    hdr = nii_init;
%    hdr = nii_init('dim',[4 256 256 1 148 0 0 0],'datatype',8);
%    hdr = nii_init('dim',[4 256 256 1 148 0 0 0],'datatype','int32');
%    hdr = nii_init('dim',[4 256 256 1 148 0 0 0],'datatype','_32BIT_SGN_INT');
%
%  OPTIONS :
%   'NiiCompatible' : bru2analyze|spm|amira|slicer, make the coordiate system as 
%     similar as reading ANALYZE-7.5 format with the given program.  Note that 
%     this is by no means orientation correction of the volume.  "bru2nalyze" would 
%     keep better compatibility among other programs without manipulationg data itself.
%
%  NOTE about NIfTI-1(.nii):
%    - Amira sets the origin as zero, hist.qform_code=1.
%    - SPM uses dime.pixdim(1)=-1, hist.qform_code=2, hist.sform_code=2.
%    - 3DSlicer flips X and Y (left-right and ant-post corrected for its display).
%
%  VERSION :
%    0.90 26.05.15 YM  first release.
%    0.91 27.05.15 YM  supports a option, "niicompatible:spm|amira|slicer".
%
%  See also hdr_read hdr_write anz_read anz_write bru2analyze

%
% NIfTI-1 HEADER ===================================
%                         /*************************/  /************************/
% struct nifti_1_header { /* NIFTI-1 usage         */  /* ANALYZE 7.5 field(s) */
%                         /*************************/  /************************/
%                                            /*--- was header_key substruct ---*/
%  int   sizeof_hdr;    /*!< MUST be 348           */  /* int sizeof_hdr;      */
%  char  data_type[10]; /*!< ++UNUSED++            */  /* char data_type[10];  */
%  char  db_name[18];   /*!< ++UNUSED++            */  /* char db_name[18];    */
%  int   extents;       /*!< ++UNUSED++            */  /* int extents;         */
%  short session_error; /*!< ++UNUSED++            */  /* short session_error; */
%  char  regular;       /*!< ++UNUSED++            */  /* char regular;        */
%  char  dim_info;      /*!< MRI slice ordering.   */  /* char hkey_un0;       */
%                                       /*--- was image_dimension substruct ---*/
%  short dim[8];        /*!< Data array dimensions.*/  /* short dim[8];        */
%  float intent_p1 ;    /*!< 1st intent parameter. */  /* short unused8;       */
%                                                      /* short unused9;       */
%  float intent_p2 ;    /*!< 2nd intent parameter. */  /* short unused10;      */
%                                                      /* short unused11;      */
%  float intent_p3 ;    /*!< 3rd intent parameter. */  /* short unused12;      */
%                                                      /* short unused13;      */
%  short intent_code ;  /*!< NIFTI_INTENT_* code.  */  /* short unused14;      */
%  short datatype;      /*!< Defines data type!    */  /* short datatype;      */
%  short bitpix;        /*!< Number bits/voxel.    */  /* short bitpix;        */
%  short slice_start;   /*!< First slice index.    */  /* short dim_un0;       */
%  float pixdim[8];     /*!< Grid spacings.        */  /* float pixdim[8];     */
%  float vox_offset;    /*!< Offset into .nii file */  /* float vox_offset;    */
%  float scl_slope ;    /*!< Data scaling: slope.  */  /* float funused1;      */
%  float scl_inter ;    /*!< Data scaling: offset. */  /* float funused2;      */
%  short slice_end;     /*!< Last slice index.     */  /* float funused3;      */
%  char  slice_code ;   /*!< Slice timing order.   */
%  char  xyzt_units ;   /*!< Units of pixdim[1..4] */
%  float cal_max;       /*!< Max display intensity */  /* float cal_max;       */
%  float cal_min;       /*!< Min display intensity */  /* float cal_min;       */
%  float slice_duration;/*!< Time for 1 slice.     */  /* float compressed;    */
%  float toffset;       /*!< Time axis shift.      */  /* float verified;      */
%  int   glmax;         /*!< ++UNUSED++            */  /* int glmax;           */
%  int   glmin;         /*!< ++UNUSED++            */  /* int glmin;           */
%                                          /*--- was data_history substruct ---*/
%  char  descrip[80];   /*!< any text you like.    */  /* char descrip[80];    */
%  char  aux_file[24];  /*!< auxiliary filename.   */  /* char aux_file[24];   */
%  short qform_code ;   /*!< NIFTI_XFORM_* code.   */  /*-- all ANALYZE 7.5 ---*/
%  short sform_code ;   /*!< NIFTI_XFORM_* code.   */  /*   fields below here  */
%                                                      /*   are replaced       */
%  float quatern_b ;    /*!< Quaternion b param.   */
%  float quatern_c ;    /*!< Quaternion c param.   */
%  float quatern_d ;    /*!< Quaternion d param.   */
%  float qoffset_x ;    /*!< Quaternion x shift.   */
%  float qoffset_y ;    /*!< Quaternion y shift.   */
%  float qoffset_z ;    /*!< Quaternion z shift.   */
%  float srow_x[4] ;    /*!< 1st row affine transform.   */
%  float srow_y[4] ;    /*!< 2nd row affine transform.   */
%  float srow_z[4] ;    /*!< 3rd row affine transform.   */
%  char intent_name[16];/*!< 'name' or meaning of data.  */
%  char magic[4] ;      /*!< MUST be "ni1\0" or "n+1\0". */
% } ;                   /**** 348 bytes total ****/
% /*! \struct nifti1_extender
%     \brief This structure represents a 4-byte string that should follow the
%            binary nifti_1_header data in a NIFTI-1 header file.  If the char
%            values are {1,0,0,0}, the file is expected to contain extensions,
%            values of {0,0,0,0} imply the file does not contain extensions.
%            Other sequences of values are not currently defined.
%  */
% struct nifti1_extender { char extension[4] ; } ;
% /*! \struct nifti1_extension
%     \brief Data structure defining the fields of a header extension.
%  */
% struct nifti1_extension {
%    int    esize ; /*!< size of extension, in bytes (must be multiple of 16) */
%    int    ecode ; /*!< extension code, one of the NIFTI_ECODE_ values       */
%    char * edata ; /*!< raw data, with no byte swapping (length is esize-8)  */
% } ;


if nargin == 0 && nargout == 0,
  help nii_init;
  return;
end


% header key
HK.sizeof_hdr    = int32(348);
HK.data_type     = '';
HK.db_name       = '';
HK.extents       = zeros(1,1, 'int32');
HK.session_error = zeros(1,1, 'int16');
HK.regular       = 'r';
HK.dim_info      = zeros(1,1, 'uint8');

% read "image_dimension"
DIME.dim         = zeros(1,8, 'int16');  DIME.dim(2:end) = 1;  % to be compatible with SPM.
DIME.intent_p1   = zeros(1,1, 'single');
DIME.intent_p2   = zeros(1,1, 'single');
DIME.intent_p3   = zeros(1,1, 'single');
DIME.intent_code = zeros(1,1, 'int16');
DIME.datatype    = zeros(1,1, 'int16');
DIME.bitpix      = zeros(1,1, 'int16');
DIME.slice_start = zeros(1,1, 'int16');
DIME.pixdim      = zeros(1,8, 'single')';
DIME.vox_offset  = single(352);  %  348 + char[4]
DIME.scl_slope   = zeros(1,1, 'single');
DIME.scl_inter   = zeros(1,1, 'single');
DIME.slice_end   = zeros(1,1, 'int16');
DIME.slice_code  = zeros(1,1, 'int8');
%DIME.xyzt_units  = zeros(1,1, 'uint8');  % make this as 'uint8' for bitor/bitand().
DIME.xyzt_units  = bitor(uint8(2),uint8(8));  % 2=NIFTI_UNITS_MM, 8=NIFTI_UNITS_MM
DIME.cal_max     = zeros(1,1, 'single');
DIME.cal_min     = zeros(1,1, 'single');
DIME.slice_duration = zeros(1,1, 'single');
DIME.toffset     = zeros(1,1, 'single');
DIME.glmax       = zeros(1,1, 'int32');
DIME.glmin       = zeros(1,1, 'int32');

% read "data_history"
HIST.descrip     = '';
HIST.aux_file    = '';
% HIST.qform_code  = zeros(1,1, 'int16');
HIST.qform_code  = NaN;  % would be determined later.
% HIST.sform_code  = zeros(1,1, 'int16');
HIST.sform_code  = NaN;  % would be determined later.
HIST.quatern_b   = zeros(1,1, 'single');
HIST.quatern_c   = zeros(1,1, 'single');
HIST.quatern_d   = zeros(1,1, 'single');
HIST.qoffset_x   = zeros(1,1, 'single');
HIST.qoffset_y   = zeros(1,1, 'single');
HIST.qoffset_z   = zeros(1,1, 'single');
HIST.srow_x      = zeros(1,4, 'single')';  % 1st row affine trans.
HIST.srow_y      = zeros(1,4, 'single')';  % 2nd row affine trans.
HIST.srow_z      = zeros(1,4, 'single')';  % 3rd row affine trans.
HIST.intent_name = '';
HIST.magic       = 'n+1';  % ni1:hdr+img, n+1:nii

EXT.extension    = uint8([0 0 0 0]);
EXT.section      = [];



NII_COMPATIBLE  = 'bru2analyze';  % spm | amira | slicer | bru2analyze
% set values if given.
for N = 1:2:nargin,
  vname  = varargin{N};
  vvalue = varargin{N+1};
  switch lower(vname)
   case {'niicompatible','compatible','nii_compabile'}
    NII_COMPATIBLE = vvalue;
    continue;
  end
  if isfield(HK,vname),   HK.(vname)   = vvalue;  end
  if isfield(DIME,vname), DIME.(vname) = vvalue;  end
  if isfield(HIST,vname), HIST.(vname) = vvalue;  end
  if isfield(EXT,vname),  EXT.(vname)  = vvalue;  end
end




% update DIME.datatype as a integer, if chars.
if ischar(DIME.datatype)
  switch lower(DIME.datatype),
   case {'binary'}
    DIME.datatype = 1;
   case {'uchar', 'uint8'}
    DIME.datatype = 2;
   case {'short', 'int16', '_16bit_sgn_int'}
    DIME.datatype = 4;
   case {'int', 'int32', 'long', '_32bit_sgn_int'}
    DIME.datatype = 8;
   case {'float', 'single'}
    DIME.datatype = 16;
   case {'complex'}
    DIME.datatype = 32;
   case {'double'}
    DIME.datatype = 64;
   case {'rgb'}
    DIME.datatype = 128;
   otherwise
    error('\n ERROR %s: datatype ''%s'' not supported.\n',mfilename,DIME.datatype);
  end
end

% update DIME.bitpix according to DIME.datatype
switch DIME.datatype
 case 1
  DIME.bitpix =  1;
 case 2
  DIME.bitpix =  8;
 case 4
  DIME.bitpix = 16;
 case 8
  DIME.bitpix = 32;
 case 16
  DIME.bitpix = 32;
 case 32
  DIME.bitpix = 64;
 case 64
  DIME.bitpix = 64;
 case 128
  DIME.bitpix = 24;
end

% update hist.qform_code etc
if isnan(HIST.qform_code),
  voxdim = double(DIME.pixdim(2:4));
  fov    = voxdim .* double(DIME.dim(2:4));
  offs   = fov/2 - voxdim/2;
  switch lower(NII_COMPATIBLE)
   case {'bru2analyze','bruk2analyze','best','qform=2,d=1'}
    % this would keep the orientation compatibilty among other programs,
    % without manipulating 2dseq dimension.
    DIME.pixdim(1)  =  1;
    HIST.qform_code =  2; 
    HIST.quatern_b  =  0;
    HIST.quatern_c  =  0;
    HIST.quatern_d  =  1;
    HIST.qoffset_x  =  offs(1);  % positive
    HIST.qoffset_y  =  offs(2);  % positive
    HIST.qoffset_z  = -offs(3);  % negative
   case 'spm'
    % it would be compatible with SPM reading Analyze7.5
    DIME.pixdim(1)  = -1;
    HIST.qform_code =  2;
    HIST.quatern_b  =  0;
    HIST.quatern_c  =  1;
    HIST.quatern_d  =  0;
    HIST.qoffset_x  =  offs(1);  % positive
    HIST.qoffset_y  = -offs(2);  % negative
    HIST.qoffset_z  = -offs(3);  % negative
   case 'amira'
    % it would be compatible with Amira reading Analyze7.5
    DIME.pixdim(1)  =  1;
    HIST.qform_code =  1;
    HIST.quatern_b  =  0;
    HIST.quatern_c  =  0;
    HIST.quatern_d  =  0;
    HIST.qoffset_x  = -offs(1);  % negative
    HIST.qoffset_y  = -offs(2);  % negative
    HIST.qoffset_z  = -offs(3);  % negative
   case {'slicer','3dslicer','3d-slicer'}
    % it would be compatible with 3DSlicer reading Analyze-7.5
    DIME.pixdim(1)  =  1;
    HIST.qform_code =  2;
    HIST.quatern_b  =  0;
    HIST.quatern_c  =  0;
    HIST.quatern_d  =  1;
    HIST.qoffset_x  =  0;
    HIST.qoffset_y  =  0;
    HIST.qoffset_z  =  0;
   case {'test'}
    % for testing...
    DIME.pixdim(1)  =  1;
    HIST.qform_code =  2; 
    HIST.quatern_b  =  0;
    HIST.quatern_c  =  0;
    HIST.quatern_d  =  1;
    HIST.qoffset_x  =  offs(1);  % positive
    HIST.qoffset_y  =  offs(2);  % positive
    HIST.qoffset_z  = -offs(3);  % negative
   otherwise
    % no xform
    HIST.qform_code =  0;
  end
  
  QFORM_CODE_UPDATED = 1;
else
  % qform_code is updated by the user, do nothing...
  QFORM_CODE_UPDATED = 0;
end
% update hist.sform_code etc
if isnan(HIST.sform_code),
  if QFORM_CODE_UPDATED,
    switch lower(NII_COMPATIBLE)
     case {'bru2analyze','bruk2analyze','best','qform=2,d=1'}
      % this would keep the orientation compatibilty among other programs,
      % without manipulating 2dseq dimension.
      HIST.sform_code = 0;
     case 'spm'
      % it would be compatible with SPM reading Analyze7.5
      HIST.sform_code = 2;
      HIST.srow_x = [-voxdim(1)  0       0       HIST.qoffset_x];
      HIST.srow_y = [    0    voxdim(2)  0       HIST.qoffset_y];
      HIST.srow_z = [    0       0    voxdim(3)  HIST.qoffset_z];
     case 'amira'
      % it would be compatible with Amira reading Analyze7.5
      HIST.sform_code = 0;
     case {'slicer','3dslicer','3d-slicer'}
      % it would be compatible with 3DSlicer reading Analyze-7.5
      HIST.sform_code = 1;
      HIST.srow_x = [-voxdim(1)  0       0       HIST.qoffset_x];
      HIST.srow_y = [    0   -voxdim(2)  0       HIST.qoffset_y];
      HIST.srow_z = [    0       0    voxdim(3)  HIST.qoffset_z];
     case 'test'
      % for testing...
      HIST.sform_code = 0;
     otherwise
      % no xform
      HIST.sform_code = 0;
    end
  else
    HIST.sform_code = 0;
  end
else
  % sform_code is updated by the user, do nothing...
end


% update EXT.extension(1)
if ~isempty(EXT.section),
  EXT.extension(1) = 1;
  voxoffs = 352;
  for K = 1:length(EXT.section),
    tmps = EXT.section;
    if tmps.esize < 8,
      error(' ERROR nii_init(): invalid extention (esize=%d)\n',tmps.esize);
    end
    % should be a multiple of 16...
    if mod(double(tmps.esize),16) ~= 0,
      error(' ERROR nii_init(): EXT.section(%d).esize=%d is not a multiple of 16.\n',K,tmps.esize);
    end
    voxoffs = voxoffs + double(tmps.esize);
  end
  DIME.vox_offset = single(voxoffs);
end


% return the structure
HDR.hk   = HK;		% header_key
HDR.dime = DIME;    % image_dimension
HDR.hist = HIST;	% data_history
HDR.ext  = EXT;     % extension

return;
