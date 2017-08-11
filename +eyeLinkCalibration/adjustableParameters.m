function p = adjustableParameters(p,varargin)
%  PLDAPS ADJUSTABLE PARAMETERS FILE
%  PACKAGE:  eyeLinkCalibration

if(nargin==1)        
    switch lower(p.trial.session.subject)
        case 'debug'
    end
else
    
    %  State dependent steps
    state = varargin{1};
    
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Here you could adjust windows, etc.
            
            switch lower(p.trial.session.subject)
                case 'debug'
            end
            
        case p.trial.pldaps.trialStates.trialSetup
            
            %  Timing
            p.functionHandles.stateTiming.minimumFixationDuration = 0.5;
            
            %  Geometry
            p.functionHandles.geometry.targetWindow = [0 0 10 10];
                        
            switch lower(p.trial.session.subject)
                case 'debug'
                    p.functionHandles.timing.reward = 0;
            end
    end
end
end
