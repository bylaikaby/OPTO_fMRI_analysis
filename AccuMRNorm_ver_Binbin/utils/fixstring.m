function ffile = fixString(file)
%FIXSTRING - replaces "_" with "\_" for compatibility issues
%	ffile = FIXSTRING(file)
%	

ffile 	= strrep(file,'_','\_');
