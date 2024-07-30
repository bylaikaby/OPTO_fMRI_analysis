passrange=[20 80];
Fs=500;
dat=randn(10000,1);
tr=1;
stopdB=60;
passripple=0.01;

% highpass filter with very tight FIR filter at 1Hz (get rid of DC)
[b,a,pars] = designFIRflt(passrange,Fs,'bandpass',tr,stopdB,passripple);
odat       = doFIRfilter(b,a,dat,1);
% resample at twice the high freq. of specified range
NewFs=2*passrange(2);
NewFsTr=NewFs*0.02;
odat= myresample(odat,Fs,NewFs,NewFsTr);

