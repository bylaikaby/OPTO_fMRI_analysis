function ess2smr(varargin)
%ESS2SMR - exports adf/adfw/Cln data as 'smr' format for CED's Spikes2
%  ESS2SMR(ADFFILE) exports adf/adfw data as 'smr' format.
%  ESS2SMR(SESSION,[GRPEXP]) exports Cln dta as 'smr' format.
%
%  EXAMPLE :
%    >> ess2smr('y:/temp/testsmr.adfw')
%
%  VERSION :
%    0.90 15.01.07 YM  pre-release
%    0.91 16.01.07 YM  bug fix
%    0.92 22.02.07 YM  supports exporting the CLN signal.
%    0.93 20.05.14 YM  bug fix, supports sesversion()>=2
%
%  See also SONLOAD ADF_READ ADF_INFO

if nargin == 0,  eval(sprintf('help %s;',mfilename)); return;  end



% INITIALIZE SON Libray
SONLoad;


% CONTROL FLAGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BLOCK_SIZE = 16*1024;
EXPORT_DGZ = 0;   % right now, SONWriteMarkBlock is not supported yet.

if ~isempty(strfind(varargin{1},'.adfw')),
  % called like ess2smr(ADFFILE)
  fp = fileparts(varargin{1});
  tmpfiles = dir(varargin{1});
  for N = 1:length(tmpfiles),
    ADFFILE = fullfile(fp,tmpfiles(N).name);
    subExportADF(ADFFILE,BLOCK_SIZE,EXPORT_DGZ);
  end
else
  % called like ess2smr(SESSION,[GRPEXP])
  Ses = goto(varargin{1});
  if nargin > 1,
    if isnumeric(varargin{2}),
      EXPS = varargin{2};
    else
      EXPS = getexps(Ses,varargin{2});
    end
  else
    EXPS = validexps(Ses);
  end
  for N = 1:length(EXPS),
    subExportSIG(Ses,EXPS(N),'Cln',BLOCK_SIZE,EXPORT_DGZ);
  end
end

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subExportADF(ADFFILE,BLOCK_SIZE,EXPORT_DGZ)

% GET BASIC INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fp,fr,fe] = fileparts(ADFFILE);
ADFFILE2 = fullfile(fp,sprintf('%s_2%s',fr,fe));
DGZFILE  = fullfile(fp,sprintf('%s.dgz',fr));
SMRFILE  = fullfile(fp,sprintf('%s.smr',fr));
if ~exist(ADFFILE,'file'),
  error(' %s: ''%s'' not found.\n',mfilename,ADFFILE);
end
[nchan nobs sampt obslens] = adf_info(ADFFILE);  % samp as msec
if exist(ADFFILE2,'file'),
  [nchan2 nobs2 sampt2 obslens2] = adf_info(ADFFILE2);  % samp as msec
  % checks obslens and obslens2
  for N = 1:length(obslens),
    obslens(N) = min(obslens(N),obslens2(N));
  end
  %obslens2 = obslens;
else
  nchan2 = 0;
end

if EXPORT_DGZ,
  MARKER{1} = subGetEvents(DGZFILE,sampt,obslens);
else
  MARKER = {};
end

% prints available files
fprintf('%s %s: %s',datestr(now,'HH:MM:SS'),mfilename,ADFFILE);
if nchan2 > 0,
  fprintf(', %s_2%s',fr,fe);
end
if EXPORT_DGZ > 0 && exist(DGZFILE,'file'),
  fprintf(', %s.dgz',fr);
end
fprintf(': --> %s\n',SMRFILE);


fprintf('  reading(ch=%d)',nchan+nchan2);
% NOW READ DATA
ADFCHAN = 1:(nchan+nchan2);
ADFWAV = zeros(sum(obslens),length(ADFCHAN),'int16');
for iCh = 1:length(ADFCHAN),
  ChanNo = ADFCHAN(iCh);
  tmpoffs = 0;
  for iObs = 1:nobs,
    tmpsel = (1:obslens(iObs)) + tmpoffs;
    if ChanNo <= nchan,
      tmpwv = adf_read(ADFFILE,iObs-1,ChanNo-1,0,obslens(iObs),'int');
    else
      tmpwv = adf_read(ADFFILE2,iObs-1,ChanNo-nchan-1,0,obslens(iObs),'int');
    end
    ADFWAV(tmpsel,iCh) = tmpwv;
    tmpoffs = tmpoffs + obslens(iObs);
  end
  fprintf('.');
end

subWriteSMR(SMRFILE,BLOCK_SIZE,sampt,ADFCHAN,ADFWAV,MARKER)

fprintf(' done.\n');

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subExportSIG(Ses,ExpNo,SigName,BLOCK_SIZE,EXPORT_DGZ)

% GET BASIC INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%
Ses = goto(Ses);

fprintf('%s %s: %s(ExpNo=%d)',datestr(now,'HH:MM:SS'),mfilename,Ses.name,ExpNo);

fprintf(' loading(%s)...',SigName);
SIG = sigload(Ses,ExpNo,SigName);
par = expgetpar(Ses,ExpNo);

sampt   = SIG.dx*1000;   % in msec
ADFCHAN = 1:size(SIG.dat,2);
ADFWAV  = int16(round(SIG.dat));  % must be (time,chan)
SIG.dat = [];

fprintf('ch=%d',size(ADFWAV,2))

if EXPORT_DGZ,
  sysname = par.evt.system;
  if ~ischar(sysname),  sysname = 'unknown';  end
  OBSLENS = sampt*size(ADFWAV,2)/1000; % in sec
  OBSLENS = [0 OBSLENS(:)'];
  TSTAMPS = [];
  MARKERS = [];
  if isfield(SIG,'stm') && ~isempty(SIG.stm),
    for iObs = 1:length(SIG.stm.v),
      for N = 1:length(SIG.stm.v{iObs}),
        tmpts = SIG.stm.time{iObs}(N) + OBSLENS(iObs);
        stmid = SIG.stm.v{iObs}(N);
        TSTAMPS = cat(2,TSTAMPS,tmpts);
        MARKERS = cat(2,MARKERS,stmid);
      end
    end
  end
  if ~isempty(TSTAMPS),
    % for debugging
    %TSTAMPS(end+1) = TSTAMPS(end)+10;
    %MARKERS(end+1) = MARKERS(end)+1;
    MARKER.comment    = sprintf('dgz by %s',sysname);
    MARKER.sampt      = 0.001;   % 1 msec for dgz
    MARKER.count      = length(TSTAMPS);
    MARKER.timestamps = int32(TSTAMPS/MARKER.sampt);
    MARKER.markers    = zeros(4,MARKER.count,'uint8');
    MARKER.markers(1,:) = uint8(MARKERS);
  end
  MARKER = {MARKER};
else
  MARKER = {};
end


if sesversion(Ses) >= 2
  %[fp, fr] = fileparts(expfilename(Ses,ExpNo,));
  fr = sprintf('%s_%03d_%s',Ses.name,ExpNo,SigName);
else
  [fp,fr] = fileparts(catfilename(Ses,ExpNo));
end
fp = pwd;
SMRFILE  = fullfile(fp,sprintf('%s.smr',fr));

subWriteSMR(SMRFILE,BLOCK_SIZE,sampt,ADFCHAN,ADFWAV,MARKER);

fprintf(' done.\n');

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subWriteSMR(SMRFILE,BLOCK_SIZE,sampt,ADFCHAN,ADFWAV,MARKER)

%size(ADFCHAN)
%size(ADFWAV)
%sampt

% CREATE A NEW SMR FILE
sFh = SONCreateFile(SMRFILE,32,256);
if sFh < 0,
  error(' %s: failed to create a SMR file, ret=%s\n',mfilename,subGetError(sFh));
end

try
  % SET TIME BASE INFORMATION
  timeBase = 1.0e-6;
  usPerTime =  1;
  timePerAdc = (sampt/1000)/timeBase/usPerTime;
  %usPerTime  = (sampt/1000)/timeBase;
  %timePerAdc = 1;
  SONTimeBase(sFh,timeBase);
  SONSetFileClock(sFh,usPerTime,timePerAdc);


  SONChan = 0;
  % SET EVENT CHANNELS
  for N = 1:length(MARKER),
    if isempty(MARKER{N}),  continue;  end
    n = SONSetEventChan(sFh, SONChan, SONChan, BLOCK_SIZE,...
                        MARKER{N}.comment,...
                        sprintf('marker %d',SONChan),...
                        1.0/MARKER{N}.sampt,'marker');
    if n ~= 0,
      SONCloseFile(sFh);
      error(' %s: SONSetEventChan() failed, ret=%s\n',mfilename,subGetError(n));
    end
    SONChan = SONChan + 1;
  end
  %mVPerAdc = 10/65536/RECGAIN*1000;
  %scalev = mVPerAdc/(10/65536);  % see documentation of SON Library.
  VPerAdc = 10/65536;
  scalev  = VPerAdc/(10/65536);
  %  real = (short*scl*(10/65536))+offs
  % SET WAVEFORM CHANNELS
  for N = 1:length(ADFCHAN),
    n = SONSetWaveChan(sFh, SONChan, SONChan,...
                       (sampt/1000)/timeBase,BLOCK_SIZE,...
                       sprintf('adf chan%d',ADFCHAN(N)),...
                       sprintf('Adc chan%d',SONChan),...
                       scalev, 0, 'Volts');
    if n ~= 0,
      SONCloseFile(sFh);
      error(' %s: SONSetWaveChan() failed, ret=%s.\n',mfilename,subGetError(n));
    end
    SONChan = SONChan + 1;
  end

  % allocate the data transfer buffer
  n = SONSetBuffering(sFh,-1,1000000);
  if n ~= 0,
    SONCloseFile(sFh);
    error(' %s: SONSetBuffering() failed, ret=%s.\n',mfilename,subGetError(n));
  end
  n = SONSetBuffSpace(sFh);
  if n ~= 0,
    SONCloseFile(sFh);
    error(' %s: SONSetBuffSpace() failed, ret=%s.\n',mfilename,subGetError(n));
  end


  fprintf(' writing');
  % WRITE DATA
  SONChan = 0;
  for N = 1:length(MARKER),
    if isempty(MARKER{N}),  continue;  end
    %n = SONWriteExtMarkBlock(sFh, SONChan, MARKER{N}.timestamps,...
    %                         MARKER{N}.markers, zeros(1,MARKER{N}.count,'int16'),...
    %                         MARKER{N}.count);
    n = SONWriteMarkBlock(sFh, SONChan, MARKER{N}.timestamps,...
                             MARKER{N}.markers,...
                             MARKER{N}.count);
    if n ~= 0,
      SONCloseFile(sFh);
      error(' %s: SONWriteExtMarkBlock() failed, ret=%s.\n',mfilename,subGetError(n));
    end
    SONChan = SONChan + 1;
  end
  sTime = 0;
  %npts = min(BLOCK_SIZE-20/2,size(ADFWAV,1));
  %npts =  1250618;
  for N = 1:length(ADFCHAN),
    n = SONWriteADCBlock(sFh, SONChan, ADFWAV(:,N), size(ADFWAV,1), sTime);
    %n = SONWriteADCBlock(sFh, SONChan, ADFWAV(1:npts,N), npts, sTime)
    fprintf('.%d',n);
    if n < 0,
      SONCloseFile(sFh);
      error(' %s: SONWriteADCBlock() failed, ret=%s.\n',mfilename,subGetError(n));
    end
    SONChan = SONChan + 1;
  end

  %n = SONCommitFile(sFh,0);
  %if n ~= 0,
  %  SONCloseFile(sFh);
  %  error(' %s: SONCommitFile() failed, ret=%s.\n',mfilename,subGetError(n));
  %end
catch
  SONCloseFile(sFh);
  lasterr
  return
end

n = SONCloseFile(sFh);
if n ~= 0,
  SONCloseFile(sFh);
  error(' %s: SONCloseFile() failed, ret=%s\n',mfilename,subGetError(n));
end

return




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MARKER = subGetEvents(DGZFILE,sampt,obslens)
MARKER = [];
if ~exist(DGZFILE,'file'),  return;  end
dg = dg_read(DGZFILE);

OBSLENS = sampt*obslens/1000; % in sec
OBSLENS = [0 OBSLENS(:)'];
TSTAMPS = [];
MARKERS = [];

sysname = dg.e_pre{1}{2};  % name of the state system
if strcmpi(sysname,'MriGeneric'),
  for iObs = 1:length(dg.e_types),
    etypes    = dg.e_types{iObs};
    esubtypes = dg.e_subtypes{iObs};
    etimes    = dg.e_times{iObs};
    eparams   = dg.e_params{iObs};
    % stimulus on
    idx1 = find(etypes == 27 & esubtypes == 2);  % stimulus on
    idx2 = find(etypes == 29);
    if isempty(idx1),  continue;   end
    if length(idx1) ~= length(idx2),  continue;  end
    tmpts = etimes(idx1)/1000 + OBSLENS(iObs);
    stmid = zeros(size(idx2));
    for K = 1:length(idx2),
      stmid(K) = eparams{idx2(K)}(1);
    end
    TSTAMPS = cat(2,TSTAMPS,tmpts);
    MARKERS = cat(2,MARKERS,stmid);
  end
end

if ~isempty(TSTAMPS),
  % for debugging
  %TSTAMPS(end+1) = TSTAMPS(end)+10;
  %MARKERS(end+1) = MARKERS(end)+1;
  
  MARKER.comment    = sprintf('dgz by %s',sysname);
  MARKER.sampt      = 0.001;   % 1 msec for dgz
  MARKER.count      = length(TSTAMPS);
  MARKER.timestamps = int32(TSTAMPS/MARKER.sampt);
  MARKER.markers    = zeros(4,MARKER.count,'uint8');
  MARKER.markers(1,:) = uint8(MARKERS);
end


return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ERRSTR = subGetError(errno)

switch errno,
 case -1
  tmpstr = 'SON_NO_FILE';
 case -2
  tmpstr = 'SON_NO_DOS_FILE';
 case -3
  tmpstr = 'SON_NO_PATH';
 case -4
  tmpstr = 'SON_NO_HANDLES';
 case -5
  tmpstr = 'SON_BAD_HANDLE';
 case -6
  tmpstr = 'SON_MEMORY_ZAP';
 case -7
  tmpstr = 'SON_MEMORY_ZAP';
 case -8
  tmpstr = 'SON_OUT_OF_MEMORY';
 case -15
  tmpstr = 'SON_INVALID_DRIVE';  % -15      /* Not used by son.c - historical (Mac?) */
 case -16
  tmpstr = 'SON_OUT_OF_HANDLES'; % -16      /* This refers to SON file handles */
 case -600
  tmpstr = 'SON_FILE_ALREADY_OPEN'; % -600  /* Used on 68k Mac, not used by son.c */
 case -17
  tmpstr = 'SON_BAD_READ'; % -17
 case -18
  tmpstr = 'SON_BAD_WRITE'; % -18
 case -9
  tmpstr = 'SON_NO_CHANNEL';  % -9
 case -10
  tmpstr = 'SON_CHANNEL_USED';  % -10
 case -11
  tmpstr = 'SON_CHANNEL_UNUSED';  % -11
  case -12
   tmpstr = 'SON_PAST_EOF';  % -12
 case -13
  tmpstr = 'SON_WRONG_FILE';  % -13
  case -14
   tmpstr = 'SON_NO_EXTRA';  % -14
 case -19
  tmpstr = 'SON_CORRUPT_FILE';  % -19
 case -20
  tmpstr = 'SON_PAST_SOF';  % -20
 case -21
  tmpstr = 'SON_READ_ONLY';  % -21
 case -22
  tmpstr = 'SON_BAD_PARAM';  % -22
 otherwise
  tmpstr = 'unknown';
end

ERRSTR = sprintf('%s(%d)',tmpstr,errno);


return

