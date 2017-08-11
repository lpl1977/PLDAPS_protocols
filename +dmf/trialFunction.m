function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION FILE
%  PACKAGE:  dmf

%  **  ISSUES TO CONSIDER / THOUGHTS FOR REVISIONS

%  Why does it sometimes go over 540?
%  How do I do blocks?
%  How can I more flexibly set the number of trials?

switch state
    
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        %  experimentPostOpenScreen--executed once after screen has been
        %  opened.
        
        %  ** Need to move this out of this case
        %  eyeLinkManager
        p.functionHandles.eyeLinkManagerObj = eyeLinkManager(...
            'eyeLinkControlStructure',p.trial.eyelink.setup,...
            'ifi',p.trial.display.ifi,...
            'windowPtr',p.trial.display.ptr,...
            'bgColor',p.trial.display.bgColor,...
            'dotWidth',60,'dotColor',[1 0 0],'dotPulseWidth',0.25,'dotPeriod',0.5,...
            'rewardFunction',p.functionHandles.rewardManagerObj.giveFunc,...
            'reward',0.5,...
            'displayFunction','flickeringDot');
        
        %  By now the analog stick object should have been created, so
        %  let's adjust the pixel height and width of its mapping so that
        %  maximum horizontal excursion corresponds to the maximum
        %  horizontal extent of the screen.  Because I do not want to have
        %  the cursor move on the vertical axis, its height is zero.
        p.functionHandles.analogStickObj.pWidth = p.trial.display.pWidth; %2*(p.functionHandles.geometry.symbolDisplacement+p.functionHandles.geometry.symbolRadius);
        p.functionHandles.analogStickObj.pHeight = 0;
        
        %  Make last final custom adjustments based on subject.
        dmf.adjustableParameters(p,state);
        
        %  Now generate the symbol textures
        p.functionHandles.graphicsManagerObj.prepareSymbolTextures;
        fprintf(1,'****************************************************************\n');
        fprintf(1,'Created %d symbol textures\n',length(p.functionHandles.graphicsManagerObj.symbolTextures));
        fprintf(1,'****************************************************************\n');
        
    case p.trial.pldaps.trialStates.trialSetup
        %  trialSetup--this is where we would perform any steps that needed
        %  to be done before a trial is started, for example preparing
        %  stimuli parameters
        
        %  Condition from cell array
        p.trial.condition = p.functionHandles.trialManagerObj.nextTrial;
        
        %  Set any adjustable parameters
        dmf.adjustableParameters(p,state);
        
        %  Initialize trial state variables
        p.functionHandles.stateVariables = stateControl('start');
        
        %  Initialize trial outcome object
        p.functionHandles.trialOutcomeObj = dmf.outcome(...
            'trialNumber',p.functionHandles.trialManagerObj.trialNumber,...
            'rewardedResponse',p.trial.condition.rewardedResponse,...
            'correctionLoopTrial',p.functionHandles.trialManagerObj.inCorrectionLoop,...
            'selectionCode',p.trial.condition.selectionCode,...
            'rewardDuration',p.functionHandles.reward);
        
        %  Initialize flags for graphical display
        p.functionHandles.analogStickCursorObj.visible = false;
        p.functionHandles.graphicsManagerObj.fixationDotVisible = true;
        
        %  Create textures for display
        p.functionHandles.graphicsManagerObj.prepareStateTextures(p.trial.condition.selectedSet,p.trial.condition.rewardedResponse);
        
        %  Echo trial specs to screen
        fprintf('TRIAL ATTEMPT %d\n',p.trial.pldaps.iTrial);
        if(~p.functionHandles.trialManagerObj.inCorrectionLoop)
            fprintf('Completed %d of %d trials\n',p.functionHandles.trialManagerObj.trialNumber-1,p.functionHandles.trialManagerObj.maxTrials);
        else
            fprintf('Correction loop trial %d for %stokenized trials\n',p.functionHandles.trialManagerObj.correctionLoopTrialNumber,sprintf('%s ',p.functionHandles.trialManagerObj.correctionLoopTokens{:}));
        end
        fprintf('%25s:\n','Symbols');
        for i=1:3
            fprintf('%25s:  ',p.functionHandles.possibleResponses{i});
            fprintf('%s ',p.functionHandles.setObj.symbolFeatures.colors{p.trial.condition.setSymbolCode(i,1)});
            fprintf('%s ',p.functionHandles.setObj.symbolFeatures.patterns{p.trial.condition.setSymbolCode(i,2)});
            fprintf('%s',p.functionHandles.setObj.symbolFeatures.shapes{p.trial.condition.setSymbolCode(i,3)});
            fprintf('\n');
        end
        fprintf('%25s:  %s\n','Rewarded response',p.trial.condition.rewardedResponse);
        fprintf('%25s:  %s\n','Satisifed selection code',p.trial.condition.selectionCode);
        fprintf('\n');
                
        %  Put in windows for normalized analog stick position.
        symbolWidth = 2*p.functionHandles.geometry.symbolRadius / p.functionHandles.analogStickObj.pWidth;
        p.functionHandles.analogStickWindowManagerObj.addWindow(...
            'neutral',symbolWidth*[-1 -1 1 1],true);
        p.functionHandles.analogStickWindowManagerObj.addWindow(...
            'engage',[-1+2*symbolWidth -1 1-2*symbolWidth -0.95],false);
        p.functionHandles.analogStickWindowManagerObj.addWindow(...
            'left',[-1 -1 -symbolWidth -0.95],false);
        p.functionHandles.analogStickWindowManagerObj.addWindow(...
            'right',[symbolWidth -1 1 -0.95],false);
        p.functionHandles.analogStickWindowManagerObj.addWindow(...
            'center',[-symbolWidth -1 symbolWidth -0.95],false);
        
        %  Put in windows for eye position in pixel coordinates.
        symbolWindow = [0 0 2*(p.functionHandles.geometry.symbolDisplacement+p.functionHandles.geometry.symbolRadius)+20 2*p.functionHandles.geometry.symbolRadius+20];
        p.functionHandles.eyePositionWindowManagerObj.addWindow(...
            'symbols',CenterRectOnPointd(symbolWindow,p.trial.display.ctr(1),p.trial.display.ctr(2)),false);
        fixationWindow = [0 0 p.functionHandles.geometry.symbolRadius p.functionHandles.geometry.symbolRadius];
        p.functionHandles.eyePositionWindowManagerObj.addWindow(...
            'fixation',CenterRectOnPointd(fixationWindow,p.trial.display.ctr(1),p.trial.display.ctr(2)),true);
        
        %  Prepare for analog stick windowing
        p.functionHandles.analogStickWindowManagerObj.flushTrajectoryRecord;
        
        %  Prepare for eye windowing
        p.functionHandles.eyePositionWindowManagerObj.flushTrajectoryRecord;
        
        %  Re-center the analog stick (we change it below during the trial)
        p.functionHandles.analogStickObj.pCenter = p.trial.display.ctr([1 2]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  cleanUpandSave--post trial management; perform any steps that
        %  should happen upon completion of a trial such as performance
        %  tracking and trial index updating.
        
        %  Capture data for this trial
        p.trial.trialRecord.stateTransitionLog = p.functionHandles.stateVariables.transitionLog;
        if(p.trial.pldaps.quit~=0)
            if(p.trial.pldaps.quit~=2)
                p.functionHandles.trialOutcomeObj.recordInterrupt(...
                    'interruptMessage','trialPaused');
            else
                p.functionHandles.trialOutcomeObj.recordInterrupt(...
                    'interruptMessage','pldapsQuit');
            end
        end
        p.trial.trialRecord.outcome = p.functionHandles.trialOutcomeObj.commit;
        fprintf('\n');
        
        %  Track performance
        p.functionHandles.performanceTrackingObj.update(p.functionHandles.trialOutcomeObj);
        
        %  Update trial manager if trial completed; if trial aborted or
        %  interrupted, repeat it.
        if(p.functionHandles.trialOutcomeObj.trialCompleted)
            if(~p.functionHandles.trialManagerObj.inCorrectionLoop)
                
                %  Write performance to screen
                p.functionHandles.performanceTrackingObj.output;
                fprintf('\n');
                
                %  Check correction loop entry
                p.functionHandles.trialManagerObj.checkCorrectionLoopEntry(p.functionHandles.trialOutcomeObj.correct);
                if(p.functionHandles.trialManagerObj.inCorrectionLoop)
                    fprintf('Entering correction loop for %stokenized trials\n',sprintf('%s ',p.functionHandles.trialManagerObj.correctionLoopTokens{:}));
                end
            else
                
                %  Check correction loop exit
                p.functionHandles.trialManagerObj.checkCorrectionLoopExit(p.functionHandles.trialOutcomeObj.correct);
                if(p.functionHandles.trialManagerObj.inCorrectionLoop)
                    fprintf('Continue correction loop.\n');
                else
                    fprintf('Monkey made a correct responses; exit correction loop.\n');
                end
            end
        else
            fprintf('Trial aborted or interrupted.\n');
            p.functionHandles.trialManagerObj.repeatTrial;
        end
        fprintf('\n');
        
        %  Check run termination criteria
        if(p.trial.pldaps.quit == 0)
            p.trial.pldaps.quit = p.functionHandles.trialManagerObj.checkRunTerminationCriteria;
        else
            %  Write performance to screen
            p.functionHandles.performanceTrackingObj.output;
            fprintf('\n');
        end
        
        %%%%%%%%%%%%%%%%%%
        %  FRAME STATES  %
        %%%%%%%%%%%%%%%%%%
        
    case p.trial.pldaps.trialStates.frameDraw
        %  frameDraw--final image has been calculated and will now be
        %  drawn. This is where all calls to Screen should be done.  Also,
        %  if there is a call to a function calling Screen, put it here!
        
        %  Write appropriate texture into the display pointer.  Expected
        %  operation is that if the state is not on the list, nothing will
        %  be drawn.
        p.functionHandles.graphicsManagerObj.drawStateTexture(...
            p.trial.display.ptr,p.functionHandles.stateVariables.nextState);
        
        %  Draw in the cursor based on upcoming state
        nextState = cell2mat(regexp(p.functionHandles.stateVariables.nextState,'[a-z,A-Z]+','match'));
        switch nextState
            case 'response'
                screenPosition = p.functionHandles.analogStickObj.screenPosition;
            otherwise
                screenPosition = p.trial.display.ctr([1 2]);
        end
        p.functionHandles.analogStickCursorObj.drawCursor(screenPosition,...
            'fillColor',p.functionHandles.colors.cursor.(nextState),...
            'armWidth',6,...
            'height',30,...
            'borderWidth',4);
        
        %  Update the analog stick display
        p.functionHandles.analogStickWindowManagerObj.updateDisplay;
        
        %  Update the eye window display
        p.functionHandles.eyePositionWindowManagerObj.updateDisplay;
        
        %  Fixation dot
        p.functionHandles.graphicsManagerObj.drawFixationDot(...
            p.trial.display.ptr,p.trial.display.ctr([1 2]));
        
    case p.trial.pldaps.trialStates.frameDrawingFinished
        %  frameDrawingFinished--here we could do any steps that need to be
        %  done immediately prior to the flip.
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  frameUpdate--called once after the last frame is done (or
        %  even before).  Get current eyepostion, cursor position,
        %  keypresses, analog stick position, etc. in preparation for the
        %  subsequent frame cycle.
        
        %  Update the analog stick window manager
        p.functionHandles.analogStickWindowManagerObj.updateWindows(p.functionHandles.analogStickObj.normalizedPosition);
        p.functionHandles.analogStickWindowManagerObj.updateTrajectory(p.functionHandles.analogStickObj.normalizedPosition);
        
        %  Update the eye position window manager
        p.functionHandles.eyePositionWindowManagerObj.updateWindows([p.trial.eyeX p.trial.eyeY]);
        p.functionHandles.eyePositionWindowManagerObj.updateTrajectory([p.trial.eyeX p.trial.eyeY]);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  framePrepareDrawing--where you can prepare all drawing and
        %  task state control (just don't actually make the Screen calls
        %  here).
        
        %  Check if we have run out of time on this trial.  If so, stop any
        %  tones you might have started and were still running when we ran
        %  out of time and record this as a trial abort.
        if(p.trial.ttime >= p.trial.pldaps.maxTrialLength)
            pds.audio.stop(p,'warning');
            pds.audio.stop(p,'incorrect');
            pds.audio.stop(p,'reward');
            p.functionHandles.trialOutcomeObj.recordAbort(...
                'abortState',p.functionHandles.stateVariables.currentState,...
                'abortMessage','trialDurationElapsed',...
                'abortTime',GetSecs);
            p.trial.flagNextTrial = true;
            fprintf('Monkey timed out...\n');
        end
        
        %  Control trial progress with trial state variables.  The regular
        %  expression allows me to ignore numerical characters appended to
        %  the end of the state name.
        switch cell2mat(regexp(p.functionHandles.stateVariables.nextState,'[a-z,A-Z]+','match'))
            
            case 'start'
                
                %  STATE:  start
                %
                %  First state we enter at the beginning of a trial.  As
                %  soon as the analog stick is in the neutral position and
                %  the monkey is fixating then we can proceed to the engage
                %  state.  Otherwise, go to warning.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state\n',p.functionHandles.stateVariables.currentState);
                else
                    if(p.functionHandles.analogStickWindowManagerObj.inWindow('neutral') && p.functionHandles.eyePositionWindowManagerObj.inWindow('fixation'))
                        p.functionHandles.analogStickWindowManagerObj.enableWindow('engage');
                        p.functionHandles.analogStickWindowManagerObj.disableWindow('neutral');
                        p.functionHandles.stateVariables.nextState = 'engage';
                        p.functionHandles.analogStickCursorObj.visible = true;
                        p.functionHandles.graphicsManagerObj.fixationDotVisible = false;
                    elseif(~p.functionHandles.analogStickWindowManagerObj.inWindow('neutral'))
                        p.functionHandles.stateVariables.nextState = 'warning';
                        p.functionHandles.analogStickCursorObj.visible = true;
                        p.functionHandles.graphicsManagerObj.fixationDotVisible = false;
                    end
                end
                
            case 'warning'
                
                %  STATE:  warning
                %
                %  We enter this state if monkey does not have the analog
                %  stick at the neutral position when the trial starts or
                %  if he is not fixating when he attempts to engage the
                %  analog stick. Proceed back to start once he has returned
                %  the analog stick to the neutral position.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state\n',p.functionHandles.stateVariables.currentState);
                    pds.audio.play(p,'warning',Inf);
                    p.functionHandles.analogStickCursorObj.visible = true;
                elseif(p.functionHandles.analogStickWindowManagerObj.inWindow('neutral'))
                    fprintf('\tMonkey returned analog stick to neutral position after %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    pds.audio.stop(p,'warning');
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.graphicsManagerObj.fixationDotVisible = true;
                    p.functionHandles.stateVariables.nextState = 'start';
                end
                
            case 'engage'
                
                %  STATE:  engage
                %
                %  We enter this state once the analog stick is in the
                %  neutral position during the start state and the monkey
                %  is fixating.  Go to hold once he engages the analog
                %  stick and is fixating.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state\n',p.functionHandles.stateVariables.currentState);
                elseif(p.functionHandles.analogStickWindowManagerObj.inWindow('engage'))
                    if(p.functionHandles.eyePositionWindowManagerObj.inWindow('fixation'))
                        fprintf('\tMonkey engaged analog stick while fixating after %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                        p.functionHandles.stateVariables.nextState = 'hold';
                        p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                    else
                        p.functionHandles.analogStickWindowManagerObj.disableWindow('engage');
                        p.functionHandles.stateVariables.nextState = 'warning';
                    end
                elseif(~p.functionHandles.eyePositionWindowManagerObj.inWindow('fixation'))
                    p.functionHandles.analogStickWindowManagerObj.enableWindow('neutral');
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('engage');
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.graphicsManagerObj.fixationDotVisible = true;
                    p.functionHandles.stateVariables.nextState = 'start';
                end
                
            case 'hold'
                
                %  STATE:  hold
                %
                %  We enter this state once the analog stick is engaged,
                %  the monkey is fixating, and before we are ready to show
                %  the symbols.  He will wait the hold duration before the
                %  symbol presentation begins and in that time should
                %  continue fixation.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %5.3f sec\n',...
                        p.functionHandles.stateVariables.currentState,...
                        p.functionHandles.stateTiming.(p.functionHandles.stateVariables.currentState));
                elseif(p.functionHandles.stateVariables.timeInStateElapsed && p.functionHandles.eyePositionWindowManagerObj.inWindow('fixation'))
                    fprintf('\tMonkey fixated and held analog stick in engaged position for %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.eyePositionWindowManagerObj.enableWindow('symbols');
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('fixation');
                    p.functionHandles.stateVariables.nextState = 'symbols01';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                elseif(~p.functionHandles.analogStickWindowManagerObj.inWindow('engage'))
                    fprintf('\tMonkey moved analog stick out of engaged position at %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('engage');
                    p.functionHandles.analogStickWindowManagerObj.enableWindow('neutral');
                    p.functionHandles.stateVariables.nextState = 'warning';
                elseif(~p.functionHandles.eyePositionWindowManagerObj.inWindow('fixation'))
                    fprintf('\tMonkey stopped fixating at %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('engage');
                    p.functionHandles.analogStickWindowManagerObj.enableWindow('neutral');
                    p.functionHandles.stateVariables.nextState = 'warning';
                end
                
            case 'symbols'
                
                %  STATE:  symbols
                %
                %  We enter this group of numbered states for the first
                %  time from hold. Subsequent entry is from one of this
                %  group. Exit is from symbol phase 6. For now monkey may
                %  examine the symbols so eye position should be within
                %  symbol area.  Premature movements of cursor or change in
                %  gaze will lead to trial abort and penalty.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %5.3f sec; configuration %d %d %d\n',...
                        p.functionHandles.stateVariables.currentState,...
                        p.functionHandles.stateTiming.(p.functionHandles.stateVariables.currentState),...
                        p.functionHandles.graphicsManagerObj.stateConfig.(p.functionHandles.stateVariables.currentState));
                elseif(~p.functionHandles.eyePositionWindowManagerObj.inWindow('symbols'))
                    
                    %  Monkey is no longer viewing symbols.  This is a
                    %  trial abort.
                    fprintf('\tMonkey diverted gaze from symbols at %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.trialOutcomeObj.recordAbort(...
                        'abortState',p.functionHandles.stateVariables.currentState,...
                        'abortMessage','eyePositionError',...
                        'abortTime',GetSecs);
                    p.functionHandles.graphicsManagerObj.fixationDotVisible = false;
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('all');
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('all');
                elseif(~p.functionHandles.analogStickWindowManagerObj.inWindow('engage'))
                    
                    %  Monkey has moved analog stick out of engaged
                    %  position.  This is a trial abort.
                    fprintf('\tMonkey moved analog stick prematurely at %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.trialOutcomeObj.recordAbort(...
                        'abortState',p.functionHandles.stateVariables.currentState,...
                        'abortMessage','analogStickError',...
                        'abortTime',GetSecs);
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('all');
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('all');
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    
                    %  Time in state has elapsed so move on to the next
                    %  state.
                    symbolPhase = str2double(cell2mat(regexp(p.functionHandles.stateVariables.currentState,'[0-9]+','match'))) + 1;                    
                    while(symbolPhase <= 6 && (p.functionHandles.stateTiming.(sprintf('symbols%02d',symbolPhase)) - p.trial.display.ifi) <= 0)
                        symbolPhase = symbolPhase + 1;
                    end
                    
                    if(symbolPhase <= 6)
                        p.functionHandles.stateVariables.nextState = sprintf('symbols%02d',symbolPhase);
                    else
                        p.functionHandles.stateVariables.nextState = 'response';
                        p.functionHandles.analogStickWindowManagerObj.enableWindow('left','right');
                        p.functionHandles.eyePositionWindowManagerObj.enableWindow('fixation');
                        p.functionHandles.stateVariables.nextState = 'response';
                        
                        %  Update windowing so the movement will be
                        %  relative rather than absolute
                        normalizedPosition = p.functionHandles.analogStickObj.normalizedPosition;
                        symbolWidth = 2*p.functionHandles.geometry.symbolRadius / p.functionHandles.analogStickObj.pWidth; %(p.functionHandles.geometry.symbolDisplacement+p.functionHandles.geometry.symbolRadius);
                        p.functionHandles.analogStickWindowManagerObj.addWindow(...
                            'engage',[-2*symbolWidth+normalizedPosition(1) -1 2*symbolWidth+normalizedPosition(1) -0.95],true);
                        p.functionHandles.analogStickWindowManagerObj.addWindow(...
                            'left',[-1 -1 -symbolWidth+normalizedPosition(1) -0.95],true);
                        p.functionHandles.analogStickWindowManagerObj.addWindow(...
                            'right',[symbolWidth+normalizedPosition(1) -1 1 -0.95],true);
                        p.functionHandles.analogStickWindowManagerObj.addWindow(...
                            'center',[-symbolWidth+normalizedPosition(1) -1 symbolWidth+normalizedPosition(1) -0.95],true);
                        
                        p.functionHandles.analogStickObj.pCenter(1) = 2*p.functionHandles.analogStickObj.pCenter(1) - p.functionHandles.analogStickObj.screenPosition(1);
                    end
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                end
                
            case 'response'
                
                %  STATE:  response
                %
                %  We enter this state for the first time from symbols.
                %  Subsequent entry is from this state.  Monkey's eyes must
                %  be within the symbol area when he releases the analog
                %  stick. Response will be scored based on the window from
                %  which monkey releases joystick.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %5.3f sec\n',...
                        p.functionHandles.stateVariables.currentState,...
                        p.functionHandles.stateTiming.(p.functionHandles.stateVariables.currentState));
                        p.functionHandles.trialOutcomeObj.recordResponse('response','center');
                elseif(~p.functionHandles.eyePositionWindowManagerObj.inWindow('symbols'))
                    
                    %  Monkey is no longer viewing symbols.  This is a
                    %  trial abort regardless of state.
                    fprintf('\tMonkey diverted gaze from area of symbols at %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.trialOutcomeObj.recordAbort(...
                        'abortState',p.functionHandles.stateVariables.currentState,...
                        'abortMessage','eyePositionError',...
                        'abortTime',GetSecs);
                    p.functionHandles.graphicsManagerObj.fixationDotVisible = false;
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('all');
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('all');
                elseif(~p.functionHandles.analogStickWindowManagerObj.inWindow('engage'))
                    
                    %  Monkey has left the engaged window; his response is
                    %  now set and he goes on to return state.
                    p.functionHandles.trialOutcomeObj.recordResponse('responseTime',GetSecs);
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('left','right','engage');
                    p.functionHandles.analogStickWindowManagerObj.enableWindow('neutral');
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('symbols');
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.graphicsManagerObj.fixationDotVisible = true;
                    p.functionHandles.stateVariables.nextState = 'return';
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    
                    %  Time in state has elapsed.  This is a trial abort
                    fprintf('\tMonkey elapsed maximum response time\n');
                    p.functionHandles.trialOutcomeObj.recordAbort(...
                        'abortState',p.functionHandles.stateVariables.currentState,...
                        'abortMessage','responseDurationElapsed',...
                        'abortTime',GetSecs);
                    p.functionHandles.graphicsManagerObj.fixationDotVisible = false;
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('all');
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('all');
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                else
                    
                    %  Monkey still has analog stick engaged.  Update his
                    %  response based on his current window position.
                    if(p.functionHandles.analogStickWindowManagerObj.inWindow('left'))
                        p.functionHandles.trialOutcomeObj.recordResponse('response','left');
                    elseif(p.functionHandles.analogStickWindowManagerObj.inWindow('right'))
                        p.functionHandles.trialOutcomeObj.recordResponse('response','right');
                    else
                        p.functionHandles.trialOutcomeObj.recordResponse('response','center');
                    end
                end
                
            case 'return'
                
                %  STATE:  return
                %
                %  Monkey must now return analog stick to neutral position
                %  and fixate before he can receive feedback.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state\n',p.functionHandles.stateVariables.currentState);
                elseif(p.functionHandles.analogStickWindowManagerObj.inWindow('neutral') && p.functionHandles.eyePositionWindowManagerObj.inWindow('fixation'))
                    fprintf('\tMonkey returned analog stick to neutral and is fixating at %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.stateVariables.nextState = 'wait';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                end
                
            case 'wait'
                
                %  STATE:  wait
                %
                %  Brief variable wait time between scoring the monkey's
                %  response and delivery of feedback.  Monkey must maintain
                %  fixation until he gets feedback.  Otherwise it is a
                %  trial abort. If he moves the joystick out of the neutral
                %  position, this is also a trial abort.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %5.3f sec\n',...
                        p.functionHandles.stateVariables.currentState,...
                        p.functionHandles.stateTiming.(p.functionHandles.stateVariables.currentState));
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    p.functionHandles.stateVariables.nextState = 'feedback';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.reward - p.trial.display.ifi;
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('all');
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('all');
                elseif(~p.functionHandles.eyePositionWindowManagerObj.inWindow('fixation'))
                    fprintf('\tMonkey diverted gaze from fixation at %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.trialOutcomeObj.recordAbort(...
                        'abortState',p.functionHandles.stateVariables.currentState,...
                        'abortMessage','eyePositionError',...
                        'abortTime',GetSecs);
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                    p.functionHandles.graphicsManagerObj.fixationDotVisible = false;
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('all');
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('all');
                elseif(~p.functionHandles.analogStickWindowManagerObj.inWindow('neutral'))
                    fprintf('\tMonkey moved analog stick at %0.3f sec\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.trialOutcomeObj.recordAbort(...
                        'abortState',p.functionHandles.stateVariables.currentState,...
                        'abortMessage','analogStickError',...
                        'abortTime',GetSecs);
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.stateTiming.(p.functionHandles.stateVariables.nextState) - p.trial.display.ifi;
                    p.functionHandles.graphicsManagerObj.fixationDotVisible = false;
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.analogStickWindowManagerObj.disableWindow('all');
                    p.functionHandles.eyePositionWindowManagerObj.disableWindow('all');
                end
                
            case 'feedback'
                
                %  STATE:  feedbackDelivery
                %
                %  Give monkey a reward (or other feedback, or nothing at
                %  all) and advance to next trial.  He only reaches this
                %  position if he has maintained fixation and also not
                %  moved the analog stick away from neutral position.
                %  Trial will end upon completion of his feedback.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state\n',p.functionHandles.stateVariables.currentState);
                    if(p.functionHandles.trialOutcomeObj.correct)
                        p.functionHandles.rewardManagerObj.give(p.functionHandles.reward);
                        fprintf('\tMonkey''s response <strong>%s</strong> was <strong>correct</strong>--reward delivered for %0.2f sec\n',p.functionHandles.trialOutcomeObj.response,p.functionHandles.reward);
                    else
                        fprintf('\tMonkey''s response <strong>%s</strong> was <strong>incorrect</strong>.\n',p.functionHandles.trialOutcomeObj.response);
                    end
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    p.trial.flagNextTrial = true;
                end
                
            case 'penalty'
                
                %  STATE:  penalty
                %
                %  Apply a time penalty and advance to next trial.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state\n',p.functionHandles.stateVariables.currentState);
                    pds.audio.play(p,'warning',1);
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    p.trial.flagNextTrial = true;
                    pds.audio.stop(p,'warning');
                end
        end
end
end
