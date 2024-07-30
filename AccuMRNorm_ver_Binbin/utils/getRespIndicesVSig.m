function [RespIndices,vid] = getRespIndicesVSig(tcImg,SigName,HemoDelay,Twin)
%GETRESPINDICESVSIG - get a struct of response indices from'VMua' etc.
% [RESPINDICES,VID] = GETRESPINDICESVSIG
% (tcImg,SigName,HemoDelay,Twin) To get a structure of response
% indices from 'VMua','VLfp' etc.
% USAGE   : [RespIndices,vid] = getRespIndicesVSig(tcImg,SigName,[HemoDelay=2]);
%         : 'RespIndices' is a cell array of response time for each electrodes.
% EXAMPLE : RespIndices = getRespIndicesVSig(tcImg,'VMua3');
% NOTES   : VSig (VMua,VLfp) should have been computed.
% VERSION : 0.90 01.11.03 YM
%

if nargin < 2, help getRespIndicesVSig;  return;  end
if nargin < 3, HemoDelay = 2;                     end
if nargin < 4, Twin = 0;                          end

DIM = 4;  % tcImg.dat = (x,y,sli,t)
matfile = catfilename(tcImg.session,tcImg.ExpNo,'mat');

% load VSig (VMuaX, VSdfX or VLfpHX).
vsig = load(matfile,SigName);
eval(sprintf('vsig = vsig.%s;',SigName));
vid  = vsig.vid;
% ASSUMING BLANK-MOVIE-BLANK
stimont  = vsig.stm.t{1}(2);
stimofft = vsig.stm.t{1}(3);
% Time Window
Twin     = round(Twin/tcImg.dx);

for ChanNo = 1:length(vid.rIndex),
  % select response times.
  tmpidx = vid.respTime{ChanNo};
  tmpidx = tmpidx(find(tmpidx >= stimont & tmpidx <= stimofft));
  tmpidx = tmpidx + HemoDelay;
  % convert to index for tcImg.dat.
  tmpidx = round(tmpidx / tcImg.dx) + 1;
  % apply time window
  if Twin > 0,
    tmporg = tmpidx;
    tmpidx = [];
    for K = -Twin:Twin,
      tmpidx = [tmpidx, tmporg+K];
    end
    tmpidx = sort(tmpidx(:));
  end
  % check size limitation.
  tmpidx = tmpidx(find(tmpidx <= size(tcImg.dat,DIM)));
  RespIndices{ChanNo} = unique(tmpidx);
end