%
% Read Cheetah Event Strings
%

% Thanos 11/20/99

function [rec] = read_events( filename, varargin )

% ---------------------------------------------------------------------------
if nargin<1 error( [ mfilename ':At least one argument is required.'] ); end;
% ---------------------------------------------------------------------------
n = []; verbose = []; header = 1; scombine = 1;
% ---------------------------------------------------------------------------

nin=nargin-1;

while nin>0
  vv = varargin{nin}; 
  if ~isempty(vv) & isstr(vv)

    if strcmp(lower(vv), 'n') n = varargin{nin+1}; end;
    if strcmp(lower(vv), 'verbose') verbose = 1; end;
    if strcmp(lower(vv), 'header') header = 1; end;
    if strcmp(lower(vv), 'noheader') header = []; end;

    if strcmp(lower(vv), 'combine') scombine = 1; end;
    if strcmp(lower(vv), 'separate') scombine = []; end;
    
    if strcmp(lower(vv), 'tstart') 
      tstart = varargin{nin+1};
      if isstr(tstart) tstart = time2ms( tstart ); end;
    end;
    if strcmp(lower(vv), 'tend') 
      tend = varargin{nin+1};
      if isstr(tend) tend = time2ms( tend ); end;
    end;
  end;
  nin = nin-1;
end;

% ---------------------------------------------------------------------------


fp = fopen( filename, 'rb' );
if fp<0 error( [ mfilename ' : Could not open file ' filename ] ); end;

% ---------------------------------------------------------------------------

if ~isempty(header)
  read_cheader( fp );
end;

% ---------------------------------------------------------------------------

i = 0;

while ~feof( fp )
  i=i+1;
  if ~isempty(n) 
    if i>n break; end; 
  end;
  rr = read_record( fp );
  if ~isempty( rr.timestamp )
    if isempty(scombine)
      rec.rec{i} = rr;
    else
      rec.t(i) = rr.timestamp;
      rec.es{i} = rr.event_string;
    end;
    if verbose fprintf(1, '%d %s  -> %s \n', i, ms2time(rec.rec{i}.timestamp), rec.rec{i}.event_string ); end;
  else
    break;
  end;
end;

fclose( fp );


% ---------------------------------------------------------------------------

function [rec] = read_record( fp )

rec = [];

%short nstx; // always 800 from DCDCB; Null if generated internally 
rec.nstx = fread( fp, 1, 'short' ); 
if rec.nstx<0 error([ mfilename ' : error reading nstx' ] ); end;

% short npkt_id; DCDCB ID 1002, etc. Null when generated internally 
rec.npkt_id = fread( fp, 1, 'short' ); 
if rec.npkt_id<0 error([ mfilename ' : error reading npkt_id' ] ); end;

% short npkt_data_size; always 2 ; Null when generated internally 
rec.npkt_data_size = fread( fp, 1, 'short' ); 
if rec.npkt_data_size<0 error([ mfilename ' : error reading npkt_data_size' ] ); end;

% DWORD64 qwTimeStamp; always a 64 bit 1 microsecond resolution timestamp value 
rec.timestamp = fread( fp, 1, 'uint64' ); 
if rec.timestamp<0 error([ mfilename ' : error reading timestamp' ] ); end;
rec.timestamp = rec.timestamp/1000;

% short nevent_id; just an id value 
rec.nevent_id = fread( fp, 1, 'short' ); 
if rec.nevent_id<0 error([ mfilename ' : error reading event id' ] ); end;

% short nttl; TTL input value when the record is read from the Interface Box Port 
rec.nttl = fread( fp, 1, 'ushort' );
%if rec.nttl<0 error([ mfilename ' : error reading nttl' ] ); end;

% short ncrc; // from the DCDCB ; Null when generated internally 
rec.ncrc = fread( fp, 1, 'ushort' ); 
% if rec.ncrc<0 error([ mfilename ' : error reading ncrc' ] ); end;

% short ndummy1; // just a place holder 
rec.ndummy1 = fread( fp, 1, 'short' ); 
if rec.ndummy1<0 error([ mfilename ' : error reading ndummy1' ] );  end;
  
% short ndummy2; // just a place holder 
rec.ndummy2 = fread( fp, 1, 'short' ); 
if rec.ndummy2<0 error([ mfilename ' : error reading ndummy2' ] ); end;


% UINT dnExtra[8]; // extra "bit values" Null when generated from DCDCB Port 
rec.dnextra = fread( fp, 8, 'uint' ); 
if rec.dnextra<0 error([ mfilename ' : error reading dnextra' ] ); end;

% char EventString[128]; // char string for user input events ; Null if generated from DCDCB Port; User message if internally generated 
rec.event_string = fread( fp, 128, 'char' ); 
if rec.event_string error([ mfilename ' : error reading event_string' ] ); end;
rec.event_string = char( rec.event_string );
if ~isempty(rec.event_string) rec.event_string = deblank( reshape( rec.event_string, 1, 128 ) ); end;

