function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION FILE
%  PACKAGE:  eyeLinkCalibration
%
%  Each trial replicates the 9-point calibration performed with EyeLink
%  GUI.

%  Frame cycle:
%  1.  Present target; wait for monkey to acquire target
%  2.  Once fixation is established, wait duration ms
%  3.  Reward
%  4.  Blank screen

switch state

    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        %  experimentPostOpenScreen--executed once after screen has been
        %  opened.        
             
        %  Create eyeLinkManager object
        p.functionHandles.eyeLinkManagerObj = eyeLinkManager(...
            'eyeLinkControlStructure',p.trial.eyelink.setup,...
            'ifi',p.trial.display.ifi,...
            'windowPtr',p.trial.display.ptr,...
            'bgColor',p.trial.display.bgColor,...
            'dotWidth',60,'dotColor',[1 0 0],...
            'rewardFunction',p.functionHandles.rewardManagerObj.giveFunc,...
            'reward',p.functionHandles.reward,...
            'displayFunction','simpleDot',...
            'targetOn',true);
        
    case p.trial.pldaps.trialStates.trialSetup
        %  trialSetup--this is where we would perform any steps that needed
        %  to be done before a trial is started, for example preparing
        %  stimuli parameters and obtaining trial conditions
        
        %  Condition from cell array
        p.trial.condition = p.functionHandles.trailManagerObj.nextTrial;
        p.functionHandles.eyeLinkManagerObj.currentXpos = p.trial.condition.xPos(1);
        p.functionHandles.eyeLinkManagerObj.currentYpos = p.trial.condition.yPos(1);

        %  Initialize trial state variables
        p.functionHandles.stateVariables = stateControl('presentTarget');        
        p.functionHandles.targetIndex = 1;
        
        %  Reset the display for the analog stick
        p.functionHandles.eyeWindowManagerObj.flushTrajectoryRecord;
        
        %  Adjustable parameters
        eyeLinkCalibration.adjustableParameters(p,state);
                
        %  Echo trial information to screen
        fprintf('Trial %d\n',p.trial.pldaps.iTrial);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  cleanUpandSave--post trial management; perform any steps that
        %  should happen upon completion of a trial such as performance
        %  tracking and trial index updating.
            
        %  Check run termination criteria
        if(p.trial.pldaps.quit == 0)
            p.trial.pldaps.quit = p.functionHandles.trialManagerObj.checkRunTerminationCriteria;
        else
            %  Determine if we are continuing or instead quitting
            fprintf('Type dbcont to run another trial or dbquit to quit\n');
            p.trial.pldaps.quit = 1;
        end
        
        %%%%%%%%%%%%%%%%%%
        %  FRAME STATES  %
        %%%%%%%%%%%%%%%%%%
        
    case p.trial.pldaps.trialStates.frameDraw
        %  frameDraw--final image has been calculated and will now be
        %  drawn. This is where all calls to Screen should be done.  Also,
        %  if there is a call to a function calling Screen, put it here!
        
        %  Draw the target
        p.functionHandles.eyeLinkManagerObj.simpleDot;
        
        %  Adjust the window manager
        targetRect = CenterRectOnPointd(...
            p.functionHandles.geometry.targetWindow,...
            p.functionHandles.eyeLinkManagerObj.currentXpos,...
            p.functionHandles.eyeLinkManagerObj.currentYpos);
        
        %  Update the eye window display
        p.functionHandles.eyeWindowDisplayObj.updateDisplay();
        
    case p.trial.pldaps.trialStates.frameDrawingFinished
        %  frameDrawingFinished--here we could do any steps that need to be
        %  done immediately prior to the flip.              
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  frameUpdate--called once after the last frame is done (or
        %  even before).  Get current eyepostion, cursor position,
        %  keypresses, analog stick position, etc. in preparation for the
        %  subsequent frame cycle.
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  framePrepareDrawing--where you can prepare all drawing and
        %  task state control (just don't actually make the Screen calls
        %  here).
        
end

