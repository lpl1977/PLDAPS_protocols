function p = trialFunction(p,state)
%  PLDAPS TRIAL FUNCTION FILE
%  PACKAGE:  dmf.operant

%  This trial function is specifically for the training on the operant
%  response.

switch state
    
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        %  experimentPostOpenScreen--executed once after screen has been
        %  opened.
        
    case p.trial.pldaps.trialStates.trialSetup
        %  trialSetup--this is where we would perform any steps that needed
        %  to be done before a trial is started, for example preparing
        %  stimuli parameters
        
        %  Reward
        p.trial.stimulus.reward = 0.4;
        
        %  Time intervals
        p.trial.stimulus.timing.intertrialInterval = 1;
        p.trial.stimulus.timing.engageIntervalFixed = 0.5;
        p.trial.stimulus.timing.meanEngageDelta = 1;
        p.trial.stimulus.timing.maxEngageDelta = 3*p.trial.stimulus.timing.meanEngageDelta;
        p.trial.stimulus.timing.releaseInterval = 3;
        p.trial.stimulus.timing.rewardDelay = 0.3;

        p.trial.stimulus.timing.fixationGracePeriod = 0.5;
        
        %  Sample stimulus onset is with respect to start of engage
        %  interval
        p.trial.stimulus.timing.sampleOnsetDelay = p.trial.stimulus.timing.fixationGracePeriod;
        p.trial.stimulus.timing.sampleDuration = 0;
        
        %  Probe stimulus onset is with respect to end of engage interval
        p.trial.stimulus.timing.probeOnsetAdvance = 0;
        p.trial.stimulus.timing.probeDuration = 0;
        
        p.trial.stimulus.timing.penaltyDuration = 5;
        
        %  Draw an engage delay interval
        p.trial.stimulus.timing.engageInterval = p.trial.stimulus.timing.engageIntervalFixed + ...
            min(p.trial.stimulus.timing.maxEngageDelta,exprnd(p.trial.stimulus.timing.meanEngageDelta));
        
        %  Reward duration
        p.trial.stimulus.timing.rewardDuration = p.trial.stimulus.reward;
        
        %  Get condition for upcoming trial
        p.trial.condition = p.conditions{p.trial.pldaps.iTrial};
        
        %  Set up task state control for the upcoming trial
        p.functionHandles.stateControlObj.trialSetup;
        
        %  Specify starting state
        if(p.trial.pldaps.iTrial==1)
            p.functionHandles.stateControlObj.nextState('state','start');
        else
            iti = p.trial.stimulus.timing.intertrialInterval - p.functionHandles.stateControlObj.elapsedTime;
            p.functionHandles.stateControlObj.nextState('state','intertrial','duration',iti);
        end
        
        %  Set up state variables for upcoming trial
        p.functionHandles.stateVariablesObj = stateVariables(...
            'engageCueOn',false,...
            'releaseCueOn',false,...
            'sampleStimulusOn',false,...
            'probeStimulusOn',false,...
            'rewardCueOn',false,...
            'fixationEnforced',false,...
            'matchTrial',true,...
            'trialCompleted',false);
        
        %  Echo trial specifications to screen
        fprintf('This is trial attempt %d of %d\n',p.trial.pldaps.iTrial,p.trial.pldaps.finish);
        
        
        %
        %         %  Condition from cell array
        %         p.trial.condition = p.functionHandles.trialManagerObj.nextTrial;
        %
        %         %  Set any adjustable parameters
        %         dmf.adjustableParameters(p,state);
        %
        %         %  Initialize trial state variables
        %         p.functionHandles.stateVariables = stateControl('start');
        %
        %         %  Initialize trial outcome object
        %         p.functionHandles.trialOutcomeObj = dmf.outcome(...
        %             'trialNumber',p.functionHandles.trialManagerObj.trialNumber,...
        %             'rewardedResponse',p.trial.condition.rewardedResponse,...
        %             'correctionLoopTrial',p.functionHandles.trialManagerObj.inCorrectionLoop,...
        %             'selectionCode',p.trial.condition.selectionCode,...
        %             'rewardDuration',p.functionHandles.reward,...
        %             'response','center');
        %
        %         %  Initialize flags for graphical display
        %         p.functionHandles.analogStickCursorObj.visible = false;
        %         p.functionHandles.graphicsManagerObj.fixationDotVisible = true;
        %
        %         %  Create textures for display
        %         p.functionHandles.graphicsManagerObj.prepareStateTextures(p.trial.condition.selectedSet);
        %
        %         %  Echo trial specs to screen
        %         fprintf('TRIAL ATTEMPT %d\n',p.trial.pldaps.iTrial);
        %         if(~p.functionHandles.trialManagerObj.inCorrectionLoop)
        %             fprintf('Completed %d of %d trials\n',p.functionHandles.trialManagerObj.trialNumber-1,p.functionHandles.trialManagerObj.maxTrials);
        %         else
        %             fprintf('Correction loop trial %d for %stokenized trials\n',p.functionHandles.trialManagerObj.correctionLoopTrialNumber,sprintf('%s ',p.functionHandles.trialManagerObj.correctionLoopTokens{:}));
        %         end
        %         fprintf('%25s:\n','Symbols');
        %         for i=1:3
        %             fprintf('%25s:  ',p.functionHandles.possibleResponses{i});
        %             fprintf('%s ',p.functionHandles.setObj.symbolFeatures.colors{p.trial.condition.setSymbolCode(i,1)});
        %             fprintf('%s ',p.functionHandles.setObj.symbolFeatures.patterns{p.trial.condition.setSymbolCode(i,2)});
        %             fprintf('%s',p.functionHandles.setObj.symbolFeatures.shapes{p.trial.condition.setSymbolCode(i,3)});
        %             fprintf('\n');
        %         end
        %         fprintf('%25s:  %s\n','Rewarded response',p.trial.condition.rewardedResponse);
        %         fprintf('%25s:  %s\n','Satisifed selection code',p.trial.condition.selectionCode);
        %         fprintf('\n');
        %
        %
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  cleanUpandSave--post trial management; perform any steps that
        %  should happen upon completion of a trial such as performance
        %  tracking and trial index updating.
        
        fprintf('End trial.\n\n');
        
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
        
        if(p.functionHandles.stateVariablesObj.engageCueOn)
            Screen('DrawDots',p.trial.display.ptr,[0 0],40,[1 0 0],p.trial.display.ctr(1:2),2);
        end
        
        if(p.functionHandles.stateVariablesObj.releaseCueOn)
            Screen('DrawDots',p.trial.display.ptr,[0 0],40,[0 1 0],p.trial.display.ctr(1:2),2);
        end
        
        if(p.functionHandles.stateVariablesObj.rewardCueOn)
            Screen('DrawDots',p.trial.display.ptr,[0 0],40,[0 0 1],p.trial.display.ctr(1:2),2);
        end
        
        if(p.functionHandles.stateVariablesObj.sampleStimulusOn)
            Screen('DrawDots',p.trial.display.ptr,[0 -100],100,[1 1 1],p.trial.display.ctr(1:2),2);
        end
        
        if(p.functionHandles.stateVariablesObj.probeStimulusOn)
            Screen('DrawDots',p.trial.display.ptr,[0 -100],100,[0 0 0],p.trial.display.ctr(1:2),2);
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
                        fprintf(' - Monkey must wait for an additional %0.2f seconds until this trial starts.\n',p.functionHandles.stateControlObj.remainingTime);
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
                end
                
                %  Conditional control for state transition
                if(p.functionHandles.windowManagerObj.analogStick.in('neutral'))
                    fprintf(' - Analog stick is in neutral state; trial may begin.\n');
                    p.functionHandles.stateControlObj.nextState('state','ready');
                end
                
            case 'ready'
                
                %  Wait for monkey to engage analog stick so that we can
                %  move on to engaged state.
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state.\n',p.functionHandles.stateControlObj.state);
                end
                
                %  Conditional control for state transition
                if(p.functionHandles.windowManagerObj.analogStick.in('engaged'))
                    fprintf(' - Monkey engaged analog stick at %0.2f sec to start trial.\n',p.functionHandles.stateControlObj.elapsedTime);
                    p.functionHandles.stateControlObj.nextState('state','engaged','duration',p.trial.stimulus.timing.engageInterval);
                end
                
            case 'engaged'
                
                %  Monkey has engaged the analog stick; show the red dot
                %  and wait for the delay.  If he releases during this
                %  state, go to blank (ITI); otherwise, go to release.
                %  Fixation will be required for part of this state
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state with wait duration of %0.2f seconds.\n',...
                        p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                    p.functionHandles.stateVariablesObj.engageCueOn = true;
                end
                
                %  Conditional control of eye windowing enforcement
                if(p.functionHandles.stateControlObj.elapsedTime >= p.trial.stimulus.timing.fixationGracePeriod)
                    p.functionHandles.stateVariablesObj.fixationEnforced=true;
                end
                
                %  Conditional control of stimulus display flags
                if(p.functionHandles.stateControlObj.elapsedTime >= p.trial.stimulus.timing.sampleOnsetDelay && ...
                        p.functionHandles.stateControlObj.elapsedTime < p.trial.stimulus.timing.sampleDuration + p.trial.stimulus.timing.sampleOnsetDelay)
                    p.functionHandles.stateVariablesObj.sampleStimulusOn = true;
                else
                    p.functionHandles.stateVariablesObj.sampleStimulusOn = false;
                    if(p.functionHandles.stateControlObj.remainingTime <= p.trial.stimulus.timing.probeOnsetAdvance && ...
                            p.functionHandles.stateControlObj.remainingTime > p.trial.stimulus.timing.probeOnsetAdvance - p.trial.stimulus.timing.probeDuration)
                        p.functionHandles.stateVariablesObj.probeStimulusOn = true;
                    else
                        p.functionHandles.stateVariablesObj.probeStimulusOn = false;
                    end
                end
                
                %  Conditional control for state transition
                if(p.functionHandles.stateVariablesObj.fixationEnforced && ~p.functionHandles.windowManagerObj.eye.in('fixation'))
                    fprintf(' - Monkey prematurely broke fixation at %0.2f seconds.\n',p.functionHandles.stateControlObj.elapsedTime);
                    p.trial.flagNextTrial = true;
                elseif(~p.functionHandles.windowManagerObj.analogStick.in('engaged'))
                    fprintf(' - Monkey prematurely released analog stick at %0.2f seconds.\n',p.functionHandles.stateControlObj.elapsedTime);
                    p.trial.flagNextTrial = true;
                elseif(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Monkey held analog stick to end of engage delay.\n');
                    p.functionHandles.stateControlObj.nextState('state','release','duration',p.trial.stimulus.timing.releaseInterval);
                end
                
            case 'release'
                
                %  Show monkey release cue.  He may release the lever
                %  during the release interval to get feedback.  Once he
                %  releases, go to rewardDelay.  If he waits too long, end
                %  trial.
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    if(p.functionHandles.stateVariablesObj.matchTrial)
                        fprintf('Entered <strong>%s</strong> state; monkey should release analog stick within %0.2f seconds.\n',...
                            p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                    else
                        fprintf('Entered <strong>%s</strong> state; monkey should hold analog stick for %0.2f seconds.\n',...
                            p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                    end                        
                    p.functionHandles.stateVariablesObj.engageCueOn = false;
                    p.functionHandles.stateVariablesObj.releaseCueOn = true;
                end
                
                %  Conditional control of stimulus display flags
                if(p.functionHandles.stateControlObj.elapsedTime <= p.trial.stimulus.timing.probeDuration - p.trial.stimulus.timing.probeOnsetAdvance)
                    p.functionHandles.stateVariablesObj.probeStimulusOn = true;
                else
                    p.functionHandles.stateVariablesObj.probeStimulusOn = false;
                end
                
                %  Conditional control for state transition
                if(p.functionHandles.stateVariablesObj.fixationEnforced && ~p.functionHandles.windowManagerObj.eye.in('fixation'))
                    fprintf(' - Monkey prematurely broke fixation at %0.2f seconds.\n',p.functionHandles.stateControlObj.elapsedTime);
                    p.trial.flagNextTrial = true;
                elseif(p.functionHandles.windowManagerObj.analogStick.in('neutral'))
                    p.functionHandles.stateVariablesObj.trialCompleted = true;
                    if(p.functionHandles.stateVariablesObj.matchTrial)
                        fprintf(' - Monkey released analog stick and is eligible for reward.\n');
                        if(p.trial.stimulus.timing.rewardDelay > 0)
                            p.functionHandles.stateControlObj.nextState('state','rewardDelay','duration',p.trial.stimulus.timing.rewardDelay);
                        else
                            p.functionHandles.stateControlObj.nextState('state','reward','duration',p.trial.stimulus.timing.rewardDuration);
                        end
                    else
                        fprintf(' - Monkey released analog stick and will receive a penalty.\n');
                        p.functionHandles.stateVariablesObj.releaseCueOn = false;
                        p.functionHandles.stateControlObj.nextState('state','penalty','duration',p.trial.stimulus.timing.penaltyDuration);
                    end
                elseif(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Monkey held analog stick to end of release delay.\n');
                    p.trial.flagNextTrial = true;
                end
                
            case 'rewardDelay'
                
                %  Monkey has released the lever and will wait for his
                %  reward.
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %0.2f seconds.\n',...
                        p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                    p.functionHandles.stateVariablesObj.releaseCueOn = false;
                    p.functionHandles.stateVariablesObj.rewardCueOn = true;
                end
                
                %  Conditional control for state transition
                if(p.functionHandles.stateVariablesObj.fixationEnforced && ~p.functionHandles.windowManagerObj.eye.in('fixation'))
                    fprintf(' - Monkey prematurely broke fixation at %0.2f seconds.\n',p.functionHandles.stateControlObj.elapsedTime);
                    p.trial.flagNextTrial = true;
                elseif(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Monkey may now receive his reward.\n');
                    p.functionHandles.stateControlObj.nextState('state','reward','duration',p.trial.stimulus.timing.rewardDuration);
                end
                
            case 'reward'
                
                %  Monkey receives his reward now
                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state\n',p.functionHandles.stateControlObj.state);
                    pds.behavior.reward.give(p,p.trial.stimulus.reward);
                end
                
                %  Conditional control for state transition
                if(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Monkey has received his reward.\n');
                    p.functionHandles.stateVariablesObj.rewardCueOn = false;
                    p.trial.flagNextTrial = true;
                end
                
            case 'penalty'
                
                %  Monkey released the analog stick when he should have
                %  ignored the release cue.  He is assessed a time penalty.
                                
                %  Execute on first entry
                if(p.functionHandles.stateControlObj.firstEntryIntoState)
                    fprintf('Entered <strong>%s</strong> state for %0.2f seconds.\n',...
                        p.functionHandles.stateControlObj.state,p.functionHandles.stateControlObj.duration);
                end
                
                %  Conditional control for state transition
                if(p.functionHandles.stateControlObj.remainingTime <= 0)
                    fprintf(' - Monkey has completed his penalty.\n');
                    p.trial.flagNextTrial = true;
                end                
        end        
end
end
