function Sig = getbriefstmt(Sig)
%GETBRIEFSTMT - Get timing for stimuli of shorter duration than TR
% Sig = GETBRIEFSTMT (Sig) is used to obtain the timing of stimuli
% that are of such brief duration (<<TR), so that no events can be
% saved due to the quantization of time at the QNX side (multiples
% of the TR value).
% NKL, 08.04.04
  
FrDuration = 33.3;      % 30Hz
for R = 1:length(Sig),
  v0 = find(~Sig{R}.stm.v{1});
  for N=1:length(Sig{R}.evt.params{1}.prm),
    Sig{R}.stm.t{1}(v0(N)+2) = Sig{R}.stm.t{1}(v0(N)+1) + ...
        Sig{R}.evt.params{1}.prm{N}(1) * FrDuration/1000;
  end;
  Sig{R}.stm.t{1} = Sig{R}.stm.t{1} + FrDuration/1000;
end;

