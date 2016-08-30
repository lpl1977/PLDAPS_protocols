function p = trial_function(p,state)
%  PLDAPS trial function for set task
%
%  p = only_zuul.trial_function(p,state)

%
%  Call default trial function for general state dependent steps not
%  defined here
%
pldapsDefaultTrialFunction(p,state);

%
%  Custom defined state dependent steps
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
        feval(str2func(strcat('only_zuul.',p.trial.session.subject)),p);
        
        %  Initialize or update trial indexing
        if(p.trial.pldaps.iTrial==1)            
            p.trial.task.indexing.current_trial = 1;
            p.trial.task.indexing.total_completed = 0;
        else
            p.trial.task.indexing.current_trial = p.data{p.trial.pldaps.iTrial-1}.task.indexing.next_trial;
            p.trial.task.indexing.total_completed = p.data{p.trial.pldaps.iTrial-1}.task.indexing.total_completed;
        end
            
        %  Conditions from cell array
        p.trial.task.condition = p.conditions{p.trial.task.indexing.current_trial};
                    
        %  Initialize trial state variables
        p.trial.task.state_variables = only_zuul.state_variables(p.trial.task.condition);
        
        %  Initialize trial outcomes
        p.trial.task.outcome = only_zuul.outcome;
        
        %  Initialize performance
        if(p.trial.pldaps.iTrial==1)            
            nlum = length(p.trial.task.features.log10C);
            p.trial.task.performance.total = only_zuul.performance(nlum+1);
            p.trial.task.performance.mask = only_zuul.performance(nlum+1);
            p.trial.task.performance.set = only_zuul.performance(nlum);
            p.trial.task.performance.notset = only_zuul.performance(1);
        else
            p.trial.task.performance = p.data{p.trial.pldaps.iTrial-1}.task.performance;
        end
        
        %  Make symbols masks if mask trial
        if(p.trial.task.state_variables.mask_trial)
            p.trial.task.stimulus.symbol.rng = rng;
            colors = p.trial.task.features.symbol.colors;
            background = p.trial.task.features.symbol.background;
            diameter = p.trial.task.features.symbol.outer_diameter;
            M = symbols.pixel_noise(diameter,colors,background,p.trial.task.stimulus.symbol.rng);
            p.trial.task.stimulus.symbol.textureIndex = Screen('MakeTexture',p.trial.display.ptr,M);
        end
        %  Initialize random symbol position order
        p.trial.task.stimulus.symbol.position_order = randperm(3);
        
        %  Setup for noise annulus
        
        %  Initialize array of texture indices (seems to work more smoothly
        %  to pre-allocate and then clear at end of trial) and container
        %  for random number generator seeds
        p.trial.task.stimulus.noise_ring.rng(1:p.trial.pldaps.maxFrames) = struct(rng);
        p.trial.task.stimulus.noise_ring.textureIndex = zeros(p.trial.pldaps.maxFrames,1);
        
        %  Print information to screen
        
        fprintf('START TRIAL ATTEMPT %d (%d total trials of %d completed, %d remain):\n',p.trial.pldaps.iTrial,p.trial.task.indexing.total_completed,p.trial.task.constants.maxTrials,p.trial.task.constants.maxTrials-p.trial.task.indexing.total_completed);
        fprintf('\tTrial %d of %d for block %d of %d.\n',p.trial.task.condition.trial_number,p.trial.task.constants.TrialsPerBlock,p.trial.task.condition.block_number,p.trial.task.constants.maxBlocks);
        fprintf('\tThis is a %s %s trial number %d with log contrast %0.3f.\n',upper(p.trial.task.condition.sequence_type),upper(p.trial.task.condition.trial_type),p.trial.task.performance.(p.trial.task.condition.sequence_type).completed,p.trial.task.condition.log10C);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        %  Close out texture indices
        if(p.trial.task.state_variables.noise_frame>0)
            Screen('Close',p.trial.task.stimulus.noise_ring.textureIndex(1:p.trial.task.state_variables.noise_frame));
        end
        if(p.trial.task.state_variables.mask_trial)
            Screen('Close',p.trial.task.stimulus.symbol.textureIndex);
        end
        
        %  Eliminate unused array portions if possible
%         if(p.trial.task.state_variables.noise_frame>0)
%             p.trial.task.stimulus.noise_ring.rng = p.trial.task.stimulus.noise_ring.rng(1:p.trial.task.state_variables.noise_frame);
%         else
%             p.trial.task.stimulus.noise_ring.rng = [];
%         end
        
        %  Update performance
        p.trial.task.performance.total = only_zuul.performance.update(p.trial.task.performance.total,p.trial.task.outcome,p.trial.task.condition);
        p.trial.task.performance.(p.trial.task.condition.sequence_type) = only_zuul.performance.update(p.trial.task.performance.(p.trial.task.condition.sequence_type),p.trial.task.outcome,p.trial.task.condition);        
        
        %
        %  Update trial indexing
        %
        
        %  Depending on training flags, shuffle aborts and errors.
        if(p.trial.task.outcome.completed && (p.trial.task.outcome.correct || ~p.trial.task.training.repeat_errors))
            p.trial.task.indexing.next_trial = p.trial.task.indexing.current_trial+1;
            p.trial.task.indexing.total_completed = p.trial.task.indexing.total_completed + 1;
        else
            if(~p.trial.task.outcome.correct && p.trial.task.outcome.completed)
                p.trial.task.performance.total = only_zuul.performance.track_repeats(p.trial.task.performance.total);
            end
            p.trial.task.indexing.next_trial = p.trial.task.indexing.current_trial;
            p.conditions{end+1} = p.conditions{end};            
            if((p.trial.task.training.shuffle_aborts && ~p.trial.task.outcome.completed) || (p.trial.task.outcome.completed && p.trial.task.training.shuffle_errors))
                indx = p.trial.task.indexing.current_trial:p.trial.task.indexing.current_trial + p.trial.task.constants.TrialsPerBlock-p.trial.task.condition.trial_number;                
                fprintf('\tReshuffling trials %d through %d (within block trial %d through %d)\n\n',indx(1),indx(end),p.trial.task.condition.trial_number,p.trial.task.constants.TrialsPerBlock);
                temp = p.conditions(indx);
                p.conditions(indx) = Shuffle(temp);
                for i = 1:length(indx)
                    p.conditions{indx(i)}.trial_number = temp{i}.trial_number;
                end
            end            
        end
        
        %  Display performance
        
        only_zuul.performance.print_performance(p.trial.task.performance,p.trial.task.features.log10C);
        
        
%         
%         fprintf('MASK current performance:\n');
%         only_zuul.performance.print_performance(p.trial.task.performance.mask,p.trial.task.features.log10C);
%         
%         fprintf('SET current performance:\n');
%         only_zuul.performance.print_performance(p.trial.task.performance.set,p.trial.task.features.log10C);
%         
%         fprintf('NOTSET current performance:\n');
%         only_zuul.performance.print_performance(p.trial.task.performance.notset,-Inf);
        
%         completed = double(p.trial.task.performance.completed); attempted
%         = double(p.trial.task.performance.attempted); correct =
%         double(p.trial.task.performance.correct);
%         
%         fixation_breaks =
%         double(p.trial.task.performance.fixation_break);
%         failed_to_initiate =
%         double(p.trial.task.performance.failed_to_initiate);
%         joystick_warning_elapsed =
%         double(p.trial.task.performance.joystick_warning_elapsed);
%         eye_warning_elapsed =
%         double(p.trial.task.performance.eye_warning_elapsed);
%         early_releases = double(p.trial.task.performance.early_release);
%         early_presses = double(p.trial.task.performance.early_press);
%         release_drift_errors =
%         double(p.trial.task.performance.release_drift_error);
%         press_drift_errors =
%         double(p.trial.task.performance.press_drift_error); misses =
%         double(p.trial.task.performance.miss);
%         
%         fprintf('Current performance:\n'); fprintf('\tCompleted:
%         %d of %d (%0.3f)\n',completed,attempted,completed/attempted);
%         fprintf('\tCorrectly completed:  %d of %d
%         (%0.3f)\n',correct,completed,correct/completed); fprintf('\n');
%         
%         for i=1:length(p.trial.task.features.log10C)
%             fprintf('         R (%5.2f):  %4d R %4d P %4d T, %5.2f
%             correct | %5.2f
%             R\n',p.trial.task.features.log10C(i),p.trial.task.performance.matrix(i,:),p.trial.task.performance.matrix(i,1)/p.trial.task.performance.matrix(i,3),p.trial.task.performance.matrix(i,1)/p.trial.task.performance.matrix(i,3));
%         end fprintf('         P (%5.2f):  %4d R %4d P %4d T, %5.2f
%         correct | %5.2f
%         R\n',-Inf,p.trial.task.performance.matrix(end,:),p.trial.task.performance.matrix(end,2)/p.trial.task.performance.matrix(end,3),p.trial.task.performance.matrix(end,1)/p.trial.task.performance.matrix(end,3));
%         fprintf('\n');
%         
%         fprintf('Trial aborts (%d of %d
%         trials):\n',attempted-completed,attempted); fprintf('\tFixation
%         breaks:          %3d\n',fixation_breaks); fprintf('\tFailed to
%         initiate:       %3d\n',failed_to_initiate); fprintf('\tJoystick
%         warning elapsed: %3d\n',joystick_warning_elapsed); fprintf('\tEye
%         warning elapsed:      %3d\n',eye_warning_elapsed);
%         fprintf('\tEarly releases:           %3d\n',early_releases);
%         fprintf('\tEarly presses:            %3d\n',early_presses);
%         fprintf('\tRelease drift errors:
%         %3d\n',release_drift_errors); fprintf('\tPress drift errors:
%         %3d\n',press_drift_errors); fprintf('\tMisses:
%         %3d\n',misses); fprintf('\n');
        
        %  Check if we have completed conditions; if so, we're finished.
        if(p.trial.task.performance.total.completed==p.trial.task.constants.maxTrials+p.trial.task.performance.total.repeats)
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
        display_joystick_status;
        
        %  Display fixation window
        display_fixation_window;
                
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control.
        
        %  NOTE:  AT END OF THIS CASE I DRAW THE FIXATION WINDOW
        
        %
        %  Check trial time first; end trial if exceeds maximum
        %
        
        if(p.trial.ttime > p.trial.pldaps.maxTrialLength-p.trial.task.constants.minTrialTime)
            fprintf('\t%s did not initiate trial within %0.3f sec.\n',p.trial.session.subject,p.trial.pldaps.maxTrialLength-60);
            p.trial.task.outcome.failed_to_initiate = true;
            p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
            p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
            fprintf('END TRIAL %d.\n\n',p.trial.pldaps.iTrial);
            p.trial.flagNextTrial = true;
        end
        
        %
        %  Control trial events based on trial state
        %
        
        switch p.trial.task.state_variables.trial_state
            
            case 'start'
                
                %  STATE:  start
                
                %  If monkey has joystick released then go to engage state.
                %  Otherwise go to joystick warning.
                
                if(~p.trial.task.state_variables.joystick_released)
                    %  Monkey does not have joystick released.
                    fprintf('\t%s started trial without joystick released; go to joystick warning.\n',p.trial.session.subject);
                    p.trial.task.state_variables.wait_for_release = true;
                    p.trial.task.state_variables.trial_state = 'joystick_warning';
                else
                    %  Monkey has joystick released.
                    fprintf('\t%s started trial with joystick released; go to engage.\n',p.trial.session.subject);
                    p.trial.task.state_variables.trial_state = 'engage';
                end
                
                %  Show fixation cue
                
                ShowFixationCue;
                
            case 'engage'
                
                %  STATE:  engage
                
                %  Start trial once monkey has joystick engaged and is
                %  fixating.
                
                if(isnan(p.trial.task.timing.engage.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.task.timing.engage.start_time = GetSecs;
                    p.trial.task.timing.engage.cue_start_time = GetSecs;
                    
                    %  Show fixation cue
                    ShowFixationCue;
                    
                    fprintf('ENGAGE state\n');
                    
                    %  If the monkey is not currently fixating then we're
                    %  going to have to wait for him to fixate.
                    if(~p.trial.task.state_variables.fixating)
                        fprintf('\t%s must fixate before we may proceed.\n',p.trial.session.subject);
                        p.trial.task.state_variables.wait_for_fixation = true;
                    else
                        p.trial.task.state_variables.wait_for_fixation = false;
                    end
                    
                    %  If the monkey does not currently have the joystick
                    %  engaged then we are going to have to wait for him to
                    %  engage.
                    if(~p.trial.task.state_variables.joystick_engaged)
                        fprintf('\t%s must engage joystick before we may proceed.\n',p.trial.session.subject);
                        p.trial.task.state_variables.wait_for_engage = true;
                    else
                        p.trial.task.state_variables.wait_for_engage = false;
                    end
                    
                    
                else
                    
                    %  We are still in the engage state.  We will continue
                    %  checking the joystick and fixation and will blinked
                    %  the fixation cue as long as the monkey has both not
                    %  engaged the joystick and fixated.
                    
                    if(p.trial.task.state_variables.joystick_engaged && p.trial.task.state_variables.fixating)
                        
                        %  The monkey has both joystick engaged and is
                        %  fixating.  Print some feedback, reset the timing
                        %  variables, and go on to the delay state.
                        fprintf('\t%s engaged joystick and is fixating after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.engage.start_time);
                        p.trial.task.timing.engage.start_time = NaN;
                        p.trial.task.timing.engage.cue_start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'delay';
                        
                        %  Show fixation cue
                        ShowFixationCue;
                        
                    elseif(p.trial.task.state_variables.joystick_pressed || p.trial.task.state_variables.joystick_press_buffer)
                        
                        %  The monkey overshot the engage region.
                        fprintf('\t%s pressed the joystick after %0.3f sec; go to joystick warning.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.engage.start_time);
                        p.trial.task.timing.engage.start_time = NaN;
                        p.trial.task.timing.engage.cue_start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'joystick_warning';
                        
                        %  Show fixation cue
                        ShowFixationCue;
                        
                    elseif(p.trial.task.timing.engage.cue_start_time > GetSecs - p.trial.task.timing.engage.cue_display_time)
                        
                        %  We're not yet in the blink so show the fixation
                        %  cue regarless.
                        ShowFixationCue;
                        
                    elseif(p.trial.task.timing.engage.cue_start_time <= GetSecs - (p.trial.task.timing.engage.cue_display_time + p.trial.task.timing.engage.cue_extinguish_time))
                        
                        %  We've exceeded the duration of the blink, so
                        %  reset the cue start time.
                        p.trial.task.timing.engage.cue_start_time = GetSecs;
                        
                        %  Show the fixation cue regardless
                        ShowFixationCue;
                    end
                end
                
            case 'delay'
                
                %  STATE:  delay
                
                %  Monkey enters the state for the first time with the
                %  joystick engaged and fixating.  Continue to show him the
                %  fixation cue as long as this is the case and we have not
                %  yet reached the end of the delay period.
                
                ShowFixationCue;
                if(isnan(p.trial.task.timing.delay.start_time))
                    p.trial.task.timing.delay.start_time = GetSecs;
                    fprintf('DELAY state for %0.3f sec.\n',p.trial.task.timing.delay.duration);
                    
                elseif(p.trial.task.timing.delay.start_time > GetSecs - p.trial.task.timing.delay.duration)
                    
                    %  We're still in the delay period.  As long as he
                    %  continues to engage and fixate, show him the
                    %  fixation cue.  If he releases or breaks fixation
                    %  during this period, give him a timeout.  If he
                    %  pushes the joystick too far then give him a joystick
                    %  warning.
                    
                    if(~p.trial.task.state_variables.joystick_engaged)
                        %  Monkey released or pressed joystick early.
                        
                        if(p.trial.task.state_variables.joystick_released || p.trial.task.state_variables.joystick_release_buffer)
                            fprintf('\t%s released joystick at %0.3f sec; go to engage.\n',...'delay'
                                p.trial.session.subject,GetSecs-p.trial.task.timing.delay.start_time);
                            p.trial.task.state_variables.trial_state = 'engage';
                        else
                            fprintf('\t%s pressed joystick at %0.3f sec, give him a joystick warning.\n',...
                                p.trial.session.subject,GetSecs-p.trial.task.timing.delay.start_time);
                            p.trial.task.state_variables.trial_state = 'joystick_warning';
                        end
                        p.trial.task.timing.delay.start_time = NaN;
                    elseif(~p.trial.task.state_variables.fixating)
                        %  Monkey broke fixation.
                        fprintf('\t%s broke fixation after %0.3f sec; give him an eye warning.\n',...
                            p.trial.session.subject,GetSecs-p.trial.task.timing.delay.start_time);
                        p.trial.task.timing.delay.start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'eye_warning';                        
                    end
                    
                else
                    %  Monkey has successfully held the joystick engaged
                    %  and fixated to the end of the duration.
                    
                    fprintf('\t%s successfully held joystick engaged and remained fixating.\n',p.trial.session.subject);
                    p.trial.task.state_variables.trial_state = 'symbol';
                    p.trial.task.timing.delay.start_time = NaN;
                end
                
            case 'joystick_warning'
                
                %  STATE:  joystick_warning
                
                %  Monkey enters this state if he has pushed the joystick
                %  too far.  Exit joystick warning when he gets the
                %  joystick into the appropriate range (either release or
                %  engage).
                
                %  Fixation cue will be red
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.joystick_warning.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.task.timing.joystick_warning.start_time = GetSecs;
                    fprintf('JOYSTICK WARNING started for %0.3f sec.\n',p.trial.task.timing.joystick_warning.duration);
                    
                    %  Play the joystick warning until he returns joystick
                    %  to appropriate position
                    pds.audio.play(p,'joystick_warning',0);
                    
                elseif(p.trial.task.timing.joystick_warning.start_time > GetSecs - p.trial.task.timing.joystick_warning.duration)
                    
                    
                    %  We are still in the joystick warning state.  We will
                    %  continue the joystick warning as long as the monkey
                    %  has not moved the joystick back into the appropriate
                    %  range.
                    
                    if(p.trial.task.state_variables.wait_for_release && p.trial.task.state_variables.joystick_released)
                        p.trial.task.state_variables.wait_for_release = false;
                        
                        %  Monkey released joystick
                        fprintf('\t%s released joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.joystick_warning.start_time);
                        p.trial.task.timing.joystick_warning.start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'engage';
                        
                        %  Stop the joystick warning tone
                        pds.audio.stop(p,'joystick_warning');
                        
                        
                    elseif(~p.trial.task.state_variables.wait_for_release)
                        if(p.trial.task.state_variables.joystick_engaged)
                            
                            %  Monkey has joystick engaged
                            fprintf('\t%s re-engaged joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.joystick_warning.start_time);
                            p.trial.task.timing.joystick_warning.start_time = NaN;
                            p.trial.task.state_variables.trial_state = 'delay';
                            
                            %  Stop the joystick warning tone
                            pds.audio.stop(p,'joystick_warning');
                        elseif(p.trial.task.state_variables.joystick_released || p.trial.task.state_variables.joystick_release_buffer)
                            
                            %  Monkey has somehow managed to pass back
                            %  through the engaged state
                            fprintf('\t%s released joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.joystick_warning.start_time);
                            p.trial.task.timing.joystick_warning.start_time = NaN;
                            p.trial.task.state_variables.trial_state = 'start';
                            
                            %  Stop the joystick warning tone
                            pds.audio.stop(p,'joystick_warning');
                        end
                    end
                    
                else
                    %  Monkey has failed to re-engage within the joystick
                    %  warning duration
                    
                    %  Stop the joystick warning tone
                    pds.audio.stop(p,'joystick_warning');
                    
                    fprintf('\t%s elapsed his joystick warning interval.\nEND TRIAL %d.\n\n',p.trial.session.subject,p.trial.pldaps.iTrial);
                    
                    p.trial.task.outcome.joystick_warning_elapsed = true;
                    p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                    p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                    p.trial.task.timing.joystick_warning.start_time = NaN;
                    
                    p.trial.flagNextTrial = true;
                    
                end
                
            case 'eye_warning'
                
                %  STATE:  eye_warning
                
                %  Monkey enters this state if he has broken fixation
                %  during the delay period.  Exit eye warning when he is
                %  fixating and has the joystick engaged.  If he releases
                %  go back to engage and if he presses go back to warning.
                %  While in the eye warning we will blink the fixation cue
                %  at him as in the engage state.
                
                
                if(isnan(p.trial.task.timing.eye_warning.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.task.timing.eye_warning.start_time = GetSecs;
                    p.trial.task.timing.eye_warning.cue_start_time = GetSecs;
                    fprintf('EYE WARNING started for %0.3f sec.\n',p.trial.task.timing.eye_warning.duration);
                    
                    %  Play the eye warning until he returns to fixation
                    pds.audio.play(p,'eye_warning',0);
                    
                    %  Show fixation cue
                    ShowFixationCue;
                    
                elseif(p.trial.task.timing.eye_warning.start_time <= GetSecs - p.trial.task.timing.eye_warning.duration)
                    
                    %  Monkey has failed to fixate during the warning
                    %  duration
                    
                    %  Stop the eye warning tone
                    pds.audio.stop(p,'eye_warning');
                    
                    fprintf('\t%s elapsed his eye warning interval.\nEND TRIAL %d.\n\n',p.trial.session.subject,p.trial.pldaps.iTrial);
                    
                    p.trial.task.outcome.eye_warning_elapsed = true;
                    p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                    p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                    p.trial.task.timing.eye_warning.start_time = NaN;
                    p.trial.task.timing.eye_warning.cue_start_time = GetSecs;
                    
                    p.trial.flagNextTrial = true;
                    
                else
                    
                    %  We are still in the eye warning state.  We will
                    %  continue to check fixation and blink the fixation
                    %  cue as long as the monkey has not returned to
                    %  fixation and we haven't elapsed the maximum warning
                    %  time.
                    
                    if(p.trial.task.state_variables.fixating)
                        
                        %  The monkey has returned to fixation!  Reset the
                        %  timing variables and go back to the delay state.
                        fprintf('\t%s fixated after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.eye_warning.start_time);
                        p.trial.task.timing.eye_warning.start_time = NaN;
                        p.trial.task.timing.eye_warning.cue_start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'delay';
                        
                        %  Stop the eye warning tone
                        pds.audio.stop(p,'eye_warning');
                        
                        %  Show fixation cue
                        ShowFixationCue;
                        
                    elseif(p.trial.task.state_variables.joystick_pressed || p.trial.task.state_variables.joystick_press_buffer)
                        
                        %  The monkey overshot the engage region.
                        fprintf('\t%s pressed the joystick after %0.3f sec; go to joystick warning.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.eye_warning.start_time);
                        p.trial.task.timing.eye_warning.start_time = NaN;
                        p.trial.task.timing.eye_warning.cue_start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'joystick_warning';
                        
                        %  Stop the eye warning tone
                        pds.audio.stop(p,'eye_warning');
                        
                        %  Show fixation cue
                        ShowFixationCue;
                        
                    elseif(p.trial.task.state_variables.joystick_released || p.trial.task.state_variables.joystick_release_buffer)
                        
                        %  The monkey released the joystick.
                        fprintf('\t%s released the joystick after %0.3f sec; go to engage.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.eye_warning.start_time);
                        p.trial.task.timing.eye_warning.start_time = NaN;
                        p.trial.task.timing.eye_warning.cue_start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'engage';
                        
                        %  Stop the eye warning tone
                        pds.audio.stop(p,'eye_warning');
                        
                        %  Show fixation cue
                        ShowFixationCue;
                        
                        
                    elseif(p.trial.task.timing.eye_warning.cue_start_time > GetSecs - p.trial.task.timing.eye_warning.cue_display_time)
                        
                        %  We're not yet in the blink so show the fixation
                        %  cue regarless.
                        ShowFixationCue;
                        
                    elseif(p.trial.task.timing.eye_warning.cue_start_time <= GetSecs - (p.trial.task.timing.eye_warning.cue_display_time + p.trial.task.timing.eye_warning.cue_extinguish_time))
                        
                        %  We've exceeded the duration of the blink, so
                        %  reset the cue start time.
                        p.trial.task.timing.eye_warning.cue_start_time = GetSecs;
                        
                        %  Show the fixation cue regardless
                        ShowFixationCue;
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
                
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.symbol.start_time))
                    p.trial.task.timing.symbol.start_time = GetSecs;
                    
                    if(p.trial.task.state_variables.mask_trial)
                        fprintf('SYMBOL MASK, %d of 3 for %0.3f sec.\n',p.trial.task.state_variables.current_symbol,p.trial.task.timing.symbol.display_time);
                        ShowSymbolMask;
                    else
                        fprintf('SYMBOL %s, %d of 3 for %0.3f sec.\n',p.trial.task.condition.symbol_features(p.trial.task.state_variables.current_symbol).name,p.trial.task.state_variables.current_symbol,p.trial.task.timing.symbol.display_time);
                        ShowSymbol;
                    end
            
                elseif(~p.trial.task.state_variables.joystick_engaged)
                    %  Monkey released or pressed joystick early.
                    
                    if(p.trial.task.state_variables.joystick_released || p.trial.task.state_variables.joystick_release_buffer)
                        fprintf('\t%s released joystick at %0.3f sec, give him a timeout.\n',...
                            p.trial.session.subject,GetSecs-p.trial.task.timing.symbol.start_time);
                        p.trial.task.outcome.early_release = true;
                        p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                        p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                    else
                        fprintf('\t%s pressed joystick at %0.3f sec, give him a timeout.\n',...
                            p.trial.session.subject,GetSecs-p.trial.task.timing.symbol.start_time);
                        p.trial.task.outcome.early_press = true;
                        p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                        p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                    end
                    p.trial.task.state_variables.trial_state = 'timeout';
                    p.trial.task.timing.symbol.start_time = NaN;
                elseif(~p.trial.task.state_variables.fixating)
                    %  Monkey broke fixation.
                    
                    fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',...
                        p.trial.session.subject,GetSecs-p.trial.task.timing.delay.start_time);
                    p.trial.task.outcome.fixation_break = true;
                    p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                    p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                    p.trial.task.timing.symbol.start_time = NaN;
                    p.trial.task.state_variables.trial_state = 'timeout';
                elseif(p.trial.task.timing.symbol.start_time <= GetSecs - (p.trial.task.timing.symbol.display_time + p.trial.task.timing.symbol.interval))
                    %  We have reached the end of the current symbol, so
                    %  update
                    if(p.trial.task.timing.symbol.interval==0 || p.trial.task.training.continue_symbols)
                        if(p.trial.task.state_variables.mask_trial)
                            ShowSymbolMask;
                        else
                            ShowSymbol;
                        end
                    end
                    p.trial.task.timing.symbol.start_time = NaN;
                    if(p.trial.task.state_variables.current_symbol==3)
                        p.trial.task.state_variables.trial_state = 'response_cue';
                    else
                        p.trial.task.state_variables.current_symbol = p.trial.task.state_variables.current_symbol + 1;
                    end
                elseif(p.trial.task.timing.symbol.start_time > GetSecs - p.trial.task.timing.symbol.display_time || p.trial.task.training.continue_symbols)
                    %  Nothing exciting happened.  Keep showing the symbol
                    %  if we are not in the interval or if we are
                    %  continuing to show the symbols after the display
                    %  time
                    if(p.trial.task.state_variables.mask_trial)
                        ShowSymbolMask;
                    else
                        ShowSymbol;
                    end
                end
                
            case 'timeout'
                
                %  STATE:  timeout
                
                %  In this state we are going to give the monkey a timeout
                %  period. After that is over, end trial.
                
                if(isnan(p.trial.task.timing.timeout.start_time))
                    fprintf('TIMEOUT state for %0.3f sec...  ',p.trial.task.timing.timeout.duration);
                    p.trial.task.timing.timeout.start_time = GetSecs;
                    
                elseif(p.trial.task.timing.timeout.start_time <= GetSecs - p.trial.task.timing.timeout.duration)
                    fprintf('Timeout elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.task.timing.timeout.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
                
            case 'error'
                
                %  STATE:  error
                
                %  In this state we are going to give the monkey a time
                %  penalty for an error and end the trial.
                
                if(isnan(p.trial.task.timing.error_penalty.start_time))
                    fprintf('ERROR state for %0.3f sec...  ',p.trial.task.timing.error_penalty.duration);
                    p.trial.task.timing.error_penalty.start_time = GetSecs;
                    
                elseif(p.trial.task.timing.error_penalty.start_time <= GetSecs - p.trial.task.timing.error_penalty.duration)
                    fprintf('Error penalty elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.task.timing.error_penalty.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
            case 'response_cue'
                
                %  STATE:  response_cue
                
                %  In this state we show a response cue.  Monkey should
                %  either press or release the joystick prior to the end of
                %  the grace period in order to convey his response.
                
                if(isnan(p.trial.task.timing.response_cue.start_time))
                    p.trial.task.timing.response_cue.start_time = GetSecs;
                    
                    if(p.trial.task.training.continue_symbols)
                        if(p.trial.task.state_variables.mask_trial)
                            ShowSymbolMask;
                        else
                            ShowSymbol;
                        end
                    end
                    ShowResponseCue;
                    ShowFixationCue;
                    
                    fprintf('RESPONSE state for trial %d.  Respond within %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.task.timing.response_cue.grace);
                    
                elseif(p.trial.task.timing.response_cue.start_time > GetSecs - p.trial.task.timing.response_cue.grace)
                    
                    %  Still in grace period so check joystick as long as
                    %  he is still fixating
                    if(p.trial.task.state_variables.fixating)
                        
                        if(p.trial.task.training.continue_symbols)
                            if(p.trial.task.state_variables.mask_trial)
                                ShowSymbolMask;
                            else
                                ShowSymbol;
                            end
                        end
                        ShowResponseCue;
                        ShowFixationCue;
                        
                        if(isnan(p.trial.task.outcome.reaction_time))
                            if(~p.trial.task.state_variables.joystick_engaged)
                                p.trial.task.outcome.reaction_time = GetSecs - p.trial.task.timing.response_cue.start_time;
                            end
                        end
                        
                        if(p.trial.task.state_variables.joystick_released)
                            %  Monkey has released the joystick
                            
                            fprintf('\t%s released joystick with reaction time %0.3f sec ',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                            
                            if(~isnan(p.trial.task.timing.response_cue.buffer_entry_time))
                                p.trial.task.timing.response_cue.buffer_dwell_time = GetSecs - p.trial.task.timing.response_cue.buffer_entry_time;
                                fprintf('(%0.3f sec in buffer).\n',p.trial.task.timing.response_cue.buffer_dwell_time);
                            else
                                p.trial.task.timing.response_cue.buffer_dwell_time = 0;
                                fprintf('(<0.0083 sec in buffer).\n');
                            end
                            
                            p.trial.task.timing.response_cue.response_duration = GetSecs - p.trial.task.outcome.reaction_time - p.trial.task.timing.response_cue.start_time;
                            fprintf('\tResponse duration was %0.3f sec.\n',p.trial.task.timing.response_cue.response_duration);
                            
                            if(p.trial.task.state_variables.release_trial)
                                p.trial.task.state_variables.trial_state = 'reward_delay';
                            else
                                p.trial.task.state_variables.trial_state = 'error_delay';
                            end
                            p.trial.task.timing.response_cue.start_time = NaN;
                            p.trial.task.timing.response_cue.buffer_entry_time = NaN;
                            p.trial.task.state_variables.wait_for_release = false;
                            
                        elseif(p.trial.task.state_variables.joystick_release_buffer)
                            
                            %  Joystick is now in the release buffer.
                            
                            if(isnan(p.trial.task.timing.response_cue.buffer_entry_time))
                                p.trial.task.timing.response_cue.buffer_entry_time = GetSecs;
                                
                            elseif(p.trial.task.timing.response_cue.buffer_entry_time <= GetSecs - p.trial.task.timing.response_cue.buffer_maximum_time)
                                %  the maximum time has elapsed and
                                %  joystick is not fully released.  Abort
                                %  the trial
                                fprintf('\t%s drifted out of engage state at %0.3f sec without fully releasing joystick.\n',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                                p.trial.task.timing.response_cue.start_time = NaN;
                                p.trial.task.timing.response_cue.buffer_entry_time = NaN;
                                p.trial.task.outcome.release_drift_error = true;
                                p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                                p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                                p.trial.task.state_variables.trial_state = 'timeout';
                            end
                            
                        elseif(p.trial.task.state_variables.joystick_pressed)
                            %  Monkey has pressed the joystick
                            
                            fprintf('\t%s pressed joystick with reaction time %0.3f sec ',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                            
                            if(~isnan(p.trial.task.timing.response_cue.buffer_entry_time))
                                p.trial.task.timing.response_cue.buffer_dwell_time = GetSecs - p.trial.task.timing.response_cue.buffer_entry_time;
                                fprintf('(%0.3f sec in buffer).\n',p.trial.task.timing.response_cue.buffer_dwell_time);
                            else
                                p.trial.task.timing.response_cue.buffer_dwell_time = 0;
                                fprintf('(<0.0083 sec in buffer).\n');
                            end
                            
                            p.trial.task.timing.response_cue.response_duration = GetSecs - p.trial.task.outcome.reaction_time - p.trial.task.timing.response_cue.start_time;
                            %fprintf('\tResponse duration was %0.3f
                            %sec.\n',p.trial.task.timing.response_cue.response_duration);
                            
                            if(p.trial.task.state_variables.press_trial)
                                p.trial.task.state_variables.trial_state = 'reward_delay';
                            else
                                p.trial.task.state_variables.trial_state = 'error_delay';
                            end
                            p.trial.task.state_variables.wait_for_release = p.trial.task.training.release_for_reward;
                            p.trial.task.timing.response_cue.start_time = NaN;
                            p.trial.task.timing.response_cue.buffer_entry_time = NaN;
                        elseif(p.trial.task.state_variables.joystick_press_buffer)
                            
                            %  Joystick is now in the press buffer.
                            
                            if(isnan(p.trial.task.timing.response_cue.buffer_entry_time))
                                p.trial.task.timing.response_cue.buffer_entry_time = GetSecs;
                                
                            elseif(p.trial.task.timing.response_cue.buffer_entry_time <= GetSecs - p.trial.task.timing.response_cue.buffer_maximum_time)
                                %  the maximum time has elapsed and
                                %  joystick is not fully pressed.  Abort
                                %  the trial
                                fprintf('\t%s drifted out of engage state at %0.3f sec without fully pressing joystick.\n',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                                p.trial.task.timing.response_cue.start_time = NaN;
                                p.trial.task.timing.response_cue.buffer_entry_time = NaN;
                                p.trial.task.outcome.press_drift_error = true;
                                p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                                p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                                p.trial.task.state_variables.trial_state = 'timeout';
                            end
                        end
                    else
                        
                        %  Monkey broke fixation too early.  Give him a
                        %  timeout.
                        
                        fprintf('\t%s broke fixation after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.response_cue.start_time);
                        p.trial.task.fixation_break = true;
                        
                        p.trial.task.timing.response_cue.start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'timeout';
                    end
                    
                else
                    %  Monkey has held joystick till end of grace period,
                    %  so give him a timeout
                    
                    fprintf('\t%s held joystick to end of response duration; this is a missed response.\n',p.trial.session.subject);
                    p.trial.task.timing.response_cue.start_time = NaN;
                    p.trial.task.outcome.miss = true;
                    p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                    p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                    p.trial.task.state_variables.trial_state = 'timeout';
                end
                
            case 'error_delay'
                
                %  STATE:  error_delay
                %
                %  In this state we continue to show the fixation dot while
                %  the monkey is waiting to see if he gets his reward.
                
                
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.error_delay.start_time))
                    
                    if(p.trial.task.training.release_for_reward && p.trial.task.state_variables.wait_for_release)
                        fprintf('ERROR DELAY.  %s must completely release joystick, fixate and await feedback %0.3f sec (%0.3f remain).\n',p.trial.session.subject,p.trial.task.timing.error_delay.duration,p.trial.task.timing.error_delay.duration -p.trial.task.timing.response_cue.response_duration);
                    else
                        fprintf('ERROR DELAY.  %s must fixate and await feedback for %0.3f sec.\n',p.trial.session.subject,p.trial.task.timing.error_delay.duration);
                    end
                    
                    p.trial.task.timing.error_delay.start_time = GetSecs;
                elseif(p.trial.task.timing.error_delay.start_time > GetSecs - p.trial.task.timing.error_delay.duration -p.trial.task.timing.response_cue.response_duration)
                    
                    %  Still in delay so check to make sure monkey
                    %  continues to fixate.
                    
                    if(~p.trial.task.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.error_delay.start_time);
                        p.trial.task.outcome.fixation_break = true;
                        p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                        p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                        p.trial.task.state_variables.trial_state = 'timeout';
                        p.trial.task.timing.error_delay.start_time = NaN;
                    end
                    
                    if(p.trial.task.training.release_for_reward && p.trial.task.state_variables.wait_for_release && p.trial.task.state_variables.joystick_released)
                        p.trial.task.timing.response_cue.response_duration =p.trial.task.timing.response_cue.response_duration + GetSecs - p.trial.task.timing.error_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.error_delay.start_time,p.trial.task.timing.response_cue.response_duration);
                        p.trial.task.state_variables.wait_for_release = false;
                    end
                    
                elseif(p.trial.task.training.release_for_reward && p.trial.task.state_variables.wait_for_release)
                    if(isnan(p.trial.task.timing.error_delay.eligible_start_time))
                        fprintf('\t%s has exceeded the error delay and is eligible for another trial once he releases the joystick.\n',p.trial.session.subject);
                        p.trial.task.timing.error_delay.eligible_start_time = GetSecs;
                    end
                    if(p.trial.task.state_variables.joystick_released)
                        p.trial.task.timing.response_cue.response_duration =p.trial.task.timing.response_cue.response_duration + GetSecs - p.trial.task.timing.error_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.error_delay.start_time,p.trial.task.timing.response_cue.response_duration);
                        p.trial.task.state_variables.wait_for_release = false;
                    end
                elseif(~p.trial.task.training.release_for_reward || ~p.trial.task.state_variables.wait_for_release)
                    p.trial.task.timing.error_delay.eligible_start_time = GetSecs;
                end
                
                if(~isnan(p.trial.task.timing.error_delay.eligible_start_time) && ~p.trial.task.state_variables.wait_for_release)
                    
                    %  Monkey completed error delay to se can get next
                    %  trial now!
                    fprintf('\t%s completed error delay with joystick released.  He gets no reward (WOMP WOMP).\n',p.trial.session.subject);
                    p.trial.task.timing.error_delay.start_time = NaN;
                    p.trial.task.timing.error_delay.eligible_start_time = NaN;
                    p.trial.task.outcome.correct = false;
                    p.trial.task.outcome.completed = true;
                    p.trial.task.state_variables.trial_state = 'error';
                end
                
            case 'reward_delay'
                
                %  STATE:  reward_delay
                %
                %  In this state we continue to show the fixation dot.
                %  Monkey must release the joystick. Once this is done we
                %  can give him his reward!
                
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.reward_delay.start_time))
                    
                    if(p.trial.task.training.release_for_reward && p.trial.task.state_variables.wait_for_release)
                        fprintf('REWARD DELAY.  %s must release joystick, fixate and await feedback for %0.3f sec (%0.3f sec remain).\n',p.trial.session.subject,p.trial.task.timing.reward_delay.duration,p.trial.task.timing.reward_delay.duration -p.trial.task.timing.response_cue.response_duration);
                    else
                        fprintf('REWARD DELAY.  %s must fixate and await feedback for %0.3f sec.\n',p.trial.session.subject,p.trial.task.timing.reward_delay.duration);
                    end
                    
                    p.trial.task.timing.reward_delay.start_time = GetSecs;
                elseif(p.trial.task.timing.reward_delay.start_time > GetSecs - p.trial.task.timing.reward_delay.duration -p.trial.task.timing.response_cue.response_duration)
                    
                    %  Still in delay so check to make sure monkey
                    %  continues to fixate.
                    
                    if(~p.trial.task.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.reward_delay.start_time);
                        p.trial.task.outcome.fixation_break = true;
                        p.trial.task.outcome.abort_state = p.trial.task.state_variables.trial_state;
                        p.trial.task.outcome.abort_time = GetSecs - p.trial.trstart;
                        p.trial.task.state_variables.trial_state = 'timeout';
                        p.trial.task.timing.reward_delay.start_time = NaN;
                    end
                    
                    if(p.trial.task.training.release_for_reward && p.trial.task.state_variables.wait_for_release && p.trial.task.state_variables.joystick_released)
                        p.trial.task.timing.response_cue.response_duration =p.trial.task.timing.response_cue.response_duration + GetSecs - p.trial.task.timing.reward_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.reward_delay.start_time,p.trial.task.timing.response_cue.response_duration);
                        p.trial.task.state_variables.wait_for_release = false;
                    end
                elseif(p.trial.task.training.release_for_reward && p.trial.task.state_variables.wait_for_release)
                    if(isnan(p.trial.task.timing.reward_delay.eligible_start_time))
                        fprintf('\t%s has exceeded the reward delay and is eligible for a reward once he releases the joystick.\n',p.trial.session.subject);
                        p.trial.task.timing.reward_delay.eligible_start_time = GetSecs;
                    end
                    if(p.trial.task.state_variables.joystick_released)
                        p.trial.task.timing.response_cue.response_duration =p.trial.task.timing.response_cue.response_duration + GetSecs - p.trial.task.timing.reward_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.reward_delay.start_time,p.trial.task.timing.response_cue.response_duration);
                        p.trial.task.state_variables.wait_for_release = false;
                    end
                elseif(~p.trial.task.training.release_for_reward || ~p.trial.task.state_variables.wait_for_release)
                    p.trial.task.timing.reward_delay.eligible_start_time = GetSecs;
                end
                
                if(~isnan(p.trial.task.timing.reward_delay.eligible_start_time) && ~p.trial.task.state_variables.wait_for_release)
                    
                    %  Monkey completed reward delay so he can get his
                    %  reward now!
                    fprintf('\t%s completed reward delay.  He gets a reward!\n',p.trial.session.subject);
                    p.trial.task.timing.reward_delay.start_time = NaN;
                    p.trial.task.timing.reward_delay.eligible_start_time = NaN;
                    p.trial.task.outcome.correct = true;
                    p.trial.task.outcome.completed = true;
                    p.trial.task.state_variables.trial_state = 'reward';
                end
                
                
                
            case 'reward'
                
                %  STATE:  reward
                
                %  Provide the monkey with his just desserts.
                
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.reward.start_time))
                    pds.behavior.reward.give(p,p.trial.stimulus.reward_amount);
                    
                    p.trial.task.timing.reward.start_time = GetSecs;
                    
                    fprintf('REWARD:  ');
                elseif(p.trial.task.timing.reward.start_time <= GetSecs - p.trial.stimulus.reward_amount)
                    fprintf('%s received reward for %0.3f sec.\n',p.trial.session.subject,p.trial.stimulus.reward_amount);
                    fprintf('END TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.flagNextTrial = true;
                end
                
        end
end

%  NESTED FUNCTIONS BELOW


    function ShowFixationCue
        %  ShowFixationCue
        %
        %  This function draws a fixation sqaure
        
        win = p.trial.display.overlayptr;
        
        width = p.trial.task.features.fixation.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        switch p.trial.task.state_variables.trial_state
            case 'joystick_warning'
                color = p.trial.task.features.joystick_warning.color;
            case 'engage'
                color = p.trial.task.features.engage.color;
            otherwise
                color = p.trial.task.features.fixation.color;
        end
        linewidth = p.trial.task.features.fixation.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

    function ShowResponseCue
        %  ShowResponseCue
        %
        %  This function draws a cue to indicate to monkey what his
        %  repsonse should be.  It is embedded in a noise annulus.
        
        win = p.trial.display.ptr;
        frame_index = p.trial.task.state_variables.noise_frame + 1;
        p.trial.task.state_variables.noise_frame = frame_index;
        
        annulus_outer_diameter = p.trial.task.features.annulus.outer_diameter;
        frame_width = annulus_outer_diameter;
        annulus_inner_diameter = p.trial.task.features.annulus.inner_diameter;
        response_cue_outer_diameter = p.trial.task.features.response_cue.diameter+2*p.trial.task.features.response_cue.linewidth;
        response_cue_inner_diameter = p.trial.task.features.response_cue.diameter;
        annulus_indx = noise_ring.get_annulus(frame_width,annulus_outer_diameter,annulus_inner_diameter);
        response_cue_indx = noise_ring.get_annulus(frame_width,response_cue_outer_diameter,response_cue_inner_diameter);
        
        M = p.trial.display.bgColor(1)*ones(frame_width);
        M = noise_ring.add_ring(M,response_cue_indx,p.trial.task.condition.luminance-p.trial.display.bgColor(1));
        [M,p.trial.task.stimulus.noise_ring.rng(frame_index)] = noise_ring.add_noise(M,annulus_indx,p.trial.task.features.annulus.noise_sigma);
        M = noise_ring.fix_range(M);
        
        p.trial.task.stimulus.noise_ring.textureIndex(frame_index) = Screen('MakeTexture',win,M);
        Screen('DrawTexture',win,p.trial.task.stimulus.noise_ring.textureIndex(frame_index));
    end

    function ShowSymbolMask
        %  ShowSymbolMask
        %
        %  This function draws the symbol mask
        
        win = p.trial.display.overlayptr;
        diameter = p.trial.task.features.symbol.outer_diameter;
        for ii=1:p.trial.task.state_variables.current_symbol
            Screen('DrawTexture',win,p.trial.task.stimulus.symbol.textureIndex,...
                [(ii-1)*diameter 0 ii*diameter diameter],p.trial.task.features.symbol.positions(p.trial.task.stimulus.symbol.position_order(ii),:));
        end
    end

    function ShowSymbol
        %  ShowSymbol
        %
        %  This function draws the symbol.  For now just circles, switching
        %  based on color
        
        %  Set parameters
        win = p.trial.display.overlayptr;
        order = p.trial.task.stimulus.symbol.position_order(1:p.trial.task.state_variables.current_symbol);
        color = repmat([p.trial.task.condition.symbol_features(order).color],3,1);
        rect = p.trial.task.features.symbol.positions(order,:)';
        Screen('FillOval',win,color,rect);
    end

    function check_joystick_status
        %  check_joystick_status
        %
        %  This function compares the joystick against threshold and sets
        %  the flags
        
        
        %  Determine status of joystick against thresholds
        switch p.trial.task.state_variables.trial_state
            case 'joystick_warning'
                [zone,p.trial.joystick.position] = joystick.zones(p.trial.joystick.joystick_warning);
            case 'engage'
                [zone,p.trial.joystick.position] = joystick.zones(p.trial.joystick.engage);
            case 'response_cue'
                if(p.trial.task.training.relative_response_threshold)
                    if(isnan(p.trial.task.timing.response_cue.start_time))
                        p.trial.joystick.response = p.trial.joystick.default;
                        p.trial.joystick.response_cue.threshold(1) = max(p.trial.joystick.position-3,p.trial.joystick.default.threshold(1));
                        p.trial.joystick.response_cue.threshold(2) = max(p.trial.joystick.position-2,p.trial.joystick.default.threshold(2));
                        p.trial.joystick.response_cue.threshold(3) = min(p.trial.joystick.position+2,p.trial.joystick.default.threshold(3));
                        p.trial.joystick.response_cue.threshold(4) = min(p.trial.joystick.position+3,p.trial.joystick.default.threshold(4));
                    end
                else
                    p.trial.joystick.response = p.trial.joystick.default;
                end
                [zone,p.trial.joystick.position] = joystick.zones(p.trial.joystick.response);
            otherwise
                [zone,p.trial.joystick.position] = joystick.zones(p.trial.joystick.default);
        end
        %  Set joystick state variables
        p.trial.task.state_variables.joystick_released = zone==1;
        p.trial.task.state_variables.joystick_release_buffer = zone==2;
        p.trial.task.state_variables.joystick_engaged = zone==3;
        p.trial.task.state_variables.joystick_press_buffer = zone==4;
        p.trial.task.state_variables.joystick_pressed = zone==5;
    end

    function display_joystick_status
        %  display_joystick_status
        %
        %  This function calls the function to display the joystick status
        %  to the console screen
        
        switch p.trial.task.state_variables.trial_state
            case 'joystick_warning'
                joystick.display(p,p.trial.joystick.position,p.trial.joystick.joystick_warning.threshold);
            case 'engage'
                joystick.display(p,p.trial.joystick.position,p.trial.joystick.engage.threshold);
            case 'response_cue'
                if(p.trial.task.training.relative_response_threshold)
                    joystick.display(p,p.trial.joystick.position,p.trial.joystick.response_cue.threshold);
                else
                    joystick.display(p,p.trial.joystick.position,p.trial.joystick.default.threshold);
                end
            otherwise
                joystick.display(p,p.trial.joystick.position,p.trial.joystick.default.threshold);
        end
    end

    function display_fixation_window
        %  display_fixation_window
        %
        %  This function displays the fixation window
        win = p.trial.display.overlayptr;
        width = p.trial.stimulus.fpWin;
        baseRect = [0 0 width(1) width(2)];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.display.clut.hCyan;
        Screen('FrameRect',win,color,centeredRect);
    end

    function check_fixation_status
        %  Check fixation status
        width = p.trial.stimulus.fpWin;
        p.trial.task.state_variables.fixating = squarewindow(~p.trial.task.training.enforce_fixation,p.trial.display.ctr(1:2)-[p.trial.eyeX p.trial.eyeY],width(1),width(2));
    end
end