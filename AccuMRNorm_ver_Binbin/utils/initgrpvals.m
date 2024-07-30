function ostruct = initgrpvals(varname)
%INITGRPVALS - Initializes all signals that can be used for grouping MAT files
%	ostruct = INITGRPVALS(varname) tmp | DO) is used by grpmk and
%	alike functions for grouping variables. The use can define which ones
%	to group, and this function here sets the initial values, together
%	with some parameters, such as band widths for bandpass filtering etc.
%	NKL, 10.10.02
%
%	See also GRPMK, SESGRPMAKE, SESGRPALL

tmp.Cln			= 0;
tmp.ClnSpc		= 0;
tmp.Spkt		= 0;
tmp.Sdf			= 0;

tmp.LfpPow		= 0;
tmp.Lfp1Pow		= 0;
tmp.MuaPow		= 0;
tmp.Mua1Pow		= 0;
tmp.TotPow		= 0;

tmp.Bands		= 0;
tmp.Vital		= 0;
tmp.EyeMov		= 0;
tmp.tcImg		= 0;
tmp.Xcor		= 0;
tmp.XcorTc		= 0;

tmp.APPEND		= 0;

DO = tmp;

if nargout,
   if strcmp('tmp',varname) | strcmp('DO',varname),
		eval(sprintf('ostruct = %s;', varname));
   else
		disp('Input can be tmp | DO');
		keyboard;	
   end;
else
   if strcmp(varname,'tmp'),
	   assignin('caller','tmp',tmp);
   elseif strcmp(varname,'DO'),
	   assignin('caller','DO',DO);
   else
	   disp('Input can be tmp | DO');
	   keyboard;
   end;
end;

