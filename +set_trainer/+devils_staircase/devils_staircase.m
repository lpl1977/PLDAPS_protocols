function p = devils_staircase(p,state)
%p = devils_staircase(p,state)
%
%  PLDAPS trial function for set game training aka devil's staircase

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
        feval(str2func(strcat('set_trainer.devils_staircase.',p.trial.session.subject)),p);
        
        %  Initialize trial state
        
        p.trial.task.trial_state = 'ready';
        
        %  Update trial counter from last trial
        if(p.trial.pldaps.iTrial==1)
            p.trial.task.trial_counter = 1;
        else
            p.trial.task.trial_counter = p.data{p.trial.pldaps.iTrial-1}.task.trial_counter;
        end
        
        % set / noset
        p.trial.task.state_variables.trial_type = p.conditions{p.trial.task.trial_counter}.trial_type;
        
        %  symbol sequence
        p.trial.task.symbols = p.conditions{p.trial.task.trial_counter}.symbols;
        
        %  Release or hold (catch) trial
        p.trial.task.state_variables.release_trial = logical(binornd(1,p.trial.task.control_variables.(p.trial.task.state_variables.trial_type).release_probability));
        p.trial.task.state_variables.catch_trial = ~p.trial.task.state_variables.release_trial;
        
        %  Initialize symbol counter
        p.trial.task.state_variables.current_symbol = 0;
        p.trial.task.state_variables.symbol_on = false;
        
        %  Initialize or extract performance data
        if(p.trial.pldaps.iTrial==1)
            trial_types = p.trial.task.control_variables.fields;
            for i=1:length(trial_types)
                p.trial.task.staircase.(trial_types{i}) = staircase(p.trial.task.control_variables.(trial_types{i}).M_down,p.trial.task.control_variables.(trial_types{i}).step_spread_ratio);
            end
            p.trial.task.performance.early_releases = 0;
            p.trial.task.performance.delay_errors = 0;
            p.trial.task.performance.fixation_breaks = 0;
            
            p.trial.task.performance.total_completed = 0;
            p.trial.task.performance.total_attempted = 0;
            p.trial.task.performance.total_correct = 0;
        else
            trial_types = p.trial.task.control_variables.fields;
            for i=1:length(trial_types)
                p.trial.task.staircase.(trial_types{i}) = p.data{p.trial.pldaps.iTrial-1}.task.staircase.(trial_types{i});
            end
            
            p.trial.task.performance.early_releases = p.data{p.trial.pldaps.iTrial-1}.task.performance.early_releases;
            p.trial.task.performance.delay_errors = p.data{p.trial.pldaps.iTrial-1}.task.performance.delay_errors;
            p.trial.task.performance.fixation_breaks = p.data{p.trial.pldaps.iTrial-1}.task.performance.fixation_breaks;
            
            p.trial.task.performance.total_completed = p.data{p.trial.pldaps.iTrial-1}.task.performance.total_completed;
            p.trial.task.performance.total_attempted = p.data{p.trial.pldaps.iTrial-1}.task.performance.total_attempted;
            p.trial.task.performance.total_correct = p.data{p.trial.pldaps.iTrial-1}.task.performance.total_correct;
        end
        
        p.trial.task.performance.correct = false;
        p.trial.task.performance.completed = false;
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        %  Update trial counter if trial completed.  If not, then shuffle trial back into remaining.        
        if(p.trial.task.performance.completed)
            p.trial.task.trial_counter = p.trial.task.trial_counter + 1;
        else
            p.conditions(p.trial.task.trial_counter:end) = Shuffle(p.conditions(p.trial.task.trial_counter:end));
        end
        
        
        %  Update staircase
        if(p.trial.task.performance.completed)
            p.trial.task.staircase.(p.trial.task.state_variables.trial_type) = ...
                p.trial.task.staircase.(p.trial.task.state_variables.trial_type).update(p.trial.task.state_variables.release_trial,p.trial.task.performance.correct);
            p.trial.task.performance.total_completed = p.trial.task.performance.total_completed + 1;
            p.trial.task.performance.total_correct = p.trial.task.performance.total_correct + p.trial.task.performance.correct;
        end
        
        %  Display performance
        total_completed = p.trial.task.performance.total_completed;
        total_attempted = p.trial.task.performance.total_attempted;
        total_correct = p.trial.task.performance.total_correct;
        
        early_releases = p.trial.task.performance.early_releases;
        delay_errors = p.trial.task.performance.delay_errors;
        fixation_breaks = p.trial.task.performance.fixation_breaks;
        
        fprintf('\tCompleted trials:  %d of %d (%0.3f)\n',total_completed,total_attempted,total_completed/total_attempted);
        fprintf('\tTotal correct:  %d of %d (%0.3f)\n',total_correct,total_completed,total_correct/total_completed);
        fprintf('\n');
        fprintf('\tEarly releases:  %d of %d (%0.3f)\n',early_releases,total_attempted,early_releases/total_attempted);
        fprintf('\tDelay error trials:  %d of %d (%0.3f)\n',delay_errors,total_attempted,delay_errors/total_attempted);
        fprintf('\tFixation break trials:  %d of %d (%0.3f)\n',fixation_breaks,total_attempted,fixation_breaks/total_attempted);
        fprintf('\n');
        trial_types = p.trial.task.control_variables.fields;
        for i=1:length(trial_types)
            fprintf('%s performance:\n',upper(trial_types{i}));
            p.trial.task.staircase.(trial_types{i}).current_results;
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
        
        switch p.trial.task.trial_state
            
            case 'ready'
                
                %  STATE:  ready
                
                if(isnan(p.trial.task.timing.ready.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.task.timing.ready.start_time = GetSecs;
                    p.trial.task.timing.ready.cue_start_time = GetSecs;
                    fprintf('READY state for trial %d.\n',p.trial.pldaps.iTrial);
                    
                    fprintf('\tThis is a %s ',upper(p.trial.task.state_variables.trial_type));
                                        
                    if(p.trial.task.state_variables.release_trial)
                        fprintf('RELEASE trial with log contrast %0.3f.\n',min(0,p.trial.task.staircase.(p.trial.task.state_variables.trial_type).log_contrast));
                    else
                        fprintf('CATCH trial.\n');
                    end
                    
                    
                    %  If the monkey currently has the joystick engaged
                    %  we're going to have to wait for him to release it
                    %  before proceeding.
                    if(~p.trial.task.state_variables.joystick_released)
                        fprintf('\t%s must release joystick before re-engaging.\n',p.trial.session.subject);
                        p.trial.task.state_variables.wait_for_release = true;
                    else
                        p.trial.task.state_variables.wait_for_release = false;
                    end
                    
                    %  Show ready and fixation cues
                    ShowReadyCue;
                    ShowFixationCue;
                    
                    %  Keep track of attempts
                    p.trial.task.performance.total_attempted = p.trial.task.performance.total_attempted + 1;
                else
                    
                    %  We are still in the ready state.  We will continue
                    %  blinking the ready cue as long as the monkey has not
                    %  engaged the joystick and the fixation cue as long as
                    %  he has not fixated.  Note that if we are waiting for
                    %  him to release the joystick we will blink the ready
                    %  cue even if he has the joystick engaged, so first
                    %  check and see whether or not we are still waiting.
                    if(p.trial.task.state_variables.wait_for_release && p.trial.task.state_variables.joystick_released)
                        p.trial.task.state_variables.wait_for_release = false;
                    end
                    
                    if(~p.trial.task.state_variables.wait_for_release && p.trial.task.state_variables.joystick_engaged && p.trial.task.state_variables.fixating)
                        
                        %  We're not waiting and the monkey has both
                        %  engaged and is fixating.  Print some feedback,
                        %  reset the timing variables, and go on to the
                        %  next state.
                        fprintf('\t%s engaged and fixated after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.ready.start_time);
                        p.trial.task.timing.ready.start_time = NaN;
                        p.trial.task.timing.ready.cue_start_time = NaN;
                        p.trial.task.trial_state = 'symbol';
                        
                        %  Show hold joystick and fixation cues
                        ShowReadyCue;
                        ShowFixationCue;
                        
                    elseif(p.trial.task.timing.ready.cue_start_time > GetSecs - p.trial.task.timing.ready.cue_display_time)
                        
                        %  We're not yet in the blink so show both the
                        %  ready cue and the fixation cue regarless.
                        ShowReadyCue;
                        ShowFixationCue;
                        
                    elseif(p.trial.task.timing.ready.cue_start_time <= GetSecs - p.trial.task.timing.ready.cue_period)
                        
                        %  We've exceeded the duration of the blink, so
                        %  reset the cue start time.
                        p.trial.task.timing.ready.cue_start_time = GetSecs;
                        
                        %  Show the ready and fixation cues regardless
                        ShowReadyCue;
                        ShowFixationCue;
                        
                    else
                        
                        %  We are now in the blink.  Show the ready cue
                        %  only if we are not waiting for monkey to release
                        %  and he has the joystick engaged.
                        
                        if(~p.trial.task.state_variables.wait_for_release && p.trial.task.state_variables.joystick_engaged)
                            ShowReadyCue;
                        end
                        
                        %  Show the fixation cue only if he is fixating.
                        if(p.trial.task.state_variables.fixating)
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
                if(p.trial.task.state_variables.symbol_on && p.trial.task.timing.symbol.presentation_duration(p.trial.task.state_variables.current_symbol)~=0)
                    ShowSymbol;
                end
                ShowContinueHoldCue;
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.symbol.sequence_start_time))
                    p.trial.task.timing.symbol.sequence_start_time = GetSecs;
                    fprintf('SYMBOL PRESENTATION SEQUENCE:  ');
                    fprintf('%s ',p.trial.task.symbols{:});
                    fprintf('\n');
                end
                
                if(isnan(p.trial.task.timing.symbol.start_time))
                    
                    %  Start our timers and print some feedback to screen.
                    p.trial.task.timing.symbol.start_time = GetSecs;
                    if(p.trial.task.state_variables.symbol_on)
                        p.trial.task.timing.symbol.duration = p.trial.task.timing.symbol.presentation_duration(p.trial.task.state_variables.current_symbol);
                        fprintf('\tPresentation %d of 3 for %0.3f sec:  %s.\n',p.trial.task.state_variables.current_symbol,p.trial.task.timing.symbol.duration,p.trial.task.symbols{p.trial.task.state_variables.current_symbol});
                    else
                        p.trial.task.timing.symbol.duration = p.trial.task.timing.symbol.delay_duration(p.trial.task.state_variables.current_symbol+1);
                        fprintf('\tDelay %d of 3 for %0.3f sec.\n',p.trial.task.state_variables.current_symbol+1,p.trial.task.timing.symbol.duration);
                    end
                    
                elseif(p.trial.task.timing.symbol.start_time > GetSecs - p.trial.task.timing.symbol.duration)
                    
                    %  We're still in symbol presentation sequence.  As
                    %  long as he continues to engage and fixate, show him
                    %  the ready and fixation cues as well as a symbol.  If
                    %  he realeses during this period, give him a timeout
                    
                    if(~p.trial.task.state_variables.joystick_engaged)
                        %  Monkey released joystick early.  Give him a
                        %  timeout unless this is the third symbol, in
                        %  which case proceed to result.
                        
                        if(p.trial.task.state_variables.current_symbol < 3)
                            fprintf('\t%s released joystick early at %0.3f sec.\n',p.trial.session.subject,...
                                GetSecs-p.trial.task.timing.symbol.sequence_start_time);
                            p.trial.task.performance.early_releases = p.trial.task.performance.early_releases+1;
                            p.trial.task.trial_state = 'timeout';
                        else
                            fprintf('\t%s released joystick during third symbol at %0.03f sec;  ',p.trial.session.subject,...
                                GetSecs-p.trial.task.timing.symbol.sequence_start_time);
                            if(p.trial.task.state_variables.release_trial)
                                fprintf('go to reward delay.\n');
                                p.trial.task.trial_state = 'reward_delay';
                            else
                                fprintf('go to error.\n');
                                p.trial.task.trial_state = 'error';
                                p.trial.task.performance.correct = false;
                                p.trial.task.performance.completed = true;
                            end
                            p.trial.task.timing.symbol.sequence_start_time = NaN;
                            p.trial.task.timing.symbol.start_time = NaN;
                        end
                        p.trial.task.timing.symbol.start_time = NaN;
                        p.trial.task.timing.symbol.sequence_start_time = NaN;
                    elseif(~p.trial.task.state_variables.fixating);
                        %  Monkey broke fixation.  Give him a timeout
                        
                        fprintf('\t%s broke fixation after %0.3f sec.\n',p.trial.session.subject,...
                            GetSecs-p.trial.task.timing.symbol.sequence_start_time);
                        p.trial.task.trial_state = 'timeout';
                        p.trial.task.performance.fixation_breaks = p.trial.task.performance.fixation_breaks+1;
                        p.trial.task.timing.symbol.start_time = NaN;
                        p.trial.task.timing.symbol.sequence_start_time = NaN;
                    end
                    
                else
                    
                    %  Monkey has successfully held the joystick to the end
                    %  of the duration.  If we are done showing
                    %  symbols, proceed to the hold or release cue.
                    %  Otherwise proceed to next step in sequence.
                    
                    %  If this is a delay period then proceed to symbol
                    %  presentation
                    
                    if(p.trial.task.state_variables.current_symbol < 3)
                        if(p.trial.task.state_variables.symbol_on)
                            p.trial.task.state_variables.symbol_on = false;
                        else
                            p.trial.task.state_variables.current_symbol = p.trial.task.state_variables.current_symbol + 1;
                            p.trial.task.state_variables.symbol_on = true;
                        end
                    else
                        fprintf('\t%s successfully held joystick and remained fixating.\n',p.trial.session.subject);
                        if(p.trial.task.state_variables.release_trial)
                            p.trial.task.trial_state = 'release';
                        else
                            p.trial.task.trial_state = 'hold';
                        end
                        p.trial.task.timing.symbol.sequence_start_time = NaN;
                    end
                    p.trial.task.timing.symbol.start_time = NaN;
                end
                
            case 'timeout'
                
                %  STATE:  timeout
                
                %  In this state we are going to burn a timeout period.
                %  After that is over, end trial.
                
                if(isnan(p.trial.task.timing.timeout.start_time))
                    fprintf('TIMEOUT state for %0.3f sec.\n',p.trial.task.timing.timeout.duration);
                    p.trial.task.timing.timeout.start_time = GetSecs;
                    
                    %  Play the breakfix sound since this is our first time
                    %  into the state
                    pds.audio.play(p,'breakfix');
                    
                elseif(p.trial.task.timing.timeout.start_time <= GetSecs - p.trial.task.timing.timeout.duration)
                    fprintf('\tTimeout elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.task.timing.timeout.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
                
            case 'error'
                
                %  STATE:  error
                
                %  In this state we are going to play an error tone and
                %  burn a timeout period. After that is over, end trial.
                
                if(isnan(p.trial.task.timing.timeout.start_time))
                    fprintf('ERROR state for %0.3f sec.\n',p.trial.task.timing.timeout.duration);
                    p.trial.task.timing.timeout.start_time = GetSecs;
                    
                    
                    %  Play the error sound since this is our first time
                    %  into the state
                    %pds.audio.play(p,'incorrect');
                    
                elseif(p.trial.task.timing.timeout.start_time <= GetSecs - p.trial.task.timing.timeout.duration)
                    fprintf('\tTimeout elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.task.timing.timeout.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
            case 'hold'
                
                %  STATE:  hold
                
                %  In this state we show a hold cue.  Monkey should
                %  hold the joystick for the duration of this state.
                
                ShowHoldCue;
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.hold.start_time))
                    p.trial.task.timing.hold.start_time = GetSecs;
                    fprintf('HOLD state for trial %d.  Hold for %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.task.timing.hold.duration);
                    
                elseif(p.trial.task.timing.hold.start_time > GetSecs - p.trial.task.timing.hold.duration)
                    
                    %  Still in hold period so check joystick
                    if(p.trial.task.state_variables.joystick_released && p.trial.task.state_variables.fixating)
                        
                        %  Monkey has released joystick during a hold.  This
                        %  will be counted as a false alarm (an error).
                        
                        fprintf('\t%s released joystick with reaction time %0.3f sec; error.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.hold.start_time);
                        
                        p.trial.task.timing.hold.start_time = NaN;
                        p.trial.task.trial_state = 'error';
                        p.trial.task.performance.correct = false;
                        p.trial.task.performance.completed = true;
                        
                    elseif(~p.trial.task.state_variables.fixating)
                        
                        %  Monkey broke fixation too early.  Give him a
                        %  timeout.
                        
                        fprintf('\t%s broke fixation after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.hold.start_time);
                        p.trial.task.fixation_breaks = p.trial.task.fixation_breaks+1;
                        
                        p.trial.task.timing.hold.start_time = NaN;
                        p.trial.task.trial_state = 'timeout';
                    end
                else
                    %  Monkey has held joystick till end of hold duration.
                    %  This is a correct reject so give him a reward.
                    
                    fprintf('\t%s held joystick to end of hold duration.  He gets a reward.\n',p.trial.session.subject);
                    p.trial.task.timing.hold.start_time = NaN;
                    p.trial.task.trial_state = 'reward';
                    p.trial.task.performance.correct = true;
                    p.trial.task.performance.completed = true;
                end
                
            case 'release'
                
                %  STATE:  release
                
                %  In this state we show a release cue.  Monkey should
                %  release the joystick prior to the end of the grace
                %  period.
                
                ShowReleaseCue;
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.release.start_time))
                    p.trial.task.timing.release.start_time = GetSecs;
                    fprintf('RELEASE state for trial %d.  Release within %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.task.timing.release.grace);
                    
                elseif(p.trial.task.timing.release.start_time > GetSecs - p.trial.task.timing.release.grace)
                    
                    %  Still in grace period so check joystick
                    if(p.trial.task.state_variables.joystick_released && p.trial.task.state_variables.fixating)
                        
                        %  Monkey has released joystick within the
                        %  appropriate period of time, so he is correct.
                        %  This is a hit.
                        
                        fprintf('\t%s released joystick with reaction time %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.release.start_time);
                        
                        p.trial.task.timing.release.start_time = NaN;
                        p.trial.task.trial_state = 'reward_delay';
                        
                    elseif(~p.trial.task.state_variables.fixating)
                        
                        %  Monkey broke fixation too early.  Give him a
                        %  timeout.
                        
                        fprintf('\t%s broke fixation after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.release.start_time);
                        p.trial.task.fixation_breaks = p.trial.task.fixation_breaks+1;
                        
                        p.trial.task.timing.release.start_time = NaN;
                        p.trial.task.trial_state = 'timeout';
                    end
                else
                    %  Monkey has held joystick till end of grace period,
                    %  this is an error so give him an error and count it
                    %  as a miss.
                    
                    fprintf('\t%s held joystick to end of release duration; this is a miss.\n',p.trial.session.subject);
                    p.trial.task.performance.correct = false;
                    p.trial.task.performance.completed = true;
                    p.trial.task.trial_state = 'error';
                end
                
            case 'reward_delay'
                
                %  STATE:  reward_delay
                
                %  In this state we continue to show the fixation dot.
                %  Monkey must continue fixating and may not engage the
                %  joystick.  Once this is done we can give him his reward!
                
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.reward_delay.start_time))
                    fprintf('REWARD DELAY.  %s must fixate with joystick released for %0.3f sec.\n',p.trial.session.subject,p.trial.task.timing.reward_delay.duration);
                    p.trial.task.timing.reward_delay.start_time = GetSecs;
                elseif(p.trial.task.timing.reward_delay.start_time > GetSecs - p.trial.task.timing.reward_delay.duration)
                    
                    %  Still in delay so check to make sure monkey
                    %  continues to fixate and keep joystick released.
                    
                    if(p.trial.task.state_variables.joystick_engaged)
                        fprintf('\t%s engaged joystick after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.reward_delay.start_time);
                        p.trial.task.trial_state = 'timeout';
                        p.trial.task.performance.delay_errors = p.trial.task.performance.delay_errors+1;
                    elseif(~p.trial.task.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.reward_delay.start_time);
                        p.trial.task.performance.fixation_breaks = p.trial.task.performance.fixation_breaks+1;
                    end
                    
                else
                    
                    %  Monkey completed reward delay so he can get his
                    %  reward now!
                    fprintf('\t%s completed reward delay!\n',p.trial.session.subject);
                    p.trial.task.timing.reward_delay.start_time = NaN;
                    p.trial.task.trial_state = 'reward';
                    p.trial.task.performance.correct = true;
                    p.trial.task.performance.completed = true;
                end
                
            case 'reward'
                
                %  STATE:  reward
                
                %  Provide the monkey with his just desserts.  Screen is
                %  now blank
                
                
                pds.behavior.reward.give(p,p.trial.stimulus.reward_amount);
                %pds.audio.play(p,'reward');
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
        
        width = p.trial.task.features.fixation.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.task.features.fixation.color;
        linewidth = p.trial.task.features.fixation.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

    function ShowReadyCue
        %  ShowReadyCue
        %
        %  This function draws a cue to engage the joystick.
        
        win = p.trial.display.ptr;
        
        width = p.trial.task.features.ready.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.task.features.ready.color;
        linewidth = p.trial.task.features.ready.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

    function ShowContinueHoldCue
        %  ShowContinueHoldCue
        %
        %  This function draws a cue to continue holding the joystick.
        
        win = p.trial.display.ptr;
        
        width = p.trial.task.features.continue_hold.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.task.features.continue_hold.color;
        linewidth = p.trial.task.features.continue_hold.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

    function ShowHoldCue
        %  ShowHoldCue
        %
        %  This function draws a cue to indicate to monkey that he has
        %  engaged the joystick.
        
        win = p.trial.display.ptr;
        
        width = p.trial.task.features.hold.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.task.features.hold.color;
        linewidth = p.trial.task.features.hold.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

    function ShowReleaseCue
        %  ShowReleaseCue
        %
        %  This function draws a cue to indicate to monkey that he should
        %  release the joystick.
        
        win = p.trial.display.ptr;
        
        width = p.trial.task.features.release.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        
        color = p.trial.task.staircase.(p.trial.task.state_variables.trial_type).get_color;
        linewidth = p.trial.task.features.release.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
        
    end


    function ShowSymbol
        %  ShowSymbol
        %
        %  This function draws the symbol.
        
        %  Set initial parameters
        win = p.trial.display.overlayptr;
        
        width = p.trial.task.features.symbol.width;
        linewidth = p.trial.task.features.symbol.linewidth;
        %         baseRect = [0 0 width width];
        %         centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        
        %  Get other features
        
        symbol = p.trial.task.symbols{p.trial.task.state_variables.current_symbol};
        
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
        p.trial.task.state_variables.joystick_released = ~status(1);
        p.trial.task.state_variables.joystick_engaged = ~~status(2);
        
    end

    function check_fixation_status
        %  check_fixation_status
        
        %  Set fixation status
        p.trial.task.state_variables.fixating = true;
        
    end
end