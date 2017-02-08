function p = trial_function(p,state)
%  PLDAPS trial function for set task
%
%  p = only_zuul.trial_function(p,state)

%
%  Call default trial function for general state dependent steps not
%  defined here.  Important to call this prior to custom defined
%  state-dependent steps
%
pldapsDefaultTrialFunction(p,state);

%
%  Custom defined state-dependent steps
%
switch state
    
    case p.trial.pldaps.trialStates.trialSetup
        %  Trial Setup, for example starting up Datapixx ADC and allocating
        %  memory
        %
        %  This is where we would perform any steps that needed to be done
        %  before a trial is started, for example preparing stimuli
        %  parameters
        
        %  Set subject specific parameters / actions
        %
        %  Note this is a little conceptually fuzzy.  In this file are
        %  parameters which need to be set for the initial setup of the
        %  experiment for the specific subject as well as parameters which
        %  may be changed between trials (i.e. reward rate).  This should
        %  probably be segregated.
        feval(str2func(strcat('only_zuul.',p.trial.session.subject)),p);
        
        %  Condition from cell array
        p.trial.condition = p.conditions{p.functionHandles.indexing.trial_number};
        
        %  Initialize trial state variables
        p.functionHandles.state_variables = only_zuul.state_variables(p.trial.condition);
        
        %  Initialize symbol positions
        p.trial.specs.features.symbol.positions = randperm(3)+3*(unidrnd(2)-1);
        
        %  Print trial information to screen
        fprintf('TRIAL ATTEMPT %d:\n',p.trial.pldaps.iTrial);
        fprintf('\t%d of %d possible trials completed.\n',p.functionHandles.performance.completed.total,p.functionHandles.indexing.num_trials);
        fprintf('\tThis is a %s trial with log contrast %0.3f.\n',upper(p.trial.condition.sequence_type),p.trial.condition.log10C);
        fprintf('\tSymbol sequence:  %s %s %s\n',p.trial.condition.symbol_codes{:});
        fprintf('\tPositions:  %s %s %s\n',p.trial.specs.features.symbol.polar{p.trial.specs.features.symbol.positions});
        fprintf('\n');
        
        %  Confirm joystick is attached; if not, then pause experiment
        if(~joystick.connected)
            fprintf('WARNING:  joystick is disconnected!  Please plug it in now during the pause and type dbcont to continue...\n\n');
            p.trial.pldaps.pause.type = 1;
            p.trial.pldaps.quit = 1;
        end
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        %
        %  Perform any steps that should happen upon completion of a trial
        
        %  If we are still in the experiment, then update indexing and deal
        %  with errors and aborts, etc.
        
        if(p.trial.pldaps.quit == 0)
            
            %
            %  Update trial indexing; depending on training flags, shuffle
            %  aborts and errors.
            %
            
            if(p.trial.outcome.completed && (p.trial.outcome.correct || ~p.trial.training_flags.repeat_errors))
                p.functionHandles.indexing.increment;
            else
                if(p.trial.outcome.completed && ~p.trial.outcome.correct)
                    p.functionHandles.indexing.increment;
                end
                if((p.trial.training_flags.shuffle_aborts && ~p.trial.outcome.completed) || (p.trial.outcome.completed && p.trial.training_flags.shuffle_errors))
                    [first_trial,last_trial] = p.functionHandles.indexing.shuffle;
                    fprintf('\tReshuffling trials %d through %d for block %d\n',first_trial,last_trial,p.functionHandles.indexing.current_block);
                end
            end
            
            %  Check if we have completed conditions; if so, we're finished.
            if(p.functionHandles.indexing.conditions_complete)
                p.trial.pldaps.quit=2;
            end
        else
            
            %  Trial was interrupted by user (paused or quit)
            p.trial.outcome = p.functionHandles.performance.interrupted_trial(p.trial.pldaps.quit);
        end
        
        %  Display performance
        p.functionHandles.performance.display_performance;
        
    case p.trial.pldaps.trialStates.frameDraw
        %  Final image has been calculated and will now be drawn
        %
        %  This is where all calls to Screen should be done.
        
        %  Display joystick status to screen
        display_joystick_status;
        
        %  Display fixation window
        display_fixation_window;
        
        %  If enabled, show the symbols
        if(p.functionHandles.state_variables.show_symbols)
            ShowSymbols;
        end
        
        %  If enabled, show the response cue
        if(p.functionHandles.state_variables.show_response_cue)
            ShowResponseCue;
        end
        
        %  If enabled, show fixation cue
        if(p.functionHandles.state_variables.show_fixation_cue)
            ShowFixationCue;
        end
        
    case p.trial.pldaps.trialStates.frameDrawingFinished
        %  Here we could do any steps that need to be done immediately
        %  prior to the flip.
        
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update is called once after the last frame is done (or
        %  even before).  Get current eyepostion, curser position,
        %  keypresses, joystick position, etc. in preparation for the
        %  subsequent trial
        
        %  Get current fixation status
        check_fixation_status;
        
        %  Get current joystick status
        check_joystick_status;
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control (just don't actually make the Screen calls
        %  here).
        
        %  Reset drawing state variables
        p.functionHandles.state_variables.show_fixation_cue = false;
        p.functionHandles.state_variables.show_symbols = false;
        p.functionHandles.state_variables.show_response_cue = false;
        
        %
        %  Control trial events based on trial state
        %
        
        switch p.functionHandles.state_variables.trial_state
            
            case 'start'
                
                %  STATE:  start
                
                %  If monkey has joystick released then go to engage state.
                %  Otherwise go to joystick warning.
                
                fprintf('START state\n');
                
                %  Always show a fixation cue
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                if(~p.functionHandles.state_variables.joystick_released)
                    
                    %  Monkey does not have joystick released.
                    fprintf('\t%s started trial without joystick released; go to joystick warning.\n',p.trial.session.subject);
                    p.functionHandles.state_variables.wait_for_release = true;
                    p.functionHandles.state_variables.trial_state = 'joystick_warning';
                    
                else
                    
                    %  Monkey has joystick released.
                    fprintf('\t%s started trial with joystick released; go to engage.\n',p.trial.session.subject);
                    p.functionHandles.state_variables.trial_state = 'engage';
                    
                end
                
            case 'engage'
                
                %  STATE:  engage
                
                %  Start trial once monkey has joystick engaged and is
                %  fixating.
                
                %  Show fixation cue except during blink
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                if(isnan(p.trial.specs.timing.engage.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.specs.timing.engage.start_time = GetSecs;
                    p.trial.specs.timing.engage.cue_start_time = GetSecs;
                    
                    fprintf('ENGAGE state\n');
                    
                    %  If the monkey is not currently fixating then we're
                    %  going to have to wait for him to fixate.
                    if(~p.functionHandles.state_variables.fixating)
                        fprintf('\t%s must fixate before we may proceed.\n',p.trial.session.subject);
                        p.functionHandles.state_variables.wait_for_fixation = true;
                    else
                        p.functionHandles.state_variables.wait_for_fixation = false;
                    end
                    
                    %  If the monkey does not currently have the joystick
                    %  engaged then we are going to have to wait for him to
                    %  engage.
                    if(~p.functionHandles.state_variables.joystick_engaged)
                        fprintf('\t%s must engage joystick before we may proceed.\n',p.trial.session.subject);
                        p.functionHandles.state_variables.wait_for_engage = true;
                    else
                        p.functionHandles.state_variables.wait_for_engage = false;
                    end
                    
                else
                    
                    %  We are still in the engage state.  We will continue
                    %  checking the joystick and fixation and will blink
                    %  the fixation cue as long as the monkey has neither
                    %  engaged the joystick, fixated, nor elapsed the total
                    %  trial time limit.
                    
                    %  Check trial time first; cut him off if he doesn't
                    %  have time to actually complete the trial
                    
                    if(p.trial.ttime > p.trial.pldaps.maxTrialLength-p.trial.specs.constants.min_trial_time)
                        fprintf('\t%s did not initiate trial within %0.3f sec.  Give him a timeout.\n',p.trial.session.subject,p.trial.pldaps.maxTrialLength-60);
                        
                        %  Nothing more to see so set trial state to blank
                        p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'failed to initiate');
                        p.trial.specs.timing.engage.start_time = NaN;
                        p.trial.specs.timing.engage.cue_start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'timeout';
                        p.functionHandles.state_variables.show_fixation_cue = false;
                        
                    elseif(p.functionHandles.state_variables.joystick_engaged && p.functionHandles.state_variables.fixating)
                        
                        %  The monkey has both joystick engaged and is
                        %  fixating.  Print some feedback, reset the timing
                        %  variables, and go on to the delay state.
                        fprintf('\t%s engaged joystick and is fixating after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.engage.start_time);
                        p.trial.specs.timing.engage.start_time = NaN;
                        p.trial.specs.timing.engage.cue_start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'delay';
                        
                    elseif(p.functionHandles.state_variables.joystick_pressed || p.functionHandles.state_variables.joystick_press_buffer)
                        
                        %  The monkey overshot the engage region.
                        fprintf('\t%s pressed the joystick after %0.3f sec; go to joystick warning.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.engage.start_time);
                        p.trial.specs.timing.engage.start_time = NaN;
                        p.trial.specs.timing.engage.cue_start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'joystick_warning';
                        
                    elseif(p.trial.specs.timing.engage.cue_start_time > GetSecs - p.trial.specs.timing.engage.cue_display_time)
                        
                        %  We're not yet in the blink so show the fixation
                        %  cue regarless.
                        
                    elseif(p.trial.specs.timing.engage.cue_start_time <= GetSecs - (p.trial.specs.timing.engage.cue_display_time + p.trial.specs.timing.engage.cue_extinguish_time))
                        
                        %  We've exceeded the duration of the blink, so
                        %  reset the cue start time.
                        p.trial.specs.timing.engage.cue_start_time = GetSecs;
                        
                    else
                        %  We are in the blink so turn the fixation cue off
                        p.functionHandles.state_variables.show_fixation_cue = false;
                    end
                end
                
            case 'delay'
                
                %  STATE:  delay
                
                %  Monkey enters the state for the first time with the
                %  joystick engaged and fixating.  Continue to show him the
                %  fixation cue as long as this is the case and we have not
                %  yet reached the end of the delay period.
                
                
                %  Always show a fixation cue
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                if(isnan(p.trial.specs.timing.delay.start_time))
                    
                    p.trial.specs.timing.delay.start_time = GetSecs;
                    fprintf('DELAY state for %0.3f sec.\n',p.trial.specs.timing.delay.duration);
                    
                elseif(p.trial.specs.timing.delay.start_time > GetSecs - p.trial.specs.timing.delay.duration)
                    
                    %  We're still in the delay period.  As long as he
                    %  continues to engage and fixate, show him the
                    %  fixation cue.  If he releases or breaks fixation
                    %  during this period, give him a timeout.  If he
                    %  pushes the joystick too far then give him a joystick
                    %  warning.
                    
                    if(~p.functionHandles.state_variables.joystick_engaged)
                        
                        %  Monkey released or pressed joystick early.
                        if(p.functionHandles.state_variables.joystick_released || p.functionHandles.state_variables.joystick_release_buffer)
                            fprintf('\t%s released joystick at %0.3f sec; go to engage.\n',...'delay'
                                p.trial.session.subject,GetSecs-p.trial.specs.timing.delay.start_time);
                            p.functionHandles.state_variables.trial_state = 'engage';
                        else
                            fprintf('\t%s pressed joystick at %0.3f sec, give him a joystick warning.\n',...
                                p.trial.session.subject,GetSecs-p.trial.specs.timing.delay.start_time);
                            p.functionHandles.state_variables.trial_state = 'joystick_warning';
                        end
                        p.trial.specs.timing.delay.start_time = NaN;
                        
                    elseif(~p.functionHandles.state_variables.fixating)
                        
                        %  Monkey broke fixation.
                        fprintf('\t%s broke fixation after %0.3f sec; give him an eye warning.\n',...
                            p.trial.session.subject,GetSecs-p.trial.specs.timing.delay.start_time);
                        p.trial.specs.timing.delay.start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'eye_warning';
                        
                    end
                else
                    
                    %  Monkey has successfully held the joystick engaged
                    %  and fixated to the end of the duration.
                    fprintf('\t%s successfully held joystick engaged and remained fixating.\n',p.trial.session.subject);
                    p.functionHandles.state_variables.trial_state = 'symbol';
                    p.trial.specs.timing.delay.start_time = NaN;
                    
                end
                
            case 'joystick_warning'
                
                %  STATE:  joystick_warning
                
                %  Monkey enters this state if he has pushed the joystick
                %  too far.  Exit joystick warning when he gets the
                %  joystick into the appropriate range (either release or
                %  engage).
                
                %  Fixation cue will be red
                
                %  Always show a fixation cue unless he times out
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                if(isnan(p.trial.specs.timing.joystick_warning.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.specs.timing.joystick_warning.start_time = GetSecs;
                    fprintf('JOYSTICK WARNING started for %0.3f sec.\n',p.trial.specs.timing.joystick_warning.duration);
                    
                    %  Play the joystick warning until he returns joystick
                    %  to appropriate position
                    pds.audio.play(p,'joystick_warning',Inf);
                    
                elseif(p.trial.specs.timing.joystick_warning.start_time > GetSecs - p.trial.specs.timing.joystick_warning.duration)
                    
                    
                    %  We are still in the joystick warning state.  We will
                    %  continue the joystick warning as long as the monkey
                    %  has not moved the joystick back into the appropriate
                    %  range.
                    
                    if(p.functionHandles.state_variables.wait_for_release && p.functionHandles.state_variables.joystick_released)
                        p.functionHandles.state_variables.wait_for_release = false;
                        
                        %  Monkey released joystick
                        fprintf('\t%s released joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.joystick_warning.start_time);
                        p.trial.specs.timing.joystick_warning.start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'engage';
                        
                        %  Stop the joystick warning tone
                        pds.audio.stop(p,'joystick_warning');
                        
                    elseif(~p.functionHandles.state_variables.wait_for_release)
                        if(p.functionHandles.state_variables.joystick_engaged)
                            
                            %  Monkey has joystick engaged
                            fprintf('\t%s re-engaged joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.joystick_warning.start_time);
                            p.trial.specs.timing.joystick_warning.start_time = NaN;
                            p.functionHandles.state_variables.trial_state = 'delay';
                            
                            %  Stop the joystick warning tone
                            pds.audio.stop(p,'joystick_warning');
                            
                        elseif(p.functionHandles.state_variables.joystick_released || p.functionHandles.state_variables.joystick_release_buffer)
                            
                            %  Monkey has somehow managed to pass back
                            %  through the engaged state
                            fprintf('\t%s released joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.joystick_warning.start_time);
                            p.trial.specs.timing.joystick_warning.start_time = NaN;
                            p.functionHandles.state_variables.trial_state = 'start';
                            
                            %  Stop the joystick warning tone
                            pds.audio.stop(p,'joystick_warning');
                            
                        end
                    end
                    
                else
                    
                    %  Monkey has failed to re-engage within the joystick
                    %  warning duration
                    
                    %  Stop the joystick warning tone
                    pds.audio.stop(p,'joystick_warning');
                    
                    fprintf('\t%s elapsed his joystick warning interval.  Give him a timeout\n',p.trial.session.subject);
                    
                    p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'joystick warning elapsed');
                    p.trial.specs.timing.joystick_warning.start_time = NaN;
                    p.functionHandles.state_variables.trial_state = 'timeout';
                    p.functionHandles.state_variables.show_fixation_cue = false;
                    
                end
                
            case 'eye_warning'
                
                %  STATE:  eye_warning
                
                %  Monkey enters this state if he has broken fixation
                %  during the delay period.  Exit eye warning when he is
                %  fixating and has the joystick engaged.  If he releases
                %  go back to engage and if he presses go back to warning.
                %  While in the eye warning we will blink the fixation cue
                %  at him as in the engage state.
                
                %  Always show a fixation cue unless he times out or is in
                %  a blink
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                if(isnan(p.trial.specs.timing.eye_warning.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.specs.timing.eye_warning.start_time = GetSecs;
                    p.trial.specs.timing.eye_warning.cue_start_time = GetSecs;
                    fprintf('EYE WARNING started for %0.3f sec.\n',p.trial.specs.timing.eye_warning.duration);
                    
                    %  Play the eye warning until he returns to fixation
                    pds.audio.play(p,'eye_warning',Inf);
                    
                    %  Show fixation cue
                    p.functionHandles.state_variables.show_fixation_cue = true;
                    
                elseif(p.trial.specs.timing.eye_warning.start_time <= GetSecs - p.trial.specs.timing.eye_warning.duration)
                    
                    %  Monkey has failed to fixate during the warning
                    %  duration
                    
                    %  Stop the eye warning tone
                    pds.audio.stop(p,'eye_warning');
                    
                    fprintf('\t%s elapsed his eye warning interval.  Give him a timeout.\n',p.trial.session.subject);
                    
                    p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'eye warning elapsed');
                    p.trial.specs.timing.eye_warning.start_time = NaN;
                    p.trial.specs.timing.eye_warning.cue_start_time = GetSecs;
                    p.functionHandles.state_variables.trial_state = 'timeout';
                    p.functionHandles.state_variables.show_fixation_cue = false;
                    
                else
                    
                    %  We are still in the eye warning state.  We will
                    %  continue to check fixation and blink the fixation
                    %  cue as long as the monkey has not returned to
                    %  fixation and we haven't elapsed the maximum warning
                    %  time.
                    
                    if(p.functionHandles.state_variables.fixating)
                        
                        %  The monkey has returned to fixation!  Reset the
                        %  timing variables and go back to the delay state.
                        fprintf('\t%s fixated after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.eye_warning.start_time);
                        p.trial.specs.timing.eye_warning.start_time = NaN;
                        p.trial.specs.timing.eye_warning.cue_start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'delay';
                        
                        %  Stop the eye warning tone
                        pds.audio.stop(p,'eye_warning');
                        
                    elseif(p.functionHandles.state_variables.joystick_pressed || p.functionHandles.state_variables.joystick_press_buffer)
                        
                        %  The monkey overshot the engage region.
                        fprintf('\t%s pressed the joystick after %0.3f sec; go to joystick warning.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.eye_warning.start_time);
                        p.trial.specs.timing.eye_warning.start_time = NaN;
                        p.trial.specs.timing.eye_warning.cue_start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'joystick_warning';
                        
                        %  Stop the eye warning tone
                        pds.audio.stop(p,'eye_warning');
                        
                    elseif(p.functionHandles.state_variables.joystick_released || p.functionHandles.state_variables.joystick_release_buffer)
                        
                        %  The monkey released the joystick.
                        fprintf('\t%s released the joystick after %0.3f sec; go to engage.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.eye_warning.start_time);
                        p.trial.specs.timing.eye_warning.start_time = NaN;
                        p.trial.specs.timing.eye_warning.cue_start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'engage';
                        
                        %  Stop the eye warning tone
                        pds.audio.stop(p,'eye_warning');
                        
                    elseif(p.trial.specs.timing.eye_warning.cue_start_time > GetSecs - p.trial.specs.timing.eye_warning.cue_display_time)
                        
                        %  We're not yet in the blink so show the fixation
                        %  cue regarless.
                        
                    elseif(p.trial.specs.timing.eye_warning.cue_start_time <= GetSecs - (p.trial.specs.timing.eye_warning.cue_display_time + p.trial.specs.timing.eye_warning.cue_extinguish_time))
                        
                        %  We've exceeded the duration of the blink, so
                        %  reset the cue start time.
                        p.trial.specs.timing.eye_warning.cue_start_time = GetSecs;
                        
                    else
                        
                        %  We're in the blink so turn off the fixation cue
                        p.functionHandles.state_variables.show_fixation_cue = false;
                    end
                end
                
            case 'symbol'
                
                %  STATE:  symbol
                
                %  Monkey enters the state for the first time with the
                %  joystick engaged and fixating.  Continue to show him the
                %  fixation cue as long as this is the case and we have not
                %  yet reached the end of the symbol presentation period.
                %
                %  Monkey should remain fixating with joystick engaged for
                %  entire duration of this period
                
                %  Always show a fixation cue unless he aborts
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                %  Always show symbols unless he aborts
                p.functionHandles.state_variables.show_symbols = true;
                
                if(isnan(p.trial.specs.timing.symbol.start_time))
                    p.trial.specs.timing.symbol.start_time = GetSecs;
                    
                    fprintf('SYMBOL %s, %d of 3 for %0.3f sec.\n',p.trial.condition.symbol_codes{p.functionHandles.state_variables.current_symbol},p.functionHandles.state_variables.current_symbol,p.trial.specs.timing.symbol.display_time);
                    
                elseif(~p.functionHandles.state_variables.joystick_engaged)
                    
                    %  Monkey released or pressed joystick early.
                    if(p.functionHandles.state_variables.joystick_released || p.functionHandles.state_variables.joystick_release_buffer)
                        fprintf('\t%s released joystick at %0.3f sec, give him a timeout.\n',...
                            p.trial.session.subject,GetSecs-p.trial.specs.timing.symbol.start_time);
                        p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'early release');
                    else
                        fprintf('\t%s pressed joystick at %0.3f sec, give him a timeout.\n',...
                            p.trial.session.subject,GetSecs-p.trial.specs.timing.symbol.start_time);
                        p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'early press');
                    end
                    p.functionHandles.state_variables.trial_state = 'timeout';
                    p.trial.specs.timing.symbol.start_time = NaN;
                    p.functionHandles.state_variables.show_fixation_cue = false;
                    p.functionHandles.state_variables.show_symbols = false;
                    
                elseif(~p.functionHandles.state_variables.fixating)
                    
                    %  Monkey broke fixation.
                    fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',...
                        p.trial.session.subject,GetSecs-p.trial.specs.timing.symbol.start_time);
                    p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'fixation break');
                    p.trial.specs.timing.symbol.start_time = NaN;
                    p.functionHandles.state_variables.trial_state = 'timeout';
                    p.functionHandles.state_variables.show_fixation_cue = false;
                    p.functionHandles.state_variables.show_symbols = false;
                    
                elseif(p.trial.specs.timing.symbol.start_time <= GetSecs - (p.trial.specs.timing.symbol.display_time + p.trial.specs.timing.symbol.interval))
                    
                    %  We have reached the end of the current symbol, so
                    %  update
                    p.trial.specs.timing.symbol.start_time = NaN;
                    if(p.functionHandles.state_variables.current_symbol==3)
                        if(~p.trial.training_flags.continue_symbols)
                            p.functionHandles.state_variables.show_symbols = false;
                        end
                        p.functionHandles.state_variables.trial_state = 'response_cue';
                    else
                        p.functionHandles.state_variables.current_symbol = p.functionHandles.state_variables.current_symbol + 1;
                    end
                    
                elseif(p.trial.specs.timing.symbol.start_time > GetSecs - p.trial.specs.timing.symbol.display_time || p.trial.training_flags.continue_symbols)
                    
                    %  Nothing exciting happened.  Keep showing the symbol
                    %  if we are not in the interval or if we are
                    %  continuing to show the symbols after the display
                    %  time
                    
                else
                    
                    %  We are in the interval between symbols so blank the
                    %  symbol
                    p.functionHandles.state_variables.show_symbols = false;
                end
                
            case 'timeout'
                
                %  STATE:  timeout
                
                %  In this state we are going to give the monkey a timeout
                %  period. After that is over, end trial.
                
                if(isnan(p.trial.specs.timing.timeout.start_time))
                    fprintf('TIMEOUT state for %0.3f sec...  ',p.trial.specs.timing.timeout.duration);
                    p.trial.specs.timing.timeout.start_time = GetSecs;
                    
                    %  Play a really annoying sound here
                    pds.audio.play(p,'timeout',1);
                    
                elseif(p.trial.specs.timing.timeout.start_time <= GetSecs - p.trial.specs.timing.timeout.duration)
                    fprintf('Timeout elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.specs.timing.timeout.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
                
            case 'error'
                
                %  STATE:  error
                
                %  In this state we are going to give the monkey a time
                %  penalty for an error and end the trial.  No need for a
                %  fixation dot
                
                if(isnan(p.trial.specs.timing.error_penalty.start_time))
                    fprintf('ERROR state for %0.3f sec...  ',p.trial.specs.timing.error_penalty.duration);
                    p.trial.specs.timing.error_penalty.start_time = GetSecs;
                    pds.audio.play(p,'incorrect',1);
                    
                elseif(p.trial.specs.timing.error_penalty.start_time <= GetSecs - p.trial.specs.timing.error_penalty.duration)
                    fprintf('Error penalty elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.specs.timing.error_penalty.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
            case 'response_cue'
                
                %  STATE:  response_cue
                
                %  In this state we show a response cue.  Monkey should
                %  either press or release the joystick prior to the end of
                %  the grace period in order to convey his response.
                
                %  Show fixation cue always in this state unless he aborts
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                %  Only show repsonse cue if he is fixating and engaged
                
                if(isnan(p.trial.specs.timing.response_cue.start_time))
                    
                    p.trial.specs.timing.response_cue.reaction_time = NaN;
                    p.trial.specs.timing.response_cue.buffer_entry_time = NaN;
                    
                    p.trial.specs.timing.response_cue.start_time = GetSecs;
                    
                    if(p.trial.training_flags.continue_symbols)
                        p.functionHandles.state_variables.show_symbols = true;
                    end
                    p.functionHandles.state_variables.show_response_cue = true;
                    
                    fprintf('RESPONSE state for trial %d.  Respond within %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.specs.timing.response_cue.grace);
                    
                elseif(p.trial.specs.timing.response_cue.start_time > GetSecs - p.trial.specs.timing.response_cue.grace)
                    
                    %  Still in grace period so check joystick as long as
                    %  he is still fixating
                    if(p.functionHandles.state_variables.fixating)
                        
                        if(p.trial.training_flags.continue_symbols)
                            p.functionHandles.state_variables.show_symbols = true;
                        end
                        p.functionHandles.state_variables.show_response_cue = true;
                        if(isnan(p.trial.specs.timing.response_cue.reaction_time))
                            if(~p.functionHandles.state_variables.joystick_engaged)
                                p.trial.specs.timing.response_cue.reaction_time = GetSecs - p.trial.specs.timing.response_cue.start_time;
                            end
                        end
                        
                        if(p.functionHandles.state_variables.joystick_released)
                            
                            %  Monkey has released the joystick
                            
                            fprintf('\t%s released joystick with reaction time %0.3f sec ',p.trial.session.subject,p.trial.specs.timing.response_cue.reaction_time);
                            
                            if(~isnan(p.trial.specs.timing.response_cue.buffer_entry_time))
                                p.trial.specs.timing.response_cue.buffer_dwell_time = GetSecs - p.trial.specs.timing.response_cue.buffer_entry_time;
                                fprintf('(%0.3f sec in buffer).\n',p.trial.specs.timing.response_cue.buffer_dwell_time);
                            else
                                p.trial.specs.timing.response_cue.buffer_dwell_time = 0;
                                fprintf('(<0.0083 sec in buffer).\n');
                            end
                            
                            p.trial.specs.timing.response_cue.response_duration = GetSecs - p.trial.specs.timing.response_cue.reaction_time - p.trial.specs.timing.response_cue.start_time;
                            fprintf('\tResponse duration was %0.3f sec.\n',p.trial.specs.timing.response_cue.response_duration);
                            
                            if(p.functionHandles.state_variables.release_trial)
                                p.functionHandles.state_variables.trial_state = 'reward_delay';
                            else
                                p.functionHandles.state_variables.trial_state = 'error_delay';
                            end
                            p.trial.specs.timing.response_cue.start_time = NaN;
                            p.functionHandles.state_variables.wait_for_release = false;
                            
                        elseif(p.functionHandles.state_variables.joystick_release_buffer)
                            
                            %  Joystick is now in the release buffer.
                            
                            if(isnan(p.trial.specs.timing.response_cue.buffer_entry_time))
                                p.trial.specs.timing.response_cue.buffer_entry_time = GetSecs;
                                
                            elseif(p.trial.specs.timing.response_cue.buffer_entry_time <= GetSecs - p.trial.specs.timing.response_cue.buffer_maximum_time)
                                %  the maximum time has elapsed and
                                %  joystick is not fully released.  Abort
                                %  the trial
                                fprintf('\t%s drifted out of engage state at %0.3f sec without fully releasing joystick.\n',p.trial.session.subject,p.trial.specs.timing.response_cue.reaction_time);
                                
                                p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'release drift error');
                                p.trial.specs.timing.response_cue.start_time = NaN;
                                p.functionHandles.state_variables.trial_state = 'timeout';
                                p.functionHandles.state_variables.show_fixation_cue = false;
                            end
                            
                        elseif(p.functionHandles.state_variables.joystick_pressed)
                            
                            %  Monkey has pressed the joystick
                            
                            fprintf('\t%s pressed joystick with reaction time %0.3f sec ',p.trial.session.subject,p.trial.specs.timing.response_cue.reaction_time);
                            
                            if(~isnan(p.trial.specs.timing.response_cue.buffer_entry_time))
                                p.trial.specs.timing.response_cue.buffer_dwell_time = GetSecs - p.trial.specs.timing.response_cue.buffer_entry_time;
                                fprintf('(%0.3f sec in buffer).\n',p.trial.specs.timing.response_cue.buffer_dwell_time);
                            else
                                p.trial.specs.timing.response_cue.buffer_dwell_time = 0;
                                fprintf('(<0.0083 sec in buffer).\n');
                            end
                            p.trial.specs.timing.response_cue.response_duration = GetSecs - p.trial.specs.timing.response_cue.reaction_time - p.trial.specs.timing.response_cue.start_time;
                            
                            if(p.functionHandles.state_variables.press_trial)
                                p.functionHandles.state_variables.trial_state = 'reward_delay';
                            else
                                p.functionHandles.state_variables.trial_state = 'error_delay';
                            end
                            
                            p.trial.specs.timing.response_cue.start_time = NaN;
                            p.functionHandles.state_variables.wait_for_release = p.trial.training_flags.release_for_reward;
                            
                        elseif(p.functionHandles.state_variables.joystick_press_buffer)
                            
                            %  Joystick is now in the press buffer.
                            
                            if(isnan(p.trial.specs.timing.response_cue.buffer_entry_time))
                                p.trial.specs.timing.response_cue.buffer_entry_time = GetSecs;
                                
                            elseif(p.trial.specs.timing.response_cue.buffer_entry_time <= GetSecs - p.trial.specs.timing.response_cue.buffer_maximum_time)
                                %  the maximum time has elapsed and
                                %  joystick is not fully pressed.  Abort
                                %  the trial
                                fprintf('\t%s drifted out of engage state at %0.3f sec without fully pressing joystick.  Give him a timeout.\n',p.trial.session.subject,p.trial.specs.timing.response_cue.reaction_time);
                                p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'press drift error');
                                p.trial.specs.timing.response_cue.start_time = NaN;
                                p.functionHandles.state_variables.trial_state = 'timeout';
                                p.functionHandles.state_variables.show_fixation_cue = false;
                            end
                        end
                    else
                        
                        %  Monkey broke fixation too early.  Give him a
                        %  timeout.
                        
                        fprintf('\t%s broke fixation after %0.3f sec.  Give him a timeout.\n',p.trial.session.subject,GetSecs-p.trial.specs.timing.response_cue.start_time);
                        p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'fixation break');
                        p.functionHandles.state_variables.trial_state = 'timeout';
                        p.functionHandles.state_variables.show_fixation_cue = false;
                    end
                    
                else
                    
                    %  Monkey has held joystick till end of grace period,
                    %  so give him a timeout
                    
                    fprintf('\t%s held joystick to end of response duration; this is a missed response.\n',p.trial.session.subject);
                    p.trial.specs.timing.response_cue.start_time = NaN;
                    p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'miss');
                    p.functionHandles.state_variables.trial_state = 'timeout';
                    p.functionHandles.state_variables.show_fixation_cue = false;
                end
                
            case 'response_initiated'
                
                %  STATE:  response_initiated
                
                %  We enter this state once an eligible response is
                %  detected.
                                
                %  Show fixation cue always in this state unless he aborts
                p.functionHandles.state_variables.show_fixation_cue = true;                
                
                if(p.functionHandles.state_variables.joystick_released)
                    
                    %  Monkey has released the joystick
                    
                    fprintf('\t%s released joystick with reaction time %0.3f sec ',p.trial.session.subject,p.trial.specs.timing.response_cue.reaction_time);
                    
                    if(~isnan(p.trial.specs.timing.response_cue.buffer_entry_time))
                        p.trial.specs.timing.response_cue.buffer_dwell_time = GetSecs - p.trial.specs.timing.response_cue.buffer_entry_time;
                        fprintf('(%0.3f sec in buffer).\n',p.trial.specs.timing.response_cue.buffer_dwell_time);
                    else
                        p.trial.specs.timing.response_cue.buffer_dwell_time = 0;
                        fprintf('(<0.0083 sec in buffer).\n');
                    end
                    
                    p.trial.specs.timing.response_cue.response_duration = GetSecs - p.trial.specs.timing.response_cue.reaction_time - p.trial.specs.timing.response_cue.start_time;
                    fprintf('\tResponse duration was %0.3f sec.\n',p.trial.specs.timing.response_cue.response_duration);
                    
                    if(p.functionHandles.state_variables.release_trial)
                        p.functionHandles.state_variables.trial_state = 'reward_delay';
                    else
                        p.functionHandles.state_variables.trial_state = 'error_delay';
                    end
                    p.trial.specs.timing.response_cue.start_time = NaN;
                    p.functionHandles.state_variables.wait_for_release = false;
                    
                elseif(p.functionHandles.state_variables.joystick_release_buffer)
                    
                    %  Joystick is now in the release buffer.
                    
                    if(isnan(p.trial.specs.timing.response_cue.buffer_entry_time))
                        p.trial.specs.timing.response_cue.buffer_entry_time = GetSecs;
                        
                    elseif(p.trial.specs.timing.response_cue.buffer_entry_time <= GetSecs - p.trial.specs.timing.response_cue.buffer_maximum_time)
                        %  the maximum time has elapsed and
                        %  joystick is not fully released.  Abort
                        %  the trial
                        fprintf('\t%s drifted out of engage state at %0.3f sec without fully releasing joystick.\n',p.trial.session.subject,p.trial.specs.timing.response_cue.reaction_time);
                        
                        p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'release drift error');
                        p.trial.specs.timing.response_cue.start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'timeout';
                        p.functionHandles.state_variables.show_fixation_cue = false;
                    end
                    
                elseif(p.functionHandles.state_variables.joystick_pressed)
                    
                    %  Monkey has pressed the joystick
                    
                    fprintf('\t%s pressed joystick with reaction time %0.3f sec ',p.trial.session.subject,p.trial.specs.timing.response_cue.reaction_time);
                    
                    if(~isnan(p.trial.specs.timing.response_cue.buffer_entry_time))
                        p.trial.specs.timing.response_cue.buffer_dwell_time = GetSecs - p.trial.specs.timing.response_cue.buffer_entry_time;
                        fprintf('(%0.3f sec in buffer).\n',p.trial.specs.timing.response_cue.buffer_dwell_time);
                    else
                        p.trial.specs.timing.response_cue.buffer_dwell_time = 0;
                        fprintf('(<0.0083 sec in buffer).\n');
                    end
                    p.trial.specs.timing.response_cue.response_duration = GetSecs - p.trial.specs.timing.response_cue.reaction_time - p.trial.specs.timing.response_cue.start_time;
                    
                    if(p.functionHandles.state_variables.press_trial)
                        p.functionHandles.state_variables.trial_state = 'reward_delay';
                    else
                        p.functionHandles.state_variables.trial_state = 'error_delay';
                    end
                    
                    p.trial.specs.timing.response_cue.start_time = NaN;
                    p.functionHandles.state_variables.wait_for_release = p.trial.training_flags.release_for_reward;
                    
                elseif(p.functionHandles.state_variables.joystick_press_buffer)
                    
                    %  Joystick is now in the press buffer.
                    
                    if(isnan(p.trial.specs.timing.response_cue.buffer_entry_time))
                        p.trial.specs.timing.response_cue.buffer_entry_time = GetSecs;
                        
                    elseif(p.trial.specs.timing.response_cue.buffer_entry_time <= GetSecs - p.trial.specs.timing.response_cue.buffer_maximum_time)
                        %  the maximum time has elapsed and
                        %  joystick is not fully pressed.  Abort
                        %  the trial
                        fprintf('\t%s drifted out of engage state at %0.3f sec without fully pressing joystick.  Give him a timeout.\n',p.trial.session.subject,p.trial.specs.timing.response_cue.reaction_time);
                        p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'press drift error');
                        p.trial.specs.timing.response_cue.start_time = NaN;
                        p.functionHandles.state_variables.trial_state = 'timeout';
                        p.functionHandles.state_variables.show_fixation_cue = false;
                    end
                end
                
            case 'error_delay'
                
                %  STATE:  error_delay
                %
                %  In this state we continue to show the fixation dot while
                %  the monkey is waiting to see if he gets his reward.
                
                
                %  Fixation cue is always shown in this state unless he
                %  aborts
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                if(isnan(p.trial.specs.timing.error_delay.start_time))
                    
                    if(p.trial.training_flags.release_for_reward && p.functionHandles.state_variables.wait_for_release)
                        fprintf('ERROR DELAY.  %s must completely release joystick, fixate and await feedback %0.3f sec (%0.3f remain).\n',p.trial.session.subject,p.trial.specs.timing.error_delay.duration,p.trial.specs.timing.error_delay.duration -p.trial.specs.timing.response_cue.response_duration);
                    else
                        fprintf('ERROR DELAY.  %s must fixate and await feedback for %0.3f sec.\n',p.trial.session.subject,p.trial.specs.timing.error_delay.duration);
                    end
                    
                    p.trial.specs.timing.error_delay.start_time = GetSecs;
                elseif(p.trial.specs.timing.error_delay.start_time > GetSecs - p.trial.specs.timing.error_delay.duration -p.trial.specs.timing.response_cue.response_duration)
                    
                    %  Still in delay so check to make sure monkey
                    %  continues to fixate.
                    
                    if(~p.functionHandles.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.specs.timing.error_delay.start_time);
                        
                        p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'fixation break');
                        p.functionHandles.state_variables.trial_state = 'timeout';
                        p.trial.specs.timing.error_delay.start_time = NaN;
                        p.functionHandles.state_variables.show_fixation_cue = false;
                    end
                    
                    if(p.trial.training_flags.release_for_reward && p.functionHandles.state_variables.wait_for_release && p.functionHandles.state_variables.joystick_released)
                        p.trial.specs.timing.response_cue.response_duration =p.trial.specs.timing.response_cue.response_duration + GetSecs - p.trial.specs.timing.error_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.specs.timing.error_delay.start_time,p.trial.specs.timing.response_cue.response_duration);
                        p.functionHandles.state_variables.wait_for_release = false;
                    end
                    
                elseif(p.trial.training_flags.release_for_reward && p.functionHandles.state_variables.wait_for_release)
                    if(isnan(p.trial.specs.timing.error_delay.eligible_start_time))
                        fprintf('\t%s has exceeded the error delay and is eligible for another trial once he releases the joystick.\n',p.trial.session.subject);
                        p.trial.specs.timing.error_delay.eligible_start_time = GetSecs;
                    end
                    if(p.functionHandles.state_variables.joystick_released)
                        p.trial.specs.timing.response_cue.response_duration =p.trial.specs.timing.response_cue.response_duration + GetSecs - p.trial.specs.timing.error_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.specs.timing.error_delay.start_time,p.trial.specs.timing.response_cue.response_duration);
                        p.functionHandles.state_variables.wait_for_release = false;
                    end
                elseif(~p.trial.training_flags.release_for_reward || ~p.functionHandles.state_variables.wait_for_release)
                    p.trial.specs.timing.error_delay.eligible_start_time = GetSecs;
                end
                
                if(~isnan(p.trial.specs.timing.error_delay.eligible_start_time) && ~p.functionHandles.state_variables.wait_for_release)
                    
                    %  Monkey completed error delay
                    fprintf('\t%s completed error delay with joystick released.  He gets no reward (WOMP WOMP).\n',p.trial.session.subject);
                    p.trial.specs.timing.error_delay.start_time = NaN;
                    p.trial.specs.timing.error_delay.eligible_start_time = NaN;
                    p.trial.outcome = p.functionHandles.performance.completed_trial(p,false);
                    p.functionHandles.state_variables.trial_state = 'error';
                end
                
            case 'reward_delay'
                
                %  STATE:  reward_delay
                %
                %  In this state we continue to show the fixation dot.
                %  Monkey must release the joystick. Once this is done we
                %  can give him his reward!
                
                %  Fixation cue is always shown in this state unless he
                %  aborts
                p.functionHandles.state_variables.show_fixation_cue = true;
                
                if(isnan(p.trial.specs.timing.reward_delay.start_time))
                    
                    if(p.trial.training_flags.release_for_reward && p.functionHandles.state_variables.wait_for_release)
                        fprintf('REWARD DELAY.  %s must release joystick, fixate and await feedback for %0.3f sec (%0.3f sec remain).\n',p.trial.session.subject,p.trial.specs.timing.reward_delay.duration,p.trial.specs.timing.reward_delay.duration -p.trial.specs.timing.response_cue.response_duration);
                    else
                        fprintf('REWARD DELAY.  %s must fixate and await feedback for %0.3f sec.\n',p.trial.session.subject,p.trial.specs.timing.reward_delay.duration);
                    end
                    
                    p.trial.specs.timing.reward_delay.start_time = GetSecs;
                elseif(p.trial.specs.timing.reward_delay.start_time > GetSecs - p.trial.specs.timing.reward_delay.duration -p.trial.specs.timing.response_cue.response_duration)
                    
                    %  Still in delay so check to make sure monkey
                    %  continues to fixate.
                    
                    if(~p.functionHandles.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.specs.timing.reward_delay.start_time);
                        
                        p.trial.outcome = p.functionHandles.performance.aborted_trial(p,'fixation break');
                        p.functionHandles.state_variables.trial_state = 'timeout';
                        p.trial.specs.timing.reward_delay.start_time = NaN;
                        p.functionHandles.state_variables.show_fixation_cue = false;
                    end
                    
                    if(p.trial.training_flags.release_for_reward && p.functionHandles.state_variables.wait_for_release && p.functionHandles.state_variables.joystick_released)
                        p.trial.specs.timing.response_cue.response_duration =p.trial.specs.timing.response_cue.response_duration + GetSecs - p.trial.specs.timing.reward_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.specs.timing.reward_delay.start_time,p.trial.specs.timing.response_cue.response_duration);
                        p.functionHandles.state_variables.wait_for_release = false;
                    end
                elseif(p.trial.training_flags.release_for_reward && p.functionHandles.state_variables.wait_for_release)
                    if(isnan(p.trial.specs.timing.reward_delay.eligible_start_time))
                        fprintf('\t%s has exceeded the reward delay and is eligible for a reward once he releases the joystick.\n',p.trial.session.subject);
                        p.trial.specs.timing.reward_delay.eligible_start_time = GetSecs;
                    end
                    if(p.functionHandles.state_variables.joystick_released)
                        p.trial.specs.timing.response_cue.response_duration =p.trial.specs.timing.response_cue.response_duration + GetSecs - p.trial.specs.timing.reward_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.specs.timing.reward_delay.start_time,p.trial.specs.timing.response_cue.response_duration);
                        p.functionHandles.state_variables.wait_for_release = false;
                    end
                elseif(~p.trial.training_flags.release_for_reward || ~p.functionHandles.state_variables.wait_for_release)
                    p.trial.specs.timing.reward_delay.eligible_start_time = GetSecs;
                end
                
                if(~isnan(p.trial.specs.timing.reward_delay.eligible_start_time) && ~p.functionHandles.state_variables.wait_for_release)
                    
                    %  Monkey completed reward delay so he can get his
                    %  reward now!
                    fprintf('\t%s completed reward delay.  He gets a reward!\n',p.trial.session.subject);
                    p.trial.specs.timing.reward_delay.start_time = NaN;
                    p.trial.specs.timing.reward_delay.eligible_start_time = NaN;
                    
                    p.trial.outcome = p.functionHandles.performance.completed_trial(p,true);
                    p.functionHandles.state_variables.trial_state = 'reward';
                end
                
            case 'reward'
                
                %  STATE:  reward
                
                %  Provide the monkey with his just desserts.
                
                %  Fixation cue is not needed in this state
                
                if(isnan(p.trial.specs.timing.reward.start_time))
                    p.trial.specs.timing.reward.start_time = GetSecs;
                    pds.behavior.reward.give(p,p.trial.stimulus.reward_amount);
                    pds.audio.play(p,'reward',1);
                    
                    fprintf('REWARD:  ');
                    
                elseif(p.trial.specs.timing.reward.start_time <= GetSecs - p.trial.stimulus.reward_amount)
                    fprintf('%s received reward for %0.3f sec.\n',p.trial.session.subject,p.trial.stimulus.reward_amount);
                    fprintf('END TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.flagNextTrial = true;
                end
        end
end

%  NESTED FUNCTIONS BELOW

%  Draw the fixation square into the overlay pointer
    function ShowFixationCue
        win = p.trial.display.overlayptr;
        width = p.trial.specs.features.fixation.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPoint(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        switch p.functionHandles.state_variables.trial_state
            case 'joystick_warning'
                color = p.trial.specs.features.joystick_warning.color;
            case 'engage'
                color = p.trial.specs.features.engage.color;
            otherwise
                color = p.trial.specs.features.fixation.color;
        end
        linewidth = p.trial.specs.features.fixation.linewidth;
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

%  Draw response cue into display pointer
    function ShowResponseCue
        win = p.trial.display.ptr;
        cue_lum = p.trial.condition.luminance-p.trial.display.bgColor(1);
        background = p.trial.display.bgColor(1);
        sigma = p.trial.specs.features.annulus.noise_sigma;
        center = p.trial.display.ctr([1 2]);
        p.functionHandles.rch.draw(win,cue_lum,background,sigma,center);
    end

%  Draw symbols into overlay pointer
    function ShowSymbols
        
        %  Window into which to draw them
        win = p.trial.display.overlayptr;
        
        %  Positions in which symbols are drawn
        centers = p.trial.specs.features.symbol.centers(p.trial.specs.features.symbol.positions(1:p.functionHandles.state_variables.current_symbol),:);
        
        %  Extract colors of symbols to use
        color = zeros(p.functionHandles.state_variables.current_symbol,3);
        for ii=1:p.functionHandles.state_variables.current_symbol
            indx = strcmp(p.trial.condition.symbol_codes{ii}(1),p.trial.specs.features.symbol.color_names);
            color(ii,:) = p.trial.specs.features.symbol.color_indx(indx);
        end
                
        %  Draw in base shape
        for ii=1:p.functionHandles.state_variables.current_symbol
            switch p.trial.condition.symbol_codes{ii}(2)
                case 'S'  %  Square
                    d = sqrt(pi/4)*p.trial.specs.features.symbol.max_diameter;
                    Screen('FillRect',win,color(ii,:),CenterRectOnPoint([0 0 d d],centers(ii,1),centers(ii,2)));
                case 'C'  %  Circle
                    d = p.trial.specs.features.symbol.max_diameter;
                    Screen('FillOval',win,color(ii,:),CenterRectOnPoint([0 0 d d],centers(ii,1),centers(ii,2)));
                case 'D'  %  Diamond
                    a = sqrt(pi/8)*p.trial.specs.features.symbol.max_diameter;
                    Screen('FillPoly',win,color(ii,:),[-a 0 ; 0 a ; a 0 ; 0 -a]+repmat(centers(ii,:),4,1),1);
            end
        end
                
        %  Draw in pattern
        for ii=1:p.functionHandles.state_variables.current_symbol
            switch p.trial.condition.symbol_codes{ii}(3)
                
                case 'O'  %  Open symbols
                    switch p.trial.condition.symbol_codes{ii}(2)
                        case 'S'  %  Square
                            d = sqrt(pi/8)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillRect',win,p.trial.specs.features.symbol.background,CenterRectOnPoint([0 0 d d],centers(ii,1),centers(ii,2)));
                        case 'C'  %  Circle
                            d = sqrt(1/2)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillOval',win,p.trial.specs.features.symbol.background,CenterRectOnPoint([0 0 d d],centers(ii,1),centers(ii,2)));
                        case 'D'  %  Diamond
                            a = sqrt(pi/16)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillPoly',win,p.trial.specs.features.symbol.background,[-a 0 ; 0 a ; a 0 ; 0 -a]+repmat(centers(ii,:),4,1),1);
                    end
                    
                case 'C'  %  Concentric
                    switch p.trial.condition.symbol_codes{ii}(2)
                        case 'S'  %  Square
                            d1 = sqrt(pi/6)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillRect',win,p.trial.specs.features.symbol.background,CenterRectOnPoint([0 0 d1 d1],centers(ii,1),centers(ii,2)));
                            d2 = sqrt(pi/12)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillRect',win,color(ii,:),CenterRectOnPoint([0 0 d2 d2],centers(ii,1),centers(ii,2)));
                        case 'C'  %  Circle
                            d1 = sqrt(2/3)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillOval',win,p.trial.specs.features.symbol.background,CenterRectOnPoint([0 0 d1 d1],centers(ii,1),centers(ii,2)));
                            d2 = sqrt(1/3)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillOval',win,color(ii,:),CenterRectOnPoint([0 0 d2 d2],centers(ii,1),centers(ii,2)));                            
                        case 'D'  %  Diamond
                            a1 = sqrt(pi/12)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillPoly',win,p.trial.specs.features.symbol.background,[-a1 0 ; 0 a1 ; a1 0 ; 0 -a1]+repmat(centers(ii,:),4,1),1);
                            a2 = sqrt(pi/24)*p.trial.specs.features.symbol.max_diameter;
                            Screen('FillPoly',win,color(ii,:),[-a2 0 ; 0 a2 ; a2 0 ; 0 -a2]+repmat(centers(ii,:),4,1),1);
                    end
            end
        end                
    end

%  Compare joystick against threshold and set flags
    function check_joystick_status
        
        %  If the debug flag is set then automatically set joystick status
        if(p.trial.debug_flags.joystick_zombie)
            switch p.functionHandles.state_variables.trial_state
                case 'engage'
                    zone = 2;
                case 'response_cue'
                    if(p.functionHandles.state_variables.release_trial)
                        zone = 1;
                    else
                        zone = 3;
                    end
                otherwise
                    zone = 1;
            end
        else
            %  Determine status of joystick against thresholds
            switch p.functionHandles.state_variables.trial_state
                case 'joystick_warning'
                    [zone,p.trial.joystick.position] = joystick.zones(p.trial.joystick.joystick_warning);
                case 'engage'
                    [zone,p.trial.joystick.position] = joystick.zones(p.trial.joystick.engage);
                case 'response_cue'
                    if(p.trial.training_flags.relative_response_threshold)
                        if(isnan(p.trial.specs.timing.response_cue.start_time))
                            p.trial.joystick.response_cue.threshold(1) = max(p.trial.joystick.position-3,p.trial.joystick.default.threshold(1));
                            p.trial.joystick.response_cue.threshold(2) = max(p.trial.joystick.position-2,p.trial.joystick.default.threshold(2));
                            p.trial.joystick.response_cue.threshold(3) = min(p.trial.joystick.position+2,p.trial.joystick.default.threshold(3));
                            p.trial.joystick.response_cue.threshold(4) = min(p.trial.joystick.position+3,p.trial.joystick.default.threshold(4));
                        end
                    else
                        p.trial.joystick.response_cue = p.trial.joystick.default;
                    end
                    [zone,p.trial.joystick.position] = joystick.zones(p.trial.joystick.response_cue);
                otherwise
                    [zone,p.trial.joystick.position] = joystick.zones(p.trial.joystick.default);
            end
        end
        %  Set joystick state variables
        p.functionHandles.state_variables.joystick_released = zone==1;
        p.functionHandles.state_variables.joystick_release_buffer = zone==2;
        p.functionHandles.state_variables.joystick_engaged = zone==3;
        p.functionHandles.state_variables.joystick_press_buffer = zone==4;
        p.functionHandles.state_variables.joystick_pressed = zone==5;
    end

%  Display joystick status to console screen
    function display_joystick_status
        switch p.functionHandles.state_variables.trial_state
            case 'joystick_warning'
                joystick.display(p,p.trial.joystick.position,p.trial.joystick.joystick_warning.threshold);
            case 'engage'
                joystick.display(p,p.trial.joystick.position,p.trial.joystick.engage.threshold);
            case 'response_cue'
                if(p.trial.training_flags.relative_response_threshold)
                    joystick.display(p,p.trial.joystick.position,p.trial.joystick.response_cue.threshold);
                else
                    joystick.display(p,p.trial.joystick.position,p.trial.joystick.default.threshold);
                end
            otherwise
                joystick.display(p,p.trial.joystick.position,p.trial.joystick.default.threshold);
        end
    end

%  Display the fixation window
    function display_fixation_window
        win = p.trial.display.overlayptr;
        width = p.trial.stimulus.fpWin;
        baseRect = [0 0 width(1) width(2)];
        centeredRect = CenterRectOnPoint(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.display.clut.hCyan;
        Screen('FrameRect',win,color,centeredRect);
    end

%  Check if monkey is fixating
    function check_fixation_status
        width = p.trial.stimulus.fpWin;
        if(p.trial.eyelink.useAsEyepos && p.trial.eyelink.use)
            p.functionHandles.state_variables.fixating = squarewindow(~p.trial.training_flags.enforce_fixation,p.trial.display.ctr(1:2)-[p.trial.eyeX p.trial.eyeY],width(1),width(2));
        else
            p.functionHandles.state_variables.fixating = true;
        end
    end
end