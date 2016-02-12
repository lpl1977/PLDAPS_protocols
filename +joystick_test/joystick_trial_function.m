function p = joystick_trial_function(p,state)
%joystick_trial_function(p,state)
%
%  PLDAPS trial function for joystick training

%  Call default trial function for state dependent steps
pldapsDefaultTrialFunction(p,state);

%
%  Joystick states
%
JOYSTICK_DISCONNECTED = 0;
JOYSTICK_REST = 1;
JOYSTICK_DEFLECTED = 2;

%
%  Altered so that it dispenses small rewards as long as the joystick is
%  pressed.
%
NO_RELEASE=1;

%  Specific state dependent steps
switch state
    
    case p.trial.pldaps.trialStates.trialSetup
        %  Trial Setup, for example starting up Datapixx ADC and allocating
        %  memory
        
        %  This is where we would perform any steps that needed to be done
        %  before a trial is started, for example preparing stimuli
        %  parameters
        
        %  Prepare joystick state
        p.trial.stimulus.joystick_ready = 1;        
        
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
        p.trial.stimulus.joystick_state = joystick.get_joystick_status;
        
        %  If joystick is ready and it is now engaged, then set to not
        %  ready.
        %
        %  If the joystick is not ready and it is still engaged, then the
        %  monkey is still pressing it and will be rewarded upon release.
        %
        %  If the joystick is not ready and it is not engaged, then the
        %  monkey has released it and he is eligible for reward when the
        %  trial ends.
        
        if(NO_RELEASE==1 && p.trial.stimulus.joystick_state==JOYSTICK_DEFLECTED)
                disp(['monkey gets a reward on trial ' num2str(p.trial.pldaps.iTrial)]);
                p.trial.pldaps.goodtrial = 1;
                p.trial.state = p.trial.stimulus.states.TRIALCOMPLETE;
                
                pds.behavior.reward.give(p,0.1);
                p.trial.flagNextTrial = true;
%         else
%             if(p.trial.stimulus.joystick_ready==1 && p.trial.stimulus.joystick_engaged==1)
%                 p.trial.stimulus.joystick_ready = 0;
%             elseif(p.trial.stimulus.joystick_ready==0 && p.trial.stimulus.joystick_engaged==0)
%                 disp(['monkey gets a reward on trial ' num2str(p.pldaps.iTrial)]);
%                 p.trial.pldaps.goodtrial = 1;
%                 p.trial.state = p.trial.stimulus.states.TRIALCOMPLETE;
%                 
%                 pds.behavior.reward.give(p,0.1);
%                 p.trial.flagNextTrial = true;
%             end
        end
end

