function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION FILE
%  PACKAGE:  dmf

%  **  ISSUES TO CONSIDER / THOUGHTS FOR REVISIONS

switch state
    
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        %  experimentPostOpenScreen--executed once after screen has been
        %  opened.
        
        %  By now the analog stick object should have been created, so
        %  let's adjust for screen geometry
        p.functionHandles.analogStickObj.pWidth = p.trial.display.pWidth;
        p.functionHandles.analogStickObj.pHeight = 0;
        
        %  Now put some windows in; these are the defaults and can be
        %  modified later.  Width of the center window is the symbol
        %  diameter.
        p.functionHandles.geometry.horizontalSpan = 2*(p.functionHandles.geometry.symbolDisplacement + p.functionHandles.geometry.symbolRadius);
        p.functionHandles.geometry.centerWindow = 2*p.functionHandles.geometry.symbolRadius / p.functionHandles.geometry.horizontalSpan; %analogStickObj.pWidth;
        p.functionHandles.analogStickWindowManager.addWindow('neutral',[-0.5*p.functionHandles.geometry.centerWindow -0.5 0.5*p.functionHandles.geometry.centerWindow 0.5]);
        p.functionHandles.analogStickWindowManager.addWindow('engaged',[-0.5*p.functionHandles.geometry.centerWindow -1 0.5*p.functionHandles.geometry.centerWindow -0.5]);
        p.functionHandles.analogStickWindowManager.addWindow('center',[-0.5*p.functionHandles.geometry.centerWindow -1 0.5*p.functionHandles.geometry.centerWindow -0.5]);
        p.functionHandles.analogStickWindowManager.addWindow('left',[-1 -1 -0.5*p.functionHandles.geometry.centerWindow -0.5]);
        p.functionHandles.analogStickWindowManager.addWindow('right',[0.5*p.functionHandles.geometry.centerWindow -1 1 -0.5]);
        
        %  Make last final custom adjustments based on subject.
        dmf.adjustableParameters(p,state);
        
        %  Generate symbol textures at beginning of experiment (we can only
        %  do this once we have the display pointer, and we only need do it
        %  this one time)
        p.functionHandles.symbolTextures = dmf.generateSymbolTextures(p);
        fprintf(1,'****************************************************************\n');
        fprintf(1,'Generated %d symbol textures.\n',length(p.functionHandles.symbolTextures));
        fprintf(1,'****************************************************************\n');
        
        fprintf(1,'****************************************************************\n');
        fprintf('Windows for analog stick:\n');
        p.functionHandles.analogStickWindowManager.displayWindows;
        fprintf(1,'****************************************************************\n');
        
        %  If this is the mini-rig then prepare to use the rewardManager
        if(isField(p.trial,'a2duino') && p.trial.a2duino.useForReward)
            fprintf(1,'****************************************************************\n');
            fprintf(1,'Using the a2duino DAQ for reward.\n');
            fprintf(1,'Reward type: %s.\n',p.trial.a2duino.rewardType);
            fprintf(1,'****************************************************************\n');
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        %  trialSetup--this is where we would perform any steps that needed
        %  to be done before a trial is started, for example preparing
        %  stimuli parameters
        
        %  Condition from cell array
        p.trial.condition = p.functionHandles.trialManagerObj.nextTrial;
        
        %  Initialize trial state variables
        p.functionHandles.stateVariables = stateControl('start');
        
        %  Initialize trial outcome object
        p.functionHandles.trialOutcomeObj = dmf.outcome(...
            'trialNumber',p.functionHandles.trialManagerObj.trialNumber,...
            'rewardedResponse',p.trial.condition.rewardedResponse,...
            'correctionLoopTrial',p.functionHandles.trialManagerObj.inCorrectionLoop,...
            'selectionCode',p.trial.condition.selectionCode);
        
        %  Initialize flags for graphical display
        p.functionHandles.analogStickCursorObj.visible = false;
        p.functionHandles.showSymbols = false;
        p.functionHandles.showWarning = false;
        p.functionHandles.showEngage = false;
        p.functionHandles.showHold = false;
        p.functionHandles.symbolPhase = 1;
        
        %  Set any adjustable parameters
        dmf.adjustableParameters(p,state);
        
        %  All adjustments should have been made before final steps and
        %  before trial start!
        
        %  Create textures for display
        p.functionHandles.sequenceTextures = dmf.generateSequenceTextures(p);
        
        %  Echo trial specs to screen
        fprintf('TRIAL ATTEMPT %d\n',p.trial.pldaps.iTrial);
        if(~p.functionHandles.trialManagerObj.inCorrectionLoop)
            fprintf('Completed %d of %d trials\n',p.functionHandles.trialManagerObj.trialNumber,p.functionHandles.trialManagerObj.maxTrials);
        else
            fprintf('Correction loop trial %d for %stokenized trials\n',p.functionHandles.trialManagerObj.correctionLoopTrialNumber,sprintf('%s ',p.functionHandles.trialManagerObj.correctionLoopTokens{:}));
        end
        fprintf('%25s:\n','Symbols');
        for i=1:3
            fprintf('%25s:  ',p.functionHandles.possibleResponses{i});
            fprintf('%s ',p.functionHandles.sequenceObj.features.colors{p.trial.condition.sequenceSymbolCode(i,1)});
            fprintf('%s ',p.functionHandles.sequenceObj.features.patterns{p.trial.condition.sequenceSymbolCode(i,2)});
            fprintf('%s',p.functionHandles.sequenceObj.features.shapes{p.trial.condition.sequenceSymbolCode(i,3)});
            fprintf('\n');
        end
        fprintf('%25s:  %s\n','Rewarded response',p.trial.condition.rewardedResponse);
        fprintf('%25s:  %s\n','Satisifed selection code',p.trial.condition.selectionCode);
        fprintf('\n');
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  cleanUpandSave--post trial management; perform any steps that
        %  should happen upon completion of a trial such as performance
        %  tracking and trial index updating.
        
        %  Clean up sequence textures
        Screen('Close',p.functionHandles.sequenceTextures);
        
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
        
        %  Check if we have hit a termination condition
        if(isfield(p.trial,'a2duino') && p.trial.a2duino.useForReward)
            switch p.trial.a2duino.rewardType
                case 'pellet'
                    if(~p.functionHandles.a2duinoObj.rewardInProgress && ~p.functionHandles.a2duinoObj.rewardCompleted)
                        fprintf('We are out of pellets; terminating session.\n');
                        p.trial.pldaps.quit = 2;
                    end
            end
        end
        
        %%%%%%%%%%%%%%%%%%
        %  FRAME STATES  %
        %%%%%%%%%%%%%%%%%%
        
    case p.trial.pldaps.trialStates.frameDraw
        %  frameDraw--final image has been calculated and will now be
        %  drawn. This is where all calls to Screen should be done.  Also,
        %  if there is a call to a function calling Screen, put it here!
        
        %  For now we aren't cycling through the symbol phases
        if(p.functionHandles.showSymbols)
            Screen('DrawTexture',p.trial.display.ptr,p.functionHandles.sequenceTextures(p.functionHandles.symbolPhase));
        end
        
        %  Draw the cursor (there is an internal check for cursor
        %  visibility).
        if(p.functionHandles.showWarning)
            fillColor = [0.8 0 0];
        elseif(p.functionHandles.showEngage)
            fillColor = [0 0.8 0];
        elseif(p.functionHandles.showHold)
            fillColor = [0.8 0.8 0.8];
        else
            fillColor = [0 0 0];
        end
        screenPosition = p.functionHandles.analogStickObj.screenPosition;
        screenPosition(1) = max(min(screenPosition(1),p.functionHandles.geometry.center(1)+0.5*p.functionHandles.geometry.horizontalSpan),p.functionHandles.geometry.center(1)-0.5*p.functionHandles.geometry.horizontalSpan);
        p.functionHandles.analogStickCursorObj.drawCursor(screenPosition,'fillColor',fillColor);
        
        %  *******
        %  once you start putting a fixation spot in, you'll want to draw
        %  that last if you want it to be visible at all times!
        %  *******
        
    case p.trial.pldaps.trialStates.frameDrawingFinished
        %  frameDrawingFinished--here we could do any steps that need to be
        %  done immediately prior to the flip.
        
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  frameUpdate--called once after the last frame is done (or
        %  even before).  Get current eyepostion, cursor position,
        %  keypresses, joystick position, etc. in preparation for the
        %  subsequent frame cycle.
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  framePrepareDrawing--where you can prepare all drawing and
        %  task state control (just don't actually make the Screen calls
        %  here).
        
        %  Make sure we haven't accidentally over-run the data buffer.
        %  Also, stop any tones you might have started and were still
        %  running when we ran out of time.
        if(p.trial.ttime >= p.trial.pldaps.maxTrialLength)
            pds.audio.stop(p,'warning');
            pds.audio.stop(p,'incorrect');
            pds.audio.stop(p,'reward');
            p.functionHandles.showWarning = false;
            p.functionHandles.trialOutcomeObj.recordAbort(...
                'abortState',p.functionHandles.stateVariables.currentState,...
                'abortMessage','trialDurationElapsed',...
                'abortTime',GetSecs);
            p.trial.flagNextTrial = true;
            fprintf('Monkey timed out...\n');
        end
        
        %  Control trial progress with trial state variables
        switch p.functionHandles.stateVariables.nextState
            
            case 'start'
                
                %  STATE:  start
                %
                %  First state we enter at the beginning of a trial.  As
                %  soon as the analog stick is in the neutral position we
                %  can proceed to the next state.  Otherwise, go to
                %  warning.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.currentState));
                end
                if(p.functionHandles.analogStickWindowManager.inWindow('neutral'))
                    fprintf('\tAnalog stick in neutral position.\n');
                    p.functionHandles.stateVariables.nextState = 'engage';
                else
                    fprintf('\tAnalog stick not in neutral position.\n');
                    p.functionHandles.stateVariables.nextState = 'warning';
                end
                
            case 'warning'
                
                %  STATE:  warning
                %
                %  We enter this state if monkey does not have the joystick
                %  at the rest position when the trial starts. Proceed back
                %  to start once he has returned the joystick to the
                %  neutral position.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.currentState));
                    pds.audio.play(p,'warning',Inf);
                    p.functionHandles.analogStickCursorObj.visible = true;
                    p.functionHandles.showWarning = true;
                elseif(p.functionHandles.analogStickWindowManager.inWindow('neutral'))
                    fprintf('\tAnalog stick returned to neutral position.\n');
                    pds.audio.stop(p,'warning');
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.showWarning = false;
                    p.functionHandles.stateVariables.nextState = 'start';
                end
                
            case 'engage'
                
                %  STATE:  engage
                %
                %  We enter this state once the analog stick is in the
                %  neutral position during the start state.
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.currentState));
                    p.functionHandles.analogStickCursorObj.visible = true;
                    p.functionHandles.showEngage = true;
                elseif(p.functionHandles.analogStickWindowManager.inWindow('engaged'))
                    fprintf('\tAnalog stick engaged after %0.3f sec.\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.showHold = true;
                    p.functionHandles.showEngage = false;
                    p.functionHandles.stateVariables.nextState = 'hold';
                end
                
            case 'hold'
                
                %  STATE:  hold
                %
                %  We enter this state once the analog stick is engaged and
                %  before we are ready to show the symbols.  He will wait
                %  the hold duration before the symbol appears.
                if(p.functionHandles.stateVariables.firstEntryIntoState(p.functionHandles.timing.holdDelay))
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.currentState));
                    fprintf('\tMonkey will be required to hold the analog stick for %5.3f sec.\n',p.functionHandles.stateVariables.timeRemainingInState);
                elseif(p.functionHandles.analogStickWindowManager.inWindow('engaged') && p.functionHandles.stateVariables.timeInStateElapsed)
                    fprintf('\tMonkey kept analog stick engaged for %0.3f sec.\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.stateVariables.nextState = 'symbols';
                elseif(~p.functionHandles.analogStickWindowManager.inWindow('engaged'))
                    fprintf('\tMonkey moved analog stick prematurely at %0.3f sec.\n',p.functionHandles.stateVariables.timeInState);
                    p.functionHandles.stateVariables.nextState = 'warning';
                end
                
                
            case 'symbols'
                
                %  STATE:  symbols
                %
                %  Show the symbols until delay elapsed and as long as he
                %  has joystick at center position.  If he moves the
                %  joystick too early, go to abort penalty.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    p.functionHandles.showSymbols = true;
                    p.functionHandles.symbolPhase = 1;
                else
                    p.functionHandles.showHold = false;
                    p.functionHandles.stateVariables.nextState = 'response';
                end
                
            case 'response'
                
                %  STATE:  response
                %
                %  Now we wait for the monkey to make his response.
                %
                %  Enter this state with the cursor in the engaged state.
                %  He may either release the joystick or move the joystick
                %  left or right.  His default response is center.  He
                %  chooses center by allowing the joystick to return to
                %  neutral without first choosing left or right.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState(p.functionHandles.timing.responseDuration))
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    fprintf('\tMonkey will have %5.3f sec to make his response.\n',p.functionHandles.stateVariables.timeRemainingInState);
                end
                
                %  Proceed through time and position checks
                if(p.functionHandles.stateVariables.timeInStateElapsed)
                    
                    %  He has elapsed the maximum time allotted for his
                    %  response.  This is a trial abort.
                    p.functionHandles.trialOutcomeObj.recordAbort(...
                        'abortState',p.functionHandles.stateVariables.currentState,...
                        'abortMessage','responseDurationElapsed',...
                        'abortTime',GetSecs);
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.showSymbols = false;
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.timing.penaltyDuration;
                    
                elseif(p.functionHandles.analogStickWindowManager.inWindow('left'))
                    
                    %  Monkey has chosen left.  Record it and go on.
                    p.functionHandles.trialOutcomeObj.recordResponse(...
                        'response','left',...
                        'responseTime',GetSecs);
                    p.functionHandles.stateVariables.nextState = 'return';
                elseif(p.functionHandles.analogStickWindowManager.inWindow('right'))
                    
                    %  Monkey has chosen right.  Record it and go on.
                    p.functionHandles.trialOutcomeObj.recordResponse(...
                        'response','right',...
                        'responseTime',GetSecs);
                    p.functionHandles.stateVariables.nextState = 'return';
                elseif(p.functionHandles.analogStickWindowManager.inWindow('neutral'))
                    
                    %  Monkey has released the analog stick and it has
                    %  returned to the neutral position.  His response is
                    %  center because he never reached left or right
                    %  windows.
                    p.functionHandles.trialOutcomeObj.recordResponse(...
                        'response','center',...
                        'responseTime',GetSecs);
                    p.functionHandles.stateVariables.nextState = 'return';
                end
                
            case 'return'
                
                %  STATE:  return
                %
                %  Monkey has either made a choice or allowed the analog
                %  stick to return to the neutral position.  He can no
                %  longer alter his choice and must return the analog stick
                %  to the neutral position before he can get his reward.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                end
                
                %  Turn the cursor off as soon as it's left the response
                %  window
                if(~p.functionHandles.analogStickWindowManager.inWindow(p.functionHandles.trialOutcomeObj.response))
                    p.functionHandles.analogStickCursorObj.visible = false;
                end
                
                %  When analog stick is in neutral position, extinguish the
                %  symbols and score his response.
                if(p.functionHandles.analogStickWindowManager.inWindow('neutral'))
                    fprintf('\tMonkey responded %s\n',p.functionHandles.trialOutcomeObj.response);
                    p.functionHandles.showSymbols = false;
                    if(p.functionHandles.trialOutcomeObj.correct)
                        fprintf('\tMonkey''s response was correct.\n');
                        p.functionHandles.stateVariables.nextState = 'reward';
                    else
                        fprintf('\tMonkey''s response was incorrect.\n');
                        p.functionHandles.stateVariables.nextState = 'error';
                    end
                end
                
            case 'reward'
                
                %  STATE:  reward
                %
                %  Monkey has correctly made his choice.  Give him a reward
                %  and then advance to the next trial.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState(p.functionHandles.timing.rewardDuration))
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    pds.audio.play(p,'reward',1);
                    
                    %  Provide reward
                    if(isfield(p.trial,'a2duino') && p.trial.a2duino.useForReward)
                        switch p.trial.a2duino.rewardType
                            case 'pellet'
                                p.functionHandles.a2duinoObj.startPelletRelease;
                            case 'fluid'
                                p.functionHandles.a2duinoObj.startFluidReward(p.functionHandles.reward);
                        end
                    else
                        pds.behavior.reward.give(p,p.functionHandles.reward);
                    end
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    pds.audio.stop(p,'reward');
                    
                        p.trial.flagNextTrial = true;
                    %  Check to make sure the reward is not currently in
                    %  progress
                    if(isfield(p.trial,'a2duino') && p.trial.a2duino.useForReward)
                        if(~p.functionHandles.a2duinoObj.rewardInProgress)
                            p.trial.flagNextTrial = true;
                        end
                    else
                        p.trial.flagNextTrial = true;
                    end
                end
                
            case 'error'
                
                %  STATE:  error
                %
                %  Monkey has incorrectly made his choice.  Give him an
                %  error tone and then advance to the penalty phase.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState(p.functionHandles.timing.errorDuration))
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    pds.audio.play(p,'incorrect',1);
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    pds.audio.stop(p,'incorrect');
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.timing.errorPenaltyDuration;
                end
                
            case 'penalty'
                
                %  STATE:  penalty
                %
                %  Monkey has reached this state because he did something
                %  we want to discourage.  He will now get a time penalty.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    p.trial.flagNextTrial = true;
                end
        end
end
end
