function curproj = getproj(ptype)
%GETPROJ - Select project type (OLD DATA -- Nature paper)
%	curproj = GETPROJ(ptype)
%	NKL 29.10.00

WX		= 5;
WY		= 30;
WXLEN	= 1270;
WYLEN	= 930;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LINEAR SYSTEMS ANALYSIS (VARIABLE PULSE WIDTH AND CONTRAST)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VPVC.PRONAME	= 'vpvc';
VPVC.CATFILE	= 'vpvc';
VPVC.LABELPLOT	= 13;
VPVC.SCALE		= [-4 12];
VPVC.COLUMNS	= 3;
VPVC.ROWS		= 5;
VPVC.CONDITION	= {	'p24c100'; 'p24c50'; 'p24c25'; ...
					'p12c100'; 'p12c50'; 'p12c25'; ...
					'p6c100'; 'p6c50'; 'p6c25'; ...
					'p4c100'; 'p4c50'; 'p4c25'; ...
					'p3c100'; 'p3c50'; 'p3c25'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLE WIDTH FIXED CONTRAST (100%)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VPFC.PRONAME	= 'vpfc';
VPFC.CATFILE	= 'vpvc';
VPFC.LABELPLOT	= 5;
VPFC.SCALE		= [-4 12];
VPFC.COLUMNS	= 1;
VPFC.ROWS		= 5;
VPFC.CONDITION	= {	'p24c100'; 'p12c100'; 'p6c100';	'p4c100'; 'p3c100'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTER-SUBJECT VARIABILITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BVAR.PRONAME	= 'boldvar';
BVAR.CATFILE	= 'vpvc';
BVAR.LABELPLOT	= 7;
BVAR.SCALE		= [-5 10];
BVAR.COLUMNS	= 2;
BVAR.ROWS		= 4;
BVAR.CONDITION	= {	'p24c100'; 'p24c50'; 'p12c100'; 'p12c50'; ...
					'p6c100'; 'p6c50'; 'p3c100'; 'p3c50'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTER-SUBJECT VARIABILITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LVAR.PRONAME	= 'lfpvar';
LVAR.CATFILE	= 'vpvc';
LVAR.LABELPLOT	= 7;
LVAR.SCALE		= [-5 10];
LVAR.COLUMNS	= 2;
LVAR.ROWS		= 4;
LVAR.CONDITION	= {	'p24c100'; 'p24c50'; 'p12c100'; 'p12c50'; ...
					'p6c100'; 'p6c50'; 'p3c100'; 'p3c50'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTER-SUBJECT VARIABILITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MVAR.PRONAME	= 'muavar';
MVAR.CATFILE	= 'vpvc';
MVAR.LABELPLOT	= 7;
MVAR.SCALE		= [-5 10];
MVAR.COLUMNS	= 2;
MVAR.ROWS		= 4;
MVAR.CONDITION	= {	'p24c100'; 'p24c50'; 'p12c100'; 'p12c50'; ...
					'p6c100'; 'p6c50'; 'p3c100'; 'p3c50'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTER-SUBJECT VARIABILITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SVAR.PRONAME	= 'suavar';
SVAR.CATFILE	= 'vpvc';
SVAR.LABELPLOT	= 7;
SVAR.SCALE		= [-5 10];
SVAR.COLUMNS	= 2;
SVAR.ROWS		= 4;
SVAR.CONDITION	= {	'p24c100'; 'p24c50'; 'p12c100'; 'p12c50'; ...
					'p6c100'; 'p6c50'; 'p3c100'; 'p3c50'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED PULSE AND VARIABLE CONTRAST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FPVC.PRONAME	= 'fpvc';
FPVC.CATFILE	= 'fpvc';
FPVC.LABELPLOT	= 5;
FPVC.SCALE		= [-4 12];
FPVC.COLUMNS	= 2;
FPVC.ROWS		= 3;
FPVC.CONDITION	= {	'p125c100'; 'p125c50'; 'p125c25'; ...
					'p125c125'; 'p125c12'; 'p125c6'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED PULSE, FIXED CONTRAST, AND VARIABLE SPEED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SPEED.PRONAME	= 'speed';
SPEED.CATFILE	= 'fpvc';
SPEED.LABELPLOT	= 4;
SPEED.SCALE		= [-4 4];
SPEED.COLUMNS	= 1;
SPEED.ROWS		= 4;
SPEED.CONDITION	= {	'p125s1'; 'p125s2'; 'p125s4'; 'p125s8'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EFFECTS OF ANESTHESIA DEPTH ON NEURAL AND BOLD SIGNALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ANES.PRONAME	= 'anes';
ANES.CATFILE	= 'anes';
ANES.LABELPLOT	= 5;
ANES.SCALE		= [-4 12];
ANES.COLUMNS	= 2;
ANES.ROWS		= 3;
ANES.CONDITION	= {	'iso04a'; 'iso08a'; 'iso10a'; ...
					'iso12a'; 'ketam1'; 'ketam2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SINGLE SUBJECT WITH MULTIPLE SESSIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B00.PRONAME		= 'b00';
B00.CATFILE		= 'b00';
B00.LABELPLOT	= 7;
B00.SCALE		= [-8 16];
B00.COLUMNS		= 3;
B00.ROWS		= 3;
B00.CONDITION	= {	'p24c100'; 'p24c50'; 'p24c25'; ...
					'p12c100'; 'p12c50'; 'p12c25'; ...
					'p4c100'; 'p4c50'; 'p4c25'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOUBLE CHANNEL RECORDING EXAMPLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D99a.PRONAME	= 'd99a';
D99a.CATFILE	= 'd99ch1';
D99a.LABELPLOT	= 7;
D99a.SCALE		= [-8 16];
D99a.COLUMNS	= 1;
D99a.ROWS		= 4;
D99a.CONDITION	= {	'fl30'; 'fl45'; 'fl60'; 'fl90' };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOUBLE CHANNEL RECORDING EXAMPLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D99b.PRONAME	= 'd99b';
D99b.CATFILE	= 'd99ch2';
D99b.LABELPLOT	= 7;
D99b.SCALE		= [-8 16];
D99b.COLUMNS	= 1;
D99b.ROWS		= 4;
D99b.CONDITION	= {	'fl30'; 'fl45'; 'fl60'; 'fl90' };

switch ptype,
  case 'vpvc',
	curproj = VPVC;
  case 'vpfc',
	curproj = VPFC;
	WXLEN	= 640;
  case 'fpvc',
	curproj = FPVC;
  case 'boldvar',
	curproj = BVAR;
	WXLEN	= 800;
  case 'lfpvar',
	curproj = LVAR;
	WXLEN	= 800;
  case 'muavar',
	curproj = MVAR;
	WXLEN	= 800;
  case 'suavar',
	curproj = SVAR;
	WXLEN	= 800;
  case 'speed',
	curproj = SPEED;
  case 'anes',
	curproj = ANES;
  case 'b00',
	curproj = B00;
  case 'd99a',
	curproj = D99a;
	WXLEN	= 640;
  case 'd99b',
	curproj = D99b;
	WXLEN	= 640;
end;

%%% GET DIRECTORIES (HOST-DEPENDENT)
HOSTNAME = evalc('!hostname');
HOSTNAME = deblank(char(HOSTNAME(1:6)));
switch HOSTNAME,
case 'wks12',			% Hendrik Desktop
   matdir	= 'f:/mri/DataMatlab/';			% wks12
case {'wks26'},			% Hendrik Matlab-computer (Linux)
   matdir	= '/data/mri/DataMatlab/';		% wks26
case {'nklwin'},		% Nikos Desktop
   matdir	= 'y:/DataMatlab/';
case {'win42'},			% Nikos Laptop
   matdir	= 'f:/DataMatlab/';
case {'win58'},			% Nikos Matlab-computer #1
   matdir	= 'y:/DataMatlab/';
case {'win59'},			% Nikos Matlab-computer #2
   matdir	= 'y:/DataMatlab/';
otherwise,
   error(sprintf('showcat: unknown HOSTNAME= ''%s''\n'));
end;

curproj.MATDIR	= matdir;
curproj.WX		= WX;
curproj.WY		= WY;
curproj.WXLEN	= WXLEN;
curproj.WYLEN	= WYLEN;
