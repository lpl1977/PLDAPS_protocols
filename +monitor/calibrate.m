function p = calibrate(p,state)
%p = calibrate(p,state)
%
%  PLDAPS trial function for performing monitor calibration using X-Rite
%  i1Pro

%  Call default trial function for state dependent steps
pldapsDefaultTrialFunction(p,state);

%
%  Switch frame states
%
switch state
    
    case p.trial.pldaps.trialStates.trialSetup
        %  Trial Setup, for example starting up Datapixx ADC and allocating
        %  memory
        
        %  This is where we would perform any steps that needed to be done
        %  before a trial is started, for example preparing stimuli
        %  parameters
        
        %  Confirm spectrophotometer is connected; if not, quit
        
        if(~I1('IsConnected'))
            fprintf('X-Rite i1Pro spectrophotometer is disconnected, quitting.\n');
            p.trial.pldaps.quit=2;
        end
                
        fprintf('Trial %d of %d\n',p.trial.pldaps.iTrial,p.trial.pldaps.finish);
        fprintf('Display gray with intensity %0.3f\n',p.conditions{p.trial.pldaps.iTrial}.stimulus(1));
        p.trial.display.bgColor = p.conditions{p.trial.pldaps.iTrial}.stimulus;
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        
        %  Check if we have completed conditions; if so, we're finished.
        if(p.trial.pldaps.iTrial==length(p.conditions))
            p.trial.pldaps.quit=2;
        end
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update is called once after the last frame is done (or
        %  even before).  Get current eyepostion, curser position,
        %  keypresses, joystick position, etc.
        
        if(p.trial.trstart < GetSecs - p.trial.stimulus.delay)
            fprintf('Start measurement\n');
            I1('TriggerMeasurement');
            Lxy = I1('GetTriStimulus');
            fprintf('Luminance %0.3f\n',Lxy(1));
            p.trial.calib_data.spectrum = I1('GetSpectrum');
            p.trial.calib_data.Lxy = Lxy;
            p.trial.calib_data.stimulus = p.conditions{p.trial.pldaps.iTrial}.stimulus;
            p.trial.flagNextTrial = true;
        end
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control.
        
        %  Full field stimulus
        %Screen('FillRect', p.trial.display.ptr,p.conditions{p.trial.pldaps.iTrial}.stimulus);


end