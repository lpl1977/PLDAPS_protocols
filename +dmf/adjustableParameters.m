function p = adjustableParameters(p,varargin)
%  PLDAPS SETUP FILE
%  PACKAGE:  dmf
%
%  This setup file is for the delayed match to feature task.  It contains
%  parameters which might be adjusted between trials (and are subject
%  dependent also).

if(nargin==1)
    
    %  Non state dependent steps--could be called in the experiment setup
    %  file
    switch lower(p.trial.session.subject)
        case 'murray'
            p.functionHandles.includedResponses = {'left','center','right'};                        
            p.functionHandles.displayConfig.left = ones(3);
            p.functionHandles.displayConfig.right = ones(3);
            p.functionHandles.displayConfig.center = ones(3);            
        case {'meatball','debug'}
            p.functionHandles.includedResponses = {'left','center','right'};                        
            p.functionHandles.displayConfig.left = [ones(1,3); zeros(2,3)];
            p.functionHandles.displayConfig.right = [zeros(2,3); ones(1,3)];
            p.functionHandles.displayConfig.center = [zeros(1,3); ones(1,3); zeros(1,3)];            
        case 'splinter'
            p.functionHandles.includedResponses = {'center'};                        
            p.functionHandles.displayConfig.left = [ones(1,3); zeros(2,3)];
            p.functionHandles.displayConfig.right = [zeros(2,3); ones(1,3)];
            p.functionHandles.displayConfig.center = [zeros(1,3); ones(1,3); zeros(1,3)];            
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
                    p.functionHandles.conditionalRewardRate = 1;
                case 'meatball'
                    p.functionHandles.timing.holdDelay = min(4,0.5 + exprnd(0.5));
                    p.functionHandles.conditionalRewardRate = 1;
                    %p.functionHandles.timing.holdDelay = 0; 
                    %p.functionHandles.timing.holdDelay = min(4,0.5 + exprnd(0.5));
                case 'splinter'
                    p.functionHandles.timing.holdDelay = min(4,0.25 + exprnd(0.5));
                    
                    p.functionHandles.conditionalRewardRate = 0.8;
            end
    end
end
end
