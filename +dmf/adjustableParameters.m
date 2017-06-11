function p = adjustableParameters(p,varargin)
%  PLDAPS SETUP FILE
%  PACKAGE:  dmf
%
%  This setup file is for the delayed match to feature task.  It contains
%  parameters which might be adjusted between trials (and are subject
%  dependent also).

if(nargin==1)
    
    %  Non state dependent steps--executed when we call this from the
    %  experiment setup function
    
    %  Left response:
    %  041 241 441  **Shape match
    %  140 142 144  **Color match
    %  141          **Co-incident shape and color match
    
    %  Center response:
    %  040 240 440
    %  042 242 442
    %  044 244 444
    %  143 341      **Conflicting shape and color match
    
    %  Right response:
    %  043 243 443  **Shape match
    %  340 342 344  **Color match
    %  343          **Co-incident shape and color match
    
    switch lower(p.trial.session.subject)
        case 'murray'
            p.functionHandles.includedResponses = {'left','center','right'};      

            p.functionHandles.selectionCodes.left = {'441'};
            p.functionHandles.selectionCodes.center = {'440','442','444'};
            p.functionHandles.selectionCodes.right = {'443'};
            
%             p.functionHandles.selectionCodes.left = {...
%                 '140','142','144'};
%             p.functionHandles.selectionCodes.center = {...
%                 '040','240','440',...
%                 '042','242','442',...
%                 '044','244','444'};
%             p.functionHandles.selectionCodes.right = {...
%                 '340','342','344'};
            
%             p.functionHandles.includedResponses = {'left','center','right'};
%             p.functionHandles.selectionCodes.left = {...
%                 '041','241','441'};
%             p.functionHandles.selectionCodes.center = {...
%                 '040','240','440',...
%                 '042','242','442',...
%                 '044','244','444'};
%             p.functionHandles.selectionCodes.right = {...
%                 '043','243','443'};

        case 'meatball'
            p.functionHandles.includedResponses = {'left','center','right'};   

            p.functionHandles.selectionCodes.left = {'441'};
            p.functionHandles.selectionCodes.center = {'440','442','444'};
            p.functionHandles.selectionCodes.right = {'443'};
            
%             p.functionHandles.selectionCodes.left = {'144'};
%             p.functionHandles.selectionCodes.center = {'044','244','444'};
%             p.functionHandles.selectionCodes.right = {'344'};
            
%             p.functionHandles.selectionCodes.left = {...
%                 '140','142','144'};
%             p.functionHandles.selectionCodes.center = {...
%                 '040','240','440',...
%                 '042','242','442',...
%                 '044','244','444'};
%             p.functionHandles.selectionCodes.right = {...
%                 '340','342','344'};
        
        case 'splinter'
            p.functionHandles.includedResponses = {'left','center','right'};   

            p.functionHandles.selectionCodes.left = {'441'};
            p.functionHandles.selectionCodes.center = {'440','442','444'};
            p.functionHandles.selectionCodes.right = {'443'};
        
        case 'debug'
            p.functionHandles.includedResponses = {'left','center','right'};
            p.functionHandles.selectionCodes.left = {'140','142','144'};
            p.functionHandles.selectionCodes.center = {'040','240','440','042','242','442','044','244','444'};
            p.functionHandles.selectionCodes.right = {'340','342','344'};
    end
else
    
    %  State dependent steps
    state = varargin{1};
    
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Here you could adjust windows, etc.
            switch lower(p.trial.session.subject)
                case 'murray'
                case 'meatball'
                case 'splinter'
                case 'debug'
            end
            
        case p.trial.pldaps.trialStates.trialSetup
            
            %  Symbol alpha
            switch lower(p.trial.session.subject)
                case 'murray'
                    symbolAlphas = 1.0; % + 0.5*(p.functionHandles.trialManagerObj.repetitionNumber<4);
                case 'meatball'
                    symbolAlphas = 1;
                case 'splinter'
                    symbolAlphas = 0.5;
                case 'debug'
                    symbolAlphas = 1.0; %0.5 + 0.5*(p.functionHandles.trialManagerObj.repetitionNumber<1);
            end
            p.functionHandles.symbolAlphas.left = [ones(1,3); symbolAlphas*ones(2,3)];
            p.functionHandles.symbolAlphas.center = [symbolAlphas*ones(1,3); ones(1,3); symbolAlphas*ones(1,3)];
            p.functionHandles.symbolAlphas.right = [symbolAlphas*ones(2,3); ones(1,3)];
            
            %  Reward
            p.functionHandles.reward = 0.5;
            
            %  Timing
            p.functionHandles.timing.responseDuration = 10;
            p.functionHandles.timing.rewardDuration = 0.7;
            p.functionHandles.timing.errorDuration = p.functionHandles.timing.rewardDuration;
            p.functionHandles.timing.errorPenaltyDuration = 2;
            p.functionHandles.timing.penaltyDuration = 10;
            p.functionHandles.timing.holdDelay = 0;
            
            switch lower(p.trial.session.subject)
                case 'murray'
                    %  Careful!  Murray seems to boycott if the reward rate
                    %  is too low.
                    p.functionHandles.reward = 0.475;
                    p.functionHandles.timing.holdDelay = min(3,0.5 + exprnd(0.5));
                case 'meatball'
                    p.functionHandles.reward = 0.45;
                    p.functionHandles.timing.holdDelay = min(3,0.5 + exprnd(0.5));
                case 'splinter'
                    p.functionHandles.reward = 1.0;
                    p.functionHandles.timing.holdDelay = min(3,0.5 + exprnd(0.5));
                case 'debug'
                    p.functionHandles.timing.reward = 0;
                    p.functionHandles.timing.holdDelay = min(3,0.5 + exprnd(0.5));
            end
    end
end
end
