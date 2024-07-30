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
%           rat_atlas: 'Y:\DataMatlab\Anatomy\Rat_Atlas\GSKrat97templateMRI+atlas.v5\v5\96x96x120'
%
%    getdirs('DataMatlab')
%      ans = Y:\DataMatlab
%
%  VERSION :
%    0.90 05.08.08 YM  modified from NKL, 02 03.99
%    0.91 19.01.09 YM  bug fix
%    0.92 29.01.12 YM  split into this and getdirs_def.
%
%  See also fullfile getHostName utils/getdirs_def

DIRS = getdirs_def;

switch lower(DIRS.HOSTNAME),
 case {'win49'},			% OLD MRI
  DIRS.homedir	= '\\win58\mri/';
  DIRS.DataMatlab	= '\\win58\DataMatlab/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= '\\win58\DataNeuro/';
  DIRS.unconv_dir	= 'e:/adfdat/';    % unconverted adf/adfw
  DIRS.movdir	= '\\win58\Mri/Movies/';
 case {'win67'},			% NEW MRI
  DIRS.homedir	= 'D:/Mri/';
  DIRS.DataMatlab	= 'E:/DataMatlab/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= 'E:/DataNeuro/';
  DIRS.movdir	= 'D:/Mri/Movies/';
 case {'win28'},			% MRI-4.7T
  DIRS.homedir	= 'd:/analysis/matlab_mri/'; % matlab scripts home
  DIRS.DataMri	= 'z:/DATA/nmr/';     % mri data
  DIRS.DataNeuro	= 'r:/DataNeuro/';    % dgz, adf/adfw
  DIRS.DataMatlab	= 'c:/DataMatlab/';   % processed data
  DIRS.unconv_dir	= 't:/DataNeuro/';    % unconverted adf/adfw
  DIRS.stimhome = 'x:/Mri/MriStim/';
  DIRS.bitmapdir = strcat(DIRS.homedir,'stmimages/');
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win17'},			% Neurophys. room
  DIRS.homedir	= 'd:/analysis/matlab_mri/'; % matlab scripts home
  DIRS.DataMri	= 'z:/DATA/nmr/';     % mri data
  DIRS.DataNeuro	= 't:/DataNeuro/';    % dgz, adf/adfw G-drive on win49
  DIRS.DataMatlab	= 'd:/DataMatlab/';   % processed data
  DIRS.unconv_dir	= 'e:/';    % unconverted adf/adfw on win47
  DIRS.stimhome = 'x:/Mri/MriStim/';
  DIRS.bitmapdir = strcat(DIRS.homedir,'stmimages/');
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win19'},			% JOSEF MATLAB-COMPUTER
  DIRS.homedir	= 'd:/';
  DIRS.DataMri	= '//Wks5/guest/mridata/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= 'd:/matlab/data/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win220'},			% Michaels MATLAB-COMPUTER
  DIRS.homedir	= 'd:/';
  DIRS.DataMri	= '//Wks5/guest/mridata/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= 'd:/matlab/data/';
 case {'nklwin'},		% NIKOS DESKTOP
  DIRS.homedir	= '\\win58\mri/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= '\\win58\DataMatlab/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win42'},			% NIKOS LAPTOP
  DIRS.homedir	= 'f:/mri/';
  DIRS.DataMri	= 'f:/Data/';
  DIRS.DataNeuro	= 'f:/DataNeuro/';
  DIRS.DataMatlab	= 'f:/DataMatlab/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'nb-nikos'},	% NIKOS IBM LAPTOP 2011
  DIRS.homedir	= 'y:/mri/';
  DIRS.DataMri	= 'y:/DataMri/';
  DIRS.DataNeuro	= 'y:/DataNeuro/';
  DIRS.DataMatlab	= 'y:/DataMatlab/';
  DIRS.movdir	= 'y:/Mri/Movies/';
 case {'win4'},			% NIKOS IBM LAPTOP 2006
  DIRS.homedir	= 'f:/mri/';
  DIRS.DataMri	= 'f:/DataMri/';
  DIRS.DataNeuro	= 'f:/DataNeuro/';
  DIRS.DataMatlab	= 'f:/DataMatlab/';
  DIRS.DataMatlab	= 'h:/Data/DataMatlab/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win10'},			% NIKOS IBM LAPTOP NEW
  DIRS.homedir	= 'f:/mri/';
  DIRS.DataMri	= 'f:/DataMri/';
  DIRS.DataNeuro	= 'f:/DataNeuro/';
  DIRS.DataMatlab	= 'f:/DataMatlab/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win25'},			% NIKOS DELL LAPTOP NEW
  DIRS.homedir	= 'f:/mri/';
  DIRS.DataMri	= 'f:/DataMri/';
  DIRS.DataNeuro	= 'f:/DataNeuro/';
  DIRS.DataMatlab	= 'd:/DataMatlab/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win85'},			% NIKOS NEW IBM 2005
  DIRS.homedir	= 'f:/mri/';
  DIRS.DataMri	= 'f:/DataMri/';
  DIRS.DataNeuro	= 'f:/DataNeuro/';
  DIRS.DataMatlab	= 'f:/DataMatlab/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win45'},			% NIKOS IBM LAPTOP
  DIRS.homedir	= 'f:/mri/';
  DIRS.DataMri	= 'f:/DataMri/';
  DIRS.DataNeuro	= 'f:/DataNeuro/';
  DIRS.DataMatlab	= 'f:/DataMatlab/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win49'},			% NIKOS LAPTOP
  DIRS.homedir	= 'e:/';
  DIRS.DataMri	= 'e:/Data/';
  DIRS.DataNeuro	= 'e:/DataNeuro/';
  DIRS.DataMatlab	= 'e:/DataMatlab/';
 case {'win58'},			% NIKOS MATLAB-COMPUTER #1
  DIRS.homedir	= '\\win58\mri/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= '\\win58\DataMatlab/';
  %DIRS.DataMatlab  = '//wks20/Data/DataMatlab/';
  DIRS.movdir	= '\\win58\Mri/Movies/';
 case {'win209'},			% Test JW
  DIRS.homedir	= '\\win58\mri/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= 'b:/DataMatlab/';
  DIRS.movdir	= '\\win58\Mri/Movies/';   
 case {'win7'},			% NIKOS MATLAB-COMPUTER #1
  DIRS.homedir	= '\\win58\mri/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= '\\win58\DataMatlab/';
  DIRS.movdir	= '\\win58\Mri/Movies/';
 case {'win54'},			% NIKOS MATLAB-COMPUTER #1
  DIRS.homedir	= '\\win58\mri/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= '\\win58\DataMatlab/';
  DIRS.movdir	= '\\win58\Mri/Movies/';
 case {'wks20'},			% NIKOS MATLAB-COMPUTER #1
  DIRS.homedir	= '/y/mri/';
  DIRS.DataMri	= '/z/DATA/nmr/';
  DIRS.DataNeuro	= '/t/DataNeuro/';
  DIRS.DataMatlab	= '/y/DataMatlab/';
  DIRS.movdir	= '/y/Mri/Movies/';
 case {'node1' 'node2' 'node3' 'node4' 'node5' 'node6' 'node7' 'node8'},
  DIRS.homedir	= 'd:/mri/';
  DIRS.DataMri	= '//wks8/guest/';
  DIRS.DataMri	= 'd:/DataMri/';
  DIRS.DataNeuro	= 'd:/DataNeuro/';
  DIRS.DataMatlab	= 'd:/DataMatlab/';
  %DIRS.DataMatlab    = '//wks20/Data/DataMatlab/';
  %DIRS.DataMatlab    = '\\Win58\ydisk\DataMatlab\';
  DIRS.movdir	= 'd:/Mri/Movies/';
  DIRS.TMP		= 'd:/DataMatlab/tmp';
 case {'n01' 'n02' 'n03' 'n04' 'n05' 'n06' 'n07' 'n08'},
  if isunix,
    DIRS.homedir	= '/y/mri/';
    DIRS.DataMri	= '/z/DATA/nmr/';
    DIRS.DataNeuro	= '/t/DataNeuro/';
    DIRS.DataMatlab	= '/y/DataMatlab/';
    DIRS.movdir	= '/y/Mri/Movies/';
    DIRS.TMP		= '/y/DataMatlab/tmp';
  else
    DIRS.homedir	= '\\win58\mri/';
    DIRS.DataMri	= '//wks8/guest/';
    DIRS.DataNeuro	= 't:/DataNeuro/';
    DIRS.DataMatlab	= '\\win58\DataMatlab/';
    DIRS.DataMatlab    = '//wks20/Data/DataMatlab/';
    %DIRS.DataMatlab    = '\\Win58\ydisk\DataMatlab\';
    DIRS.movdir	= '\\win58\Mri/Movies/';
    DIRS.TMP		= '\\win58\DataMatlab/tmp';
  end
 case {'win306'}
  DIRS.homedir	= 'd:/mri/';
  DIRS.DataMri	= '//wks8/guest/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= 'd:/DataMatlab/';
  %DIRS.DataMatlab    = '//wks20/Data/DataMatlab/';
  %DIRS.DataMatlab    = '\\Win58\ydisk\DataMatlab\';
  DIRS.movdir	= 'd:/Mri/Movies/';
  DIRS.TMP		= 'd:/DataMatlab/tmp';
 case {'win59'},			% NIKOS MATLAB-COMPUTER #2
%   DIRS.homedir	= '\\win58\mri/';
%   DIRS.DataMri	= 'z:/DATA/nmr/';
%   DIRS.DataNeuro	= 't:/DataNeuro/';
%   DIRS.DataMatlab	= '\\win58\DataMatlab/';
%   DIRS.movdir	= '\\win58\Mri/Movies/';
  DIRS.homedir	= '\\win58\/mri/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= 'b:/DataNeuro/';
  DIRS.DataMatlab	= 'b:/DataMatlab/';
  DIRS.movdir	= '\\win58\Mri/Movies/';
 case {'win82'},			% AMIR'S ANALYSIS COMPUTER
  DIRS.homedir	= '\\win58\mri/';
  DIRS.DataMri	= 'z:/DATA/nmr/';
  DIRS.DataNeuro	= 't:/DataNeuro/';
  DIRS.DataMatlab	= '\\win58\DataMatlab/';
  DIRS.movdir	= 'f:/Mri/Movies/';
 case {'win199'},			% ANDREI'S COMPUTER
  DIRS.homedir	= 'd:/mri/matlab/'; % matlab scripts home
  DIRS.DataMri	= 'z:/DATA/nmr/';     % mri data
  DIRS.DataNeuro	= 't:/DataNeuro/';    % dgz, adf/adfw
  DIRS.DataMatlab	= 'd:/DataMatlab/';   % processed data
  DIRS.DataMatlab  = '//wks20/Data/DataMatlab/';
  DIRS.bitmapdir = strcat(DIRS.homedir,'stmimages/');
  DIRS.stimhome = 'd:/homes/lab/Stim/';
  DIRS.movdir	= 'e:/Mri/Movies/';
  DIRS.TMP     = 'd:/DataMatlab/tmp'; 
 case {'win44'},			% MARK COMPUTER
  DIRS.homedir	= 'f:/MRI/matlab/win58Y_matlab/'; % matlab scripts home
  DIRS.DataMri	= 'z:/DATA/nmr/';     % mri data
  DIRS.DataNeuro	= 't:/DataNeuro/';    % dgz, adf/adfw
  DIRS.DataMatlab	= 'f:/MRI/matlab/DataMatlab/';   % processed data
  DIRS.bitmapdir = strcat(DIRS.homedir,'stmimages/');
  DIRS.stimhome = 'd:/homes/lab/Stim/';
  DIRS.movdir	= 'e:/Mri/Movies/';
  DIRS.TMP     = 'e:/DataMatlab/tmp'; 
 otherwise,
  % likely clustr machine... CLUST
  %DIRS.homedir = sprintf('%s%s',fileparts(pwd),filesep);
  DIRS.homedir = fullfile(fileparts(fileparts(mfilename('fullpath'))),filesep);
  DIRS.DataMri	= '//wks8/guest/';
  if strcmpi(DIRS.homedir(2),':'),
    DRV = DIRS.homedir(1:2);
  else
    % network...
    tmpidx = findstr(DIRS.homedir,filesep);
    if tmpidx(1) == 1 && tmpidx(2) == 2,
      % likely SAMBA...
      DRV = DIRS.homedir(1:tmpidx(4));
    else
      DRV = DIRS.homedir(1:tmpidx(2));
    end
  end
  DIRS.DataNeuro	= fullfile(DRV,'DataNeuro/');
  DIRS.DataMatlab	= fullfile(DRV,'DataMatlab/');
  DIRS.movdir	= fullfile(fileparts(DIRS.homedir),'Movies/');
  DIRS.TMP		= fullfile(DRV,'DataMatlab/tmp');
  %error('ERROR %s DataMatlab=%s',mfilename,DIRS.DataMatlab);  % this to check for the cluster machine...
end;


% return only required value
if exist('FIELD_NAME','var') && ~isempty(FIELD_NAME),
  DIRS = DIRS.(FIELD_NAME);
end

return

