function varargout = bru2analyze(varargin)
%BRU2ANALYZE - dumps Bruker 2dseq as ANALIZE-7 format for SPM.
%  BRU2ANALYZE(2DSEQFILE,...)
%  BRU2ANALYZE(SESSION,EXPNO,...) dumps Bruker 2dseq as ANLYZE-7 format for SPM.
%    Optional setting can be given as a pair of the name and value, like,
%       BRU2ANALYZE(2dseqfile,'SaveDir','y:/temp/spm')  % save to 'y:/temp/spm'
%       BRU2ANALYZE(2dseqfile,'FlipDim',[2])            % flips Y
%    Supported optional arguments are
%      'ImageCrop'    : [x y width height]
%      'SliceCrop'    : [slice-start  num.slices]
%      'Permute'      : [1,2...] order to permute the dimensions
%      'FlipDim'      : [1,2...] dimension(s) to flip, 1/2/3 as X/Y/Z
%      'Average'      : 0/1 to average along 4th dimension (time)
%      'ExportAs2D'   : 0/1 to export volumes 2D
%      'SplitInTime'  : 0/1 to export time series to different files
%      'NII'          : 0/1 to export as .nii (NIfTI-1) format.
%      'NIIcompatible : 'spm', 'amira', 'slicer' or 'qform=2,d=1'
%      'SaveDir'      : directory to save
%      'FileRoot'     : filename without extension
%      'Verbose'      : 0/1
%
%  EXAMPLE:
%    % exporting functional 2dseq of the given session/exp for spm
%    >> bru2analyze('m02lx1',1)
%    % exporting MDEFT as it is.
%    >> bru2analyze('//wks8/mridata/D02.G01/5/pdata/1/2dseq','SaveDir','d:/temp')
%    % exporting MDEFT "WITH Y-AXIS FLIP" for BrainSight.
%    >> bru2analyze('//wks8/mridata/D02.G01/5/pdata/1/2dseq','FlipDim',[2])
%    % exporting MDEFT as 2D images for photoshop etc.
%    >> bru2analyze('//wks8/mridata/H03.BJ1/5/pdata/1/2dseq','SaveDir','../H03','ExportAs2D',1);
%    % exporting MDEFT for BrainVoyagerQX.
%    >> bru2analyze('//wks8/mridata_wks8/J10.6l1/30/pdata/1/2dseq','permute',[2 3 1],'flipdim',[2 3],'savedir','e:/temp')
%
%  NOTE about ANALYZE-7.5:
%    - Some major programs (SPM,Amira,3DSlicer?) ignore "hist.orient" value.
%    - Amira doen't flip any dimension automatically.
%    - SPM (coordinate) flips X (1st) dimension (left-right corrected for display).
%    - 3DSlicer flips X and Y (left-right and ant-post corrected for its display).
%
%  NOTE about NIfTI-1(.nii):
%    - Amira sets the origin as zero, hist.qform_code=1.
%    - SPM uses dime.pixdim(1)=-1, hist.qform_code=2, hist.sform_code=2.
%    - 3DSlicer flips X and Y (left-right and ant-post corrected for its display).
%
%  IMAGE ORIENTATION :
%    hdr.hist.orient: *ANALYZE default
%      *0 transverse unflipped : D1=R->L  D2=P->A  D3=I->S
%       1 coronal unflipped    : D1=R->L  D2=I->S  D3=P->A
%       2 sagittal unflipped   : D1=P->A  D2=I->S  D3=R->L
%       3 transverse flipped   : D1=R->L  D2=A->P  D3=I->S
%       4 coronal flipped      : D1=R->L  D2=S->I  D3=P->A
%       5 sagittal flipped     : D1=P->A  D2=I->S  D3=L->R
%
%  VERSION :
%    0.90 13.06.05 YM  pre-release
%    0.91 14.06.05 YM  bug fix, tested with 'm02lx1'
%    0.92 08.08.05 YM  checks reco.RECO_byte_order for machine format.
%    0.93 12.02.07 YM  bug fix on 3D-MDEFT
%    0.94 13.02.07 YM  supports FLIPDIM
%    0.95 21.02.07 YM  supports EXPORT_AS_2D
%    0.96 27.02.07 YM  supports SAVEDIR, hdr.dim.dim(1) as 4 always.
%    0.97 20.03.08 YM  supports 'FileRoot' as option.
%    0.98 08.04.08 YM  supports 'Verbose' as option.
%    0.99 14.09.09 YM  bug fix of RECO_transposition, help by MB.
%    1.00 19.05.11 YM  supports 'permute' (may not work for 4D data).
%    1.01 04.10.12 YM  supports 'AverageInTime'.
%    1.10 13.06.13 YM  fix problems when reading angiography (GEFC_TOMO).
%    1.11 14.02.14 YM  supports bru2analyze_gui().
%    1.12 07.03.14 YM  use expfilename() instead of catfilename().
%    1.13 26.05.15 YM  supports .nii (NIfTI-1).
%    1.14 17.04.18 YM  more info in .txt.
%
%  See also HDR_INIT HDR_WRITE PVREAD_RECO PVREAD_ACQP PVREAD_IMND
%           BRU2ANALYZE_GUI ANZ_VIEW TCIMG2SPM SPM2TCIMG

if nargin == 0
  if exist('bru2analyze_gui.m','file'),
    bru2analyze_gui;
  else
    eval(['help ' mfilename]);
  end
  return
end

SAVEDIR = 'spmanz';

% GET FILENAME, CROPPING INFO. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IMGCROP = [];  SLICROP = [];
PERMUTE_V = [];
FLIPDIM_V = [];
DO_AVERAGE = 0;

EXPORT_AS_2D = [];   SPLIT_IN_TIME = [];
EXPORT_AS_NII = 0;
FILE_ROOT = '';

NII_COMPATIBLE = 'spm';  % spm|amira|slicer|qform=2,d=1


VERBOSE = 1;
if ischar(varargin{1}) && ~isempty(strfind(varargin{1},'2dseq')),
  % called like BRU2ANALYZE(2DSEQFILE,varargin)
  TDSEQFILE = varargin{1};
  % parse inputs
  for N = 2:2:nargin,
    switch lower(strrep(varargin{N},' ','')),
     case {'imgcrop','imagecrop'}
      IMGCROP = varargin{N+1};
     case {'slicop','slicecrop'}
      SLICROP = varargin{N+1};
     case {'permute'}
      PERMUTE_V = varargin{N+1};
     case {'flipdim','flipdimension'}
      FLIPDIM_V = varargin{N+1};
     case {'average' 'taverage' 'timeaverage'}
      DO_AVERAGE = varargin{N+1};
     case {'exportas2d','export2d',}
      EXPORT_AS_2D  = varargin{N+1};
     case {'splitintime','splittime','tsplit' 'timesplit'}
      SPLIT_IN_TIME = varargin{N+1};
     case {'savedir','savedirectory'}
      SAVEDIR = varargin{N+1};
     case {'fileroot','froot','savename','filename','fname'}
      FILE_ROOT = varargin{N+1};
     case {'nii','nifti-1','nifti1','nifti'}
      EXPORT_AS_NII = varargin{N+1};
     case {'niicompatible','nii_compatible'}
      NII_COMPATIBLE = varargin{N+1};
     case {'verbose'}
      VERBOSE = varargin{N+1};
    end
  end
else
  % called like BRU2ANALYZE(SESSION,EXPNO,varargin)
  Ses = goto(varargin{1});
  ExpNo = varargin{2};
  if ~isnumeric(ExpNo) || length(ExpNo) ~= 1,
    fprintf('%s ERROR: 2nd arg. must be a numeric ExpNo.\n',mfilename);
    return;
  end
  if nargout,
    varargout = bru2analyze(expfilename(Ses,ExpNo,'2dseq'),varargin{:});
  else
    bru2analyze(expfilename(Ses,ExpNo,'2dseq'),varargin{:});
  end
  return
end
if isempty(EXPORT_AS_2D),   EXPORT_AS_2D  = 0;  end
if isempty(SPLIT_IN_TIME),  SPLIT_IN_TIME = 1;  end
if ~isempty(FLIPDIM_V) && ischar(FLIPDIM_V),
  % 'FLIPDIM_V' is given as a string like, 'Y' or 'XZ'
  tmpdim = [];
  for N=1:length(FLIPDIM_V),
    tmpidx = strfind('xyz',lower(FLIPDIM_V(N)));
    if ~isempty(tmpidx),  tmpdim(end+1) = tmpidx;  end
  end
  FLIPDIM_V = tmpdim;
  clear tmpdim tmpidx;
end


[fp,fr,fe] = fileparts(TDSEQFILE);
RECOFILE = fullfile(fp,'reco');
[fp,fr,fe] = fileparts(fileparts(fp));
ACQPFILE = fullfile(fp,'acqp');
IMNDFILE = fullfile(fp,'imnd');

if exist(TDSEQFILE,'file') == 0,
  fprintf(' %s ERROR: ''%s'' not found.\n',mfilename,TDSEQFILE);
  return;
end
if exist(RECOFILE,'file') == 0,
  fprintf(' %s ERROR: ''%s'' not found.\n',mfilename,RECOFILE);
  return;
end
if exist(ACQPFILE,'file') == 0,
  fprintf(' %s ERROR: ''%s'' not found.\n',mfilename,ACQPFILE);
  return;
end


% READ RECO/ACQP INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if VERBOSE > 0,
  fprintf(' %s: reading reco/acqp',mfilename);
end
reco = pvread_reco(RECOFILE);
acqp = pvread_acqp(ACQPFILE);
imnd = pvread_imnd(IMNDFILE,'verbose',0);

if length(reco.RECO_size) == 3,
  % likely mdeft
  nx = reco.RECO_size(1);
  ny = reco.RECO_size(2);
  nz = reco.RECO_size(3);
  xres = reco.RECO_fov(1) / reco.RECO_size(1) * 10;	  % 10 for cm -> mm
  yres = reco.RECO_fov(2) / reco.RECO_size(2) * 10;	  % 10 for cm -> mm
  zres = reco.RECO_fov(3) / reco.RECO_size(3) * 10;	  % 10 for cm -> mm
else
  % likely epi or others
  nx = reco.RECO_size(1);
  ny = reco.RECO_size(2);
  nz = acqp.NSLICES;
  xres = reco.RECO_fov(1) / reco.RECO_size(1) * 10;	  % 10 for cm -> mm
  yres = reco.RECO_fov(2) / reco.RECO_size(2) * 10;	  % 10 for cm -> mm
  if isfield(acqp,'ACQ_slice_sepn')
    zres = mean(acqp.ACQ_slice_sepn);
    if length(acqp.ACQ_slice_sepn) >= 1 && nz == 1,
      % likely angiography sequence, correct the num. of slices.
      nz = length(acqp.ACQ_slice_sepn)+1;
    end
  elseif isfield(imnd,'IMND_slice_sepn')
    zres = mean(imnd.IMND_slice_sepn);
    if length(imnd.IMND_slice_sepn) >= 1 && nz == 1,
      % likely angiography sequence, correct the num. of slices.
      nz = length(imnd.IMND_slice_sepn)+1;
    end
  end
  if nz == 1,
    zres = acqp.ACQ_slice_thick;
  end
end

tmpfs  = dir(TDSEQFILE);
switch reco.RECO_wordtype,
 case {'_8BIT_UNSGN_INT'}
  dtype = 'uint8';
  nt = floor(tmpfs.bytes/nx/ny/nz);
 case {'_16BIT_SGN_INT'}
  dtype = 'int16';
  nt = floor(tmpfs.bytes/nx/ny/nz/2);
 case {'_32BIT_SGN_INT'}
  dtype = 'int32';
  nt = floor(tmpfs.bytes/nx/ny/nz/4);
end
if nt == 1,  SPLIT_IN_TIME = 0;  end
if strcmpi(reco.RECO_byte_order,'bigEndian'),
  machineformat = 'ieee-be';
else
  machineformat = 'ieee-le';
end


% check trasposition on reco
transpos = 0;
if isfield(reco,'RECO_transposition'),
  transpos = reco.RECO_transposition(1);
elseif isfield(reco,'RECO_transpose_dim'),
  transpos = reco.RECO_transpose_dim(1);
end
if any(transpos),
  if transpos == 1,
    % (x,y,z) --> (y,x,z)
    tmpx = nx;    tmpy = ny;
    nx   = tmpy;  ny   = tmpx;
    tmpx = xres;  tmpy = yres;
    xres = tmpy;  yres = tmpx;
  elseif transpos == 2,
    % (x,y,z) --> (x,z,y)
    tmpy = ny;    tmpz = nz;
    ny   = tmpz;  nz   = tmpy;
    tmpy = yres;  tmpz = zres;
    yres = tmpz;  zres = tmpy;
  elseif transpos == 3,
    % (x,y,z) --> (z,y,x)
    tmpx = nx;    tmpz = nz;
    nx   = tmpz;  nz   = tmpx;
    tmpx = xres;  tmpz = zres;
    xres = tmpz;  zres = tmpx;
  end
  clear tmpx tmpy tmpz
end


% READ IMAGE DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if VERBOSE > 0,
  fprintf('/2dseq[%dx%dx%d %d %s]...',nx,ny,nz,nt,dtype);
end
fid = fopen(TDSEQFILE,'rb',machineformat);
IMG = fread(fid,inf,sprintf('%s=>%s',dtype,dtype));
fclose(fid);
if nt > 1,
  IMG = reshape(IMG,[nx,ny,nz,nt]);
  if DO_AVERAGE,
    fprintf(' average(nt=%d).',nt);
    nt = 1;
    SPLIT_IN_TIME = 0;    
    IMG = nanmean(double(IMG),4);
    switch lower(dtype)
     case {'uint8'}
      IMG = uint8(round(IMG));
     case {'int16'}
      IMG = int16(round(IMG));
     case {'int32'}
      IMG = int32(round(IMG));
    end
  end
else
  IMG = reshape(IMG,[nx,ny,nz]);
end
RECOSZ = size(IMG);


PIXDIM = [xres yres zres NaN];
if length(PERMUTE_V) == ndims(IMG),
  fprintf('permute[%s]...',strtrim(sprintf('%d ',PERMUTE_V)));
  IMG = permute(IMG,PERMUTE_V);
  PIXDIM = PIXDIM(PERMUTE_V);
  xres = PIXDIM(1);
  yres = PIXDIM(2);
  zres = PIXDIM(3);
end

if ~isempty(FLIPDIM_V),
  if VERBOSE > 0,
    tmpstr = 'XYZT';
    fprintf('flipping(%s)...',tmpstr(FLIPDIM_V));
  end
  for N = 1:length(FLIPDIM_V),
    IMG = flipdim(IMG,FLIPDIM_V(N));
  end
end
if ~isempty(IMGCROP),
  if VERBOSE > 0,
    fprintf('imgcrop[%d:%d %d:%d]...',...
            IMGCROP(1),IMGCROP(3)+IMGCROP(1)-1,...
            IMGCROP(2),IMGCROP(4)+IMGCROP(2)-1);
  end
  idx = (1:IMGCROP(3)) + IMGCROP(1) - 1;
  IMG = IMG(idx,:,:,:);
  idx = (1:IMGCROP(4)) + IMGCROP(2) - 1;
  IMG = IMG(:,idx,:,:);
end
if ~isempty(SLICROP),
  if VERBOSE > 0,
    fprintf('slicrop[%d:%d]',SLICROP(1),SLICROP(2)+SLICROP(1)-1);
  end
  idx = (1:SLICROP(2)) + SLICROP(1) - 1;
  IMG = IMG(:,:,idx,:);
end


% PREPARE HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use size() instead of nx/ny/nz/nt because of cropping
pixdim = [3 PIXDIM(1:3)];
if nt > 1,
  % functional
  if SPLIT_IN_TIME > 0,
    if size(IMG,3) == 1 || EXPORT_AS_2D > 0,
      dim = [4 size(IMG,1) size(IMG,2) 1 1];
    else
      dim = [4 size(IMG,1) size(IMG,2) size(IMG,3) 1];
    end
  else
    if EXPORT_AS_2D && size(IMG,3) > 1,
      dim = [4 size(IMG,1) size(IMG,2) 1 size(IMG,4)];
    else
      dim = [4 size(IMG,1) size(IMG,2) size(IMG,3) size(IMG,4)];
    end
  end
else
  % anatomy
  if size(IMG,3) == 1 || EXPORT_AS_2D > 0,
    dim = [4 size(IMG,1) size(IMG,2) 1 1];
  else
    dim = [4 size(IMG,1) size(IMG,2) size(IMG,3) 1];
  end
end


if EXPORT_AS_NII,
  HDR = nii_init('datatype',dtype,'dim',dim,'pixdim',pixdim,'glmax',intmax('int16'),'niicompatible',NII_COMPATIBLE);
else
  HDR = hdr_init('datatype',dtype,'dim',dim,'pixdim',pixdim,'glmax',intmax('int16'));
end


% SET OUTPUTS, IF REQUIRED.  OTHERWISE SAVE TO FILES =====================================
if nargout,
  varargout{1} = HDR;
  if nargout > 1,
    varargout{2} = IMG;
  end
  if VERBOSE > 0,  fprintf(' done.\n');  end
  return;
end


% OK, WRITE DATA =========================================================================
if VERBOSE > 0,
  fprintf(' saving to ''%s''(2D=%d,SplitInTime=%d,nii=%d',SAVEDIR,EXPORT_AS_2D,SPLIT_IN_TIME,EXPORT_AS_NII);
  if EXPORT_AS_NII,
    fprintf(':%s',NII_COMPATIBLE);
  end
  fprintf(')...');
end
%if exist(fullfile(pwd,SAVEDIR),'dir') == 0,
%  mkdir(pwd,SAVEDIR);
%end
if exist(SAVEDIR,'dir') == 0,
  mkdir(SAVEDIR);
end
if isempty(FILE_ROOT),
  froot = subGetFileRoot(TDSEQFILE);
  if isempty(froot),
    froot = sprintf('anz');
  end
else
  froot = FILE_ROOT;
end

if EXPORT_AS_NII,
  wmode = 'ab';
else
  wmode = 'wb';
end

if nt > 1,
  subExportFunctional(SAVEDIR,froot,HDR,IMG,EXPORT_AS_2D,SPLIT_IN_TIME,EXPORT_AS_NII);
else
  % anatomy
  if EXPORT_AS_2D > 0 && size(IMG,3) > 1,
    for S = 1:size(IMG,3),
      if EXPORT_AS_NII,
        IMGFILE = sprintf('%s/%s_sl%03d.nii',SAVEDIR,froot,S);
        HDRFILE = IMGFILE;
      else
        IMGFILE = sprintf('%s/%s_sl%03d.img',SAVEDIR,froot,S);
        HDRFILE = sprintf('%s/%s_sl%03d.hdr',SAVEDIR,froot,S);
      end
      hdr_write(HDRFILE,HDR);
      fid = fopen(IMGFILE,wmode);
      fwrite(fid,IMG(:,:,S),class(IMG));
      fclose(fid);
    end
  else
    if EXPORT_AS_NII,
      IMGFILE = sprintf('%s/%s.nii',SAVEDIR,froot);
      HDRFILE = IMGFILE;
    else
      IMGFILE = sprintf('%s/%s.img',SAVEDIR,froot);
      HDRFILE = sprintf('%s/%s.hdr',SAVEDIR,froot);
    end
    hdr_write(HDRFILE,HDR);
    fid = fopen(IMGFILE,wmode);
    fwrite(fid,IMG,class(IMG));
    fclose(fid);
  end
end
% write information as a text file
subWriteInfo(SAVEDIR,froot,acqp,reco,HDR,...
             TDSEQFILE,RECOSZ,[xres,yres,zres],...
             EXPORT_AS_2D,SPLIT_IN_TIME,EXPORT_AS_NII,NII_COMPATIBLE,...
             DO_AVERAGE,IMGCROP,SLICROP,PERMUTE_V,FLIPDIM_V);


if VERBOSE > 0,  fprintf(' done.\n');  end

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function froot = subGetFileRoot(TDSEQFILE)

try
  tmpf = TDSEQFILE;
  for N=1:2, [tmpf,recono] = fileparts(tmpf);  end
  for N=1:2, [tmpf scanno] = fileparts(tmpf);  end
  [tmpf,sesname,sesext] = fileparts(tmpf);
  sesname = sprintf('%s%s',sesname,sesext);
catch
  sesname = '';  scanno = '';  recono = '';
end

if ~isempty(scanno) && ~isempty(sesname),
  froot = sprintf('%s_scan%s-%s',strrep(sesname,'.',''),scanno,recono);
else
  froot = 'anz';
end

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subExportFunctional(SAVEDIR,froot,HDR,IMG,EXPORT_AS_2D,SPLIT_IN_TIME,EXPORT_AS_NII)

if EXPORT_AS_NII,
  wmode = 'ab';
else
  wmode = 'wb';
end

if SPLIT_IN_TIME > 0,
  if EXPORT_AS_2D > 0 && size(IMG,3) > 1,
    for N = 1:size(IMG,4),
      for S = 1:size(IMG,3),
        if EXPORT_AS_NII,
          IMGFILE = sprintf('%s/%s_%05d_sl%03d.nii',SAVEDIR,froot,N,S);
          HDRFILE = IMGFILE;
        else
          IMGFILE = sprintf('%s/%s_%05d_sl%03d.img',SAVEDIR,froot,N,S);
          HDRFILE = sprintf('%s/%s_%05d_sl%03d.hdr',SAVEDIR,froot,N,S);
        end
        hdr_write(HDRFILE,HDR);
        fid = fopen(IMGFILE,wmode);
        fwrite(fid,IMG(:,:,S,N),class(IMG));
        fclose(fid);
      end
    end
  else
    for N = 1:size(IMG,4),
      if EXPORT_AS_NII,
        IMGFILE = sprintf('%s/%s_%05d.nii',SAVEDIR,froot,N);
        HDRFILE = IMGFILE;
      else
        IMGFILE = sprintf('%s/%s_%05d.img',SAVEDIR,froot,N);
        HDRFILE = sprintf('%s/%s_%05d.hdr',SAVEDIR,froot,N);
      end
      hdr_write(HDRFILE,HDR);
      fid = fopen(IMGFILE,wmode);
      fwrite(fid,IMG(:,:,:,N),class(IMG));
      fclose(fid);
    end
  end
else
  if EXPORT_AS_2D > 0 && size(IMG,3) > 1,
    for S = 1:size(IMG,3),
      if EXPORT_AS_NII,
        IMGFILE = sprintf('%s/%s_sl%05d.nii',SAVEDIR,froot,S);
        HDRFILE = IMGFILE;
      else
        IMGFILE = sprintf('%s/%s_sl%05d.img',SAVEDIR,froot,S);
        HDRFILE = sprintf('%s/%s_sl%05d.hdr',SAVEDIR,froot,S);
      end
      hdr_write(HDRFILE,HDR);
      fid = fopen(IMGFILE,wmode);
      fwrite(fid,IMG(:,:,S,:),class(IMG));
      fclose(fid);
    end
  else
    if EXPORT_AS_NII,
      IMGFILE = sprintf('%s/%s.nii',SAVEDIR,froot);
      HDRFILE = IMGFILE;
    else
      IMGFILE = sprintf('%s/%s.img',SAVEDIR,froot);
      HDRFILE = sprintf('%s/%s.hdr',SAVEDIR,froot);
    end
    hdr_write(HDRFILE,HDR);
    fid = fopen(IMGFILE,wmode);
    fwrite(fid,IMG(:,:,:,:),class(IMG));
    fclose(fid);
  end
end
  
  
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subWriteInfo(SAVEDIR,froot,acqp,reco,HDR,TDSEQFILE,RECOSZ,XYZRES,EXPORT_AS_2D,SPLIT_IN_TIME,EXPORT_AS_NII,NII_COMPATIBLE,DO_AVERAGE,IMGCROP,SLICROP,PERMUTE_V,FLIPDIM_V)

TXTFILE = sprintf('%s/%s_info.txt',SAVEDIR,froot);
fid = fopen(TXTFILE,'wt');
fprintf(fid,'date:       %s\n',datestr(now));
fprintf(fid,'program:    %s\n',mfilename);
fprintf(fid,'platform:   MATLAB %s\n',version());

fprintf(fid,'\n');
fprintf(fid,'[input]\n');
fprintf(fid,'sw_version: %s\n',acqp.ACQ_sw_version);
fprintf(fid,'pulprog:    %s\n',acqp.PULPROG);
fprintf(fid,'ACQ_time:   %s\n',acqp.ACQ_time);
fprintf(fid,'RECO_time:  %s\n',reco.RECO_time);
fprintf(fid,'2dseq:      %s\n',TDSEQFILE);
fprintf(fid,'map_mode:   %s\n',reco.RECO_map_mode);
fprintf(fid,'recosize:   [');  fprintf(fid,' %d',RECOSZ); fprintf(fid,' ]\n');
fprintf(fid,'xyzres:     [');  fprintf(fid,' %g',XYZRES); fprintf(fid,' ] in mm\n');
fprintf(fid,'wordtype:   %s\n',reco.RECO_wordtype);
fprintf(fid,'byte_order: %s\n',reco.RECO_byte_order);

fprintf(fid,'\n');
fprintf(fid,'[process]\n');
fprintf(fid,'imgcrop:    [');
if ~isempty(IMGCROP),
  fprintf(fid,'%d %d %d %d',IMGCROP(1),IMGCROP(2),IMGCROP(3),IMGCROP(4));
end
fprintf(fid,'] as [x y w h]\n');
fprintf(fid,'slicrop:    [');
if ~isempty(SLICROP),
  fprintf(fid,'%d %d',SLICROP(1),SLICROP(2));
end
fprintf(fid,'] as [start n]\n');
fprintf(fid,'permute:    [');
if ~isempty(PERMUTE_V),  fprintf(fid,'%s ',sprintf(' %d',PERMUTE_V));  end
fprintf(fid,']\n');
fprintf(fid,'flipdim:    [');
if ~isempty(FLIPDIM_V),  fprintf(fid,'%s ',sprintf(' %d',FLIPDIM_V));  end
fprintf(fid,']\n');
fprintf(fid,'average:       %d\n',DO_AVERAGE);
fprintf(fid,'export_as_2d:  %d\n',EXPORT_AS_2D);
fprintf(fid,'time_split:    %d\n',SPLIT_IN_TIME);

fprintf(fid,'\n');
fprintf(fid,'[output]\n');
if EXPORT_AS_NII,
fprintf(fid,'format:     NIfTI-1 (.nii:%s)\n',NII_COMPATIBLE);
else
fprintf(fid,'format:     ANALYZE-7.5 (.hdr/img)\n');
end
fprintf(fid,'dim:        [');  fprintf(fid,' %d',HDR.dime.dim(2:end));  fprintf(fid,' ]\n');
fprintf(fid,'pixdim:     [');  fprintf(fid,' %g',HDR.dime.pixdim(2:end));  fprintf(fid,' ] in mm\n');
fprintf(fid,'datatype:   %d',HDR.dime.datatype);
switch HDR.dime.datatype
 case 1
  dtype =  'binary';
 case 2
  dtype =  'uint8';
 case 4
  dtype =  'int16';
 case 8
  dtype =  'int32';
 case 16
  dtype =  'float';
 case 32
  dtype =  'complex';
 case 64
  dtype =  'double';
 case 128
  dtype =  'rgb';
 otherwise
  dtype =  'unknown';
end
fprintf(fid,'(%s)\n',dtype);
[str,maxsize,endian] = computer;
fprintf(fid,'endian:     %s\n',endian);

fclose(fid);

return
