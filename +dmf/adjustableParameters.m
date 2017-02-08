function p = adjustableParameters(p,varargin)
%  PLDAPS SETUP FILE
%  PACKAGE:  dmf
%
%  This setup file is for the delayed match to feature task.  It contains
%  parameters which might be adjusted between trials (and are subject
%  dependent also).

if(nargin==1)
    
    %  Non state dependent steps
    switch lower(p.trial.session.subject)
        case 'murray'
            p.functionHandles.includedResponses = {'left','center','right'};
        case 'meatball'
            p.functionHandles.includedResponses = {'center'};
        case 'splinter'
            p.functionHandles.includedResponses = {'center'};
        case 'debug'
            p.functionHandles.includedResponses = {'center'};
    end
else
    
    %  State dependent steps
    state = varargin{1};
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Adjust windows            
            switch lower(p.trial.session.subject)
                case 'murray'
                case 'meatball'
                    %                     p.functionHandles.analogStickWindowManager.addWindow('engaged',[-1 -1 1 -0.5]);
                    %                     p.functionHandles.analogStickWindowManager.addWindow('center',[-1 -1 1 -0.5]);
                    %                     p.functionHandles.analogStickWindowManager.disableWindow('left');
                    %                     p.functionHandles.analogStickWindowManager.disableWindow('right');
                case 'splinter'
                    %                    p.functionHandles.analogStickWindowManager.addWindow('engaged',[-1 -1 1 -0.5]);
                    p.functionHandles.analogStickWindowManager.addWindow('center',[-1 -1 1 -0.5]);
                    p.functionHandles.analogStickWindowManager.disableWindow('left');
                    p.functionHandles.analogStickWindowManager.disableWindow('right');
                case 'debug'
%                     p.functionHandles.analogStickWindowManager.addWindow('engaged',[-1 -1 1 -0.5]);
%                     p.functionHandles.analogStickWindowManager.addWindow('center',[-1 -1 1 -0.5]);
%                     p.functionHandles.analogStickWindowManager.disableWindow('left');
%                     p.functionHandles.analogStickWindowManager.disableWindow('right');
            end
        case p.trial.pldaps.trialStates.trialSetup
            
            %  Reward
            p.functionHandles.reward = 0.5;
            
            %  Timing
            p.functionHandles.timing.responseDuration = 10;
            p.functionHandles.timing.rewardDuration = 0.7;
            p.functionHandles.timing.errorDuration = p.functionHandles.timing.rewardDuration;
            p.functionHandles.timing.errorPenaltyDuration = 2;
            p.functionHandles.timing.penaltyDuration = 5;
            p.functionHandles.timing.holdDelay = 0;
            switch lower(p.trial.session.subject)
                case {'murray','debug'}
                    p.functionHandles.timing.holdDelay = min(4,0.5 + exprnd(0.5));
                case 'meatball'
                    p.functionHandles.timing.holdDelay = min(4,0 + exprnd(0.25));
                    %p.functionHandles.timing.holdDelay = 0; 
                    %p.functionHandles.timing.holdDelay = min(4,0.5 + exprnd(0.5));
                case 'splinter'
                    p.functionHandles.timing.holdDelay = min(4,0 + exprnd(0.5));
            end
    end
end
end
