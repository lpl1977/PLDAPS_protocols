function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION
%  PACKAGE:  joystick.calibration

%
%  PLDAPS trial function for joystick calibration
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
        fprintf('%s\n',p.trial.condition.text);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        if(p.trial.pldaps.iTrial==length(p.conditions))
            p.trial.pldaps.finish=p.trial.pldaps.iTrial;
        end
      
    case p.trial.pldaps.trialStates.frameDraw
        
        Screen('DrawText',p.trial.display.ptr,sprintf('%s',p.trial.condition.text),100,100,[0 0 0]);

    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update, including getting data from mouse or keyboard and
        %  also getting data from Eyelink and Datapixx ADC.  This is where
        %  we can check fixation, etc.           
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        if(p.trial.iFrame > p.trial.pldaps.maxFrames)
            fprintf('Done with position.  Moving on.\n');
            p.trial.flagNextTrial = true;
        end
        
    case p.trial.pldaps.trialStates.experimentCleanUp                    
end
end

