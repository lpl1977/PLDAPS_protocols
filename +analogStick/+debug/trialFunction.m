function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION
%  PACKAGE:  analogStick.debug

%
%  PLDAPS trial function for analog stick testing and debugging
%


%  Specific state dependent steps
switch state
    
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        %  experimentPostOpenScreen--executed once after screen has been
        %  opened.
        
%         %  Create eye position window manager
%         p.functionHandles.windowManagerObj.createGroup(...
%             'groupName','eye',...
%             'positionFunc',@() [p.trial.eyeX p.trial.eyeY],...
%             'windowPtr',p.trial.display.overlayptr,...
%             'displayAreaSize',[p.trial.display.pWidth p.trial.display.pHeight],...
%             'displayAreaCenter',p.trial.display.ctr([1 2]),...
%             'horizontalDisplayRange',[0 p.trial.display.pWidth],...
%             'verticalDisplayRange',[0 p.trial.display.pHeight],...
%             'trajectoryColor',p.trial.display.clut.hWhite,...
%             'maxTrajectorySamples',60,...
%             'showTrajectoryTrace',true,...
%             'showDisplayAreaOutline',false,...
%             'showDisplayAreaAxes',false,...
%             'useInvertedVerticalAxis',false,...
%             'currentColor',p.trial.display.clut.hCyan,...
%             'windowColor',p.trial.display.clut.hBlue);
%         
%         %  Add the fixation window
%         p.functionHandles.windowManagerObj.eye.add('fixation',[860 1060 440 640]);
        
        %
        % %  Initialize window manager for eye position
        % p.functionHandles.eyePositionWindowManagerObj = windowManager(...
        %     'windowPtr',p.trial.display.overlayptr,...
        %     'displayAreaSize',[p.trial.display.pWidth p.trial.display.pHeight],...
        %     'displayAreaCenter',p.trial.display.ctr([1 2]),...
        %     'horizontalDisplayRange',[0 p.trial.display.pWidth],...
        %     'verticalDisplayRange',[0 p.trial.display.pHeight],...
        %     'trajectoryColor',p.trial.display.clut.hYellow,...
        %     'maxTrajectorySamples',10/p.trial.display.ifi,...
        %     'showTrajectoryTrace',true,...
        %     'showDisplayAreaOutline',false,...
        %     'showDisplayAreaAxes',false,...
        %     'useInvertedVerticalAxis',false,...
        %     'currentColor',p.trial.display.clut.hCyan,...
        %     'activeWindowColor',p.trial.display.clut.hRed,...
        %     'enabledWindowColor',p.trial.display.clut.hBlue,...
        %     'disabledWindowColor',p.trial.display.clut.hBlack);
        %
        %         %  Here is the place to add any windows to the window manager
        %         p.functionHandles.windowManagerObj.add('neutral',[2 3],@() min(5,max(0,p.functionHandles.analogStickObj.position)));
        %         p.functionHandles.windowManagerObj.add('engaged',[0 0.5],@() min(5,max(0,p.functionHandles.analogStickObj.position)));
        %
        %         %  Apply eye windows too
        %         p.functionHandles.windowManagerObj.add('fixation',[790 1190 310 710],@() [p.trial.eyeX p.trial.eyeY]);
        %
        %         p.functionHandles.windowManagerObj.disp;
        
    case p.trial.pldaps.trialStates.trialSetup
        %  Trial Setup, for example starting up Datapixx ADC and allocating
        %  memory
        
        %  This is where we would perform any steps that needed to be done
        %  before a trial is started, for example preparing stimuli
        %  parameters
        
        p.trial.condition = p.conditions{p.trial.pldaps.iTrial};
        
        %     case p.trial.pldaps.trialStates.trialCleanUpandSave
        %         %  Clean Up and Save, post trial management
        %
        % %         %  Check if we have completed conditions; if so, we're finished.
        % %         if(p.trial.pldaps.iTrial==length(p.conditions))
        % %             p.trial.pldaps.finish=p.trial.pldaps.iTrial;
        % %         end
        %
    case p.trial.pldaps.trialStates.frameUpdate
        
        %disp([p.functionHandles.analogStickObj.position p.functionHandles.windowManagerObj.in('neutral') p.functionHandles.windowManagerObj.in('engaged')])
        %         %  Frame Update, including getting data from mouse or keyboard and
        %         %  also getting data from Eyelink and Datapixx ADC.  This is where
        %         %  we can check fixation, etc.
        %
        %         %  Check joystick status
        
        %p.functionHandles.windowManagerObj.eye.update;
        %p.functionHandles.windowManagerObj.eye.draw;
        
    case p.trial.pldaps.trialStates.frameDraw
        
%        disp([p.functionHandles.windowManagerObj.analogStick.in('neutral') p.functionHandles.windowManagerObj.analogStick.in('engaged')]);
        
end
end

