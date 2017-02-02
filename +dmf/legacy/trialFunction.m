function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION FILE
%  PACKAGE:  dmf

%
%  Custom defined state-dependent steps
%

%  **  ISSUES TO CONSIDER

%  ** The function adjustable_parameters can be edited during a pause in
%  the task in order to change parameters between trials.
%  dmf.adjustable_parameters(p);

%  ** Create a more contained performance tracking Remember that each trial
%  is stored as an element of the cell array p.data so anything you put
%  into p.trial will be saved, for example p.trial.outcome

switch state
    
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        %  Experiment post open screen--executed once after screen has been
        %  opened.
        
        %  Generate symbol textures at beginning of experiment (we can only
        %  do this once we have the display pointer, and we only need do it
        %  this one time)
        p.functionHandles.symbolTextures = dmf.generateSymbolTextures(p);        
        fprintf(1,'****************************************************************\n');
        fprintf(1,'Generated %d symbol textures.\n',length(p.functionHandles.symbolTextures));
        fprintf(1,'****************************************************************\n');        
        
    case p.trial.pldaps.trialStates.trialSetup
        %  Trial Setup, for example starting up Datapixx ADC and allocating
        %  memory
        %
        %  This is where we would perform any steps that needed to be done
        %  before a trial is started, for example preparing stimuli
        %  parameters
        
        %  If this is the first trial, then set the trial indexing to 1.
        if(p.trial.pldaps.iTrial == 1)
            p.functionHandles.trialIndex = 1;
            p.functionHandles.nTotalTrials = 0;
            p.functionHandles.nCorrectTrials = 0;
            p.functionHandles.nCompletedTrials = 0;
        end
        
        %  Condition from cell array
        p.trial.condition = p.conditions{p.functionHandles.trialIndex};
        
%         %  Calculations which will be required in state variable initiation
%         if(p.functionHandles.controlFlags.useRandomDisplacement)
%             p.functionHandles.displacement = unifrnd(p.functionHandles.geometry.minDisplacement,p.functionHandles.geometry.maxDisplacement);
%         else
%             p.functionHandles.displacement = p.functionHandles.geometry.displacement;
%         end
        
        %  Initialize trial state variables
        p.functionHandles.stateVariables = dmf.stateVariables(p);
        
        %  Echo trial specs to screen
        fprintf('TRIAL %d:\n',p.trial.pldaps.iTrial);
        for pos = {'left','center','right'}
            if(p.functionHandles.stateVariables.displayPosition.(pos{:}))
                color = p.trial.condition.symbol.(pos{:}).color;
                pattern = p.trial.condition.symbol.(pos{:}).pattern;
                shape = p.trial.condition.symbol.(pos{:}).shape;
                
                fprintf('    Symbol at %6s:  %s %s %s\n',pos{:},color,pattern,shape);
            end
        end
        fprintf('  Response direction:  %s\n',p.trial.condition.rewardedResponse);
        fprintf('          Match type:  %s\n',p.trial.condition.matchType);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        %
        %  Perform any steps that should happen upon completion of a trial
        %  such as performance tracking and trial index updating.
        
        p.functionHandles.nTotalTrials = p.functionHandles.nTotalTrials + 1;
        p.functionHandles.nCompletedTrials = p.functionHandles.nCompletedTrials + p.functionHandles.stateVariables.trialCompleted;
        
        if(p.functionHandles.stateVariables.trialCompleted)
            p.functionHandles.nCorrectTrials = p.functionHandles.nCorrectTrials + p.functionHandles.stateVariables.trialCorrect;
            p.functionHandles.performance.update(p.trial.condition.matchType,p.functionHandles.stateVariables.response,p.functionHandles.stateVariables.trialCorrect);
        end
        
        if(p.functionHandles.stateVariables.trialCorrect)
            fprintf('Monkey''s first choice, %s, was correct.\n',p.functionHandles.stateVariables.response);
            p.functionHandles.trialIndex = p.functionHandles.trialIndex + p.functionHandles.stateVariables.trialCompleted;
        else
            if(p.functionHandles.stateVariables.trialCompleted)
                fprintf('Monkey''s first first choice, %s, was incorrect; ',p.functionHandles.stateVariables.response);
                if(unifrnd(0,1) < p.functionHandles.controlFlags.repeatErrorTrialLikelihood)
                    fprintf('monkey will repeat this trial.\n');
                else
                    fprintf('monkey will not repeat this trial.\n');
                    p.functionHandles.trialIndex = p.functionHandles.trialIndex + p.functionHandles.stateVariables.trialCompleted;
                end
            else
                fprintf('Monkey did not complete the trial; monkey will repeat this trial.\n');
            end
        end
        
        fprintf('Monkey received %0.2f of possible %0.2f in-region reward\n',p.functionHandles.stateVariables.rewardInRegionReceived,p.functionHandles.reward.inRegion);
        
        if(p.functionHandles.controlFlags.useReturnReward)
            fprintf('Monkey received %0.2f of possible %0.2f return reward!\n',p.functionHandles.stateVariables.rewardAtReturnReceived,p.functionHandles.reward.atReturn);
        end
        fprintf('\n');
        fprintf('Current performance:\n');
        fprintf('\t%d completed trials of %d total trials\n',p.functionHandles.nCompletedTrials,p.functionHandles.nTotalTrials);
        fprintf('\t%d correct of %d completed trials (%0.2f)\n',p.functionHandles.nCorrectTrials,p.functionHandles.nCompletedTrials,p.functionHandles.nCorrectTrials/p.functionHandles.nCompletedTrials);
        
        fprintf('\n');
        p.functionHandles.performance.show;
        fprintf('\n');
        
        
        %
        %  FRAME STATES
        %
        
    case p.trial.pldaps.trialStates.frameDraw
        %  Final image has been calculated and will now be drawn
        %
        %  This is where all calls to Screen should be done.
        %
        %  *** It might make sense to make all PsychPortAudio
        %  calls here as well.
%         p.functionHandles.analogStick.screenXPosition = screenX;
%             p.functionHandles.analogStick.screenYPosition = screenY

%Screen('DrawTexture',p.trial.display.ptr,p.functionHandles.symbolTextures(mod(p.trial.pldaps.iTrial,27)+1));
        
%  For now I don't think I need to make this customizable
center = p.functionHandles.geometry.center;
extent = p.functionHandles.geometry.extent;
[screenX,screenY] = analogStick.getScreenPosition(normX,0,center,extent);
analogStick.drawCursor(p,p.trial.display.ptr,[screenX screenY]);

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
        %         if(p.functionHandles.stateVariables.showStimuli)
        %             pos = {'left','center','right'};
        %             ix = zeros(3,1);
        %             for pos = {'left','center','right'}
        %
        %             end
        %         end
        %                 %  Show symbols
        %                 if(p.functionHandles.stateVariables.showSymbol.(pos{:}))
        %                     color = p.trial.display.colors.(p.trial.condition.symbol.(pos{:}).color);
        %                     shape = p.trial.condition.symbol.(pos{:}).shape;
        %                     mask = p.trial.condition.symbol.(pos{:}).mask;
        %                     p.functionHandles.drawingFunctions.drawShape(p.trial.display.ptr,xpos.(pos{:}),ypos,color,shape);
        %                      p.functionHandles.drawingFunctions.applyMask(p.trial.display.ptr,xpos.(pos{:}),ypos,mask)
        %                 end
        %
        %                 %  Show reward regions
        %                 if(p.functionHandles.controlFlags.useRewardRegions)
        %                     selected = p.functionHandles.controlFlags.useSelectionColorChange && p.functionHandles.stateVariables.trialCorrect && p.functionHandles.stateVariables.rewardedResponse.(pos{:});
        %                     p.functionHandles.drawingFunctions.drawRewardRegion(p.trial.display.ptr,xpos.(pos{:}),ypos,selected);
        %                 end
        
        %                     if(p.functionHandles.controlFlags.useSelectionColorChange && strcmp(pos,'center') && p.functionHandles.controlFlags.useCenterRewardRegion && p.functionHandles.controlFlags.useCenterSelectionTimer)
        %                         arcAngle = 360*max(0,min(1,(GetSecs-p.functionHandles.stateVariables.timer(1))/p.functionHandles.timing.maxSelectionTime));
        %                     elseif(p.functionHandles.controlFlags.useSelectionColorChange && (strcmp(pos,'center') && p.functionHandles.controlFlags.useCenterRewardRegion || ~strcmp(pos,'center')))
        %                         arcAngle = 360*(p.functionHandles.stateVariables.trialCorrect && p.functionHandles.stateVariables.rewardedResponse.(pos{:}));
        %                     else
        %                         arcAngle = 0;
        %                     end
        %                 end
        
        %  Show reward indicator as secondary reinforcer
        %                 if(p.functionHandles.controlFlags.useRewardIndicator)
        %                     if(~p.functionHandles.stateVariables.trialCompleted || (p.functionHandles.stateVariables.trialCorrect && p.functionHandles.stateVariables.rewardedResponse.(pos{:})))
        %                         reinforcerRatio = max(0,min(1,1-p.functionHandles.stateVariables.rewardElapsed/p.functionHandles.reward.maxDuration));
        %                     elseif(~p.functionHandles.stateVariables.trialCorrect && p.functionHandles.stateVariables.rewardedResponse.(pos{:}))
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
        
        %  Draw the cursor
        %         if(p.functionHandles.stateVariables.showCursor)
        %             analog_stick.drawCursor(p);
        %         end
        
        %  *******
        %  once you start putting a fixation spot in, you'll want to draw
        %  that last if you want it to be visible at all times!
        %  *******
        
    case p.trial.pldaps.trialStates.frameDrawingFinished
        %  Here we could do any steps that need to be done immediately
        %  prior to the flip.
        
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update is called once after the last frame is done (or
        %  even before).  Get current eyepostion, cursor position,
        %  keypresses, joystick position, etc. in preparation for the
        %  subsequent frame cycle.
        
        %  Update state variables related to joystick position
        p.functionHandles.stateVariables.update(p);
        
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control (just don't actually make the Screen calls
        %  here).
        
        %  Make sure we haven't accidentally over-run the data buffer.
        %  Also, stop any tones you might have started.
        if(p.trial.ttime >= p.trial.pldaps.maxTrialLength-p.trial.display.ifi)
            p.trial.flagNextTrial = true;
            p.trial.analog_stick.cursor.color = [0 0 0];
            p.trial.analog_stick.cursor.linewidth = 6;
            p.trial.analog_stick.cursor.height = 20;
            pds.audio.stop(p,'incorrect');
            pds.audio.stop(p,'joystick_warning');
            fprintf('Monkey timed out...\n');
            p.functionHandles.stateVariables.commitOutcome('time out');
        end
        
        %  Control trial progress with trial state variables
        switch p.functionHandles.stateVariables.nextState
            
            case 'start'
                
                %  STATE:  start
                %
                %  First state we enter at the beginning of a trial.
                %  Monkey will have to wait briefly before symbols appear
                %  and in that time must leave the joystick in the center
                %  position.  Otherwise, we go to joystick warning.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    p.functionHandles.stateVariables.showCursor = true;
                    p.trial.analog_stick.cursor.color = [0 0 0];
                    p.trial.analog_stick.cursor.linewidth = 6;
                    p.trial.analog_stick.cursor.height = 20;
                    p.functionHandles.stateVariables.timer(1) = GetSecs + unifrnd(p.functionHandles.timing.minStartDelay,p.functionHandles.timing.maxStartDelay);
                elseif(GetSecs - p.functionHandles.stateVariables.timer(1) >= 0)
                    
                    %  Set the reward here--we're starting the trial!
                    p.functionHandles.stateVariables.rewardUpdate(p.functionHandles.reward.maxDuration,0,0);
                    p.functionHandles.stateVariables.nextState = 'symbols';
                elseif(~p.functionHandles.stateVariables.joystickCenter)
                    p.functionHandles.stateVariables.nextState = 'joystickWarning';
                end
                
            case 'joystickWarning'
                
                %  STATE:  joystickWarning
                %
                %  Trial enters this state if monkey does not have the
                %  joystick at the rest position when the trial starts.
                %  Proceed back to start once he has returned the joystick
                %  to the center position.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    p.trial.analog_stick.cursor.color = [1 0 0];
                    p.trial.analog_stick.cursor.linewidth = 12;
                    p.trial.analog_stick.cursor.height = 40;
                    pds.audio.play(p,'joystick_warning',Inf);
                elseif(p.functionHandles.stateVariables.joystickCenter)
                    fprintf('Joystick back at center.\n');
                    pds.audio.stop(p,'joystick_warning');
                    p.trial.analog_stick.cursor.color = [0 0 0];
                    p.trial.analog_stick.cursor.linewidth = 6;
                    p.trial.analog_stick.cursor.height = 20;
                    p.functionHandles.stateVariables.nextState = 'start';
                end
                
            case 'symbols'
                
                %  STATE:  symbols
                %
                %  Show the symbols until delay elapsed and as long as he
                %  has joystick at center position.  If he moves the
                %  joystick too early, go to abort penalty.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    p.functionHandles.stateVariables.showStimuli = true;
                    p.functionHandles.stateVariables.timer(1) = GetSecs + p.functionHandles.timing.interSymbolInterval;
                    p.functionHandles.stateVariables.showSymbol.left = p.functionHandles.stateVariables.displayPosition.left;
                    p.functionHandles.stateVariables.showSymbol.right = p.functionHandles.stateVariables.displayPosition.right;
                    p.functionHandles.stateVariables.showSymbol.center = ~p.functionHandles.controlFlags.useInterSymbolInterval && p.functionHandles.stateVariables.displayPosition.center;
                elseif(~p.functionHandles.stateVariables.joystickCenter)
                    p.functionHandles.stateVariables.nextState = 'penalty';
                    p.functionHandles.stateVariables.penaltyDuration = p.functionHandles.timing.trialAbortPenalty;
                    p.functionHandles.stateVariables.commitOutcome('trial abort');
                elseif(GetSecs-p.functionHandles.stateVariables.timer(1) >= 0)
                    p.functionHandles.stateVariables.showSymbol.center = true;
                    p.functionHandles.stateVariables.nextState = 'response';
                end
                
            case 'response'
                
                %  STATE:  response
                %
                %  Now we wait for the monkey to make his response.
                %
                %  Enter this state with the cursor in the center.  Wait
                %  the minimum selection time and then score his response;
                %  if response is center, then wait for the maximum
                %  selection time.  If cursor is not in a response region,
                %  restart the minimum selection timer.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    
                    %  Set timers for minimum and maximum selection time
                    p.functionHandles.stateVariables.timer(1) = GetSecs + p.functionHandles.timing.maxSelectionTime;
                    p.functionHandles.stateVariables.timer(2) = GetSecs + p.functionHandles.timing.minSelectionTime;
                elseif(~p.functionHandles.stateVariables.joystickInRegion)
                    
                    %  If the monkey moves the cursour out of a reward
                    %  region, restart the minimum selection timer.
                    p.functionHandles.stateVariables.timer(2) = GetSecs + p.functionHandles.timing.minSelectionTime;
                elseif((GetSecs - p.functionHandles.stateVariables.timer(2) >= 0) && (~p.functionHandles.stateVariables.joystickCenter || (GetSecs - p.functionHandles.stateVariables.timer(1) >= 0)))
                    
                    %  Since monkey has passed through the minimum
                    %  selection time, we know he has the cursor in a
                    %  region.  If it's not the center, then he's made his
                    %  choice.  If it is the center, then we have had to
                    %  wait for the maximum selection time before declaring
                    %  center his choice.  Now that we're here, we can
                    %  commit the outcome of the trial.
                    p.functionHandles.stateVariables.commitOutcome;
                    fprintf('\tMonkey chose %s\n',p.functionHandles.stateVariables.response);
                    if(p.functionHandles.stateVariables.trialCorrect)
                        if(p.functionHandles.stateVariables.joystickCenter)
                            
                            %  Start giving the monkey his reward
                            %  immediately if joystick is in center and
                            %  there is an at-return reward and he has not
                            %  incurred a penalty
                            if(~p.functionHandles.controlFlags.useOvershootPenalty || ~p.functionHandles.stateVariables.joystickOvershot)
                                p.functionHandles.stateVariables.rewardUpdate(p.functionHandles.reward.maxDuration,0,0);
                                pds.behavior.reward.give(p,p.functionHandles.reward.maxDuration);
                                p.functionHandles.stateVariables.timer(3) = GetSecs;
                                p.functionHandles.stateVariables.rewardInProgress = true;
                            end
                            p.functionHandles.stateVariables.nextState = 'postHarvestDelay';
                        else
                            
                            %  Start giving the monkey his reward
                            %  immediately if he has joystick in region and
                            %  there is an in-region reward and he has not
                            %  incurred a penalty
                            if(p.functionHandles.reward.inRegion > 0 && (~p.functionHandles.controlFlags.useOvershootPenalty || ~p.functionHandles.stateVariables.joystickOvershot))
                                p.functionHandles.stateVariables.rewardUpdate(p.functionHandles.reward.inRegion,0,0);
                                pds.behavior.reward.give(p,p.functionHandles.reward.inRegion);
                                p.functionHandles.stateVariables.timer(3) = GetSecs;
                                p.functionHandles.stateVariables.rewardInProgress = true;
                            end
                            p.functionHandles.stateVariables.nextState = 'harvestReward';
                        end
                    else
                        p.functionHandles.stateVariables.nextState = 'error';
                    end
                end
                
            case 'error'
                
                %  STATE:  error
                %
                %  Monkey has incorrectly made his choice.  Give him an
                %  error tone, turn the cursor red, and then advance to the
                %  penalty phase.  Note no need to deplete reward here
                %  because we only update it if he got the right answer.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    p.functionHandles.stateVariables.timer(1) = GetSecs + p.functionHandles.timing.errorDuration;
                    p.trial.analog_stick.cursor.color = [1 0 0];
                    p.trial.analog_stick.cursor.linewidth = 12;
                    p.trial.analog_stick.cursor.height = 40;
                    pds.audio.play(p,'incorrect',1);
                    p.functionHandles.stateVariables.rewardInRegionReceived = 0;
                    p.functionHandles.stateVariables.rewardAtReturnReceived = 0;
                elseif(GetSecs - p.functionHandles.stateVariables.timer(1) >= 0)
                    pds.audio.stop(p,'incorrect');
                    p.functionHandles.stateVariables.penaltyDuration = p.functionHandles.timing.errorPenalty;
                    p.functionHandles.stateVariables.nextState = 'penalty';
                end
                
            case 'harvestReward'
                
                %  STATE:  harvestReward
                %
                %  Monkey has correctly made his choice.  He may have begun
                %  to receive his reward on the last frame cycle and will
                %  continue to receive whatever reward is alocated for
                %  being in the region. Whenever the cursor is not over the
                %  reward region, he loses reward. He may lose all his
                %  reward based on some penalties assesed during this
                %  state; for now this is only the overshoot penalty.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    p.functionHandles.stateVariables.timer(1) = GetSecs;
                end
                
                %  On every cycle through this state, we will need to check
                %  for the joystick overshoot penalty.  If he's made it,
                %  then drain his reward.
                if(p.functionHandles.controlFlags.useOvershootPenalty && p.functionHandles.stateVariables.joystickOvershot)
                    rewardRemaining = p.functionHandles.stateVariables.rewardRemaining;
                    p.functionHandles.stateVariables.rewardUpdate(-rewardRemaining,0,rewardRemaining);
                end
                
                %  Monkey could still have been receiving reward, so update
                %  amount of reward received and elapsed in last frame
                %  cycle.
                if(p.functionHandles.stateVariables.rewardRemaining > 0);
                    elapsedReward = GetSecs - p.functionHandles.stateVariables.timer(3);
                    p.functionHandles.stateVariables.timer(3) = GetSecs;
                    if(p.functionHandles.stateVariables.rewardInProgress)
                        p.functionHandles.stateVariables.rewardUpdate(-elapsedReward,elapsedReward,elapsedReward);
                    else
                        p.functionHandles.stateVariables.rewardUpdate(-elapsedReward,0,elapsedReward);
                    end
                elseif(p.functionHandles.stateVariables.rewardInProgress)
                    pds.behavior.reward.give(p,0);
                    p.functionHandles.stateVariables.rewardInProgress = false;
                end
                
                %  Based on current joystick position, determine what
                %  reward he should be getting in the next frame cycle
                if(p.functionHandles.stateVariables.joystickCenter)
                    
                    %  Once he gets the cursor all the way back to center
                    %  then shave off whatever is remaining of the
                    %  in-region reward and go on to the post harvest
                    %  delay.  If he has an at-return reward and he has not
                    %  incurred a penalty, then start it here.
                    p.functionHandles.stateVariables.rewardUpdate(-p.functionHandles.stateVariables.rewardRemaining,0,p.functionHandles.stateVariables.rewardRemaining);
                    if(p.functionHandles.reward.atReturn > 0 && (~p.functionHandles.controlFlags.useOvershootPenalty || ~p.functionHandles.stateVariables.joystickOvershot))
                        p.functionHandles.stateVariables.rewardUpdate(p.functionHandles.reward.atReturn,0,0);
                        pds.behavior.reward.give(p,p.functionHandles.reward.atReturn);
                        p.functionHandles.stateVariables.rewardInProgress = true;
                    end
                    p.functionHandles.stateVariables.rewardInRegionReceived = p.functionHandles.stateVariables.rewardReceived;
                    p.functionHandles.stateVariables.nextState = 'postHarvestDelay';
                elseif(~p.functionHandles.stateVariables.joystickInRewardedRegion && p.functionHandles.stateVariables.rewardInProgress)
                    
                    %  If cursor is out of the rewarded region and he's
                    %  receiving reward, then immediately stop giving him
                    %  reward.
                    pds.behavior.reward.give(p,0);
                    p.functionHandles.stateVariables.rewardInProgress = false;
                elseif(p.functionHandles.stateVariables.joystickInRewardedRegion && ~p.functionHandles.stateVariables.rewardInProgress && p.functionHandles.stateVariables.rewardRemaining > 0)
                    
                    %  Monkey may have temporarily moved the cursor out of
                    %  the rewarded region and then back into the rewarded
                    %  region before reaching center.  If that's the case,
                    %  and he still has reward to get, then restart his
                    %  reward.
                    pds.behavior.reward.give(p,p.functionHandles.stateVariables.rewardRemaining);
                    p.functionHandles.stateVariables.rewardInProgress = true;
                end
                
            case 'postHarvestDelay'
                
                %  STATE:  postHarvestDelay
                %
                %  After the harvest, monkey gets to look at the
                %  stimuli for just a moment longer.  If he is due a return
                %  reward, he will get it here.  Also, he only enters this
                %  state if the cursor is in center.  If he moves the
                %  cursor out of the center then he forfeits the rest of
                %  his reward.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    p.functionHandles.stateVariables.timer(1) = GetSecs + p.functionHandles.timing.postRewardDelay;
                end
                
                %  Since monkey could still be receiving reward, update
                %  amount of reward received and elapsed in last frame
                %  cycle
                if(p.functionHandles.stateVariables.rewardRemaining > 0)
                    elapsedReward = GetSecs - p.functionHandles.stateVariables.timer(3);
                    p.functionHandles.stateVariables.timer(3) = GetSecs;
                    if(p.functionHandles.stateVariables.rewardInProgress)
                        p.functionHandles.stateVariables.rewardUpdate(-elapsedReward,elapsedReward,elapsedReward);
                    else
                        p.functionHandles.stateVariables.rewardUpdate(-elapsedReward,0,elapsedReward);
                    end
                elseif(p.functionHandles.stateVariables.rewardInProgress)
                    pds.behavior.reward.give(p,0);
                    p.functionHandles.stateVariables.rewardInProgress = false;
                end
                
                %  Determine if the monkey should continue receiving reward
                %  on the next frame cycle.
                if(~p.functionHandles.stateVariables.joystickCenter)
                    
                    %  If the monkey moves the joystick back out of center
                    %  then clear his reward.
                    p.functionHandles.stateVariables.rewardUpdate(-p.functionHandles.stateVariables.rewardRemaining,0,p.functionHandles.stateVariables.rewardRemaining);
                    if(p.functionHandles.stateVariables.rewardInProgress)
                        pds.behavior.reward.give(p,0);
                        p.functionHandles.stateVariables.rewardInProgress = false;
                    end
                elseif(p.functionHandles.stateVariables.rewardRemaining <= 0 && GetSecs - p.functionHandles.stateVariables.timer(1) >= 0)
                    
                    %  If time has elapsed and monkeys got whatever reward
                    %  he's going to get, then move on.
                    p.functionHandles.stateVariables.rewardAtReturnReceived = p.functionHandles.stateVariables.rewardReceived - p.functionHandles.stateVariables.rewardInRegionReceived;
                    p.trial.flagNextTrial = true;
                end
                
            case 'penalty'
                
                %  STATE:  penalty
                %
                %  Monkey has entered this state because he incurred a
                %  penalty on the trial.  Blank the screen and wait for the
                %  penalty to elapse.
                
                if(p.functionHandles.stateVariables.firstEntryIntoState)
                    fprintf('Entered %s state\n',upper(p.functionHandles.stateVariables.nextState));
                    p.functionHandles.stateVariables.timer(1) = GetSecs + p.functionHandles.stateVariables.penaltyDuration;
                    p.functionHandles.stateVariables.showCursor = false;
                    p.functionHandles.stateVariables.showStimuli = false;
                elseif(GetSecs - p.functionHandles.stateVariables.timer(1) >= 0)
                    fprintf('Completed %d ms error penalty.\n',1000*p.functionHandles.stateVariables.penaltyDuration);
                    p.trial.flagNextTrial = true;
                end
        end
end
end