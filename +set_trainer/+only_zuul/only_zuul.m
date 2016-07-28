function p = only_zuul(p,state)
%p = only_zuul(p,state)
%
%  PLDAPS trial function for set game training aka only zuul

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
        feval(str2func(strcat('set_trainer.only_zuul.',p.trial.session.subject)),p);
        
        %  Initialize trial state variables
        
        p.trial.task.state_variables.trial_state = 'ready';
        p.trial.task.state_variables.current_symbol = 0;
        p.trial.task.state_variables.symbol_on = false;
        p.trial.task.state_variables.response_signal_iterator = 1;
        
        %  Initialize performance and outcome data
        
        if(p.trial.pldaps.iTrial==1)
            
            %  Performance data
            p.trial.task.performance.early_releases = 0;
            p.trial.task.performance.delay_errors = 0;
            p.trial.task.performance.fixation_breaks = 0;
            
            p.trial.task.performance.total_completed = 0;
            p.trial.task.performance.total_attempted = 0;
            p.trial.task.performance.total_correct = 0;
            
            p.trial.task.performance.set.hits = zeros(length(p.trial.task.log_contrast_list),1);
            p.trial.task.performance.set.misses = zeros(length(p.trial.task.log_contrast_list),1);
            p.trial.task.performance.set.correct_rejects = 0;
            p.trial.task.performance.set.false_alarms = 0;
            
            p.trial.task.performance.signal_present = p.trial.task.performance.set;
            
            %  Initialize trial outcome
            p.trial.task.outcome.correct = false;
            p.trial.task.outcome.completed = false;
            p.trial.task.outcome.early_release = false;
            p.trial.task.outcome.delay_error = false;
            p.trial.task.outcome.fixation_break = false;
            
            %  Indexing
            p.trial.task.indexing.block_number = 1;
            p.trial.task.indexing.within_block_trial_number = 1;
        else
            
            %  Previous trial performance data
            fields = fieldnames(p.data{p.trial.pldaps.iTrial-1}.task.performance);
            for i=1:length(fields)
                p.trial.task.performance.(fields{i}) = p.data{p.trial.pldaps.iTrial-1}.task.performance.(fields{i});
            end
            
            %  Previous trial outcome data
            fields = fieldnames(p.data{p.trial.pldaps.iTrial-1}.task.outcome);
            for i=1:length(fields)
                p.trial.task.outcome.(fields{i}) = p.data{p.trial.pldaps.iTrial-1}.task.outcome.(fields{i});
            end
            
            %  Previous trial indexing data
            fields = fieldnames(p.data{p.trial.pldaps.iTrial-1}.task.indexing);
            for i=1:length(fields)
                p.trial.task.indexing.(fields{i}) = p.data{p.trial.pldaps.iTrial-1}.task.indexing.(fields{i});
            end
            
            %  Update trial indexing
            if(p.trial.task.outcome.completed)
                p.trial.task.indexing.within_block_trial_number = mod(p.trial.task.indexing.within_block_trial_number+1,size(p.conditions,1));
                if(p.trial.task.indexing.within_block_trial_number==0)
                    p.trial.task.indexing.within_block_trial_number = size(p.conditions,1);
                    p.trial.task.indexing.block_number = p.trial.task.indexing.block_number + 1;
                end
            end
            
            %  Initialize trial outcome
            p.trial.task.outcome.correct = false;
            p.trial.task.outcome.completed = false;
            p.trial.task.outcome.early_release = false;
            p.trial.task.outcome.delay_error = false;
            p.trial.task.outcome.fixation_break = false;
        end
        
        %  Extract data from conditions
        trial_number = p.trial.task.indexing.within_block_trial_number;
        block_number = p.trial.task.indexing.block_number;
        
        %  trial_type
        p.trial.task.trial_type = p.conditions{trial_number,block_number}.trial_type;
        
        %  symbol sequence
        try
            p.trial.task.symbols = p.conditions{trial_number,block_number}.symbols;
        catch
            p.trial.task.symbols = [];
        end
        
        %  log_contrast
        try
            p.trial.task.log_c_indx = p.conditions{trial_number,block_number}.log_c_indx;
            p.trial.task.log_contrast = p.trial.task.log_contrast_list(p.trial.task.log_c_indx);
        catch
            p.trial.task.log_c_indx = [];
            p.trial.task.log_contrast = 0;
        end
        
        %  log_contrast response signal
        p.trial.task.log_contrast_noise = p.conditions{trial_number,block_number}.log_c_noise*p.trial.task.log_contrast_std^2;
        t_steps = p.trial.task.log_contrast_delta*(1:length(p.trial.task.log_contrast_noise));
        indx = t_steps >= p.trial.task.timing.response.duration(1) & t_steps < sum(p.trial.task.timing.response.duration(1:2));
        p.trial.task.log_contrast_signal = log10(0.5)*ones(size(t_steps)) + p.trial.task.log_contrast_noise';
        p.trial.task.log_contrast_signal(indx) = p.trial.task.log_contrast_signal(indx) + p.trial.task.log_contrast;
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        %  Update performance
        p.trial.task.performance.total_attempted = p.trial.task.performance.total_attempted + 1;
        
        if(p.trial.task.outcome.completed)
            p.trial.task.performance.total_completed = p.trial.task.performance.total_completed + 1;
            p.trial.task.performance.total_correct = p.trial.task.performance.total_correct + p.trial.task.outcome.correct;
            switch p.trial.task.trial_type
                case 'set'
                    if(p.trial.task.outcome.correct)
                        p.trial.task.performance.set.hits(p.trial.task.log_c_indx) = p.trial.task.performance.set.hits(p.trial.task.log_c_indx) + 1;
                    else
                        p.trial.task.performance.set.misses(p.trial.task.log_c_indx) = p.trial.task.performance.set.misses(p.trial.task.log_c_indx) + 1;
                    end
                case 'notset'
                    if(p.trial.task.outcome.correct)
                        p.trial.task.performance.set.correct_rejects = p.trial.task.performance.set.correct_rejects + 1;
                    else
                        p.trial.task.performance.set.false_alarms = p.trial.task.performance.set.false_alarms + 1;
                    end
                case 'signal_present'
                    if(p.trial.task.outcome.correct)
                        p.trial.task.performance.signal_present.hits(p.trial.task.log_c_indx) = p.trial.task.performance.signal_present.hits(p.trial.task.log_c_indx) + 1;
                    else
                        p.trial.task.performance.signal_present.misses(p.trial.task.log_c_indx) = p.trial.task.performance.signal_present.misses(p.trial.task.log_c_indx) + 1;
                    end
                case 'signal_absent'
                    if(p.trial.task.outcome.correct)
                        p.trial.task.performance.signal_present.correct_rejects = p.trial.task.performance.signal_present.correct_rejects + 1;
                    else
                        p.trial.task.performance.signal_present.false_alarms = p.trial.task.performance.signal_present.false_alarms + 1;
                    end
            end
        else
            p.trial.task.performance.early_releases = p.trial.task.performance.early_releases + p.trial.task.outcome.early_release;
            p.trial.task.performance.delay_errors = p.trial.task.performance.delay_errors + p.trial.task.outcome.delay_error;
            p.trial.task.performance.fixation_breaks = p.trial.task.performance.fixation_breaks + p.trial.task.outcome.fixation_break;
            
            %  Here I can reshuffle the remaining trials within the block
            trial_number = p.trial.task.indexing.within_block_trial_number;
            block_number = p.trial.task.indexing.block_number;
            fprintf('Reshuffling remaining %d trials in block %d.\n\n',size(p.conditions,1)-trial_number+1,block_number);
            p.conditions(trial_number:end,block_number) = Shuffle(p.conditions(trial_number:end,block_number));
        end
        
        %  Display performance
        total_completed = p.trial.task.performance.total_completed;
        total_attempted = p.trial.task.performance.total_attempted;
        total_correct = p.trial.task.performance.total_correct;
        
        early_releases = p.trial.task.performance.early_releases;
        delay_errors = p.trial.task.performance.delay_errors;
        fixation_breaks = p.trial.task.performance.fixation_breaks;
        
        fprintf('Current performance:\n');
        fprintf('\tCompleted trials:  %d of %d (%0.3f)\n',total_completed,total_attempted,total_completed/total_attempted);
        fprintf('\tTotal correct:  %d of %d (%0.3f)\n',total_correct,total_completed,total_correct/total_completed);
        fprintf('\n');
        fprintf('\tEarly releases:  %d of %d (%0.3f)\n',early_releases,total_attempted,early_releases/total_attempted);
        fprintf('\tDelay error trials:  %d of %d (%0.3f)\n',delay_errors,total_attempted,delay_errors/total_attempted);
        fprintf('\tFixation break trials:  %d of %d (%0.3f)\n',fixation_breaks,total_attempted,fixation_breaks/total_attempted);
        fprintf('\n');
        
        %
        %  Show this only if trial was successfully completed (because
        %  otherwise didn't change)
        %
        %
        if(p.trial.task.outcome.completed)
            %  SET performance
            hits = p.trial.task.performance.set.hits;
            misses = p.trial.task.performance.set.misses;
            correct_rejects = p.trial.task.performance.set.correct_rejects;
            false_alarms = p.trial.task.performance.set.false_alarms;
            
            fprintf('SET PERFORMANCE\n');
            
            HR = hits ./ (hits + misses);
            FAR = false_alarms / (false_alarms + correct_rejects);
            sensitivity = norminv(HR) - norminv(FAR);
            bias = -0.5*(norminv(HR) + norminv(FAR));
            fprintf('\tHit Rate by contrast:\n');
            for i=1:length(p.trial.task.log_contrast_list)
                fprintf('\t%0.03f:  %0.03f (%d of %d)\n',p.trial.task.log_contrast_list(i),HR(i),hits(i),hits(i)+misses(i));
            end
            fprintf('\tFalse Alarm Rate:  %0.03f (%d of %d)\n',FAR,false_alarms,false_alarms+correct_rejects);
            fprintf('\tSensitivity and Bias by contrast:\n');
            for i=1:length(p.trial.task.log_contrast_list)
                fprintf('\t%0.03f:  %0.03f, %0.03f\n',p.trial.task.log_contrast_list(i),sensitivity(i),bias(i));
            end
            fprintf('\n');
            
            %  RELEASE performance
            hits = p.trial.task.performance.signal_present.hits;
            misses = p.trial.task.performance.signal_present.misses;
            correct_rejects = p.trial.task.performance.signal_present.correct_rejects;
            false_alarms = p.trial.task.performance.signal_present.false_alarms;
            
            fprintf('RELEASE PERFORMANCE\n');
            
            HR = hits ./ (hits + misses);
            FAR = false_alarms / (false_alarms + correct_rejects);
            sensitivity = norminv(HR) - norminv(FAR);
            bias = -0.5*(norminv(HR) + norminv(FAR));
            fprintf('\tHit Rate by contrast:\n');
            for i=1:length(p.trial.task.log_contrast_list)
                fprintf('\t%0.03f:  %0.03f (%d of %d)\n',p.trial.task.log_contrast_list(i),HR(i),hits(i),hits(i)+misses(i));
            end
            fprintf('\tFalse Alarm Rate:  %0.03f (%d of %d)\n',FAR,false_alarms,false_alarms+correct_rejects);
            fprintf('\tSensitivity and Bias by contrast:\n');
            for i=1:length(p.trial.task.log_contrast_list)
                fprintf('\t%0.03f:  %0.03f, %0.03f\n',p.trial.task.log_contrast_list(i),sensitivity(i),bias(i));
            end
            fprintf('\n');
            fprintf('\n');
        end
        
        
        %  Check if we have completed conditions; if so, we're finished.
        if(p.trial.task.performance.total_completed==length(p.conditions))
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
        
        switch p.trial.task.state_variables.trial_state
            
            case 'ready'
                
                %  STATE:  ready
                
                if(isnan(p.trial.task.timing.ready.start_time))
                    
                    %  This is our first pass through on this trial; start
                    %  our timers and print some feedback to screen.
                    p.trial.task.timing.ready.start_time = GetSecs;
                    p.trial.task.timing.ready.cue_start_time = GetSecs;
                    
                    fprintf('READY state for trial %d, ',p.trial.pldaps.iTrial);
                    trial_number = p.trial.task.indexing.within_block_trial_number;
                    block_number = p.trial.task.indexing.block_number;
                    fprintf('trial %d of %d for block %d of %d.\n',trial_number,size(p.conditions,1),block_number,size(p.conditions,2));
                    
                    switch p.trial.task.trial_type
                        case {'set','signal_present'}
                            fprintf('This is a %s trial with log contrast %0.3f\n',upper(p.trial.task.trial_type),p.trial.task.log_contrast_list(p.trial.task.log_c_indx));
                        otherwise
                            fprintf('This is a %s trial\n',upper(p.trial.task.trial_type));
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
                        p.trial.task.state_variables.trial_state = 'symbol';
                        
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
                %  both the continue holding cue and the fixation dot as
                %  long as this is the case and we have not yet reached the
                %  end of the symbol presentation sequence.
                %
                %  Will alternate between symbols and delays until
                %  complete, then go to either hold or release depending on
                %  trial type.
                
                %  Determine number of symbols and delays
                num_symbols = length(p.trial.task.timing.symbol.presentation_duration);
                num_delays = length(p.trial.task.timing.symbol.delay_duration);
                
                %  Show ready and fixation cues and symbol
                switch p.trial.task.trial_type
                    case {'set','notset'}
                        if(p.trial.task.state_variables.symbol_on && p.trial.task.timing.symbol.presentation_duration(p.trial.task.state_variables.current_symbol)~=0)
                            ShowSymbol;
                        end
                end
                ShowContinueHoldCue;
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.symbol.sequence_start_time))
                    p.trial.task.timing.symbol.sequence_start_time = GetSecs;
                    switch p.trial.task.trial_type
                        case {'set','notset'}
                            fprintf('SYMBOL PRESENTATION SEQUENCE:  ');
                            fprintf('%s ',p.trial.task.symbols{:});
                            fprintf('\n');
                        otherwise
                            fprintf('NO SYMBOL SEQUENCE.\n');
                    end
                end
                
                if(isnan(p.trial.task.timing.symbol.start_time))
                    
                    
                    %  Start our timers and print some feedback to screen.
                    p.trial.task.timing.symbol.start_time = GetSecs;
                    if(p.trial.task.state_variables.symbol_on)
                        p.trial.task.timing.symbol.duration = p.trial.task.timing.symbol.presentation_duration(p.trial.task.state_variables.current_symbol);
                        switch p.trial.task.trial_type
                            case {'set','notset'}
                                fprintf('\tPresentation %d of %d for %0.3f sec:  %s.\n',p.trial.task.state_variables.current_symbol,num_symbols,p.trial.task.timing.symbol.duration,p.trial.task.symbols{p.trial.task.state_variables.current_symbol});
                        end
                    else
                        p.trial.task.timing.symbol.duration = p.trial.task.timing.symbol.delay_duration(p.trial.task.state_variables.current_symbol+1);
                        switch p.trial.task.trial_type
                            case {'set','notset'}
                                fprintf('\tDelay %d of %d for %0.3f sec.\n',p.trial.task.state_variables.current_symbol+1,num_delays,p.trial.task.timing.symbol.duration);
                        end
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
                        
                        if(p.trial.task.state_variables.current_symbol < num_symbols)
                            fprintf('\t%s released joystick at %0.3f sec.\n',p.trial.session.subject,...
                                GetSecs-p.trial.task.timing.symbol.sequence_start_time);
                            p.trial.task.outcome.early_release = true;
                            p.trial.task.state_variables.trial_state = 'timeout';
                        else
                            fprintf('\t%s released joystick at %0.03f sec.\n',p.trial.session.subject,...
                                GetSecs-p.trial.task.timing.symbol.sequence_start_time);
                            
                            switch p.trial.task.trial_type
                                case {'set','notset'}
                                    p.trial.task.outcome.reaction_time = GetSecs - p.trial.task.timing.symbol.start_time;
                                    fprintf('\tReaction time is %0.03f.\n',p.trial.task.outcome.reaction_time);
                            end
                            switch p.trial.task.trial_type
                                case 'set'
                                    p.trial.task.state_variables.trial_state = 'reward_delay';
                                case 'notset'
                                    p.trial.task.outcome.completed = true;
                                    p.trial.task.state_variables.trial_state = 'error';
                                otherwise
                                    p.trial.task.outcome.early_release = true;
                                    p.trial.task.state_variables.trial_state = 'timeout';
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
                        p.trial.task.state_variables.trial_state = 'timeout';
                        p.trial.task.outcome.fixation_break = true;
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
                    
                    if(p.trial.task.state_variables.current_symbol < num_symbols)
                        if(p.trial.task.state_variables.symbol_on)
                            p.trial.task.state_variables.symbol_on = false;
                        else
                            p.trial.task.state_variables.current_symbol = p.trial.task.state_variables.current_symbol + 1;
                            p.trial.task.state_variables.symbol_on = true;
                        end
                    else
                        fprintf('\t%s successfully held joystick and remained fixating.\n',p.trial.session.subject);
                        p.trial.task.state_variables.trial_state = 'response';
                        p.trial.task.timing.symbol.sequence_start_time = NaN;
                    end
                    p.trial.task.timing.symbol.start_time = NaN;
                end
                
            case 'timeout'
                
                %  STATE:  timeout
                
                %  In this state we are going to burn a timeout period.
                %  After that is over, end trial.
                
                if(isnan(p.trial.task.timing.timeout.start_time))
                    fprintf('TIMEOUT state for %0.3f sec...  ',p.trial.task.timing.timeout.duration);
                    p.trial.task.timing.timeout.start_time = GetSecs;
                    
                    %  Play the breakfix sound since this is our first time
                    %  into the state
                    pds.audio.play(p,'breakfix');
                    
                elseif(p.trial.task.timing.timeout.start_time <= GetSecs - p.trial.task.timing.timeout.duration)
                    fprintf('Timeout elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.task.timing.timeout.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
                
            case 'error'
                
                %  STATE:  error
                
                %  In this state we are going to play an error tone and
                %  burn a timeout period. After that is over, end trial.
                
                if(isnan(p.trial.task.timing.timeout.start_time))
                    fprintf('ERROR state for %0.3f sec...  ',p.trial.task.timing.timeout.duration);
                    p.trial.task.timing.timeout.start_time = GetSecs;
                    
                    %  Play the error sound since this is our first time
                    %  into the state
                    pds.audio.play(p,'incorrect');
                    
                elseif(p.trial.task.timing.timeout.start_time <= GetSecs - p.trial.task.timing.timeout.duration)
                    fprintf('Timeout elapsed.\nEND TRIAL %d.\n\n',p.trial.pldaps.iTrial);
                    p.trial.task.timing.timeout.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
                %             case 'hold'
                %
                %                 %  STATE:  hold
                %
                %                 %  In this state we show a hold cue.  Monkey should
                %                 %  hold the joystick for the duration of this state.
                %
                %                 ShowHoldCue;
                %                 ShowFixationCue;
                %
                %                 if(isnan(p.trial.task.timing.hold.start_time))
                %                     p.trial.task.timing.hold.start_time = GetSecs;
                %                     fprintf('HOLD state for trial %d.  Hold for %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.task.timing.hold.duration);
                %
                %                 elseif(p.trial.task.timing.hold.start_time > GetSecs - p.trial.task.timing.hold.duration)
                %
                %                     %  Still in hold period so check joystick
                %                     if(p.trial.task.state_variables.joystick_released && p.trial.task.state_variables.fixating)
                %
                %                         %  Monkey has released joystick during a hold.  This
                %                         %  will be counted as a false alarm (an error).
                %
                %                         p.trial.task.outcome.reaction_time = GetSecs + p.trial.task.timing.symbol.presentation_duration(3)- p.trial.task.timing.hold.start_time;
                %                         fprintf('\t%s released joystick with reaction time %0.3f sec; error.\n',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                %
                %                         p.trial.task.timing.hold.start_time = NaN;
                %                         p.trial.task.outcome.completed = true;
                %                         p.trial.task.state_variables.trial_state = 'error';
                %
                %                     elseif(~p.trial.task.state_variables.fixating)
                %
                %                         %  Monkey broke fixation too early.  Give him a
                %                         %  timeout.
                %
                %                         fprintf('\t%s broke fixation after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.hold.start_time);
                %                         p.trial.task.fixation_breaks = p.trial.task.fixation_breaks+1;
                %
                %                         p.trial.task.timing.hold.start_time = NaN;
                %                         p.trial.task.state_variables.trial_state = 'timeout';
                %                     end
                %                 else
                %                     %  Monkey has held joystick till end of hold duration.
                %                     %  This is a correct reject so give him a reward.
                %
                %                     fprintf('\t%s held joystick to end of hold duration.  He gets a reward.\n',p.trial.session.subject);
                %                     p.trial.task.timing.hold.start_time = NaN;
                %                     p.trial.task.outcome.completed = true;
                %
                %                     p.trial.task.outcome.correct = true;
                %                     p.trial.task.outcome.completed = true;
                %                     p.trial.task.state_variables.trial_state = 'reward';
                %                 end
                
            case 'response'
                
                %  STATE:  response
                
                %  In this state we show a response cue.  Monkey should
                %  hold to the end or release the joystick prior to the end
                %  of the grace period in order to convey his response
                
                ShowResponseCue;
                ShowFixationCue;
                
                if(isnan(p.trial.task.timing.response.start_time))
                    p.trial.task.timing.response.start_time = GetSecs;
                    p.trial.task.timing.response.log_contrast_switch_time = GetSecs;
                    fprintf('RESPONSE state for trial %d.  Release within %0.3f sec.\n',p.trial.pldaps.iTrial,p.trial.task.timing.response.grace);
                    
                elseif(p.trial.task.timing.response.start_time > GetSecs - p.trial.task.timing.response.grace)
                    
                    %  Still in grace period so check joystick
                    if(p.trial.task.state_variables.joystick_released && p.trial.task.state_variables.fixating)
                        
                        %  Monkey has released joystick; proceed based on
                        %  trial type
                        
                        p.trial.task.outcome.reaction_time = GetSecs + p.trial.task.timing.symbol.presentation_duration(3)- p.trial.task.timing.response.start_time;
                        
                        switch p.trial.task.trial_type
                            case {'set','signal_present'}
                                fprintf('\t%s released joystick with reaction time %0.3f sec.\n',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                                p.trial.task.state_variables.trial_state = 'reward_delay';
                            otherwise
                                fprintf('\t%s released joystick with reaction time %0.3f sec; this is a false alarm.\n',p.trial.session.subject,p.trial.task.outcome.reaction_time);
                                p.trial.task.outcome.completed = true;
                                p.trial.task.state_variables.trial_state = 'error';
                        end
                        p.trial.task.timing.response.start_time = NaN;
                        
                    elseif(~p.trial.task.state_variables.fixating)
                        
                        %  Monkey broke fixation too early.  Give him a
                        %  timeout.
                        
                        fprintf('\t%s broke fixation after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.task.timing.response.start_time);
                        p.trial.task.fixation_breaks = p.trial.task.fixation_breaks+1;
                        
                        p.trial.task.timing.response.start_time = NaN;
                        p.trial.task.state_variables.trial_state = 'timeout';
                    end
                    
                    %  Check if we should update the contrast of the
                    %  response cue
                    if(p.trial.task.timing.response.log_contrast_switch_time <= GetSecs - p.trial.task.log_contrast_delta)
                        p.trial.task.timing.response.log_contrast_switch_time = GetSecs;
                        p.trial.task.state_variables.response_signal_iterator = p.trial.task.state_variables.response_signal_iterator + 1;
                    end
                    
                    
                else
                    %  Monkey has held joystick till end of grace period;
                    %  proceed based on trial type
                    
                    switch p.trial.task.trial_type
                        case {'set','signal_present'}
                            fprintf('\t%s held joystick to end of release duration; this is a miss.\n',p.trial.session.subject);
                            p.trial.task.state_variables.trial_state = 'error';
                        otherwise
                            fprintf('\t%s held joystick to end of hold duration; this is a correct reject.\n',p.trial.session.subject);
                            p.trial.task.outcome.correct = true;
                            p.trial.task.state_variables.trial_state = 'reward';
                    end
                    p.trial.task.outcome.completed = true;
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
                        p.trial.task.state_variables.trial_state = 'timeout';
                        p.trial.task.performance.delay_errors = p.trial.task.performance.delay_errors+1;
                    elseif(~p.trial.task.state_variables.fixating)
                        fprintf('\t%s broke fixation after %0.3f sec; give him a timeout.\n',p.trial.session.subject,GetSecs - p.trial.task.timing.reward_delay.start_time);
                        p.trial.task.performance.fixation_breaks = p.trial.task.performance.fixation_breaks+1;
                    end
                    
                else
                    
                    %  Monkey completed reward delay so he can get his
                    %  reward now!
                    fprintf('\t%s completed reward delay.  This is a hit\n',p.trial.session.subject);
                    p.trial.task.timing.reward_delay.start_time = NaN;
                    p.trial.task.outcome.correct = true;
                    p.trial.task.outcome.completed = true;
                    p.trial.task.state_variables.trial_state = 'reward';
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

%     function ShowHoldCue
%         %  ShowHoldCue
%         %
%         %  This function draws a cue to indicate to monkey that he has
%         %  engaged the joystick.
%
%         win = p.trial.display.ptr;
%
%         width = p.trial.task.features.hold.width;
%         baseRect = [0 0 width width];
%         centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
%         color = p.trial.task.features.hold.color;
%         linewidth = p.trial.task.features.hold.linewidth;
%
%         Screen('FrameRect',win,color,centeredRect,linewidth);
%     end
%
%     function ShowReleaseCue
%         %  ShowReleaseCue
%         %
%         %  This function draws a cue to indicate to monkey that he should
%         %  release the joystick.
%
%         win = p.trial.display.ptr;
%
%         width = p.trial.task.features.release.width;
%         baseRect = [0 0 width width];
%         centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
%
%         color = 0.5 - power(10,p.trial.task.log_contrast_list(p.trial.task.log_c_indx) + log10(0.5));
%         linewidth = p.trial.task.features.release.linewidth;
%
%         Screen('FrameRect',win,color,centeredRect,linewidth);
%
%     end


    function ShowResponseCue
        %  ShowResponseCue
        %
        %  This function draws a cue to indicate to monkey what his
        %  repsonse should be.
        
        win = p.trial.display.ptr;
        
        width = p.trial.task.features.response.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        
        color = power(10,p.trial.task.log_contrast_signal(p.trial.task.state_variables.response_signal_iterator));
        linewidth = p.trial.task.features.response.linewidth;
        
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