function p = adjustableParameters(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  dmf

%  This setup file is for the delayed match to feature task.  It contains
%  parameters which might be adjusted between trials (and presumably are
%  subject dependent also).


%  Reward
p.functionHandles.reward = 0.5;

%  Timing
p.functionHandles.timing.responseDuration = 10;
p.functionHandles.timing.rewardDuration = 0.7;
p.functionHandles.timing.errorDuration = p.functionHandles.timing.rewardDuration;
p.functionHandles.timing.errorPenaltyDuration = 2;
p.functionHandles.timing.penaltyDuration = 5;
p.functionHandles.timing.holdDelay = 0;
%p.functionHandles.timing.holdDelay = min(4,0.5 + exprnd(0.5));
%p.functionHandles.timing.holdDelay = min(4,0.25 + exprnd(0.25));

