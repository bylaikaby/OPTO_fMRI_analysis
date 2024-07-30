function trana(SESSION,ExpNo)
%TRANA - analyzed each trial
% TRANA uses sorttrial to obtain the time and frequency profiles of
% each trial as well as their simple statistics, such as mean and
% std to be used for selectivity analysis.
%
% NKL 12.05.03

Ses = goto(SESSION);
name = catfilename(Ses,ExpNo,'mat');
grp = getgrp(Ses,ExpNo);
GrpName = grp.name;

load(name,'Lfp','Mua');
fprintf('trana: Processing Group: %s, ExpNo: %d\n',GrpName,ExpNo);
StatLfp = sorttrials(Lfp);
StatMua = sorttrials(Mua);

fprintf('trana: Results save in %s\n', name);
save(name,'-append','StatLfp','StatMua');
fprintf('Done!\n');

