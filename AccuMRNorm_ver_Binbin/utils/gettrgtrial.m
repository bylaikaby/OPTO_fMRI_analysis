function oSig = gettrgtrial(Sig,pat)
%GETTRGTRIAL - extract trials from observation period
%	oSig = GETTRGTRIAL(Sig,pat), get portions of the signal corresponding to certain
%	stimulation pattenrs defined by getpat (see getpat.m).
%
%	NKL, 1.11.02

try,
   pret = round(pat.pret/Sig.dx)+1;
   post = round(pat.post/Sig.dx);
   patlen = length([pret(1):post(1)]);

   pad = NaN * ones(patlen,size(Sig.dat,2));
   Sig.dat = cat(1,Sig.dat,pad);

   oSig = Sig;
   oSig.dat = [];
   for N=1:length(pret),
	   oSig.dat = cat(2,oSig.dat,Sig.dat(pret(N):post(N),:));
   end;
   oSig.stm = pat.stm;
catch,
	disp(lasterr);
	keyboard;
end;



