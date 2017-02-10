function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION FILE
%  PACKAGE:  dmf

%  **  ISSUES TO CONSIDER / THOUGHTS FOR REVISIONS

%  ** The function adjustable_parameters can be edited during a pause in
%  the task in order to change parameters between trials.
%  dmf.adjustable_parameters(p);

%  ** Create a more contained performance tracking Remember that each trial
%  is stored as an element of the cell array p.data so anything you put
%  into p.trial will be saved, for example p.trial.outcome


switch state
    
    case p.trial.pldaps.trialStates.experimentPostOpenScreen        
        %  experimentPostOpenScreen--executed once after screen has been
        %  opened.
        
        %  By now the analog stick object should have been created, so
        %  let's adjust for screen geometry
        p.functionHandles.analogStickObj.pWidth = p.trial.display.pWidth;
        p.functionHandles.analogStickObj.pHeight = 0;
        
        %  Now put some windows in; these are the defaults and can be
        %  modified later
        p.functionHandles.geometry.horizontalSpan = 2*(p.functionHandles.geometry.symbolDisplacement + p.functionHandles.geometry.symbolRadius);
        p.functionHandles.geometry.centerWindow = p.functionHandles.geometry.symbolDisplacement / p.functionHandles.analogStickObj.pWidth;
        p.functionHandles.analogStickWindowManager.addWindow('neutral',[-p.functionHandles.geometry.centerWindow -0.5 p.functionHandles.geometry.centerWindow 0.5]);
        p.functionHandles.analogStickWindowManager.addWindow('engaged',[-p.functionHandles.geometry.centerWindow -1 p.functionHandles.geometry.centerWindow -0.5]);
        p.functionHandles.analogStickWindowManager.addWindow('center',[-p.functionHandles.geometry.centerWindow -1 p.functionHandles.geometry.centerWindow -0.5]);
        p.functionHandles.analogStickWindowManager.addWindow('left',[-1 -1 -p.functionHandles.geometry.centerWindow -0.5]);
        p.functionHandles.analogStickWindowManager.addWindow('right',[p.functionHandles.geometry.centerWindow -1 1 -0.5]);
        
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
            fprintf(1,'Using the a2duino DAQ for reward.  Initialize rewardManager\n');
            fprintf(1,'****************************************************************\n');
            p.functionHandles.rewardManagerObj = a2duino.rewardManager(p.functionHandles.a2duinoObj);
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        %  trialSetup--this is where we would perform any steps that needed
        %  to be done before a trial is started, for example preparing
        %  stimuli parameters
        
        %  If this is the first trial, then set the trial indexing to 1.
        %         if(p.trial.pldaps.iTrial == 1)
        %             p.functionHandles.trialIndex = 1;
        %             p.functionHandles.nTotalTrials = 0;
        %             p.functionHandles.nCorrectTrials = 0;
        %             p.functionHandles.nCompletedTrials = 0;
        %         end
        
        %  Condition from cell array
        p.trial.condition = p.conditions{p.trial.pldaps.iTrial};
        
        %  Initialize trial state variables
        p.functionHandles.stateVariables = stateControl('start');
        
        %  Initialize trial outcome object
        p.functionHandles.trialOutcome = dmf.outcome(p.trial.condition.rewardedResponse);
        
        %  Initialize flags for graphical display
        p.functionHandles.analogStickCursorObj.visible = false;
        p.functionHandles.showSymbols = false;
        p.functionHandles.showWarning = false;
        p.functionHandles.showEngage = false;
        p.functionHandles.showHold = false;
        
        %  Set any adjustable parameters
        dmf.adjustableParameters(p,state);        
        
        %  Echo trial specs to screen
        fprintf('TRIAL %d:\n',p.trial.pldaps.iTrial);
        fprintf('            Symbol:  %s %s %s\n',p.trial.condition.symbol.color,p.trial.condition.symbol.pattern,p.trial.condition.symbol.shape);
        fprintf(' Rewarded response:  %s\n',p.trial.condition.rewardedResponse);
        fprintf('\n');
        
        %         for pos = {'left','center','right'}
        %             if(p.functionHandles.stateControl.displayPosition.(pos{:}))
        %                 color = p.trial.condition.symbol.(pos{:}).color;
        %                 pattern = p.trial.condition.symbol.(pos{:}).pattern;
        %                 shape = p.trial.condition.symbol.(pos{:}).shape;
        %
        %                 fprintf('    Symbol at %6s:  %s %s %s\n',pos{:},color,pattern,shape);
        %             end
        %         end
        %         fprintf('  Response direction:  %s\n',p.trial.condition.rewardedResponse);
        %         fprintf('          Match type:  %s\n',p.trial.condition.matchType);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  cleanUpandSave--post trial management; perform any steps that
        %  should happen upon completion of a trial such as performance
        %  tracking and trial index updating.
        
        %  Capture data for this trial
        p.trial.trialRecord.stateTransitionLog = p.functionHandles.stateVariables.transitionLog;
        if(p.trial.pldaps.quit~=0)
            if(p.trial.pldaps.quit~=2)
                p.functionHandles.trialOutcome.recordInterrupt('trialPaused');
            else
                p.functionHandles.trialOutcome.recordInterrupt('pldapsQuit');
            end
        end
        p.trial.trialRecord.outcome = p.functionHandles.trialOutcome.commit;
        fprintf('\n');
        
        %  Track performance
        p.functionHandles.performance.update(p.functionHandles.trialOutcome);
        
        %  Write perforamnce to screen
        p.functionHandles.performance.output;
        fprintf('\n');
        
        %  Check if we have hit a termination condition
        if(isfield(p.trial,'a2duino') && p.trial.a2duino.use)
            p.functionHandles.rewardManagerObj.checkRewardStatus;
            if(p.functionHandles.rewardManagerObj.releaseFailed)
                fprintf('We are out of pellets.\n');
                p.trial.pldaps.quit = 2;
            end
        end
        
        %         p.functionHandles.nTotalTrials = p.functionHandles.nTotalTrials + 1;
        %         p.functionHandles.nCompletedTrials = p.functionHandles.nCompletedTrials + p.functionHandles.stateControl.trialCompleted;
        %
        %         if(p.functionHandles.stateControl.trialCompleted)
        %             p.functionHandles.nCorrectTrials = p.functionHandles.nCorrectTrials + p.functionHandles.stateControl.trialCorrect;
        %             p.functionHandles.performance.update(p.trial.condition.matchType,p.functionHandles.stateControl.response,p.functionHandles.stateControl.trialCorrect);
        %         end
        %
        %         if(p.functionHandles.stateControl.trialCorrect)
        %             fprintf('Monkey''s first choice, %s, was correct.\n',p.functionHandles.stateControl.response);
        %             p.functionHandles.trialIndex = p.functionHandles.trialIndex + p.functionHandles.stateControl.trialCompleted;
        %         else
        %             if(p.functionHandles.stateControl.trialCompleted)
        %                 fprintf('Monkey''s first first choice, %s, was incorrect; ',p.functionHandles.stateControl.response);
        %                 if(unifrnd(0,1) < p.functionHandles.controlFlags.repeatErrorTrialLikelihood)
        %                     fprintf('monkey will repeat this trial.\n');
        %                 else
        %                     fprintf('monkey will not repeat this trial.\n');
        %                     p.functionHandles.trialIndex = p.functionHandles.trialIndex + p.functionHandles.stateControl.trialCompleted;
        %                 end
        %             else
        %                 fprintf('Monkey did not complete the trial; monkey will repeat this trial.\n');
        %             end
        %         end
        %
        %         fprintf('Monkey received %0.2f of possible %0.2f in-region reward\n',p.functionHandles.stateControl.rewardInRegionReceived,p.functionHandles.reward.inRegion);
        %
        %         if(p.functionHandles.controlFlags.useReturnReward)
        %             fprintf('Monkey received %0.2f of possible %0.2f return reward!\n',p.functionHandles.stateControl.rewardAtReturnReceived,p.functionHandles.reward.atReturn);
        %         end
        %         fprintf('\n');
        %         fprintf('Current performance:\n');
        %         fprintf('\t%d completed trials of %d total trials\n',p.functionHandles.nCompletedTrials,p.functionHandles.nTotalTrials);
        %         fprintf('\t%d correct of %d completed trials (%0.2f)\n',p.functionHandles.nCorrectTrials,p.functionHandles.nCompletedTrials,p.functionHandles.nCorrectTrials/p.functionHandles.nCompletedTrials);
        %
        %         fprintf('\n');
        %         p.functionHandles.performance.show;
        %         fprintf('\n');
        
        
        %%%%%%%%%%%%%%%%%%
        %  FRAME STATES  %
        %%%%%%%%%%%%%%%%%%
        
    case p.trial.pldaps.trialStates.frameDraw
        %  frameDraw--final image has been calculated and will now be
        %  drawn. This is where all calls to Screen should be done.  Also,
        %  if there is a call to a function calling Screen, put it here!
        
        if(p.functionHandles.showSymbols)
            symbolCenter = p.functionHandles.geometry.symbolCenters.(p.trial.condition.rewardedResponse);
            baseRect = [0 0 2*p.functionHandles.geometry.symbolRadius 2*p.functionHandles.geometry.symbolRadius];
            centeredRect = CenterRectOnPoint(baseRect,symbolCenter(1),symbolCenter(2));
            Screen('DrawTexture',p.trial.display.ptr,p.functionHandles.symbolTextures(p.trial.condition.symbolIndex),[],centeredRect);
        end
        
        %  Draw the cursor (there is an internal check for cursor
        %  visibility).
        if(p.functionHandles.showWarning)
            fillColor = [0.8 0 0 1];
        elseif(p.functionHandles.showEngage)
            fillColor = [0 0.8 0 1];
        elseif(p.functionHandles.showHold)
            fillColor = [0.8 0.8 0.8 1];
        else
            fillColor = [0 0 0 0];
        end
        screenPosition = p.functionHandles.analogStickObj.screenPosition;
        screenPosition(1) = max(min(screenPosition(1),p.functionHandles.geometry.center(1)+0.5*p.functionHandles.geometry.horizontalSpan),p.functionHandles.geometry.center(1)-0.5*p.functionHandles.geometry.horizontalSpan);
        p.functionHandles.analogStickCursorObj.drawCursor(screenPosition,'fillColor',fillColor);
        
        %  For now I don't think I need to make this customizable
        %         center = p.functionHandles.geometry.center;
        %         extent = p.functionHandles.geometry.extent;
        %         [screenX,screenY] = analogStick.getScreenPosition(normX,0,center,extent);
        %         analogStick.drawCursor(p,p.trial.display.ptr,[screenX screenY]);
        
        %         %  Geometry
        %         xpos.left = p.trial.display.ctr(1)-p.functionHandles.displacement;
        %         xpos.right = p.trial.display.ctr(1)+p.functionHandles.displacement;
        %         xpos.center = p.trial.display.ctr(1);
        %         ypos = p.trial.display.ctr(2);
        %
        %         xypos = [xpos.left ypos ; xpos.center ypos ; xpos.right ypos];
        %
        %
        %
        %         color = [p.trial.display.colors.(p.trial.condition.symbol.left.color) ; p.trial.display.colors.(p.trial.condition.symbol.center.color) ; p.trial.display.colors.(p.trial.condition.symbol.right.color)];
        %
        %         pattern = {p.trial.condition.symbol.left.pattern , p.trial.condition.symbol.center.pattern , p.trial.condition.symbol.right.pattern};
        %
        %         shape = {p.trial.condition.symbol.left.shape , p.trial.condition.symbol.center.shape, p.trial.condition.symbol.right.shape};
        %
        % *** Here I can make the call to Screen('DrawTextures')
        
        %                 color = p.trial.display.colors.(p.trial.condition.symbol.center.color);
        %         pattern = p.trial.condition.symbol.center.mask;
        %         shape = p.trial.condition.symbol.center.shape;
        %Screen('DrawTexture',p.trial.display.ptr,p.functionHandles.drawingFunctions.texturePointers.(pattern),xpos.center,ypos);
        %         p.functionHandles.drawingFunctions.drawShapeTextures(p.trial.display.ptr,shape,color,xypos);
        %         p.functionHandles.drawingFunctions.drawPatternMaskTextures(p.trial.display.ptr,pattern,xypos);
        
        
        %  If stimuli are enabled, iterate over positions
        %         if(p.functionHandles.stateControl.showStimuli)
        %             pos = {'left','center','right'};
        %             ix = zeros(3,1);
        %             for pos = {'left','center','right'}
        %
        %             end
        %         end
        %                 %  Show symbols
        %                 if(p.functionHandles.stateControl.showSymbol.(pos{:}))
        %                     color = p.trial.display.colors.(p.trial.condition.symbol.(pos{:}).color);
        %                     shape = p.trial.condition.symbol.(pos{:}).shape;
        %                     mask = p.trial.condition.symbol.(pos{:}).mask;
        %                     p.functionHandles.drawingFunctions.drawShape(p.trial.display.ptr,xpos.(pos{:}),ypos,color,shape);
        %                      p.functionHandles.drawingFunctions.applyMask(p.trial.display.ptr,xpos.(pos{:}),ypos,mask)
        %                 end
        %
        %                 %  Show reward regions
        %                 if(p.functionHandles.controlFlags.useRewardRegions)
        %                     selected = p.functionHandles.controlFlags.useSelectionColorChange && p.functionHandles.stateControl.trialCorrect && p.functionHandles.stateControl.rewardedResponse.(pos{:});
        %                     p.functionHandles.drawingFunctions.drawRewardRegion(p.trial.display.ptr,xpos.(pos{:}),ypos,selected);
        %                 end
        
        %                     if(p.functionHandles.controlFlags.useSelectionColorChange && strcmp(pos,'center') && p.functionHandles.controlFlags.useCenterRewardRegion && p.functionHandles.controlFlags.useCenterSelectionTimer)
        %                         arcAngle = 360*max(0,min(1,(GetSecs-p.functionHandles.stateControl.timer(1))/p.functionHandles.timing.maxSelectionTime));
        %                     elseif(p.functionHandles.controlFlags.useSelectionColorChange && (strcmp(pos,'center') && p.functionHandles.controlFlags.useCenterRewardRegion || ~strcmp(pos,'center')))
        %                         arcAngle = 360*(p.functionHandles.stateControl.trialCorrect && p.functionHandles.stateControl.rewardedResponse.(pos{:}));
        %                     else
        %                         arcAngle = 0;
        %                     end
        %                 end
        
        %  Show reward indicator as secondary reinforcer
        %                 if(p.functionHandles.controlFlags.useRewardIndicator)
        %                     if(~p.functionHandles.stateControl.trialCompleted || (p.functionHandles.stateControl.trialCorrect && p.functionHandles.stateControl.rewardedResponse.(pos{:})))
        %                         reinforcerRatio = max(0,min(1,1-p.functionHandles.stateControl.rewardElapsed/p.functionHandles.reward.maxDuration));
        %                     elseif(~p.functionHandles.stateControl.trialCorrect && p.functionHandles.stateControl.rewardedResponse.(pos{:}))
        %                         reinforcerRatio = 1;
        %                     else
        %                         reinforcerRatio = 0;
        %                     end
        %                     if(~strcmp(pos,'center') || p.functionHandles.controlFlags.useCenterRewardRegion)
        %                         p.functionHandles.drawingFunctions.drawSecondaryReinforcer(p.trial.display.ptr,xpos.(pos{:}),ypos,reinforcerRatio);
        %                     end
        %                 end
        %             end
        %         end
        
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
            p.functionHandles.showWarning = false;
            p.functionHandles.trialOutcome.recordAbort(p.functionHandles.stateVariables.currentState,'trialDurationElapsed');
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
                    fprintf('\tMonkey will be required to hold the analog stick for %0.3f sec.\n',p.functionHandles.timing.holdDelay);
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
                %  left or right.  He chooses center by letting the
                %  joystick go with the cursor over the center.  Otherwise
                %  his choice is whichever window he reaches.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState(p.functionHandles.timing.responseDuration))
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                end
                
                %  Proceed through time and position checks
                if(p.functionHandles.stateVariables.timeInStateElapsed)
                    
                    %  He has elapsed the maximum time allotted for his
                    %  response.  This is a trial abort.
                    p.functionHandles.trialOutcome.recordAbort(p.functionHandles.stateVariables.currentState,'responseDurationElapsed');
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.showSymbols = false;
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.stateDuration = p.functionHandles.timing.penaltyDuration;
                    
                elseif(p.functionHandles.analogStickWindowManager.inWindow('left'))
                    
                    %  Monkey has chosen left.  Record it and go on.
                    p.functionHandles.trialOutcome.recordResponse('left');
                    p.functionHandles.stateVariables.nextState = 'return';
                elseif(p.functionHandles.analogStickWindowManager.inWindow('right'))
                    
                    %  Monkey has chosen right.  Record it and go on.
                    p.functionHandles.trialOutcome.recordResponse('right');
                    p.functionHandles.stateVariables.nextState = 'return';
                elseif(p.functionHandles.analogStickWindowManager.inWindow('center'))
                    
                    %  Monkey has the analog stick in the center position.
                    %  He may still change his answer, so continue in this
                    %  state.
                    p.functionHandles.trialOutcome.recordResponse('center');
                elseif(~p.functionHandles.analogStickWindowManager.inWindow('engaged'))
                    
                    %  Monkey has relased the joystick.  Since we reached
                    %  this case, he either relased from the center
                    %  position or from a position outside a response
                    %  window.  We'll handle that in the return state.
                    p.functionHandles.analogStickCursorObj.visible = false;
                    p.functionHandles.stateVariables.nextState = 'return';
                end
                
            case 'return'
                
                %  STATE:  return
                %
                %  Monkey has either made a choice or allowed the analog
                %  stick to leave the center window.  He can no longer
                %  alter his choice and must return the analog stick to the
                %  neutral position before he can get his reward.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                end
                
                %  Turn the cursor off as soon as it leaves the engage
                %  window
                if(~p.functionHandles.analogStickWindowManager.inWindow(p.functionHandles.trialOutcome.response) && p.functionHandles.analogStickCursorObj.visible)
                    p.functionHandles.analogStickCursorObj.visible = false;
                end
                
                %  When analog stick is in neutral position, extinguish the
                %  symbols and score his response.
                if(p.functionHandles.analogStickWindowManager.inWindow('neutral'))
                    fprintf('\tMonkey responded %s\n',p.functionHandles.trialOutcome.response);
                    p.functionHandles.showSymbols = false;
                    if(p.functionHandles.trialOutcome.correct)
                        fprintf('\tMonkey''s response was correct.\n');
                        p.functionHandles.stateVariables.nextState = 'reward';
                    elseif(~p.functionHandles.trialOutcome.correct)
                        fprintf('\tMonkey''s response was incorrect.\n');
                        p.functionHandles.stateVariables.nextState = 'error';
                    else
                        fprintf('\tMonkey''s response was not valid.\n');
                        p.functionHandles.stateVariables.nextState = 'penalty';
                        p.functionHandles.stateVariables.stateDuration = p.functionHandles.timing.penaltyDuration;
                        p.functionHandles.trialOutcome.recordAbort(p.functionHandles.stateVariables.currentState,'invalidResponse');
                    end
                end   
                
            case 'reward'
                
                %  STATE:  reward
                %
                %  Monkey has correctly made his choice.  Give him a reward
                %  and then advance to the next trial.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState(p.functionHandles.timing.rewardDuration))
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    
                    %  This section for a2duino managed reward
                    if(isfield(p.trial,'a2duino') && p.trial.a2duino.use)
                        p.functionHandles.rewardManagerObj.giveReward('pellet');
                    else
                        pds.behavior.reward.give(p,p.functionHandles.reward);
                    end
                elseif(p.functionHandles.stateVariables.timeInStateElapsed)
                    
                    %  Check to make sure the reward is not currently in
                    %  progress (only relevant for pellets)
                    if(isfield(p.trial,'a2duino') && p.trial.a2duino.use)
                        p.functionHandles.rewardManagerObj.checkRewardStatus;
                        if(~p.functionHandles.rewardManagerObj.releaseInProgress)
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

%             case 'symbols'
%
%                 %  STATE:  symbols
%                 %
%                 %  Show the symbols until delay elapsed and as long as he
%                 %  has joystick at center position.  If he moves the
%                 %  joystick too early, go to abort penalty.
%
%                 if(p.functionHandles.stateControl.firstEntryIntoState)
%                     fprintf('Entered %s state\n',upper(p.functionHandles.stateControl.nextTrialState));
%                     p.functionHandles.stateControl.showStimuli = true;
%                     p.functionHandles.stateControl.timer(1) = GetSecs + p.functionHandles.timing.interSymbolInterval;
%                     p.functionHandles.stateControl.showSymbol.left = p.functionHandles.stateControl.displayPosition.left;
%                     p.functionHandles.stateControl.showSymbol.right = p.functionHandles.stateControl.displayPosition.right;
%                     p.functionHandles.stateControl.showSymbol.center = ~p.functionHandles.controlFlags.useInterSymbolInterval && p.functionHandles.stateControl.displayPosition.center;
%                 elseif(~p.functionHandles.stateControl.joystickCenter)
%                     p.functionHandles.stateControl.nextTrialState = 'penalty';
%                     p.functionHandles.stateControl.penaltyDuration = p.functionHandles.timing.trialAbortPenalty;
%                     p.functionHandles.stateControl.commitOutcome('trial abort');
%                 elseif(GetSecs-p.functionHandles.stateControl.timer(1) >= 0)
%                     p.functionHandles.stateControl.showSymbol.center = true;
%                     p.functionHandles.stateControl.nextTrialState = 'response';
%                 end
%
%             case 'response'
%
%                 %  STATE:  response
%                 %
%                 %  Now we wait for the monkey to make his response.
%                 %
%                 %  Enter this state with the cursor in the center.  Wait
%                 %  the minimum selection time and then score his response;
%                 %  if response is center, then wait for the maximum
%                 %  selection time.  If cursor is not in a response region,
%                 %  restart the minimum selection timer.
%
%                 if(p.functionHandles.stateControl.firstEntryIntoState)
%                     fprintf('Entered %s state\n',upper(p.functionHandles.stateControl.nextTrialState));
%
%                     %  Set timers for minimum and maximum selection time
%                     p.functionHandles.stateControl.timer(1) = GetSecs + p.functionHandles.timing.maxSelectionTime;
%                     p.functionHandles.stateControl.timer(2) = GetSecs + p.functionHandles.timing.minSelectionTime;
%                 elseif(~p.functionHandles.stateControl.joystickInRegion)
%
%                     %  If the monkey moves the cursour out of a reward
%                     %  region, restart the minimum selection timer.
%                     p.functionHandles.stateControl.timer(2) = GetSecs + p.functionHandles.timing.minSelectionTime;
%                 elseif((GetSecs - p.functionHandles.stateControl.timer(2) >= 0) && (~p.functionHandles.stateControl.joystickCenter || (GetSecs - p.functionHandles.stateControl.timer(1) >= 0)))
%
%                     %  Since monkey has passed through the minimum
%                     %  selection time, we know he has the cursor in a
%                     %  region.  If it's not the center, then he's made his
%                     %  choice.  If it is the center, then we have had to
%                     %  wait for the maximum selection time before declaring
%                     %  center his choice.  Now that we're here, we can
%                     %  commit the outcome of the trial.
%                     p.functionHandles.stateControl.commitOutcome;
%                     fprintf('\tMonkey chose %s\n',p.functionHandles.stateControl.response);
%                     if(p.functionHandles.stateControl.trialCorrect)
%                         if(p.functionHandles.stateControl.joystickCenter)
%
%                             %  Start giving the monkey his reward
%                             %  immediately if joystick is in center and
%                             %  there is an at-return reward and he has not
%                             %  incurred a penalty
%                             if(~p.functionHandles.controlFlags.useOvershootPenalty || ~p.functionHandles.stateControl.joystickOvershot)
%                                 p.functionHandles.stateControl.rewardUpdate(p.functionHandles.reward.maxDuration,0,0);
%                                 pds.behavior.reward.give(p,p.functionHandles.reward.maxDuration);
%                                 p.functionHandles.stateControl.timer(3) = GetSecs;
%                                 p.functionHandles.stateControl.rewardInProgress = true;
%                             end
%                             p.functionHandles.stateControl.nextTrialState = 'postHarvestDelay';
%                         else
%
%                             %  Start giving the monkey his reward
%                             %  immediately if he has joystick in region and
%                             %  there is an in-region reward and he has not
%                             %  incurred a penalty
%                             if(p.functionHandles.reward.inRegion > 0 && (~p.functionHandles.controlFlags.useOvershootPenalty || ~p.functionHandles.stateControl.joystickOvershot))
%                                 p.functionHandles.stateControl.rewardUpdate(p.functionHandles.reward.inRegion,0,0);
%                                 pds.behavior.reward.give(p,p.functionHandles.reward.inRegion);
%                                 p.functionHandles.stateControl.timer(3) = GetSecs;
%                                 p.functionHandles.stateControl.rewardInProgress = true;
%                             end
%                             p.functionHandles.stateControl.nextTrialState = 'harvestReward';
%                         end
%                     else
%                         p.functionHandles.stateControl.nextTrialState = 'error';
%                     end
%                 end
%
%             case 'error'
%
%                 %  STATE:  error
%                 %
%                 %  Monkey has incorrectly made his choice.  Give him an
%                 %  error tone, turn the cursor red, and then advance to the
%                 %  penalty phase.  Note no need to deplete reward here
%                 %  because we only update it if he got the right answer.
%
%                 if(p.functionHandles.stateControl.firstEntryIntoState)
%                     fprintf('Entered %s state\n',upper(p.functionHandles.stateControl.nextTrialState));
%                     p.functionHandles.stateControl.timer(1) = GetSecs + p.functionHandles.timing.errorDuration;
%                     p.trial.analog_stick.cursor.color = [1 0 0];
%                     p.trial.analog_stick.cursor.linewidth = 12;
%                     p.trial.analog_stick.cursor.height = 40;
%                     pds.audio.play(p,'incorrect',1);
%                     p.functionHandles.stateControl.rewardInRegionReceived = 0;
%                     p.functionHandles.stateControl.rewardAtReturnReceived = 0;
%                 elseif(GetSecs - p.functionHandles.stateControl.timer(1) >= 0)
%                     pds.audio.stop(p,'incorrect');
%                     p.functionHandles.stateControl.penaltyDuration = p.functionHandles.timing.errorPenalty;
%                     p.functionHandles.stateControl.nextTrialState = 'penalty';
%                 end
%
%             case 'harvestReward'
%
%                 %  STATE:  harvestReward
%                 %
%                 %  Monkey has correctly made his choice.  He may have begun
%                 %  to receive his reward on the last frame cycle and will
%                 %  continue to receive whatever reward is alocated for
%                 %  being in the region. Whenever the cursor is not over the
%                 %  reward region, he loses reward. He may lose all his
%                 %  reward based on some penalties assesed during this
%                 %  state; for now this is only the overshoot penalty.
%
%                 if(p.functionHandles.stateControl.firstEntryIntoState)
%                     fprintf('Entered %s state\n',upper(p.functionHandles.stateControl.nextTrialState));
%                     p.functionHandles.stateControl.timer(1) = GetSecs;
%                 end
%
%                 %  On every cycle through this state, we will need to check
%                 %  for the joystick overshoot penalty.  If he's made it,
%                 %  then drain his reward.
%                 if(p.functionHandles.controlFlags.useOvershootPenalty && p.functionHandles.stateControl.joystickOvershot)
%                     rewardRemaining = p.functionHandles.stateControl.rewardRemaining;
%                     p.functionHandles.stateControl.rewardUpdate(-rewardRemaining,0,rewardRemaining);
%                 end
%
%                 %  Monkey could still have been receiving reward, so update
%                 %  amount of reward received and elapsed in last frame
%                 %  cycle.
%                 if(p.functionHandles.stateControl.rewardRemaining > 0);
%                     elapsedReward = GetSecs - p.functionHandles.stateControl.timer(3);
%                     p.functionHandles.stateControl.timer(3) = GetSecs;
%                     if(p.functionHandles.stateControl.rewardInProgress)
%                         p.functionHandles.stateControl.rewardUpdate(-elapsedReward,elapsedReward,elapsedReward);
%                     else
%                         p.functionHandles.stateControl.rewardUpdate(-elapsedReward,0,elapsedReward);
%                     end
%                 elseif(p.functionHandles.stateControl.rewardInProgress)
%                     pds.behavior.reward.give(p,0);
%                     p.functionHandles.stateControl.rewardInProgress = false;
%                 end
%
%                 %  Based on current joystick position, determine what
%                 %  reward he should be getting in the next frame cycle
%                 if(p.functionHandles.stateControl.joystickCenter)
%
%                     %  Once he gets the cursor all the way back to center
%                     %  then shave off whatever is remaining of the
%                     %  in-region reward and go on to the post harvest
%                     %  delay.  If he has an at-return reward and he has not
%                     %  incurred a penalty, then start it here.
%                     p.functionHandles.stateControl.rewardUpdate(-p.functionHandles.stateControl.rewardRemaining,0,p.functionHandles.stateControl.rewardRemaining);
%                     if(p.functionHandles.reward.atReturn > 0 && (~p.functionHandles.controlFlags.useOvershootPenalty || ~p.functionHandles.stateControl.joystickOvershot))
%                         p.functionHandles.stateControl.rewardUpdate(p.functionHandles.reward.atReturn,0,0);
%                         pds.behavior.reward.give(p,p.functionHandles.reward.atReturn);
%                         p.functionHandles.stateControl.rewardInProgress = true;
%                     end
%                     p.functionHandles.stateControl.rewardInRegionReceived = p.functionHandles.stateControl.rewardReceived;
%                     p.functionHandles.stateControl.nextTrialState = 'postHarvestDelay';
%                 elseif(~p.functionHandles.stateControl.joystickInRewardedRegion && p.functionHandles.stateControl.rewardInProgress)
%
%                     %  If cursor is out of the rewarded region and he's
%                     %  receiving reward, then immediately stop giving him
%                     %  reward.
%                     pds.behavior.reward.give(p,0);
%                     p.functionHandles.stateControl.rewardInProgress = false;
%                 elseif(p.functionHandles.stateControl.joystickInRewardedRegion && ~p.functionHandles.stateControl.rewardInProgress && p.functionHandles.stateControl.rewardRemaining > 0)
%
%                     %  Monkey may have temporarily moved the cursor out of
%                     %  the rewarded region and then back into the rewarded
%                     %  region before reaching center.  If that's the case,
%                     %  and he still has reward to get, then restart his
%                     %  reward.
%                     pds.behavior.reward.give(p,p.functionHandles.stateControl.rewardRemaining);
%                     p.functionHandles.stateControl.rewardInProgress = true;
%                 end
%
%             case 'postHarvestDelay'
%
%                 %  STATE:  postHarvestDelay
%                 %
%                 %  After the harvest, monkey gets to look at the
%                 %  stimuli for just a moment longer.  If he is due a return
%                 %  reward, he will get it here.  Also, he only enters this
%                 %  state if the cursor is in center.  If he moves the
%                 %  cursor out of the center then he forfeits the rest of
%                 %  his reward.
%
%                 if(p.functionHandles.stateControl.firstEntryIntoState)
%                     fprintf('Entered %s state\n',upper(p.functionHandles.stateControl.nextTrialState));
%                     p.functionHandles.stateControl.timer(1) = GetSecs + p.functionHandles.timing.postRewardDelay;
%                 end
%
%                 %  Since monkey could still be receiving reward, update
%                 %  amount of reward received and elapsed in last frame
%                 %  cycle
%                 if(p.functionHandles.stateControl.rewardRemaining > 0)
%                     elapsedReward = GetSecs - p.functionHandles.stateControl.timer(3);
%                     p.functionHandles.stateControl.timer(3) = GetSecs;
%                     if(p.functionHandles.stateControl.rewardInProgress)
%                         p.functionHandles.stateControl.rewardUpdate(-elapsedReward,elapsedReward,elapsedReward);
%                     else
%                         p.functionHandles.stateControl.rewardUpdate(-elapsedReward,0,elapsedReward);
%                     end
%                 elseif(p.functionHandles.stateControl.rewardInProgress)
%                     pds.behavior.reward.give(p,0);
%                     p.functionHandles.stateControl.rewardInProgress = false;
%                 end
%
%                 %  Determine if the monkey should continue receiving reward
%                 %  on the next frame cycle.
%                 if(~p.functionHandles.stateControl.joystickCenter)
%
%                     %  If the monkey moves the joystick back out of center
%                     %  then clear his reward.
%                     p.functionHandles.stateControl.rewardUpdate(-p.functionHandles.stateControl.rewardRemaining,0,p.functionHandles.stateControl.rewardRemaining);
%                     if(p.functionHandles.stateControl.rewardInProgress)
%                         pds.behavior.reward.give(p,0);
%                         p.functionHandles.stateControl.rewardInProgress = false;
%                     end
%                 elseif(p.functionHandles.stateControl.rewardRemaining <= 0 && GetSecs - p.functionHandles.stateControl.timer(1) >= 0)
%
%                     %  If time has elapsed and monkeys got whatever reward
%                     %  he's going to get, then move on.
%                     p.functionHandles.stateControl.rewardAtReturnReceived = p.functionHandles.stateControl.rewardReceived - p.functionHandles.stateControl.rewardInRegionReceived;
%                     p.trial.flagNextTrial = true;
%                 end
%
%             case 'penalty'
%
%                 %  STATE:  penalty
%                 %
%                 %  Monkey has entered this state because he incurred a
%                 %  penalty on the trial.  Blank the screen and wait for the
%                 %  penalty to elapse.
%
%                 if(p.functionHandles.stateControl.firstEntryIntoState)
%                     fprintf('Entered %s state\n',upper(p.functionHandles.stateControl.nextTrialState));
%                     p.functionHandles.stateControl.timer(1) = GetSecs + p.functionHandles.stateControl.penaltyDuration;
%                     p.functionHandles.stateControl.showCursor = false;
%                     p.functionHandles.stateControl.showStimuli = false;
%                 elseif(GetSecs - p.functionHandles.stateControl.timer(1) >= 0)
%                     fprintf('Completed %d ms error penalty.\n',1000*p.functionHandles.stateControl.penaltyDuration);
%                     p.trial.flagNextTrial = true;
%                 end
%         end
% end
% end