function ans = yesorno(question)
%YESORNO - Ask user if something is valid or not
%	ans = YESORNO(question), is meant to help selecting/deselecting
%	corrupted scans, obsps etc.
%	NKL, 31.10.02

tmp = questdlg(question,'CHOOSER...','Yes');
switch tmp,
case 'Yes',
	ans = 1;
case 'No';
	ans = 0;
case 'Cancel',
	error('CHOOSER: aborted!');
end;


