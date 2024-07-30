
% ---------------------------------------------------------------------------



% ---------------------------------------------------------------------------


function [res] = read_cheader( filename, varargin )

% ---------------------------------------------------------------------------

if nargin<1 error( [ mfilename ':At least one argument is required.'] ); end;

% ---------------------------------------------------------------------------

nin=nargin-1;

while nin>0
  vv = varargin{nin}; 
  if ~isempty(vv) & isstr(vv)
    if strcmp(lower(vv), 'binsize') binsize = varargin{nin+1}; end;
  end;
  nin = nin-1;
end;


% ---------------------------------------------------------------------------

if ischar( filename )
  fp = fopen( filename, 'r' );
else
  fp = filename;
end;

if fp<0 error(['Could not open ' filename ]); end;

% ---------------------------------------------------------------------------

if ischar( filename ) res.fp = fp; end;

res.header = fread( fp, 16384, 'char');

% ---------------------------------------------------------------------------





