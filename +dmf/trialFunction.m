function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION FILE
%  PACKAGE:  dmf

%  Training on the DMF task

switch state
    
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        %  experimentPostOpenScreen--executed once after screen has been
        %  opened.
        
        %flowControl;
        
    case p.trial.pldaps.trialStates.trialSetup
        
        %  trialSetup--this is where we would perform any steps that needed
        %  to be done before a trial is started, for example preparing
        %  stimuli parameters
        
        %ListenChar(1);
        
        %
        %  Reward
        %
        p.trial.parameters.timing.rewardDuration = 0.4;
        
        %
        %  Time intervals
        %
        
        %  Reward
        p.trial.parameters.timing.rewardDelay = 0.3;
        
        %  Intertrial interval
        p.trial.parameters.timing.intertrialIntervalFixed = 1;
        p.trial.parameters.timing.meanIntertrialDelta = 0.5;
        
        %  Interval between stimulus presentations
        p.trial.parameters.timing.sampleInterval = 1;
        p.trial.parameters.timing.sampleDuration = 1;
        
        %  Analog stick release
        p.trial.parameters.timing.releaseDelay = 0.1;
        p.trial.parameters.timing.releaseInterval = 0.5;
        
        %  Fixation grace
        p.trial.parameters.timing.fixationGracePeriod = 0.5;
        
        %  Sample stimulus onset with respect to start of engage interval
        p.trial.parameters.timing.sampleRelativeOnset = 0.5;
        
        %  Probe stimulus onset with respect to end of engage interval
        p.trial.parameters.timing.probeRelativeOnset = 0.8;
        
        %  Penalty duration
        p.trial.parameters.timing.penaltyDurationFixed = 4;
        p.trial.parameters.timing.meanPenaltyDelta = 0.5;
        
        %
        %  Geometry
        %
        
        %  Visual stimuli
        p.trial.parameters.geometry.fixDiameter = 25;
        p.trial.parameters.geometry.fixBorder = 8;
        
        %  Fixation window width
        p.trial.parameters.geometry.fixWindowWidth = 400;
        
        %  Symbol radius
        p.trial.parameters.geometry.symbolRadius = 175;
        
        
        %
        %  Get condition for upcoming trial
        %
        
        p.trial.condition = p.conditions{p.trial.pldaps.iTrial};
        
        
        %
        %  Setup for trial based on p.trial.parameters
        %
        
        %  Windowing
        
        %  Update fixation window
        w = p.trial.parameters.geometry.fixWindowWidth;
        fixWindow = [p.trial.display.ctr(1)+0.5*[-w w] p.trial.display.ctr(2)+0.5*[-w w]];
        p.functionHandles.windowManagerObj.eye.add('fixation',fixWindow);
        
        %
        %  Set timing based on user updated parameters
        %
        
        fields = fieldnames(p.trial.parameters.timing);
        for i=1:numel(fields)
            p.trial.timing.(fields{i}) = p.trial.parameters.timing.(fields{i});
        end
        
        %  Upcoming intertrial interval
        maxIntertrialDelta = 4*p.trial.parameters.timing.meanIntertrialDelta;
        p.trial.timing.intertrialInterval = ...
            p.trial.timing.intertrialIntervalFixed + ...
            min(maxIntertrialDelta,exprnd(p.trial.timing.meanIntertrialDelta));
        
        %  Potential penalty
        maxPenaltyDelta = 4*p.trial.parameters.timing.meanPenaltyDelta;
        p.trial.timing.penaltyDuration = ...
            p.trial.timing.penaltyDurationFixed + ...
            min(maxPenaltyDelta,exprnd(p.trial.timing.meanPenaltyDelta));
        
        p.trial.timing.dutyCycle = p.trial.timing.sampleDuration + p.trial.timing.sampleInterval;
        p.trial.timing.probeOverlap = p.trial.timing.probeRelativeOnset + p.trial.timing.releaseDelay;
        p.trial.timing.engageInterval = p.trial.timing.sampleRelativeOnset + ...
            p.trial.timing.dutyCycle * (numel(p.trial.condition.vertices)-1) + ...
            p.trial.timing.probeOverlap;
        p.trial.timing.releaseDuration = p.trial.timing.releaseInterval + p.trial.timing.releaseDelay + p.trial.timing.penaltyDuration;
        
        %  Set up task state control for the upcoming trial
        p.functionHandles.stateControlObj.trialSetup;
        
        %  Specify starting state
        if(p.trial.pldaps.iTrial==1)
            p.functionHandles.stateControlObj.nextState('state','start');
        else
            p.functionHandles.stateControlObj.nextState('state','intertrial','duration',...
                p.trial.timing.intertrialInterval - p.functionHandles.stateControlObj.elapsedTime);
        end
        
        %  Set up state variables for upcoming trial
        p.functionHandles.stateVariablesObj = stateVariables(...
            'engageCueOn',false,...
            'releaseCueOn',false,...
            'rewardCueOn',false,...
            'penaltyCueOn',false,...
            'stimulusOn',false,...
            'stimulusIndx',1,...
            'numStimuli',numel(p.trial.condition.vertices),...
            'probeOnset',[],...
            'releaseCueOnset',[]);
        
        %  Set up trial outcome variable
        p.functionHandles.trialOutcomeObj = trialOutcome(...
            'trialCompleted',false,...
            'trialRewarded',false,...
            'hit',false,...
            'miss',false,...
            'falseAlarm',false,...
            'correctReject',false,...
            'reactionTime',[],...
            'earlyAbort',false,...
            'fixationBreak',false,...
            'lateAbort',false,...
            'userInterrupt',false,...
            'trialTimedOut',false);
        
        %  Generate symbol textures for upcoming trial
        p.functionHandles.symbolsObj.radius = p.trial.parameters.geometry.symbolRadius;
        p.functionHandles.symbolsObj.getSymbolTextures(...
            p.trial.condition.vertices,...
            p.trial.condition.colors,...
            p.trial.condition.fills);
        
        %  Echo trial specifications to screen
        fprintf('This is trial attempt %d of %d; block %d of %d\n',p.trial.pldaps.iTrial,p.trial.pldaps.finish,p.trial.condition.block(1),p.trial.condition.block(2));
        fprintf(' - This is a <strong>%s</strong> trial\n',upper(p.trial.condition.type));
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        %  cleanUpandSave--post trial management; perform any steps that
        %  should happen upon completion of a trial such as performance
        %  tracking and trial index updating.
        
        %  Determine if trial was interrupted
        if(p.trial.pldaps.quit~=0)
            p.functionHandles.trialOutcomeObj.userInterrupt = true;
        end
        
        %  Record trial outcome
        p.trial.outcome = p.functionHandles.trialOutcomeObj.struct;
        
        fprintf('End trial.\n\n');
        
        %  Check run termination criteria
        %         if(p.trial.pldaps.quit == 0)
        %             p.trial.pldaps.quit = p.functionHandles.trialManagerObj.checkRunTerminationCriteria;
        %         else
        %             %  Write performance to screen
        %             p.functionHandles.performanceTrackingObj.output;
        %             fprintf('\n');
        %         end
        
        
        %
        %         %  Capture data for this trial
        %         p.trial.trialRecord.stateTransitionLog = p.functionHandles.stateVariables.transitionLog;
        %         if(p.trial.pldaps.quit~=0)
        %             if(p.trial.pldaps.quit~=2)
        %                 p.functionHandles.trialOutcomeObj.recordInterrupt(...
        %                     'interruptMessage','trialPaused');
        %             else
        %                 p.functionHandles.trialOutcomeObj.recordInterrupt(...
        %                     'interruptMessage','pldapsQuit');
        %             end
        %         end
        %         p.trial.trialRecord.outcome = p.functionHandles.trialOutcomeObj.commit;
        %         fprintf('\n');
        %
        %         %  Track performance
        %         p.functionHandles.performanceTrackingObj.update(p.functionHandles.trialOutcomeObj);
        %
        %         %  Update trial manager if trial completed; if trial aborted or
        %         %  interrupted, repeat it.
        %         if(p.functionHandles.trialOutcomeObj.trialCompleted)
        %             if(~p.functionHandles.trialManagerObj.inCorrectionLoop)
        %
        %                 %  Write performance to screen
        %                 p.functionHandles.performanceTrackingObj.output;
        %                 fprintf('\n');
        %
        %                 %  Check correction loop entry
        %                 p.functionHandles.trialManagerObj.checkCorrectionLoopEntry(p.functionHandles.trialOutcomeObj.correct);
        %                 if(p.functionHandles.trialManagerObj.inCorrectionLoop)
        %                     fprintf('Entering correction loop for %stokenized trials\n',sprintf('%s ',p.functionHandles.trialManagerObj.correctionLoopTokens{:}));
        %                 end
        %             else
        %
        %                 %  Check correction loop exit
        %                 p.functionHandles.trialManagerObj.checkCorrectionLoopExit(p.functionHandles.trialOutcomeObj.correct);
        %                 if(p.functionHandles.trialManagerObj.inCorrectionLoop)
        %                     fprintf('Continue correction loop.\n');
        %                 else
        %                     fprintf('Monkey made a correct responses; exit correction loop.\n');
        %                 end
        %             end
        %         else
        %             fprintf('Trial aborted or interrupted.\n');
        %             p.functionHandles.trialManagerObj.repeatTrial;
        %         end
        %         fprintf('\n');
        %
        %         %  Check run termination criteria
        %         if(p.trial.pldaps.quit == 0)
        %             p.trial.pldaps.quit = p.functionHandles.trialManagerObj.checkRunTerminationCriteria;
        %         else
        %             %  Write performance to screen
        %             p.functionHandles.performanceTrackingObj.output;
        %             fprintf('\n');
        %         end
        %
        %%%%%%%%%%%%%%%%%%
        %  FRAME STATES  %
        %%%%%%%%%%%%%%%%%%
        
    case p.trial.pldaps.trialStates.frameDraw
        %  frameDraw--final image has been calculated and will now be
        %  drawn. This is where all calls to Screen should be done.  Also,
        %  if there is a call to a function calling Screen, put it here!
        
        %  Control display with state variables
        
        %  Display symbols
        if(p.functionHandles.stateVariablesObj.stimulusOn)
            p.functionHandles.symbolsObj.drawSymbols(p.functionHandles.stateVariablesObj.stimulusIndx);
        end
        
        %  Display cue
        D = p.trial.parameters.geometry.fixDiameter;
        b = p.trial.parameters.geometry.fixBorder;
        if(p.functionHandles.stateVariablesObj.engageCueOn)
            Screen('DrawDots',p.trial.display.ptr,[0 0 ; 0 0],[D+b D],[0 0 0; 1 0 0]',p.trial.display.ctr(1:2),2);
        elseif(p.functionHandles.stateVariablesObj.releaseCueOn)
            Screen('DrawDots',p.trial.display.ptr,[0 0 ; 0 0],[D+b D],[0 0 0; 0 1 0]',p.trial.display.ctr(1:2),2);
        elseif(p.functionHandles.stateVariablesObj.rewardCueOn)
            Screen('DrawDots',p.trial.display.ptr,[0 0 ; 0 0],[D+b D],[0 0 0; 0 0 1]',p.trial.display.ctr(1:2),2);
        elseif(p.functionHandles.stateVariablesObj.penaltyCueOn)
            Screen('DrawDots',p.trial.display.ptr,[0 0 ; 0 0],[D+b D],[0 0 0; 0 0 0]',p.trial.display.ctr(1:2),2);
        end
        
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
        
        %  Control trial progress with task states
        switch p.functionHandles.stateControlObj.state
            
            case 'intertrial'
                
                %  Intertrial interval.  Start with this on all trials but
                %  the first so that we can subtract off any overhead from
                %  trial management to achieve the intended interval.
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state.\n',p.functionHandles.stateControlObj.state);
                    if(p.functionHandles.stateControlObj.remainingTime > 0)
                        fprintf(' - Monkey must wait for an additional %0.2f sec until this trial starts.\n',p.functionHandles.stateControlObj.remainingTime);
                    end
                end
                
                %  Conditional control for state transition
                if(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Intertrial interval complete.\n');
                    p.functionHandles.stateControlObj.nextState('state','start');
                end
                
            case 'start'
                
                %  Wait for monkey to release analog stick so that we can
                %  move on to ready state.
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state.\n',p.functionHandles.stateControlObj.state);
                    if(~p.functionHandles.windowManagerObj.analogStick.in('neutral'))
                        fprintf(' - Monkey must release analog stick before trial can begin.\n');
                    end
                elseif(p.trial.ttime >= p.trial.pldaps.maxTrialLength)
                    fprintf(' - Monkey timed out; abort trial.\n');
                    p.functionHandles.trialOutcomeObj.trialTimedOut = true;
                    p.trial.flagNextTrial = true;
                elseif(p.functionHandles.windowManagerObj.analogStick.in('neutral'))
                    fprintf(' - Analog stick is in neutral state; trial may begin.\n');
                    p.functionHandles.stateControlObj.nextState('state','ready');
                end
                
            case 'ready'
                
                %  Wait for monkey to engage analog stick so that we can
                %  move on to engaged state.
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state.\n',p.functionHandles.stateControlObj.state);
                elseif(p.trial.ttime >= p.trial.pldaps.maxTrialLength)
                    fprintf(' - Monkey timed out; abort trial.\n');
                    p.functionHandles.trialOutcomeObj.trialTimedOut = true;
                    p.trial.flagNextTrial = true;
                elseif(p.functionHandles.windowManagerObj.analogStick.in('engaged'))
                    fprintf(' - Monkey engaged analog stick at %0.2f sec to start trial.\n',p.functionHandles.stateControlObj.elapsedTime);
                    p.functionHandles.stateVariablesObj.engageCueOn = true;
                    p.functionHandles.stateVariablesObj.stimulusOn = p.trial.timing.sampleRelativeOnset == 0;
                    p.functionHandles.stateControlObj.nextState('state','engaged','duration',p.trial.timing.engageInterval);
                end
                
            case 'engaged'
                
                %  Monkey has engaged the analog stick; show symbols and
                %  cues.  If he releases during this state, go to blank
                %  (ITI); otherwise, go to release. Fixation will be
                %  required for part of this state.
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state with wait duration of %0.2f sec.\n',...
                        p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                end
                
                %  Conditional control of stimulus display
                if(~p.functionHandles.stateVariablesObj.stimulusOn && mod(p.functionHandles.stateControlObj.elapsedTime - p.trial.timing.sampleRelativeOnset,p.trial.timing.dutyCycle) < p.trial.timing.sampleDuration)
                    p.functionHandles.stateVariablesObj.stimulusOn = true;
                elseif(p.functionHandles.stateVariablesObj.stimulusOn && ...
                        mod(p.functionHandles.stateControlObj.elapsedTime - p.trial.timing.sampleRelativeOnset,p.trial.timing.dutyCycle) >= p.trial.timing.sampleDuration && ...
                        p.functionHandles.stateControlObj.remainingTime > p.trial.timing.probeOverlap)
                    p.functionHandles.stateVariablesObj.stimulusOn = false;
                    p.functionHandles.stateVariablesObj.stimulusIndx = p.functionHandles.stateVariablesObj.stimulusIndx + 1;
                end
                
                %  Conditional control of engage and release cue display
                if(p.functionHandles.stateVariablesObj.engageCueOn && p.functionHandles.stateControlObj.remainingTime <= p.trial.timing.releaseDelay)
                    p.functionHandles.stateVariablesObj.engageCueOn = false;
                    p.functionHandles.stateVariablesObj.releaseCueOn = true;
                    p.functionHandles.stateVariablesObj.releaseCueOnset = GetSecs;
                end
                
                %  Conditional control for state transition
                if(~p.functionHandles.windowManagerObj.eye.in('fixation') && p.functionHandles.stateControlObj.elapsedTime >= p.trial.timing.fixationGracePeriod)
                    fprintf(' - Monkey not fixating at %0.2f sec; this is a trial abort.\n',p.functionHandles.stateControlObj.elapsedTime);
                    p.functionHandles.trialOutcomeObj.fixationBreak = true;
                    p.trial.flagNextTrial = true;
                elseif(~p.functionHandles.windowManagerObj.analogStick.in('engaged'))
                    fprintf(' - Monkey released analog stick to abort trial.\n');
                    p.functionHandles.trialOutcomeObj.earlyAbort = true;
                    p.trial.flagNextTrial = true;
                elseif(p.functionHandles.stateControlObj.remainingTime <= 0)
                    p.functionHandles.stateControlObj.nextState('state','release','duration',p.trial.timing.releaseDuration);
                end
                
            case 'release'
                
                %  Monkey may now release the lever during the release
                %  interval to get feedback.  If he correctly releases.
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %0.2f sec; ',...
                        p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                    if(strcmpi(p.trial.condition.type,'match'))
                        fprintf('monkey should release within %0.2f sec.\n',...
                            p.trial.timing.releaseInterval + p.trial.timing.releaseDelay);
                    else
                        fprintf('monkey should hold for another %0.2f sec prior to release.\n',...
                            p.trial.timing.releaseInterval + p.trial.timing.releaseDelay);
                    end
                end
                
                %  Conditional control of stimulus display
                if(p.functionHandles.stateVariablesObj.stimulusOn && p.functionHandles.stateControlObj.elapsedTime > p.trial.timing.releaseInterval)
                    p.functionHandles.stateVariablesObj.stimulusOn = false;
                end
                
                %  Conditional control for state transition
                if(~p.functionHandles.windowManagerObj.analogStick.in('engaged'))
                    
                    %  Monkey has released analog stick
                    p.functionHandles.trialOutcomeObj.reactionTime = GetSecs - p.functionHandles.stateVariablesObj.releaseCueOnset;
                    if(strcmpi(p.trial.condition.type,'match'))
                        if(p.functionHandles.stateControlObj.elapsedTime <= p.trial.timing.releaseInterval + p.trial.timing.releaseDelay)
                            fprintf(' - Monkey released analog stick at %0.2f sec and will receive a reward (HIT).\n',p.functionHandles.trialOutcomeObj.reactionTime);
                            p.functionHandles.stateVariablesObj.releaseCueOn = false;
                            p.functionHandles.stateVariablesObj.rewardCueOn = true;
                            p.functionHandles.trialOutcomeObj.hit = true;
                            p.functionHandles.trialOutcomeObj.trialCompleted = true;
                            if(p.trial.timing.rewardDelay > 0)
                                p.functionHandles.stateControlObj.nextState('state','rewardDelay','duration',p.trial.timing.rewardDelay);
                            else
                                p.functionHandles.stateControlObj.nextState('state','reward','duration',p.trial.timing.rewardDuration);
                            end
                        else
                            fprintf(' - Monkey released analog stick at %0.2f sec and will receive a penalty (MISS).\n',p.functionHandles.trialOutcomeObj.reactionTime);
                            p.functionHandles.stateVariablesObj.stimulusOn = false;
                            p.functionHandles.stateVariablesObj.releaseCueOn = false;
                            p.functionHandles.stateVariablesObj.penaltyCueOn = true;
                            p.functionHandles.trialOutcomeObj.miss = true;
                            p.functionHandles.trialOutcomeObj.trialCompleted = true;
                            p.functionHandles.stateControlObj.nextState('state','penalty','duration',p.functionHandles.stateControlObj.remainingTime);
                        end
                    else
                        if(p.functionHandles.stateControlObj.elapsedTime <= p.trial.timing.releaseInterval + p.trial.timing.releaseDelay)
                            fprintf(' - Monkey released analog stick at %0.2f sec and will receive a penalty (FALSE ALARM).\n',p.functionHandles.trialOutcomeObj.reactionTime);
                            p.functionHandles.stateVariablesObj.stimulusOn = false;
                            p.functionHandles.stateVariablesObj.releaseCueOn = false;
                            p.functionHandles.stateVariablesObj.penaltyCueOn = true;
                            p.functionHandles.trialOutcomeObj.falseAlarm = true;
                            p.functionHandles.trialOutcomeObj.trialCompleted = true;
                            p.functionHandles.stateControlObj.nextState('state','penalty','duration',p.functionHandles.stateControlObj.remainingTime);
                        else
                            fprintf(' - Monkey released analog stick at %0.2f sec and will receive a reward (CORRECT REJECT).\n',p.functionHandles.trialOutcomeObj.reactionTime);
                            p.functionHandles.stateVariablesObj.releaseCueOn = false;
                            p.functionHandles.stateVariablesObj.rewardCueOn = true;
                            p.functionHandles.trialOutcomeObj.correctReject = true;
                            p.functionHandles.trialOutcomeObj.trialCompleted = true;
                            if(p.trial.timing.rewardDelay > 0)
                                p.functionHandles.stateControlObj.nextState('state','rewardDelay','duration',p.trial.timing.rewardDelay);
                            else
                                p.functionHandles.stateControlObj.nextState('state','reward','duration',p.trial.timing.rewardDuration);
                            end
                        end
                    end
                elseif(p.functionHandles.stateControlObj.remainingTime <= 0)
                    
                    %  Monkey has held analog stick to end of release
                    %  interval.
                    fprintf(' - Monkey held analog stick to end of release delay; this is a trial abort.\n');
                    p.functionHandles.trialOutcomeObj.lateAbort = true;
                    p.trial.flagNextTrial = true;
                end
                
            case 'rewardDelay'
                
                %  Monkey has released the lever and waits for reward
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %0.2f sec.\n',...
                        p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                elseif(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Monkey may now receive his reward.\n');
                    p.functionHandles.stateControlObj.nextState('state','reward','duration',p.trial.timing.rewardDuration);
                end
                
            case 'reward'
                
                %  Monkey receives his reward now
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state\n',p.functionHandles.stateControlObj.state);
                    pds.behavior.reward.give(p,p.trial.timing.rewardDuration);
                elseif(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Monkey has received his reward.\n');
                    p.functionHandles.trialOutcomeObj.trialRewarded = true;
                    p.trial.flagNextTrial = true;
                end
                
            case 'penalty'
                
                %  Monkey is assessed a time penalty.
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %0.2f sec.\n',...
                        p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                elseif(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Monkey has completed his penalty.\n');
                    p.trial.flagNextTrial = true;
                end
        end
end
end
