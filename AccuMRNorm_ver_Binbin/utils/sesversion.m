function v = sesversion(Ses)
%SESVERSION - Return version of the session.
%  V = SESVERSION(SES) returns version of the session.
%
%  V = 1 : old data-style
%          multiple vars. in a mat file.
%  V = 2 : new data-style since Feb.2012
%          1 var. in a mat file.
%
%  VERSION :
%    0.90 31.01.12 YM  pre-release
%
%  See also getses sesconvert

if nargin < 1,  help sesversion; return;  end


Ses = getses(Ses);

if isa(Ses,'mcsession'),
  v = Ses.version();
  return;
end


v = 1;
if isfield(Ses.sysp,'VERSION') && ~isempty(Ses.sysp.VERSION),
  v = Ses.sysp.VERSION;
end


return
