function p = trial_function(p,state)
%  PLDAPS TRIAL FUNCTION
%  PACKAGE:  joystick.debug

%
%  PLDAPS trial function for joystick debuggin
%


%  Specific state dependent steps
switch state
    
    case p.trial.pldaps.trialStates.trialSetup
        %  Trial Setup, for example starting up Datapixx ADC and allocating
        %  memory
        
        %  This is where we would perform any steps that needed to be done
        %  before a trial is started, for example preparing stimuli
        %  parameters
        
        p.trial.condition = p.conditions{p.trial.pldaps.iTrial};
                
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        %  Check if we have completed conditions; if so, we're finished.
        if(p.trial.pldaps.iTrial==length(p.conditions))
            p.trial.pldaps.finish=p.trial.pldaps.iTrial;
        end
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update, including getting data from mouse or keyboard and
        %  also getting data from Eyelink and Datapixx ADC.  This is where
        %  we can check fixation, etc.
        
        %  Check joystick status
end
end

