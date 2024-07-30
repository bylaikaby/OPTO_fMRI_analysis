function DIRS = getdirs(FIELD_NAME)
%GETDIRS - Returns the platform-dependent directory structure
%  DIRS = GETDIRS returns the platform-dependent directory structure.
%  DIR = GETDIRS(FIELD_NAME) returns the given directory.
%
%  If neede, add host specific directories in this file.
%  Note that DataMri/DataNeuro/DataMatlab can be set in the description file like
%    SYSP.DataMri    = '//Wks8/guest';
%    SYSP.DataNeuro  = '//Win49/E/DataNeuro/';
%    SYSP.DataMatlab = 'E:/DataMatlab';
%
%  EXAMPLE :
%    dirs = getdirs
%      dirs = 
%            HOSTNAME: 'n07'
%                home: 'Y:\Mri\MatLab'
%             DataMri: '//wks8/guest/'
%           DataNeuro: 't:/DataNeuro/'
%          DataMatlab: 'y:/DataMatlab/'
%              movdir: 'Y:\Mri\Movies'
%                 TMP: 'Y:\DataMatlab\tmp'
%          unconv_dir: 'Y:\DataMatlab\tmp'
%            stimhome: 'Y:\DataMatlab'
%           bitmapdir: 'Y:\Mri\MatLab\stim\bitmaps'
%     mrvista_anatomy: 'Y:\DataMatlab\Anatomy'
%          atlas_root: 'Y:\DataMatlab\Anatomy'
%
%    getdirs('DataMatlab')
%      ans = Y:\DataMatlab
%
%  VERSION :
%    0.90 05.08.08 YM  modified from NKL, 02 03.99
%    0.91 19.01.09 YM  bug fix
%    0.92 29.01.12 YM  split into this and getdirs_def.
%    0.93 13.06.12 YM  clean up entries of computers, obsolete 'homedir'.
%
%  See also fullfile getHostName utils/getdirs_def

DIRS = getdirs_def;

switch lower(DIRS.HOSTNAME),
 case {'win58'},			% NIKOS MATLAB-COMPUTER #1
  % DIRS.homedir    = '\\nkldata\YDISK\mri\';
  DIRS.DataMri    = 'z:\DATA/nmr\';
  DIRS.DataNeuro  = 't:\DataNeuro\';
  DIRS.DataMatlab = '\\nkldata\YDISK\DataMatlab\';
  %DIRS.DataMatlab = '//wks20/Data/DataMatlab/';
  DIRS.movdir     = '\\nkldata\YDISK\Mri\Movies\';
 case {'nklwin'},		% NIKOS DESKTOP
  % DIRS.homedir    = '\\nkldata\YDISK\mri\';
  DIRS.DataMri    = 'z:\DATA\nmr\';
  DIRS.DataNeuro  = 't:\DataNeuro\';
  DIRS.DataMatlab = '\\nkldata\YDISK\DataMatlab\';
  DIRS.movdir     = 'f:\Mri\Movies\';
 
 case {'ultrabook-nikos'},	% NIKOS SAMSUNG LAPTOP 2011
  % DIRS.homedir    = 'y:/mri/';
  DIRS.DataMri    = 'f:/DataMri/';
  DIRS.DataNeuro  = 'f:/DataNeuro/';
  DIRS.DataMatlab = 'f:/DataMatlab/';
  DIRS.movdir     = 'f:/Mri/Movies/';
  
 case {'workbook-nikos'},	% NIKOS IBM LAPTOP 2011
  DIRS.homedir    = 'y:/mri/';
  DIRS.DataMri    = 'y:/DataMri/';
  DIRS.DataNeuro  = 'y:/DataNeuro/';
  DIRS.DataMatlab = 'y:/DataMatlab/';
  DIRS.movdir     = 'y:/Mri/Movies/';
 case {'nb-nikos'},	% NIKOS IBM LAPTOP 2011
  % DIRS.homedir    = 'y:/mri/';
  DIRS.DataMri    = 'y:/DataMri/';
  DIRS.DataNeuro  = 'y:/DataNeuro/';
  DIRS.DataMatlab = 'y:/DataMatlab/';
  DIRS.movdir     = 'y:/Mri/Movies/';
 case {'nb-nikos-travel'},	% NIKOS IBM LAPTOP 2015
  % DIRS.homedir    = 'y:/mri/';
  DIRS.DataMri    = 'y:/DataMri/';
  DIRS.DataNeuro  = 'y:/DataNeuro/';
  DIRS.DataMatlab = 'y:/DataMatlab/';
  DIRS.movdir     = 'y:/Mri/Movies/';
 case {'win85' 'win45' 'win42' 'win10'},  % NIKOS LAPTOPS
  % DIRS.homedir    = 'f:/mri/';
  DIRS.DataMri    = 'f:/DataMri/';
  DIRS.DataNeuro  = 'f:/DataNeuro/';
  DIRS.DataMatlab = 'f:/DataMatlab/';
  DIRS.movdir     = 'f:/Mri/Movies/';
 case {'win49'},			% NIKOS LAPTOP
  % DIRS.homedir    = 'e:/';
  DIRS.DataMri    = 'e:/Data/';
  DIRS.DataNeuro  = 'e:/DataNeuro/';
  DIRS.DataMatlab = 'e:/DataMatlab/';
 case {'win25'},			% NIKOS DELL LAPTOP NEW
  % DIRS.homedir    = 'f:/mri/';
  DIRS.DataMri    = 'f:/DataMri/';
  DIRS.DataNeuro  = 'f:/DataNeuro/';
  DIRS.DataMatlab = 'D:/DataMatlab/';
  DIRS.movdir     = 'f:/Mri/Movies/';
 
 case {'win18'},			% Matlabcomputer MS
  % DIRS.homedir    = '\\nkldata\YDISK\mri\';
  DIRS.DataMri    = 'z:/DATA/nmr/';
  DIRS.DataNeuro  = 't:/DataNeuro/';
  DIRS.DataMatlab = '\\nkldata\YDISK\DataMatlab\';
  DIRS.movdir     = '\\nkldata\YDISK\Mri/Movies\';
 case {'win209'},			% Test JW
  % DIRS.homedir    = '\\nkldata\YDISK\mri\';
  DIRS.DataMri    = 'z:/DATA/nmr/';
  DIRS.DataNeuro  = 't:/DataNeuro/';
  DIRS.DataMatlab = 'b:/DataMatlab/';
  DIRS.movdir     = '\\nkldata\YDISK\Mri/Movies\';
 case {'win220'},			% Michaels MATLAB-COMPUTER
  % DIRS.homedir    = 'd:/';
  DIRS.DataMri    = '//Wks5/guest/mridata/';
  DIRS.DataNeuro  = 't:/DataNeuro/';
  DIRS.DataMatlab = 'd:/matlab/data/';

 case {'win306'}
  % DIRS.homedir    = 'd:/mri/';
  DIRS.DataMri    = '//wks8/guest/';
  DIRS.DataNeuro  = 't:/DataNeuro/';
  DIRS.DataMatlab = 'd:/DataMatlab/';
  %DIRS.DataMatlab = '//wks20/Data/DataMatlab/';
  %DIRS.DataMatlab = '\\nkldata\YDISK\DataMatlab\';
  DIRS.movdir     = 'd:/Mri/Movies/';
  DIRS.TMP        = 'd:/DataMatlab/tmp';
 case {'win199'},			% ANDREI'S COMPUTER
  % DIRS.homedir    = 'd:/mri/matlab/'; % matlab scripts home
  DIRS.DataMri    = 'z:/DATA/nmr/';     % mri data
  DIRS.DataNeuro  = 't:/DataNeuro/';    % dgz, adf/adfw
  DIRS.DataMatlab = 'd:/DataMatlab/';   % processed data
  DIRS.DataMatlab = '//wks20/Data/DataMatlab/';
  DIRS.movdir     = 'e:/Mri/Movies/';
  DIRS.TMP        = 'd:/DataMatlab/tmp'; 
 case {'wks20'},			% wks20
  % DIRS.homedir    = '/y/mri/';
  DIRS.DataMri    = '/z/DATA/nmr/';
  DIRS.DataNeuro  = '/t/DataNeuro/';
  DIRS.DataMatlab = '/y/DataMatlab/';
  DIRS.movdir     = '/y/Mri/Movies/';
 
 otherwise,
  % just use what we get by getdirs_defs().
  
  % DIRS.homedir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),filesep);
  % DIRS.DataMri	= '//wks8/guest/';
  % if DIRS.homedir(2) == ':',
  %   DRV = DIRS.homedir(1:2);
  % else
  %   % network or *nix/mac...
  %   tmpidx = strfind(DIRS.homedir,filesep);
  %   if tmpidx(1) == 1 && tmpidx(2) == 2,
  %     % likely SAMBA...
  %     DRV = DIRS.homedir(1:tmpidx(min(4,length(tmpidx))));
  %   else
  %     DRV = DIRS.homedir(1:tmpidx(2));
  %   end
  % end
  % DIRS.DataNeuro  = fullfile(DRV,'DataNeuro/');
  % DIRS.DataMatlab = fullfile(DRV,'DataMatlab/');
  % DIRS.TMP        = fullfile(DRV,'DataMatlab/tmp');

  %error('ERROR %s DataMatlab=%s',mfilename,DIRS.DataMatlab);  % this to check for the cluster machine...
end;


% return only required value
if exist('FIELD_NAME','var') && ~isempty(FIELD_NAME),
  DIRS = DIRS.(FIELD_NAME);
end

return

