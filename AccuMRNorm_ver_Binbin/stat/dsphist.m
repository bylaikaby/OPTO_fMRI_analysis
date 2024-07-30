function ohd = dsphist(Sig,varargin)
%DSPHIST - Display histogram as bar or stem plot
% DSPHIST (Sig,varargin) displays the contents of hstSig signal
% that is generated by SIGHIST.
%
% See also HIST MHIST SIGHIST EXPGETHIST
% NKL 30.05.04

if nargin < 1,
  help dsphist;
  return;
end;

persistent H_DSPHIST;	% keep the figure handle.

OVERLAY = 0;
PLOTTYPE = 'bar';
DOSUBPLOT = 1;
if nargin > 1,
  ix = strcmp(varargin,'plottype');
  if ix,
    ixtype = ix(1) + 1;
    PLOTTYPE = varargin{ixtype};
    varargin{ix(1)} = {};     % Otherwise we'll confuse set(gca...
    varargin{ixtype} = {};
  end;
  ix = strcmp(varargin,'dosubplot');
  if ix, DOSUBPLOT=1; varargin{ix(1)} = {}; end;    % DOSUPLOT
  ix = strcmp(varargin,'overlay');
  if ix, OVERLAY=1;  varargin{ix(1)} = {};end;     % OVERLAY
end;

if iscell(Sig),
  for N=1:length(Sig),
    Sig{N}.dat = mean(Sig{N}.dat,2);
    Sig{N}.x = mean(Sig{N}.x,2);
    name{N} = Sig{N}.dir.dname;
    if N==1,
      tmpSig = Sig{N};
    else
      tmpSig.dat = cat(2,tmpSig.dat,Sig{N}.dat);
    end;
  end;
  Sig = tmpSig; clear tmpSig;
  PLOTTYPE = 'stem';
end;

if strcmp(PLOTTYPE,'stem'),
  if DOSUBPLOT,
    if ~OVERLAY,
      figure('position',[100 300 800 600]);
      orient landscape;
      papersize = get(gcf, 'PaperSize');
      width = papersize(1)*0.8;
      height = papersize(2)*0.8;
      left = (papersize(1)- width)/2;
      bottom = (papersize(2)- height)/2;
      myfiguresize = [left, bottom, width, height];
      set(gcf, 'PaperPosition', myfiguresize);
    end;
    
    set(gcf,'DefaultAxesfontsize',	9);
    set(gcf,'DefaultAxesfontweight','normal');
    for N=1:size(Sig.dat,2),
      if ~OVERLAY,
        sb(N) = subplot(2,3,N);
        C='r';
      else
        axes(findobj('tag',sprintf('ax%d',N)));
        C='k';
      end;
      mstem(Sig.x, Sig.dat(:,N),C);
      title(name{N},'color','r','fontweight','bold','fontsize',11);
      grid on;
      xlabel('SD Units'); ylabel('Frequency');
      
      XLIM = [Sig.x(1) Sig.x(end)];
      set(gca,'xlim',XLIM);
      set(gca,'xtick',[XLIM(1):XLIM(2)]);
      if ~OVERLAY,
        set(sb(N),'Tag',sprintf('ax%d',N));
      end;
    end;
    suptitle(sprintf('dsphist: Session: %s, ExpNo: %d, Epoch: %s',...
                     Sig.session,Sig.ExpNo, Sig.Epoch));
  else
    hd = stem(Sig.x, Sig.dat);
    mlegend(name,'linespec','color',[.8 .85 .9],'linewidth',2,...
            'fontweight','bold','fontsize',11);
  end;
else
  hd = bar(Sig.x,Sig.dat);
end;

XLIM = [Sig.x(1) Sig.x(end)];
set(gca,'xlim',XLIM);
set(gca,'xtick',[XLIM(1):XLIM(2)]);
if nargin > 2,
  set(hd,varargin{:});
else
  if ~strcmp(PLOTTYPE,'stem')
    set(hd,'facecolor','k','edgecolor','k');
  end;
end;
grid on;

if nargout,
  ohd = hd;
end;



