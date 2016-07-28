function p = only_zuul(p,state)
%p = only_zuul(p,state)
%
%  PLDAPS trial function for set game training aka there is no set

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
        feval(str2func(strcat('set_trainer.there_is_no_set.',p.trial.session.subject)),p);
        
        %  Initialize trial outcome
        p.trial.task.outcome.correct = false;
        p.trial.task.outcome.completed = false;
        p.trial.task.outcome.fixation_break = false;
        p.trial.task.outcome.failed_to_initiate = false;
        p.trial.task.outcome.warning_elapsed = false;
        p.trial.task.outcome.early_release = false;
        p.trial.task.outcome.early_press = false;
        p.trial.task.outcome.release_drift_error = false;
        p.trial.task.outcome.press_drift_error = false;
        p.trial.task.outcome.miss = false;
        
        %  Telemetry
        
        if(p.trial.pldaps.iTrial==1)
            
            %  Performance data
            p.trial.task.performance = p.trial.task.outcome;
            
            p.trial.task.performance.attempted = 0;
            
            nlum = length(p.trial.task.features.log10C);
            p.trial.task.performance.matrix = zeros(2*nlum,3);
            p.trial.task.performance.log10C = [p.trial.task.features.log10C(end:-1:1) p.trial.task.features.log10C(1:end)];
            
            %  Indexing
            p.trial.task.indexing.current_trial = 1;
            
        else
            
            %  Previous trial index
            indx = p.trial.pldaps.iTrial-1;
            
            %  Previous trial performance data
            fnames = fieldnames(p.data{indx}.task.performance);
            for i=1:length(fnames)
                p.trial.task.performance.(fnames{i}) = p.data{indx}.task.performance.(fnames{i});
            end
            
            %  Current trial indexing
            p.trial.task.indexing.current_trial = p.data{indx}.task.indexing.next_trial;
        end
        
        %  Extract data from conditions cell array
        indx = p.trial.task.indexing.current_trial;
        p.trial.task.trial_type = p.conditions{indx}.trial_type;
        p.trial.task.symbol_type = p.conditions{indx}.symbol_type;
        p.trial.task.luminance = p.conditions{indx}.luminance;
        p.trial.task.lum_indx = p.conditions{indx}.lum_indx;
        p.trial.task.log10C = p.conditions{indx}.log10C;
        p.trial.task.trial_number = p.conditions{indx}.trial_number;
        p.trial.task.block_number = p.conditions{indx}.block_number;
        
        %  Random number generator seed for symbol masks
        p.trial.task.stimulus.symbol_masks.rng = rng;
        
        %  Texture for symbol masks
        if(p.trial.task.training.use_symbol_masks)
            colors = p.trial.task.features.symbol.colors;
            background = p.trial.task.features.symbol.background;
            diameter = p.trial.task.features.annulus.outer_diameter;
            M = symbols.pixel_noise(diameter,colors,background);
            p.trial.task.stimulus.symbol_masks.textureIndex = Screen('MakeTexture',p.trial.display.ptr,M);
        end
        
        %  Initialize random symbol position order
        p.trial.task.stimulus.symbol.position_order = randperm(3);
        
        %  Random number generator seed for noise annulus
        p.trial.task.stimulus.noise_ring.rng = rng;
        
        %  Initialize array of texture indices (seems to work more smoothly
        %  to clear at end of trial).
        
        p.trial.task.stimulus.noise_ring.textureIndex = NaN(p.trial.pldaps.maxFrames,1);
        
        %  Initialize trial state variables
        
        p.trial.task.state_variables.trial_state = 'start';
        p.trial.task.state_variables.release_trial = strcmp('release',p.trial.task.trial_type);
        p.trial.task.state_variables.press_trial = ~p.trial.task.state_variables.release_trial;
        p.trial.task.state_variables.current_symbol = 1;
        p.trial.task.state_variables.waiting_for_release = false;
        
        %  Print information to screen
        
        fprintf('START TRIAL ATTEMPT %d (%d trials of %d completed, %d remain):\n',p.trial.pldaps.iTrial,p.trial.task.performance.completed,p.trial.task.constants.maxTrials,p.trial.task.constants.maxTrials-p.trial.task.performance.completed);
        fprintf('\tTrial %d of %d for block %d of %d.\n',p.trial.task.trial_number,p.trial.task.constants.maxTrialsPerBlock,p.trial.task.block_number,p.trial.task.constants.maxBlocks);
        fprintf('\tThis is a %s %s trial with log contrast %0.3f.\n',upper(p.trial.task.symbol_type),upper(p.trial.task.trial_type),p.trial.task.log10C);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        %  Close the textureIndex
        indx = ~isnan(p.trial.task.stimulus.noise_ring.textureIndex);
        if(any(indx))
            Screen('Close',p.trial.task.stimulus.noise_ring.textureIndex(indx));
        end
        if(p.trial.task.training.use_symbol_masks)
            Screen('Close',p.trial.task.stimulus.symbol_masks.textureIndex);
        end
        
        %  Update performance
        p.trial.task.performance.attempted = p.trial.task.performance.attempted + 1;
        
        fnames = fieldnames(p.trial.task.outcome);
        for i=1:length(fnames)
            if(islogical(p.trial.task.outcome.(fnames{i})))
                p.trial.task.performance.(fnames{i}) = p.trial.task.performance.(fnames{i}) + p.trial.task.outcome.(fnames{i});
            end
        end
        
        %  Update trial indexing
        %
        %  If we are repeating errors then repeat with the appropriate
        %  probability.  Otherwise update the trial index.
        if(p.trial.task.outcome.completed)
            if(~p.trial.task.training.repeat_errors || p.trial.task.outcome.correct)
                p.trial.task.indexing.next_trial = p.trial.task.indexing.current_trial+1;
            else
                p.trial.task.indexing.next_trial = p.trial.task.indexing.current_trial;
                p.conditions{end+1} = p.conditions{end};
            end
            
            p.trial.task.performance.matrix(p.trial.task.lum_indx,1) = p.trial.task.performance.matrix(p.trial.task.lum_indx,1)+((p.trial.task.outcome.correct && p.trial.task.state_variables.release_trial) || (~p.trial.task.outcome.correct && p.trial.task.state_variables.press_trial));
            p.trial.task.performance.matrix(p.trial.task.lum_indx,2) = p.trial.task.performance.matrix(p.trial.task.lum_indx,2)+((p.trial.task.outcome.correct && p.trial.task.state_variables.press_trial) || (~p.trial.task.outcome.correct && p.trial.task.state_variables.release_trial));
            p.trial.task.performance.matrix(p.trial.task.lum_indx,3) = p.trial.task.performance.matrix(p.trial.task.lum_indx,3)+1;
        else
            p.trial.task.indexing.next_trial = p.trial.task.indexing.current_trial;
            p.conditions{end+1} = p.conditions{end};
            
            if(p.trial.task.training.shuffle_aborts)
                indx = p.trial.task.indexing.current_trial:p.trial.task.indexing.current_trial + p.trial.task.constants.maxTrialsPerBlock-p.trial.task.trial_number;
                
                fprintf('\tReshuffling trials %d through %d (within block trial %d through %d)\n\n',indx(1),indx(end),p.trial.task.trial_number,p.trial.task.constants.maxTrialsPerBlock);
                
                temp = p.conditions(indx);
                p.conditions(indx) = Shuffle(temp);
                for i = 1:length(indx)
                    p.conditions{indx(i)}.trial_number = temp{i}.trial_number;
                end
            end
            
        end
        
        %  Display performance
        completed = double(p.trial.task.performance.completed);
        attempted = double(p.trial.task.performance.attempted);
        correct = double(p.trial.task.performance.correct);
        
        fixation_breaks = double(p.trial.task.performance.fixation_break);
        failed_to_initiate = double(p.trial.task.performance.failed_to_initiate);
        warning_elapsed = double(p.trial.task.performance.warning_elapsed);
        early_releases = double(p.trial.task.performance.early_release);
        early_presses = double(p.trial.task.performance.early_press);
        release_drift_errors = double(p.trial.task.performance.release_drift_error);
        press_drift_errors = double(p.trial.task.performance.press_drift_error);
        misses = double(p.trial.task.performance.miss);
        
        fprintf('Current performance:\n');
        fprintf('\tCompleted:            %d of %d (%0.3f)\n',completed,attempted,completed/attempted);
        fprintf('\tCorrectly completed:  %d of %d (%0.3f)\n',correct,completed,correct/completed);
        fprintf('\n');
        
        for i=1:length(p.trial.task.performance.log10C)/2
            fprintf('\t%5.2f release:  %4d R %4d P %4d T, %5.2f correct %5.2f release\n',p.trial.task.performance.log10C(i),p.trial.task.performance.matrix(i,1:2),sum(p.trial.task.performance.matrix(i,1:2)),p.trial.task.performance.matrix(i,1)/p.trial.task.performance.matrix(i,3),p.trial.task.performance.matrix(i,1)/p.trial.task.performance.matrix(i,3));
        end
        for i=1+length(p.trial.task.performance.log10C)/2 : length(p.trial.task.performance.log10C)
            fprintf('\t%5.2f   press:  %4d R %4d P %4d T, %5.2f correct %5.2f release\n',p.trial.task.performance.log10C(i),p.trial.task.performance.matrix(i,1:2),sum(p.trial.task.performance.matrix(i,1:2)),p.trial.task.performance.matrix(i,2)/p.trial.task.performance.matrix(i,3),1 - p.trial.task.performance.matrix(i,2)/p.trial.task.performance.matrix(i,3));
        end
        fprintf('\n');
        
        fprintf('Trial aborts:\n');
        fprintf('\tFixation breaks:     %3d of %d (%0.3f)\n',fixation_breaks,attempted,fixation_breaks/attempted);
        fprintf('\tFailed to initiate:  %3d of %d (%0.3f)\n',failed_to_initiate,attempted,failed_to_initiate/attempted);
        fprintf('\tWarning elapsed:     %3d of %d (%0.3f)\n',warning_elapsed,attempted,warning_elapsed/attempted);
        fprintf('\tEarly releases:      %3d of %d (%0.3f)\n',early_releases,attempted,early_releases/attempted);
        fprintf('\tEarly presses:       %3d of %d (%0.3f)\n',early_presses,attempted,early_presses/attempted);
        fprintf('\tRelease drift errors:%3d of %d (%0.3f)\n',release_drift_errors,attempted,release_drift_errors/attempted);
        fprintf('\tPress drift errors:  %3d of %d (%0.3f)\n',press_drift_errors,attempted,press_drift_errors/attempted);
        fprintf('\tMisses:              %3d of %d (%0.3f)\n',misses,attempted,misses/attempted);
        fprintf('\n');
        
        %  Check if we have completed conditions; if so, we're finished.
        if(p.trial.task.performance.completed==p.trial.task.constants.maxTrials)
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
        
        switch p.trial.task.state_variables.trial_state
            case 'warning'
                joystick.display(p,p.trial.joystick.warning);
            case 'engage'
                joystick.display(p,p.trial.joystick.engage);
            otherwise
                joystick.display(p,p.trial.joystick.default);
        end
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control.
        
        %
        %  Check trial time first; go to timeout if exceeds maximum wait
        %  time
        %
        if(p.trial.ttime > p.trial.pldaps.maxTrialLength-p.trial.task.constants.minTrialTime)
            fprintf('\t%s did not initiate trial within %0.3f sec.\n',p.trial.session.subject,p.trial.pldaps.maxTrialLength-60);
            p.trial.task.outcome.failed_to_initiate = true;
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
                %  Otherwise go to warning.
                
                if(~p.trial.task.state_variables.joystick_released)
                    %  Monkey does not have joystick released.
                    fprintf('\t%s started trial without joystick released; go to warning.\n',p.trial.session.subject);
                    p.trial.task.state_variables.waiting_for_release = true;
                    p.trial.task.state_variables.trial_state = 'warning';
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
                    %  checking the joystick and fixation and will
                    %  blinked the fixation cue as long as the monkey has
                    %  both not engaged the joystick and fixated.
                    
                    if(p.trial.task.state_variables.joystick_engaged && p.trial.task.state_variables.fixating)
                        
                        %  The monkey has both joystick engaged and is
                        %  fixating.  Print some feedback, reset the
                        %  timing variables, and go on to the delay
                        %  state.
                        fprintf('\t%s engaged joystick and is fixating after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.engage.start_time);
                        p.trial.task.timing.engage.start_time = NaN;
                        p.trial.task.timing.engage.cue_start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'delay';
                        
                        %  Show fixation cue
                        ShowFixationCue;
                        
                    elseif(p.trial.task.state_variables.joystick_pressed || p.trial.task.state_variables.joystick_press_buffer)
                        
                        %  The monkey overshot the engage region.
                        fprintf('\t%s pressed the joystick after %0.3f sec; go to warning.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.engage.start_time);
                        p.trial.task.timing.engage.start_time = NaN;
                        p.trial.task.timing.engage.cue_start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'warning';
                        
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
                    %  pushes the joystick too far then give him a warning.
                    
                    if(~p.trial.task.state_variables.joystick_engaged)
                        %  Monkey released or pressed joystick early.
                        
                        if(p.trial.task.state_variables.joystick_released || p.trial.task.state_variables.joystick_release_buffer)
                            fprintf('\t%s released joystick at %0.3f sec; go to engage.\n',...
                                p.trial.session.subject,GetSecs-p.trial.task.timing.delay.start_time);
                            p.trial.task.state_variables.trial_state = 'engage';
                        else
                            fprintf('\t%s pressed joystick at %0.3f sec, give him a warning.\n',...
                                p.trial.session.subject,GetSecs-p.trial.task.timing.delay.start_time);
                            p.trial.task.state_variables.trial_state = 'warning';
                        end
                        p.trial.task.timing.delay.start_time = NaN;
                    elseif(~p.trial.task.state_variables.fixating)
                        %  Monkey broke fixation.
                        
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',...
                            p.trial.session.subject,GetSecs-p.trial.task.timing.delay.start_time);
                        p.trial.task.outcome.fixation_break = true;
                        p.trial.task.timing.delay.start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'timeout';
                    end
                    
                else
                    %  Monkey has successfully held the joystick engaged
                    %  and fixated to the end of the duration.
                    
                    fprintf('\t%s successfully held joystick engaged and remained fixating.\n',p.trial.session.subject);
                    p.trial.task.state_variables.trial_state = 'symbol';
                    p.trial.task.timing.delay.start_time = NaN;
                end
                
            case 'warning'
                
                %  STATE:  warning
                
                %  Monkey enters this state if he has pushed the joystick
                %  too far.  Exit warning when he gets the joystick into
                %  the appropriate range (either release or engage).
                
                %  Fixation cue will be red
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.warning.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.task.timing.warning.start_time = GetSecs;
                    fprintf('WARNING started for %0.3f sec.\n',p.trial.task.timing.warning.duration);
                    
                    %  Play the warning until he returns joystick to
                    %  appropriate position
                    pds.audio.play(p,'warning',0);
                    
                elseif(p.trial.task.timing.warning.start_time > GetSecs - p.trial.task.timing.warning.duration)
                    
                    
                    %  We are still in the warning state.  We will continue
                    %  the warning as long as the monkey has not moved the
                    %  joystick back into the appropriate range.
                    
                    if(p.trial.task.state_variables.waiting_for_release && p.trial.task.state_variables.joystick_released)
                        p.trial.task.state_variables.waiting_for_release = false;
                        
                        %  Monkey released joystick
                        fprintf('\t%s released joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.warning.start_time);
                        p.trial.task.timing.warning.start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'engage';
                        
                        %  Stop the warning tone
                        pds.audio.stop(p,'warning');
                        
                        
                    elseif(~p.trial.task.state_variables.waiting_for_release)
                        if(p.trial.task.state_variables.joystick_engaged)
                            
                            %  Monkey has joystick engaged
                            fprintf('\t%s re-engaged joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.warning.start_time);
                            p.trial.task.timing.warning.start_time = NaN;
                            p.trial.task.state_variables.trial_state = 'delay';
                            
                            %  Stop the warning tone
                            pds.audio.stop(p,'warning');
                        elseif(p.trial.task.state_variables.joystick_released || p.trial.task.state_variables.joystick_release_buffer)
                            
                            %  Monkey has somehow managed to pass back
                            %  through the engaged state
                            fprintf('\t%s released joystick after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.warning.start_time);
                            p.trial.task.timing.warning.start_time = NaN;
                            p.trial.task.state_variables.trial_state = 'start';
                            
                            %  Stop the warning tone
                            pds.audio.stop(p,'warning');
                        end
                    end
                    
                else
                    %  Monkey has failed to re-engage within the warning
                    %  duration
                    
                    %  Stop the warning tone
                    pds.audio.stop(p,'warning');
                    
                    fprintf('\t%s elapsed his warning interval.\nEND TRIAL %d.\n\n',p.trial.session.subject,p.trial.pldaps.iTrial);
                    
                    p.trial.task.outcome.warning_elapsed = true;
                    p.trial.task.timing.warning.start_time = NaN;
                    
                    p.trial.flagNextTrial = true;
                    
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
                
                if(~p.trial.task.training.use_symbol_masks || p.trial.task.timing.symbol.duration==0)
                    p.trial.task.state_variables.current_symbol = 3;
                    p.trial.task.state_variables.trial_state = 'response';
                else
                    %  Show symbols
                    if(isnan(p.trial.task.timing.symbol.start_time))
                        p.trial.task.timing.symbol.start_time = GetSecs;
                        p.trial.task.timing.symbol.start_frame = p.trial.iFrame;
                        
                        if(strcmp('mask',p.trial.task.symbol_type)==1)
                            ShowSymbolMask;
                        else
                            ShowSymbol;
                        end
                        fprintf('SYMBOL %s %d of 3 for %0.3f sec.\n',p.trial.task.symbol_type,p.trial.task.state_variables.current_symbol,p.trial.task.timing.symbol.duration);
                    elseif(~p.trial.task.state_variables.joystick_engaged)
                        %  Monkey released or pressed joystick early.
                        
                        if(p.trial.task.state_variables.joystick_released || p.trial.task.state_variables.joystick_release_buffer)
                            fprintf('\t%s released joystick at %0.3f sec, give him a timeout.\n',...
                                p.trial.session.subject,GetSecs-p.trial.task.timing.symbol.start_time);
                            p.trial.task.outcome.early_release = true;
                        else
                            fprintf('\t%s pressed joystick at %0.3f sec, give him a timeout.\n',...
                                p.trial.session.subject,GetSecs-p.trial.task.timing.symbol.start_time);
                            p.trial.task.outcome.early_press = true;
                        end
                        p.trial.task.state_variables.trial_state = 'timeout';
                        p.trial.task.timing.symbol.start_time = NaN;
                    elseif(~p.trial.task.state_variables.fixating)
                        %  Monkey broke fixation.
                        
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',...
                            p.trial.session.subject,GetSecs-p.trial.task.timing.delay.start_time);
                        p.trial.task.outcome.fixation_break = true;
                        p.trial.task.timing.symbol.start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'timeout';
                    elseif(p.trial.task.timing.symbol.start_time <= GetSecs - p.trial.task.timing.symbol.duration)
                        ShowSymbolMask;
                        p.trial.task.timing.symbol.start_time = NaN;
                        if(p.trial.task.state_variables.current_symbol==3)
                            p.trial.task.state_variables.trial_state = 'response';
                        else
                            p.trial.task.state_variables.current_symbol = p.trial.task.state_variables.current_symbol + 1;
                        end
                    else
                        
                        if(strcmp('mask',p.trial.task.symbol_type)==1)
                            ShowSymbolMask;
                        else
                            ShowSymbol;
                        end
                    end
                end
                
                
                %             case 'symbol'
                %
                %                 %  STATE:  symbol
                %
                %                 %  Monkey enters the state for the first time with the
                %                 %  joystick engaged and fixating.  Continue to show him
                %                 %  both the continue holding cue and the fixation dot as
                %                 %  long as this is the case and we have not yet reached the
                %                 %  end of the symbol presentation sequence.
                %                 %
                %                 %  Will alternate between symbols and delays until
                %                 %  complete, then go to either hold or release depending on
                %                 %  trial type.
                %
                %                 %  Determine number of symbols and delays
                %                 num_symbols = length(p.trial.task.timing.symbol.presentation_duration);
                %                 num_delays = length(p.trial.task.timing.symbol.delay_duration);
                %
                %                 %  Show start and fixation cues and symbol
                %                 switch p.trial.task.trial_type
                %                     case {'set','notset'}
                %                         if(p.trial.task.state_variables.symbol_on && p.trial.task.timing.symbol.presentation_duration(p.trial.task.state_variables.current_symbol)~=0)
                %                             ShowSymbol;
                %                         end
                %                 end
                %                 ShowContinueHoldCue;
                %                 ShowFixationCue;
                %
                %                 if(isnan(p.trial.task.timing.symbol.sequence_start_time))
                %                     p.trial.task.timing.symbol.sequence_start_time = GetSecs;
                %                     switch p.trial.task.trial_type
                %                         case {'set','notset'}
                %                             fprintf('SYMBOL PRESENTATION SEQUENCE:  ');
                %                             fprintf('%s ',p.trial.task.symbols{:});
                %                             fprintf('\n');
                %                         otherwise
                %                             fprintf('NO SYMBOL SEQUENCE.\n');
                %                     end
                %                 end
                %
                %                 if(isnan(p.trial.task.timing.symbol.start_time))
                %
                %
                %                     %  Start our timers and print some feedback to screen.
                %                     p.trial.task.timing.symbol.start_time = GetSecs;
                %                     if(p.trial.task.state_variables.symbol_on)
                %                         p.trial.task.timing.symbol.duration = p.trial.task.timing.symbol.presentation_duration(p.trial.task.state_variables.current_symbol);
                %                         switch p.trial.task.trial_type
                %                             case {'set','notset'}
                %                                 fprintf('\tPresentation %d of %d for %0.3f sec:  %s.\n',p.trial.task.state_variables.current_symbol,num_symbols,p.trial.task.timing.symbol.duration,p.trial.task.symbols{p.trial.task.state_variables.current_symbol});
                %                         end
                %                     else
                %                         p.trial.task.timing.symbol.duration = p.trial.task.timing.symbol.delay_duration(p.trial.task.state_variables.current_symbol+1);
                %                         switch p.trial.task.trial_type
                %                             case {'set','notset'}
                %                                 fprintf('\tDelay %d of %d for %0.3f sec.\n',p.trial.task.state_variables.current_symbol+1,num_delays,p.trial.task.timing.symbol.duration);
                %                         end
                %                     end
                %
                %                 elseif(p.trial.task.timing.symbol.start_time > GetSecs - p.trial.task.timing.symbol.duration)
                %
                %                     %  We're still in symbol presentation sequence.  As
                %                     %  long as he continues to engage and fixate, show him
                %                     %  the start and fixation cues as well as a symbol.  If
                %                     %  he realeses during this period, give him a timeout
                %
                %                     if(~p.trial.task.state_variables.joystick_engaged)
                %                         %  Monkey released joystick early.  Give him a
                %                         %  timeout unless this is the third symbol, in
                %                         %  which case proceed to result.
                %
                %                         if(p.trial.task.state_variables.current_symbol < num_symbols)
                %                             fprintf('\t%s released joystick at %0.3f sec.\n',p.trial.session.subject,...
                %                                 GetSecs-p.trial.task.timing.symbol.sequence_start_time);
                %                             p.trial.task.outcome.early_release = true;
                %                             p.trial.task.state_variables.trial_state = 'timeout';
                %                         else
                %                             fprintf('\t%s released joystick at %0.3f sec.\n',p.trial.session.subject,...
                %                                 GetSecs-p.trial.task.timing.symbol.sequence_start_time);
                %
                %                             switch p.trial.task.trial_type
                %                                 case {'set','notset'}
                %                                     p.trial.task.outcome.reaction_time = GetSecs - p.trial.task.timing.symbol.start_time;
                %                                     fprintf('\tReaction time is %0.3f.\n',p.trial.task.outcome.reaction_time);
                %                             end
                %                             switch p.trial.task.trial_type
                %                                 case 'set'
                %                                     p.trial.task.state_variables.trial_state = 'reward_delay';
                %                                 case 'notset'
                %                                     p.trial.task.outcome.completed = true;
                %                                     p.trial.task.state_variables.trial_state = 'error';
                %                                 otherwise
                %                                     p.trial.task.outcome.early_release = true;
                %                                     p.trial.task.state_variables.trial_state = 'timeout';
                %                             end
                %                             p.trial.task.timing.symbol.sequence_start_time = NaN;
                %                             p.trial.task.timing.symbol.start_time = NaN;
                %                         end
                %                         p.trial.task.timing.symbol.start_time = NaN;
                %                         p.trial.task.timing.symbol.sequence_start_time = NaN;
                %                     elseif(~p.trial.task.state_variables.fixating);
                %                         %  Monkey broke fixation.  Give him a timeout
                %
                %                         fprintf('\t%s broke fixation after %0.3f sec.\n',p.trial.session.subject,...
                %                             GetSecs-p.trial.task.timing.symbol.sequence_start_time);
                %                         p.trial.task.state_variables.trial_state = 'timeout';
                %                         p.trial.task.outcome.fixation_break = true;
                %                         p.trial.task.timing.symbol.start_time = NaN;
                %                         p.trial.task.timing.symbol.sequence_start_time = NaN;
                %                     end
                %
                %                 else
                %
                %                     %  Monkey has successfully held the joystick to the end
                %                     %  of the duration.  If we are done showing
                %                     %  symbols, proceed to the hold or release cue.
                %                     %  Otherwise proceed to next step in sequence.
                %
                %                     %  If this is a delay period then proceed to symbol
                %                     %  presentation
                %
                %                     if(p.trial.task.state_variables.current_symbol < num_symbols)
                %                         if(p.trial.task.state_variables.symbol_on)
                %                             p.trial.task.state_variables.symbol_on = false;
                %                         else
                %                             p.trial.task.state_variables.current_symbol = p.trial.task.state_variables.current_symbol + 1;
                %                             p.trial.task.state_variables.symbol_on = true;
                %                         end
                %                     else
                %                         fprintf('\t%s successfully held joystick and remained fixating.\n',p.trial.session.subject);
                %                         p.trial.task.state_variables.trial_state = 'response';
                %                         p.trial.task.timing.symbol.sequence_start_time = NaN;
                %                     end
                %                     p.trial.task.timing.symbol.start_time = NaN;
                %                 end
                
            case 'timeout'
                
                %  STATE:  timeout
                
                %  In this state we are going to give the monkey a timeout period.
                %  After that is over, end trial.
                
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
                
            case 'response'
                
                %  STATE:  response
                
                %  In this state we show a response cue.  Monkey should
                %  either press or release the joystick prior to the end
                %  of the grace period in order to convey his response.
                
                if(isnan(p.trial.task.timing.response.start_time))
                    p.trial.task.timing.response.start_time = GetSecs;
                    p.trial.task.timing.response.start_frame = p.trial.iFrame;
                    p.trial.task.outcome.reaction_time = NaN;
                    
                    ShowResponseCue;
                    ShowFixationCue;
                    if(p.trial.task.training.use_symbol_masks && p.trial.task.training.continue_symbols)
                        ShowSymbolMask;
                    end
                    
                    fprintf('RESPONSE state for trial %d.  Respond within %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.task.timing.response.grace);
                    
                elseif(p.trial.task.timing.response.start_time > GetSecs - p.trial.task.timing.response.grace)
                    
                    %  Still in grace period so check joystick as long as
                    %  he is still fixating
                    if(p.trial.task.state_variables.fixating)
                        
                        ShowResponseCue;
                        ShowFixationCue;
                        if(p.trial.task.training.use_symbol_masks && p.trial.task.training.continue_symbols)
                            ShowSymbolMask;
                        end
                        
                        if(isnan(p.trial.task.outcome.reaction_time))
                            if(~p.trial.task.state_variables.joystick_engaged)
                                p.trial.task.outcome.reaction_time = GetSecs - p.trial.task.timing.response.start_time;
                            end
                        end
                        
                        if(p.trial.task.state_variables.joystick_released)
                            %  Monkey has released the joystick
                            
                            fprintf('\t%s released joystick with reaction time %0.3f sec ',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                            
                            if(~isnan(p.trial.task.timing.buffer.start_time))
                                p.trial.task.outcome.buffer_time = GetSecs - p.trial.task.timing.buffer.start_time;
                                fprintf('(%0.3f sec in buffer).\n',p.trial.task.outcome.buffer_time);
                            else
                                p.trial.task.outcome.buffer_time = 0;
                                fprintf('(<0.0083 sec in buffer).\n');
                            end
                            
                            p.trial.task.outcome.response_duration = GetSecs - p.trial.task.outcome.reaction_time - p.trial.task.timing.response.start_time;
                            fprintf('\tResponse duration was %0.3f sec.\n',p.trial.task.outcome.response_duration);
                            
                            if(p.trial.task.state_variables.release_trial)
                                p.trial.task.state_variables.trial_state = 'reward_delay';
                            else
                                p.trial.task.state_variables.trial_state = 'error_delay';
                            end
                            p.trial.task.timing.response.start_time = NaN;
                            p.trial.task.timing.buffer.start_time = NaN;
                            
                        elseif(p.trial.task.state_variables.joystick_release_buffer)
                            
                            %  Joystick is now in the release buffer.
                            
                            if(isnan(p.trial.task.timing.buffer.start_time))
                                p.trial.task.timing.buffer.start_time = GetSecs;
                                
                            elseif(p.trial.task.timing.buffer.start_time <= GetSecs - p.trial.task.timing.buffer.maximum_time)
                                %  the maximum time has elapsed and
                                %  joystick is not fully released.  Abort
                                %  the trial
                                fprintf('\t%s drifted out of engage state at %0.3f sec without fully releasing joystick.\n',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                                p.trial.task.timing.response.start_time = NaN;
                                p.trial.task.timing.buffer.start_time = NaN;
                                p.trial.task.state_variables.trial_state = 'timeout';
                                p.trial.task.outcome.release_drift_error = true;
                            end
                            
                        elseif(p.trial.task.state_variables.joystick_pressed)
                            %  Monkey has pressed the joystick
                            
                            fprintf('\t%s pressed joystick with reaction time %0.3f sec ',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                            
                            if(~isnan(p.trial.task.timing.buffer.start_time))
                                p.trial.task.outcome.buffer_time = GetSecs - p.trial.task.timing.buffer.start_time;
                                fprintf('(%0.3f sec in buffer).\n',p.trial.task.outcome.buffer_time);
                            else
                                p.trial.task.outcome.buffer_time = 0;
                                fprintf('(<0.0083 sec in buffer).\n');
                            end
                            
                            p.trial.task.outcome.response_duration = GetSecs - p.trial.task.outcome.reaction_time - p.trial.task.timing.response.start_time;
                            fprintf('\tResponse duration was %0.3f sec.\n',p.trial.task.outcome.response_duration);
                            
                            if(p.trial.task.state_variables.press_trial)
                                p.trial.task.state_variables.trial_state = 'reward_delay';
                            else
                                p.trial.task.state_variables.trial_state = 'error_delay';
                            end
                            p.trial.task.state_variables.waiting_for_release = true;
                            p.trial.task.timing.response.start_time = NaN;
                            p.trial.task.timing.buffer.start_time = NaN;
                        elseif(p.trial.task.state_variables.joystick_press_buffer)
                            
                            %  Joystick is now in the press buffer.
                            
                            if(isnan(p.trial.task.timing.buffer.start_time))
                                p.trial.task.timing.buffer.start_time = GetSecs;
                                
                            elseif(p.trial.task.timing.buffer.start_time <= GetSecs - p.trial.task.timing.buffer.maximum_time)
                                %  the maximum time has elapsed and
                                %  joystick is not fully pressed.  Abort
                                %  the trial
                                fprintf('\t%s drifted out of engage state at %0.3f sec without fully pressing joystick.\n',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                                p.trial.task.timing.response.start_time = NaN;
                                p.trial.task.timing.buffer.start_time = NaN;
                                p.trial.task.state_variables.trial_state = 'timeout';
                                p.trial.task.outcome.press_drift_error = true;
                            end
                        end
                    else
                        
                        %  Monkey broke fixation too early.  Give him a
                        %  timeout.
                        
                        fprintf('\t%s broke fixation after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.response.start_time);
                        p.trial.task.fixation_breaks = p.trial.task.fixation_breaks+1;
                        
                        p.trial.task.timing.response.start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'timeout';
                    end
                    
                else
                    %  Monkey has held joystick till end of grace period,
                    %  so give him a timeout
                    
                    fprintf('\t%s held joystick to end of response duration; this is a missed response.\n',p.trial.session.subject);
                    p.trial.task.timing.response.start_time = NaN;
                    p.trial.task.state_variables.trial_state = 'timeout';
                    p.trial.task.outcome.miss = true;
                end
                
            case 'error_delay'
                
                %  STATE:  error_delay
                %
                %  In this state we continue to show the fixation dot while
                %  the monkey is waiting to see if he gets his reward.
                
                
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.error_delay.start_time))
                    
                    if(p.trial.task.training.release_for_reward && p.trial.task.state_variables.waiting_for_release)
                        fprintf('ERROR DELAY.  %s must completely release joystick and fixate and await feedback %0.3f sec (%0.3f remain).\n',p.trial.session.subject,p.trial.task.timing.error_delay.duration,p.trial.task.timing.error_delay.duration - p.trial.task.outcome.response_duration);
                    else
                        fprintf('ERROR DELAY.  %s must fixate and await feedback for %0.3f sec.\n',p.trial.session.subject,p.trial.task.timing.error_delay.duration);
                    end
                    
                    p.trial.task.timing.error_delay.start_time = GetSecs;
                elseif(p.trial.task.timing.error_delay.start_time > GetSecs - p.trial.task.timing.error_delay.duration - p.trial.task.outcome.response_duration)
                    
                    %  Still in delay so check to make sure monkey
                    %  continues to fixate.
                    
                    if(~p.trial.task.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.error_delay.start_time);
                        p.trial.task.outcome.fixation_break = true;
                        p.trial.task.state_variables.trial_state = 'timeout';
                        p.trial.task.timing.error_delay.start_time = NaN;
                    end
                    
                    if(p.trial.task.training.release_for_reward && p.trial.task.state_variables.waiting_for_release && p.trial.task.state_variables.joystick_released)
                        p.trial.task.outcome.response_duration = p.trial.task.outcome.response_duration + GetSecs - p.trial.task.timing.error_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.error_delay.start_time,p.trial.task.outcome.response_duration);
                        p.trial.task.state_variables.waiting_for_release = false;
                    end
                    
                elseif(~p.trial.task.training.release_for_reward || p.trial.task.state_variables.joystick_released)
                    
                    %  Monkey completed error delay
                    fprintf('\t%s completed error delay and does not get a reward.\n',p.trial.session.subject);
                    p.trial.task.timing.error_delay.start_time = NaN;
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
                    
                    if(p.trial.task.training.release_for_reward && p.trial.task.state_variables.waiting_for_release)
                        fprintf('REWARD DELAY.  %s must release joystick and fixate and await feedback for %0.3f sec (%0.3f sec remain).\n',p.trial.session.subject,p.trial.task.timing.reward_delay.duration,p.trial.task.timing.reward_delay.duration - p.trial.task.outcome.response_duration);
                    else
                        fprintf('REWARD DELAY.  %s must fixate and await feedback for %0.3f sec.\n',p.trial.session.subject,p.trial.task.timing.reward_delay.duration);
                    end
                    
                    p.trial.task.timing.reward_delay.start_time = GetSecs;
                elseif(p.trial.task.timing.reward_delay.start_time > GetSecs - p.trial.task.timing.reward_delay.duration - p.trial.task.outcome.response_duration)
                    
                    %  Still in delay so check to make sure monkey
                    %  continues to fixate.
                    
                    if(~p.trial.task.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.reward_delay.start_time);
                        p.trial.task.outcome.fixation_break = true;
                        p.trial.task.state_variables.trial_state = 'timeout';
                        p.trial.task.timing.reward_delay.start_time = NaN;
                    end
                    
                    if(p.trial.task.training.release_for_reward && p.trial.task.state_variables.waiting_for_release && p.trial.task.state_variables.joystick_released)
                        p.trial.task.outcome.response_duration = p.trial.task.outcome.response_duration + GetSecs - p.trial.task.timing.reward_delay.start_time;
                        fprintf('\t%s released joystick at %0.3f sec; response duration was %0.3f sec.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.reward_delay.start_time,p.trial.task.outcome.response_duration);
                        p.trial.task.state_variables.waiting_for_release = false;
                    end
                    
                elseif(~p.trial.task.training.release_for_reward || p.trial.task.state_variables.joystick_released)
                    
                    %  Monkey completed reward delay so he can get his
                    %  reward now!
                    fprintf('\t%s completed reward delay.  He gets a reward!\n',p.trial.session.subject);
                    p.trial.task.timing.reward_delay.start_time = NaN;
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
                    
                    fprintf('REWARD:  %s received reward for %0.3f sec.\n',p.trial.session.subject,p.trial.stimulus.reward_amount);
                elseif(p.trial.task.timing.reward.start_time <= GetSecs - p.trial.stimulus.reward_amount)
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
            case 'warning'
                color = p.trial.task.features.warning.color;
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
        frame_index = p.trial.iFrame-p.trial.task.timing.response.start_frame+1;
        
        annulus_outer_diameter = p.trial.task.features.annulus.outer_diameter;
        frame_width = annulus_outer_diameter+1;
        annulus_inner_diameter = p.trial.task.features.annulus.inner_diameter;
        response_cue_outer_diameter = p.trial.task.features.response.diameter+2*p.trial.task.features.response.linewidth;
        response_cue_inner_diameter = p.trial.task.features.response.diameter;
        annulus_indx = noise_ring.get_annulus(frame_width,annulus_outer_diameter,annulus_inner_diameter);
        response_cue_indx = noise_ring.get_annulus(frame_width,response_cue_outer_diameter,response_cue_inner_diameter);
        
        M = 0.5*ones(frame_width);
        M = noise_ring.add_ring(M,response_cue_indx,p.trial.task.luminance-0.5);
        M = noise_ring.add_noise(M,annulus_indx,p.trial.task.features.annulus.noise_sigma);
        M = noise_ring.fix_range(M);
        
        p.trial.task.stimulus.noise_ring.textureIndex(frame_index) = Screen('MakeTexture',win,M);
        Screen('DrawTexture',win,p.trial.task.stimulus.noise_ring.textureIndex(frame_index));
    end

    function ShowSymbolMask
        %  ShowSymbolMask
        %
        %  This function draws the symbol masks
        
        win = p.trial.display.overlayptr;
        diameter = p.trial.task.features.annulus.outer_diameter;
        for ii=1:p.trial.task.state_variables.current_symbol
            Screen('DrawTexture',win,p.trial.task.stimulus.symbol_masks.textureIndex,...
                [(ii-1)*diameter 0 ii*diameter diameter],p.trial.task.features.symbol.positions(p.trial.task.stimulus.symbol.position_order(ii),:));
        end
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
        switch p.trial.task.state_variables.trial_state
            case 'warning'
                [zone,p.trial.joystick.warning.position] = joystick.zones(p.trial.joystick.warning);
            case 'engage'
                [zone,p.trial.joystick.engage.position] = joystick.zones(p.trial.joystick.engage);
            otherwise
                [zone,p.trial.joystick.default.position] = joystick.zones(p.trial.joystick.default);
        end
        %  Set joystick state variables
        p.trial.task.state_variables.joystick_released = zone==1;
        p.trial.task.state_variables.joystick_release_buffer = zone==2;
        p.trial.task.state_variables.joystick_engaged = zone==3;
        p.trial.task.state_variables.joystick_press_buffer = zone==4;
        p.trial.task.state_variables.joystick_pressed = zone==5;
    end

    function check_fixation_status
        %  check_fixation_status
        
        %  Set fixation status
        p.trial.task.state_variables.fixating = true;
        
    end
end