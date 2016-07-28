function p = ready_set_go(p,state)
%p = ready_set_go(p,state)
%
%  PLDAPS trial function for set game training aka ready_set_go

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
        
        %  Confirm joystick is attached; if not, then stop trial and pause
        %  protocol
        if(~joystick.connected)
            disp('Warning:  joystick disconnected.  Plug it in, I will wait...');
            p.trial.pldaps.pause.type = 1;
            p.trial.pldaps.quit = 1;
        end
        
        %  Set subject specific parameters / actions
        feval(str2func(strcat('set_trainer.ready_set_go.',p.trial.session.subject)),p);
        
        %  Initialize trial state
        
        p.trial.temp.trial_state = 'ready';
        
        %  Initialize trial type and timing.
        p.trial.temp.state_variables.hold_trial = ~~binornd(1,p.trial.temp.state_variables.hold_probability);
        p.trial.temp.state_variables.release_trial = ~p.trial.temp.state_variables.hold_trial;
        
        %  Hold duration        
        p.trial.temp.timing.hold.duration = min(p.trial.temp.timing.hold.min_duration + exprnd(0.5),p.trial.temp.timing.hold.max_duration);
        
        
        %  Extract performance data
        
        if(p.trial.pldaps.iTrial > 1)            
            try
                p.trial.temp.completed_holds = p.data{p.trial.pldaps.iTrial-1}.temp.completed_holds;
            catch
                p.trial.temp.completed_holds = 0;
            end
            
            try
                p.trial.temp.completed_releases = p.data{p.trial.pldaps.iTrial-1}.temp.completed_releases;
            catch
                p.trial.temp.completed_releases = 0;
            end
            
            try
                p.trial.temp.correct_holds = p.data{p.trial.pldaps.iTrial-1}.temp.correct_holds;
            catch
                p.trial.temp.correct_holds = 0;
            end
            
            try
                p.trial.temp.correct_releases = p.data{p.trial.pldaps.iTrial-1}.temp.correct_releases;
            catch
                p.trial.temp.correct_releases = 0;
            end
            
            try
                p.trial.temp.early_releases = p.data{p.trial.pldaps.iTrial-1}.temp.early_releases;
            catch
                p.trial.temp.early_releases = 0;
            end
            
            try
                p.trial.temp.missed_releases = p.data{p.trial.pldaps.iTrial-1}.temp.missed_releases;
            catch
                p.trial.temp.missed_releases = 0;
            end
            
            try
                p.trial.temp.delay_errors = p.data{p.trial.pldaps.iTrial-1}.temp.delay_errors;
            catch
                p.trial.temp.delay_errors = 0;
            end
            
            try
                p.trial.temp.fixation_breaks = p.data{p.trial.pldaps.iTrial-1}.temp.fixation_breaks;
            catch
                p.trial.temp.fixation_breaks = 0;
            end
        end
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        %  Let's print to screen what the current performance is like
        
        if(p.trial.pldaps.iTrial > 1)
            
            try
                completed_holds = p.data{p.trial.pldaps.iTrial-1}.temp.completed_holds;
            catch
                completed_holds = 0;
            end
            
            try
                completed_releases = p.data{p.trial.pldaps.iTrial-1}.temp.completed_releases;
            catch
                completed_releases = 0;
            end
            
            try
                correct_holds = p.data{p.trial.pldaps.iTrial-1}.temp.correct_holds;
            catch
                correct_holds = 0;
            end
            
            try
                correct_releases = p.data{p.trial.pldaps.iTrial-1}.temp.correct_releases;
            catch
                correct_releases = 0;
            end
            
            try
                early_releases = p.data{p.trial.pldaps.iTrial-1}.temp.early_releases;
            catch
                early_releases = 0;
            end
            
            try
                missed_releases = p.data{p.trial.pldaps.iTrial-1}.temp.missed_releases;
            catch
                missed_releases = 0;
            end
            
            try
                delay_errors = p.data{p.trial.pldaps.iTrial-1}.temp.delay_errors;
            catch
                delay_errors = 0;
            end
            
            try
                fixation_breaks = p.data{p.trial.pldaps.iTrial-1}.temp.fixation_breaks;
            catch
                fixation_breaks = 0;
            end
            
            total_completed = completed_holds + completed_releases;
            total_trials = total_completed + delay_errors + fixation_breaks;
            total_correct = correct_holds+correct_releases;
            
            fprintf('Current performance:\n');
            
            fprintf('\tCompleted trials:  %d of %d (%0.3f)\n',total_completed,total_trials,total_completed/total_trials);
            fprintf('\tDelay error trials:  %d of %d (%0.3f)\n',delay_errors,total_trials,delay_errors/total_trials);
            fprintf('\tFixation break trials:  %d of %d (%0.3f)\n',fixation_breaks,total_trials,fixation_breaks/total_trials);
            fprintf('\n');
            fprintf('\tTotal correct:  %d of %d (%0.3f)\n',total_correct,total_completed,total_correct/total_completed);
            fprintf('\tCorrect hold trials:  %d of %d (%0.3f)\n',correct_holds,completed_holds,correct_holds/completed_holds);
            fprintf('\tCorrect release trials:  %d of %d (%0.3f)\n',correct_releases,completed_releases,correct_releases/completed_releases);
            fprintf('\tEarly release trials:  %d of %d (%0.3f)\n',early_releases,total_completed,early_releases/total_completed);
            fprintf('\tMissed release trials:  %d of %d (%0.3f)\n',missed_releases,completed_releases,missed_releases/completed_releases);
            fprintf('\n');
        end
        
        
        %  Check if we have completed conditions; if so, we're finished.
        if(p.trial.pldaps.iTrial==length(p.conditions))
            p.trial.pldaps.quit=2;
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        %  Got nothing here on my end
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update is called once after the last frame is done (or
        %  even before).  Get current eyepostion, curser position,
        %  keypresses, joystick position, etc.
        
        %  Get current fixation status
        check_fixation_status;
        
        %  Get current joystick status
        check_joystick_status;
        
        %  Display joystick status to screen
        joystick.display(p,p.trial.joystick);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control.
        
        %
        %  Control trial events based on trial state
        %
        
        switch p.trial.temp.trial_state
            
            case 'ready'
                
                %  STATE:  ready
                
                if(isnan(p.trial.temp.timing.ready.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.temp.timing.ready.start_time = GetSecs;
                    p.trial.temp.timing.ready.cue_start_time = GetSecs;
                    fprintf('READY state for trial %d.\n',p.trial.pldaps.iTrial);
                    if(p.trial.temp.state_variables.hold_trial)
                        fprintf('\tThis is a HOLD trial.\n');
                    else
                        fprintf('\tThis is a RELEASE trial.\n');
                    end
                    
                    %  If the monkey currently has the joystick engaged
                    %  we're going to have to wait for him to release it
                    %  before proceeding.
                    if(~p.trial.temp.state_variables.joystick_released)
                        fprintf('\t%s must release joystick before re-engaging.\n',p.trial.session.subject);
                        p.trial.temp.state_variables.wait_for_release = true;
                    else
                        p.trial.temp.state_variables.wait_for_release = false;
                    end
                    
                    %  Show ready and fixation cues
                    ShowReadyCue;
                    ShowFixationCue;
                    
                else
                    
                    %  We are still in the ready state.  We will continue
                    %  blinking the ready cue as long as the monkey has not
                    %  engaged the joystick and the fixation cue as long as
                    %  he has not fixated.  Note that if we are waiting for
                    %  him to release the joystick we will blink the ready
                    %  cue even if he has the joystick engaged, so first
                    %  check and see whether or not we are still waiting.
                    if(p.trial.temp.state_variables.wait_for_release && p.trial.temp.state_variables.joystick_released)
                        p.trial.temp.state_variables.wait_for_release = false;
                    end
                    
                    if(~p.trial.temp.state_variables.wait_for_release && p.trial.temp.state_variables.joystick_engaged && p.trial.temp.state_variables.fixating)
                        
                        %  We're not waiting and the monkey has both
                        %  engaged and is fixating.  Print some feedback,
                        %  reset the timing variables, and go on to the
                        %  next state.
                        fprintf('\t%s engaged and fixated after %0.3f sec.  Proceed to hold.\n',p.trial.session.subject,GetSecs-p.trial.temp.timing.ready.start_time);
                        p.trial.temp.timing.ready.start_time = NaN;
                        p.trial.temp.timing.ready.cue_start_time = NaN;
                        p.trial.temp.trial_state = 'hold';
                        
                        %  Show hold and fixation cues
                        ShowHoldCue;
                        ShowFixationCue;
                        
                    elseif(p.trial.temp.timing.ready.cue_start_time > GetSecs - p.trial.temp.timing.ready.cue_display_time)
                        
                        %  We're not yet in the blink so show both the
                        %  ready cue and the fixation cue regarless.
                        ShowReadyCue;
                        ShowFixationCue;
                        
                    elseif(p.trial.temp.timing.ready.cue_start_time <= GetSecs - p.trial.temp.timing.ready.cue_period)
                        
                        %  We've exceeded the duration of the blink, so
                        %  reset the cue start time.
                        p.trial.temp.timing.ready.cue_start_time = GetSecs;
                        
                        %  Show the ready and fixation cues regardless
                        ShowReadyCue;
                        ShowFixationCue;
                        
                    else
                        
                        %  We are now in the blink.  Show the ready cue
                        %  only if we are not waiting for monkey to release
                        %  and he has the joystick engaged.
                        
                        if(~p.trial.temp.state_variables.wait_for_release && p.trial.temp.state_variables.joystick_engaged)
                            ShowReadyCue;
                        end
                        
                        %  Show the fixation cue only if he is fixating.
                        if(p.trial.temp.state_variables.fixating)
                            ShowFixationCue;
                        end
                    end
                end
                
                
            case 'hold'
                
                %  STATE:  hold
                
                %  Monkey enters the state for the first time with the
                %  joystick engaged and fixating.  Continue to show him
                %  both the hold cue and the fixation dot as long as this is
                %  the case and we have not yet reached the end of the hold
                %  period.
                
                
                %  Show hold and fixation cues
                ShowHoldCue;
                ShowFixationCue;
                
                if(isnan(p.trial.temp.timing.hold.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.temp.timing.hold.start_time = GetSecs;
                    fprintf('HOLD state of %0.3f sec for trial %d.\n',p.trial.temp.timing.hold.duration,p.trial.pldaps.iTrial);
                    
                elseif(p.trial.temp.timing.hold.start_time > GetSecs - p.trial.temp.timing.hold.duration)
                    
                    %  We're still in the period of time in which the
                    %  monkey must wait for the release signal.  As long as
                    %  he continues to engage and fixate, show him the hold
                    %  and fixation cues.  If he releases after the minimum
                    %  hold duration but shouldn't, give him an error.  If
                    %  he realeses before the minimum hold duration, give
                    %  him a timeout
                    
                    if(p.trial.temp.state_variables.joystick_engaged && p.trial.temp.state_variables.fixating)
                        ShowHoldCue;
                        ShowFixationCue;
                    else
                        if(~p.trial.temp.state_variables.joystick_engaged)
                            %  Monkey released joystick early.  This is a
                            %  false alarm if he held past the minimum
                            %  duration and this is a hold trial; otherwise
                            %  it is a trial abort.
                            
                            fprintf('\t%s released joystick early at %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.temp.timing.hold.start_time);
                            p.trial.temp.early_releases = p.trial.temp.early_releases+1;
                            
                            if(p.trial.temp.state_variables.release_trial)
                                p.trial.temp.completed_releases = p.trial.temp.completed_releases+1;
                            else
                                p.trial.temp.completed_holds = p.trial.temp.completed_holds+1;
                            end
                            
                            p.trial.temp.trial_state = 'error';
                        else
                            fprintf('\t%s broke fixation after %0.3f sec.  Proceed to timeout.\n',p.trial.session.subject,GetSecs-p.trial.temp.timing.hold.start_time);
                            p.trial.temp.trial_state = 'timeout';
                            p.trial.temp.fixation_breaks = p.trial.temp.fixation_breaks+1;
                        end
                        p.trial.temp.timing.hold.start_time = NaN;
                    end
                    
                else
                    
                    %  Monkey has successfully held the joystick to the end
                    %  of the hold period.  Proceed to the release cue if
                    %  this is a release trial.  Otherwise reward him for
                    %  holding.
                    
                    if(p.trial.temp.state_variables.release_trial)
                        fprintf('\t%s successfully held joystick and remained fixating.  Proceed to release cue.\n',p.trial.session.subject);
                        p.trial.temp.trial_state = 'release';
                    else
                        fprintf('\t%s successfully held joystick and remained fixating.  Give him his reward.\n',p.trial.session.subject);
                        p.trial.temp.trial_state = 'reward';
                        p.trial.temp.correct_holds = p.trial.temp.correct_holds+1;
                        p.trial.temp.completed_holds = p.trial.temp.completed_holds+1;
                    end
                    p.trial.temp.timing.hold.start_time = NaN;
                end
                
            case 'timeout'
                
                %  STATE:  timeout
                
                %  In this state we are going to burn a timeout period.
                %  After that is over, end trial.
                
                if(isnan(p.trial.temp.timing.timeout.start_time))
                    fprintf('TIMEOUT state for %0.3f sec.\n',p.trial.temp.timing.timeout.duration);
                    p.trial.temp.timing.timeout.start_time = GetSecs;
                    
                    %  Play the breakfix sound since this is our first time
                    %  into the state
                    pds.audio.play(p,'breakfix');
                    
                elseif(p.trial.temp.timing.timeout.start_time <= GetSecs - p.trial.temp.timing.timeout.duration)
                    fprintf('\tTimeout elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.temp.timing.timeout.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
        
            case 'error'
                
                %  STATE:  error
                
                %  In this state we are going to play an error tone and
                %  burn a timeout period. After that is over, end trial.
                
                if(isnan(p.trial.temp.timing.timeout.start_time))
                    fprintf('ERROR state for %0.3f sec.\n',p.trial.temp.timing.timeout.duration);
                    p.trial.temp.timing.timeout.start_time = GetSecs;
                    
                    %  Play the error sound since this is our first time
                    %  into the state
                    pds.audio.play(p,'incorrect');                    
                    
                elseif(p.trial.temp.timing.timeout.start_time <= GetSecs - p.trial.temp.timing.timeout.duration)
                    fprintf('\tTimeout elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);                    
                    p.trial.temp.timing.timeout.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
            case 'release'
                
                %  STATE:  release
                
                %  In this state we show a release cue.  Monkey should
                %  release the joystick prior to the end of this state.
                
                ShowReleaseCue;
                ShowFixationCue;
                
                if(isnan(p.trial.temp.timing.release.start_time))
                    p.trial.temp.timing.release.start_time = GetSecs;
                    fprintf('RELEASE state for trial %d.  Release within %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.temp.timing.release.grace);
                    
                elseif(p.trial.temp.timing.release.start_time > GetSecs - p.trial.temp.timing.release.grace)
                    
                    %  Still in grace period so check joystick
                    if(p.trial.temp.state_variables.joystick_released && p.trial.temp.state_variables.fixating)
                        
                        %  Monkey has released joystick within the
                        %  appropriate period of time, so he is correct.
                        %  This is a hit.
                        
                        fprintf('\t%s released joystick with reaction time %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.temp.timing.release.start_time);
                        
                        p.trial.temp.timing.release.start_time = NaN;
                        p.trial.temp.trial_state = 'reward_delay';
                        
                    elseif(~p.trial.temp.state_variables.fixating)
                        
                        %  Monkey broke fixation too early.  Give him a
                        %  timeout.
                        
                        fprintf('\t%s broke fixation after %0.3f sec.  Proceed to timeout.\n',p.trial.session.subject,GetSecs-p.trial.temp.timing.release.start_time);
                        p.trial.temp.fixation_breaks = p.trial.temp.fixation_breaks+1;
                        
                        p.trial.temp.timing.release.start_time = NaN;
                        p.trial.temp.trial_state = 'timeout';
                    end
                else
                    %  Monkey has held joystick till end of grace period,
                    %  this is an error so give him an error and count it
                    %  as a miss.
                    
                    fprintf('\t%s held joystick to end of grace period.\n',p.trial.session.subject);
                    p.trial.temp.missed_releases = p.trial.temp.missed_releases+1;
                    p.trial.temp.completed_holds = p.trial.temp.completed_holds+1;
                    p.trial.temp.trial_state = 'error';
                end
                
            case 'reward_delay'
                
                %  STATE:  reward_delay
                
                %  In this state we continue to show the fixation dot and
                %  release cue however monkey must continue fixating and
                %  may not engage the joystick.  Once this is done we can
                %  give him his reward!
                
                ShowReleaseCue;
                ShowFixationCue;
                
                if(isnan(p.trial.temp.timing.reward_delay.start_time))
                    fprintf('REWARD DELAY for trial %d.  %s must fixate with joystick released for %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.session.subject,p.trial.temp.timing.reward_delay.duration);
                    p.trial.temp.timing.reward_delay.start_time = GetSecs;
                elseif(p.trial.temp.timing.reward_delay.start_time > GetSecs - p.trial.temp.timing.reward_delay.duration)
                    
                    %  Still in delay so check to make sure monkey
                    %  continues to fixate and keep joystick released.
                    
                    if(p.trial.temp.state_variables.joystick_engaged)
                        fprintf('\t%s engaged joystick after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.temp.timing.reward_delay.start_time);
                        p.trial.temp.trial_state = 'timeout';
                        p.trial.temp.delay_errors = p.trial.temp.delay_errors+1;
                    elseif(~p.trial.temp.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.temp.timing.reward_delay.start_time);
                        p.trial.temp.fixation_breaks = p.trial.temp.fixation_breaks+1;
                    end
                    
                else
                    
                    %  Monkey completed reward delay so he can get his
                    %  reward now!
                    fprintf('\t%s completed reward delay!\n',p.trial.session.subject);
                    p.trial.temp.timing.reward_delay.start_time = NaN;
                    p.trial.temp.trial_state = 'reward';
                    
                    if(p.trial.temp.state_variables.hold_trial)
                        p.trial.temp.correct_holds = p.trial.temp.correct_holds+1;
                        p.trial.temp.completed_holds = p.trial.temp.completed_holds+1;
                    else
                        p.trial.temp.correct_releases = p.trial.temp.correct_releases+1;
                        p.trial.temp.completed_releases = p.trial.temp.completed_releases+1;
                    end
                end
                
            case 'reward'
                
                %  STATE:  reward
                
                %  Provide the monkey with his just desserts.  Screen is
                %  now blank
                
                
                pds.behavior.reward.give(p,p.trial.stimulus.reward_amount);
                pds.audio.play(p,'reward');
                fprintf('\t%s received reward for %0.3f sec.\n',p.trial.session.subject,p.trial.stimulus.reward_amount);
                fprintf('END TRIAL %d.\n\n',p.trial.pldaps.iTrial);                
                p.trial.flagNextTrial = true;
        end
end

%  NESTED FUNCTIONS BELOW


    function ShowFixationCue
        %  ShowFixationCue
        %
        %  This function draws a fixation sqaure but only if we are using
        %  eye position.
        if(p.trial.control_flags.use_eyepos)
            win = p.trial.display.ptr;
            
            width = p.trial.temp.features.fixation.width;
            baseRect = [0 0 width width];
            centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
            color = p.trial.temp.features.fixation.color;
            linewidth = p.trial.temp.features.fixation.linewidth;
            
            Screen('FrameRect',win,color,centeredRect,linewidth);
        end
    end

    function ShowReadyCue
        %  ShowReadyCue
        %
        %  This function draws a cue to engage the joystick.
        
        win = p.trial.display.ptr;
        
        width = p.trial.temp.features.ready.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.temp.features.ready.color;
        linewidth = p.trial.temp.features.ready.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

    function ShowHoldCue
        %  ShowHoldCue
        %
        %  This function draws a cue to indicate to monkey that he has
        %  engaged the joystick.
        
        win = p.trial.display.ptr;
        
        width = p.trial.temp.features.hold.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.temp.features.hold.color;
        linewidth = p.trial.temp.features.hold.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

    function ShowReleaseCue
        %  ShowReleaseCue
        %
        %  This function draws a cue to indicate to monkey that he should
        %  release the joystick.
        
        win = p.trial.display.ptr;
        
        width = p.trial.temp.features.release.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.temp.features.release.color;
        linewidth = p.trial.temp.features.release.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
        
    end

    function check_joystick_status
        %  check_joystick_status
        %
        %  This function compares the joystick against threshold and sets
        %  the flags
        
        
        %  Determine status of joystick against thresholds
        [status,p.trial.joystick.position] = joystick.threshold(p.trial.joystick);
        
        %  Set joystick state variables
        p.trial.temp.state_variables.joystick_released = ~status(1);
        p.trial.temp.state_variables.joystick_engaged = ~~status(2);
        
    end

    function check_fixation_status
        %  check_fixation_status
        
        %  Set fixation status
        p.trial.temp.state_variables.fixating = true;
        
    end
end