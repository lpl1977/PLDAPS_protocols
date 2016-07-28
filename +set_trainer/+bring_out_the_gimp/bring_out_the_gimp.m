function p = bring_out_the_gimp(p,state)
%p = bring_out_the_gimp(p,state)
%
%  PLDAPS trial function for set game training aka bring in the gimp

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
        feval(str2func(strcat('set_trainer.bring_out_the_gimp.',p.trial.session.subject)),p);
        
        %  Initialize trial state
        
        p.trial.temp.trial_state = 'ready';
        
        %  Initialize trial type.
        p.trial.temp.state_variables.release_trial = p.conditions{p.trial.pldaps.iTrial}.release;
        p.trial.temp.state_variables.hold_trial = ~p.trial.temp.state_variables.release_trial;
        
        %  Initialize symbol sequence
        p.trial.temp.symbols = p.conditions{p.trial.pldaps.iTrial}.symbols;
        
        %  Initialize symbol counter
        p.trial.temp.state_variables.current_symbol = 0;
        p.trial.temp.state_variables.symbol_on = false;
        
        %  Extract performance data
        
        if(p.trial.pldaps.iTrial > 1)
            try
                p.trial.temp.hits = p.data{p.trial.pldaps.iTrial-1}.temp.hits;
            catch
                p.trial.temp.hits = 0;
            end
            
            try
                p.trial.temp.misses = p.data{p.trial.pldaps.iTrial-1}.temp.misses;
            catch
                p.trial.temp.misses = 0;
            end
            
            try
                p.trial.temp.false_alarms = p.data{p.trial.pldaps.iTrial-1}.temp.false_alarms;
            catch
                p.trial.temp.false_alarms = 0;
            end
            
            try
                p.trial.temp.correct_rejects = p.data{p.trial.pldaps.iTrial-1}.temp.correct_rejects;
            catch
                p.trial.temp.correct_rejects = 0;
            end
            
            try
                p.trial.temp.early_releases = p.data{p.trial.pldaps.iTrial-1}.temp.early_releases;
            catch
                p.trial.temp.early_releases = 0;
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
                hits = p.data{p.trial.pldaps.iTrial-1}.temp.hits;
            catch
                hits = 0;
            end
            
            try
                misses = p.data{p.trial.pldaps.iTrial-1}.temp.misses;
            catch
                misses = 0;
            end
            
            try
                false_alarms = p.data{p.trial.pldaps.iTrial-1}.temp.false_alarms;
            catch
                false_alarms = 0;
            end
            
            try
                correct_rejects = p.data{p.trial.pldaps.iTrial-1}.temp.correct_rejects;
            catch
                correct_rejects = 0;
            end
            
            try
                early_releases = p.data{p.trial.pldaps.iTrial-1}.temp.early_releases;
            catch
                early_releases = 0;
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
            
            total_completed = hits + misses + false_alarms + correct_rejects;
            total_trials = total_completed + early_releases + delay_errors + fixation_breaks;
            total_correct = hits + correct_rejects;
            
            total_hold = correct_rejects+false_alarms;
            total_release = hits+misses;
            
            HR = hits / total_release;
            MR = misses / total_release;
            FAR = false_alarms / total_hold;
            CR = correct_rejects / total_hold;
            
            sensitivity = norminv(HR)-norminv(FAR);
            bias = -0.5*(norminv(HR)+norminv(FAR));
            
            fprintf('Current performance:\n');
            
            fprintf('\tCompleted trials:  %d of %d (%0.3f)\n',total_completed,total_trials,total_completed/total_trials);
            fprintf('\tEarly releases:  %d of %d (%0.3f)\n',early_releases,total_trials,early_releases/total_trials);
            fprintf('\tDelay error trials:  %d of %d (%0.3f)\n',delay_errors,total_trials,delay_errors/total_trials);
            fprintf('\tFixation break trials:  %d of %d (%0.3f)\n',fixation_breaks,total_trials,fixation_breaks/total_trials);
            fprintf('\n');
            fprintf('\tTotal correct:  %d of %d (%0.3f)\n',total_correct,total_completed,total_correct/total_completed);
            fprintf('\tCorrect hold trials:  %d of %d (%0.3f)\n',correct_rejects,total_hold,correct_rejects/total_hold);
            fprintf('\tCorrect release trials:  %d of %d (%0.3f)\n',hits,total_release,hits/total_release);
            fprintf('\n');
            fprintf('\tHR == %0.03f, MR == %0.03f, FAR == %0.03f, CR == %0.03f\n',HR,MR,FAR,CR);
            fprintf('\tSensitivity:  %0.3f\n',sensitivity);
            fprintf('\tBias:  %0.3f\n',bias);
            fprintf('-----\n\n');
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
                        fprintf('\tThis is a HOLD (NO SET) trial.\n');
                    else
                        fprintf('\tThis is a RELEASE (SET) trial.\n');
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
                        fprintf('\t%s engaged and fixated after %0.3f sec.  Proceed to symbol presentation.\n',p.trial.session.subject,GetSecs-p.trial.temp.timing.ready.start_time);
                        p.trial.temp.timing.ready.start_time = NaN;
                        p.trial.temp.timing.ready.cue_start_time = NaN;
                        p.trial.temp.trial_state = 'symbol';
                        
                        %  Show hold joystick and fixation cues
                        ShowReadyCue;
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
                
                
            case 'symbol'
                
                %  STATE:  symbol
                
                %  Monkey enters the state for the first time with the
                %  joystick engaged and fixating.  Continue to show him
                %  both the symbol cue and the fixation dot as long as this
                %  is the case and we have not yet reached the end of the
                %  symbol presentation sequence.
                %
                %  Will go to next symbol unless current symbol is three
                %  then go to either hold or release depending on trial
                %  type.
                
                
                %  Show ready and fixation cues and symbol
                if(p.trial.temp.state_variables.symbol_on && p.trial.temp.timing.symbol.presentation_duration(p.trial.temp.state_variables.current_symbol)~=0)
                    ShowSymbol;
                end
                ShowReadyCue;
                ShowFixationCue;
                
                if(isnan(p.trial.temp.timing.symbol.sequence_start_time))
                    p.trial.temp.timing.symbol.sequence_start_time = GetSecs;
                    fprintf('SYMBOL PRESENTATION SEQUENCE:  ');
                    fprintf('%s ',p.trial.symbols{:});
                    fprintf('\n');
                end
                
                if(isnan(p.trial.temp.timing.symbol.start_time))
                    
                    %  Start our timers and print some feedback to screen.
                    p.trial.temp.timing.symbol.start_time = GetSecs;
                    if(p.trial.temp.state_variables.symbol_on)
                        p.trial.temp.timing.symbol.duration = p.trial.temp.timing.symbol.presentation_duration(p.trial.temp.state_variables.current_symbol);
                        fprintf('\tPresentation %d of 3 for %0.3f sec:  %s.\n',p.trial.temp.state_variables.current_symbol,p.trial.temp.timing.symbol.duration,p.trial.temp.symbols{p.trial.temp.state_variables.current_symbol});
                    else
                        p.trial.temp.timing.symbol.duration = p.trial.temp.timing.symbol.delay_duration(p.trial.temp.state_variables.current_symbol+1);
                        fprintf('\tDelay %d of 3 for %0.3f sec.\n',p.trial.temp.state_variables.current_symbol+1,p.trial.temp.timing.symbol.duration);
                    end
                    
                elseif(p.trial.temp.timing.symbol.start_time > GetSecs - p.trial.temp.timing.symbol.duration)
                    
                    %  We're still in symbol presentation sequence.  As
                    %  long as he continues to engage and fixate, show him
                    %  the ready and fixation cues as well as a symbol.  If
                    %  he realeses during this period, give him a timeout
                    
                    if(~p.trial.temp.state_variables.joystick_engaged)
                        %  Monkey released joystick early.  Give him a
                        %  timeout
                        
                        fprintf('\t%s released joystick early at %0.3f sec.  Proceed to timeout\n',p.trial.session.subject,...
                            GetSecs-p.trial.temp.timing.symbol.sequence_start_time);
                        p.trial.temp.early_releases = p.trial.temp.early_releases+1;
                        p.trial.temp.trial_state = 'timeout';
                        p.trial.temp.timing.symbol.start_time = NaN;
                        p.trial.temp.timing.symbol.sequence_start_time = NaN;
                    elseif(~p.trial.temp.state_variables.fixating);
                        %  Monkey broke fixation.  Give him a timeout
                        
                        fprintf('\t%s broke fixation after %0.3f sec.  Proceed to timeout.\n',p.trial.session.subject,...
                            GetSecs-p.trial.temp.timing.symbol.sequence_start_time);
                        p.trial.temp.trial_state = 'timeout';
                        p.trial.temp.fixation_breaks = p.trial.temp.fixation_breaks+1;
                        p.trial.temp.timing.symbol.start_time = NaN;
                        p.trial.temp.timing.symbol.sequence_start_time = NaN;
                    end
                    
                else
                    
                    %  Monkey has successfully held the joystick to the end
                    %  of the duration.  If we are done showing
                    %  symbols, proceed to the hold or release cue.
                    %  Otherwise proceed to next step in sequence.
                    
                    %  If this is a delay period then proceed to symbol
                    %  presentation
                    
                    if(p.trial.temp.state_variables.current_symbol < 3)
                        if(p.trial.temp.state_variables.symbol_on)
                            p.trial.temp.state_variables.symbol_on = false;
                            %fprintf('\t% successfully held joystick and remained fixating.  Proceed to delay %d of 3.\n',p.trial.session.subject,p.trial.temp.state_variables.current_symbol);
                        else
                            p.trial.temp.state_variables.current_symbol = p.trial.temp.state_variables.current_symbol + 1;
                            p.trial.temp.state_variables.symbol_on = true;
                            %fprintf('\t %s successfully held joystick and remained fixating.  Proceed to symbol %d of 3.\n',p.trial.session.subject,p.trial.temp.state_variables.current_symbol);
                        end
                    else
                        p.trial.temp.timing.symbol.sequence_start_time = NaN;
                        if(p.trial.temp.state_variables.release_trial)
                            fprintf('\t%s successfully held joystick and remained fixating.  Proceed to release cue.\n',p.trial.session.subject);
                            p.trial.temp.trial_state = 'release';
                        else
                            fprintf('\t%s successfully held joystick and remained fixating.  Proceed to hold cue.\n',p.trial.session.subject);
                            p.trial.temp.trial_state = 'hold';
                        end
                    end
                    p.trial.temp.timing.symbol.start_time = NaN;
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
                
            case 'hold'
                
                %  STATE:  hold
                
                %  In this state we show a hold cue.  Monkey should
                %  hold the joystick for the duration of this state.
                
                ShowHoldCue;
                ShowFixationCue;
                
                if(isnan(p.trial.temp.timing.hold.start_time))
                    p.trial.temp.timing.hold.start_time = GetSecs;
                    fprintf('HOLD state for trial %d.  Hold for %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.temp.timing.hold.duration);
                    
                elseif(p.trial.temp.timing.hold.start_time > GetSecs - p.trial.temp.timing.hold.duration)
                    
                    %  Still in hold period so check joystick
                    if(p.trial.temp.state_variables.joystick_released && p.trial.temp.state_variables.fixating)
                        
                        %  Monkey has released joystick during a hold.  This
                        %  will be counted as a false alarm (an error).
                        
                        fprintf('\t%s released joystick with reaction time %0.3f sec; false alarm.\n',p.trial.session.subject,GetSecs-p.trial.temp.timing.hold.start_time);
                        
                        p.trial.temp.timing.hold.start_time = NaN;
                        p.trial.temp.trial_state = 'error';
                        p.trial.temp.false_alarms = p.trial.temp.false_alarms+1;
                        
                    elseif(~p.trial.temp.state_variables.fixating)
                        
                        %  Monkey broke fixation too early.  Give him a
                        %  timeout.
                        
                        fprintf('\t%s broke fixation after %0.3f sec.  Proceed to timeout.\n',p.trial.session.subject,GetSecs-p.trial.temp.timing.hold.start_time);
                        p.trial.temp.fixation_breaks = p.trial.temp.fixation_breaks+1;
                        
                        p.trial.temp.timing.hold.start_time = NaN;
                        p.trial.temp.trial_state = 'timeout';
                    end
                else
                    %  Monkey has held joystick till end of hold duration.
                    %  This is a correct reject so give him a reward.
                    
                    fprintf('\t%s held joystick to end of hold duration.  He gets a reward.\n',p.trial.session.subject);
                    p.trial.temp.timing.hold.start_time = NaN;
                    p.trial.temp.trial_state = 'reward';
                    p.trial.temp.correct_rejects = p.trial.temp.correct_rejects+1;
                end
                
            case 'release'
                
                %  STATE:  release
                
                %  In this state we show a release cue.  Monkey should
                %  release the joystick prior to the end of the grace
                %  period.
                
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
                    
                    fprintf('\t%s held joystick to end of release duration; this is a miss.\n',p.trial.session.subject);
                    p.trial.temp.misses = p.trial.temp.misses+1;
                    p.trial.temp.trial_state = 'error';
                end
                
            case 'reward_delay'
                
                %  STATE:  reward_delay
                
                %  In this state we continue to show the fixation dot.
                %  Monkey must continue fixating and may not engage the
                %  joystick.  Once this is done we can give him his reward!
                
                ShowFixationCue;
                
                if(isnan(p.trial.temp.timing.reward_delay.start_time))
                    fprintf('REWARD DELAY.  %s must fixate with joystick released for %0.3f sec.\n',p.trial.session.subject,p.trial.temp.timing.reward_delay.duration);
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
                    
                    p.trial.temp.hits = p.trial.temp.hits+1;
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
        win = p.trial.display.overlayptr;
        
        width = p.trial.temp.features.fixation.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.temp.features.fixation.color;
        linewidth = p.trial.temp.features.fixation.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
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


    function ShowSymbol
        %  ShowSymbol
        %
        %  This function draws the symbol.
        
        %  Set initial parameters
        win = p.trial.display.overlayptr;
        
        width = p.trial.temp.features.symbol.width;
        linewidth = p.trial.temp.features.symbol.linewidth;
%         baseRect = [0 0 width width];
%         centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        
        %  Get other features
        
        symbol = p.trial.symbols{p.trial.temp.state_variables.current_symbol};
        
        border = symbol(1);
        fill = symbol(2);
        shape = symbol(3);
        
        %  First get the border color
        border_color = p.trial.display.clut.(set_color(border));
        
        %  Second get the fill color
        fill_color = p.trial.display.clut.(set_color(fill));
        
        %  Third draw based on the shape
        
        switch shape
            case 'C'
                baseRect = [0 0 width+2*linewidth width+2*linewidth];
                centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
                maxDiameter = width+2*linewidth;
                Screen('FillOval',win,border_color,centeredRect,maxDiameter);
                
                baseRect = [0 0 width width];
                centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
                maxDiameter = width;
                Screen('FillOval',win,fill_color,centeredRect,maxDiameter);
            case 'S'
                baseRect = [0 0 (2*linewidth+width)/sqrt(2) (2*linewidth+width)/sqrt(2)];
                centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
                Screen('FillRect',win,border_color,centeredRect);

                baseRect = [0 0 width/sqrt(2) width/sqrt(2)];
                centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
                Screen('FillRect',win,fill_color,centeredRect);

            case 'T'
                cX = p.trial.display.ctr(1);
                cY = p.trial.display.ctr(2);
                a = 0.5*sqrt(3)*(width+2*linewidth);
                alt = 0.5*sqrt(3)*a;
                r = a/sqrt(3);
                xpos = [cX-0.5*a cX+0.5*a cX cX-0.5*a];
                ypos = [cY+(alt-r) cY+(alt-r) cY-r cY+(alt-r)];
                Screen('FillPoly',win,border_color,[xpos; ypos]');
                
                a = a-2*sqrt(3)*linewidth;
                alt = 0.5*sqrt(3)*a;
                r = a/sqrt(3);
                xpos = [cX-0.5*a cX+0.5*a cX cX-0.5*a];
                ypos = [cY+(alt-r) cY+(alt-r) cY-r cY+(alt-r)];
                Screen('FillPoly',win,fill_color,[xpos; ypos]');
        end
        
        function C = set_color(c)
            switch c
                case {'b','B'}
                    C = 'bBlue';
                case {'o','O'}
                    C = 'bOrange';
                case {'y','Y'}
                    C = 'bYellow';
                case {'p','P'}
                    C = 'bPurple';
                case {'g','G'}
                    C = 'bGreen';
                case {'c','C'}
                    C = 'bCyan';
                case {'s','S'}
                    C = 'bScarlet';
                case {'a','A'}
                    C = 'bGray';
                case {'k','K'}
                    C = 'bBlack';
            end
        end
        
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