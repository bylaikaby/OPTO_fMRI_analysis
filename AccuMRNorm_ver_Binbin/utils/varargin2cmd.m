function cmdline = varargin2cmd(prgname,cmdargs)
%VARARGIN2CMD - convert varargin to a text string for plot-title
% VARARGIN2CMD is used to note which command is producing which
% output. It is helpful for remembering how we produced various
% slides.
  
cmdline = strcat(prgname,'(');
for N=1:length(cmdargs),
  if ~isa(cmdargs{N},'char') & ~isa(cmdargs{N},'double') & length(cmdargs{N})>1,
	  carg{N} = cmdargs{N}{1};
  else
	  carg{N} = cmdargs{N};
  end;	
  if ~isa(carg{N},'char'),
	if isa(carg{N},'double'),
	  carg{N} = num2str(carg{N});
	elseif iscell(carg{N}),
	  carg{N} = carg{N}{1}.dir.dname;
	elseif isstruct(carg{N}),
	  carg{N} = carg{N}.dir.dname;
	else
	  carg{N} = carg{N}.dir.dname;
	end;
  else
	carg{N} = strcat('''',carg{N},'''');
  end;
  if N==length(cmdargs),
	cmdline = strcat(cmdline,carg{N});
  else
	cmdline = strcat(cmdline,carg{N},',');
  end;
end;
cmdline = strcat(cmdline,');');
