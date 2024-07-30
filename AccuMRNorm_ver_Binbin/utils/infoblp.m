function infoblp(SESSION,Func,LOG)
%INFOBLP - List the variables in the 1st file of each group
% INFOBLP (SesName) the function is used to find out how far are
% we with the processing of data. It uses the who('-file') option
% to check the current variables in the first experiment of each
% group of a given session.
% NKL, 10.10.00
% NKL, 07.01.06
  
format compact;
close all;

if nargin < 4,
  LOG=0;
end;

if nargin < 3,
  Func = 'who';
end;

Ses = goto(SESSION);
grps = getgroups(Ses);
if LOG,
  InfoFile = strcat('WHO_',SESSION,'.log');
  if exist(InfoFile,'file'),
	delete(InfoFile);
  end;

  diary off;
  diary(InfoFile);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          band: {1x10 cell}
%         lBands: [1 2 3 4 5 6 7 8 9]
%         mBands: 10
%        lcutoff: 500
%        mcutoff: 100
%          NewFs: 250
%        NewFsTr: 20
%        flttype: 'cheby2'
%          lstop: 1
%          mstop: 50
%          hstop: 50
%             dB: 60
%     passripple: 0.1000
%          LowFs: 110
%        LowFsTr: 10
%         mirror: 1
%       conv2sdu: 0
%           date: '23-Dec-2005'
%           time: '23:36:26'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXPS = validexps(Ses);
for N=1:length(EXPS),
  ExpNo = EXPS(N);
  blp = sigload(Ses,ExpNo,'blp');
  if isempty(blp), continue; end;
  v = blp.info;
  fprintf('ExpNo: %2d, D: %12s, T: %8s, lBands: %2d, mBands: %2d, NewFs: %3d, FLT: %7s\n',...
          ExpNo, v.date, v.time, length(v.lBands), length(v.mBands), v.NewFs, v.flttype);
  
end;

if LOG,
  diary off;
  edit(InfoFile);
end;
