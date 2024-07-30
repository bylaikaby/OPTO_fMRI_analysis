function [obslens, obsoffs] = dg_obsLengths(filename)
% PURPOSE : To get an array of all observation lengths.
% USAGE   : [obslens,obsoffs] = dg_obsLengths(filename)
% ARGOUT  : 'obslens','obsoffs' as in msec.
% SEEALSO : dg_read
% VERSION : 1.00 12.02.04 YM

if nargin ~= 1, help dg_obsLengths;  return;  end


dg = dg_read(filename);
for N = 1:length(dg.e_times),
  idx = find(dg.e_types{N} == 20);
  obslens(N) = dg.e_times{N}(idx);
end

obsoffs = dg.obs_times;
