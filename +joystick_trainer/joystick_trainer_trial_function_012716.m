function p = joystick_trainer_trial_function(p,state)
%joystick_trial_function(p,state)
%
%  PLDAPS trial function for joystick training

%  Call default trial function for state dependent steps
pldapsDefaultTrialFunction(p,state);

%  Basic structure of a trial:
%
%  1.  p.trial.stimulus.trial_states.STATE_LEADIN
%  Trial begins.  Monkey should have the joystick fully released by the end
%  of this time.  If he does not, then he will get an error signal.
%  Depending on current preferences this will either lead to a trial abort
%  to re-entry into the lead-in period.
%
%  2.  p.trial.stimulus.trial_states.STATE_ENGAGE
%  Monkey receives a signal to engage the joystick and has a grace period
%  in which to engage.  If he elapses then he will have an error signal and
%  the trial will abort. This state ends immediately upon engagement of the
%  joystick.
%
%  3.  p.trial.stimulus.trial_states.STATE_HOLD
%  During this state the monkey must engage the joystick for the entire
%  duration of the hold period.  Releasing joystick will abort trial with
%  an error signal.
%
%  4.  p.trial.stimulus.trial_states.STATE_RELEASE
%  Monkey is given the release signal and has a grace period in which to
%  release the joystick.  State ends upon release of the joystick.  If he
%  elapses the grace period then trial aborts with an error signal.
%
%  5.  p.trial.stimulus.trial_states.STATE_REST
%  Monkey is given a rest period between trials.  He should not be engaging
%  the joystick however engaging will not abort trial; he will get an error
%  signal nevertheless.  At the end of the rest, return to p.trial.stimulus.trial_states.STATE_LEADIN.
%
%  6.  p.trial.stimulus.trial_states.STATE_ABORT
%
%  The abort state is entered if an error occurs in the first four states
%  above.  It will have the duration equal to what the trial would have
%  been prior to the rest period had the trial not aborted.  Entry into the
%  abort state is associated with an error signal.

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
        if(~isstruct(joystick.get_joystick_status(0,0)))
            disp('Warning:  joystick disconnected.  Plug it in, I will wait...');
            p.trial.pldaps.pause.type = 1;
            p.trial.pldaps.quit = 1;
        end
        
        %
        %  Make sure that the timing parameters are set
        %
        p.trial.stimulus.timing.hold_time = floor(120*unifrnd(p.trial.stimulus.timing.min_hold_time,p.trial.stimulus.timing.max_hold_time))/120;
        p.trial.stimulus.timing.rest_time = floor(120*unifrnd(p.trial.stimulus.timing.min_rest_time,p.trial.stimulus.timing.max_rest_time))/120;
        
        %
        %  Initialize trial state to the lead-in period
        %
        fprintf('Trial starts with lead-in time of %0.3f sec.\n',p.trial.stimulus.timing.leadin_time);
        p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_LEADIN;
        p.trial.stimulus.timing.leadin_start_time = NaN;
        p.trial.stimulus.timing.engage_start_time = NaN;
        p.trial.stimulus.timing.release_start_time = NaN;
        p.trial.stimulus.timing.rest_start_time = NaN;
        p.trial.stimulus.timing.abort_stat_time = NaN;
        p.trial.stimulus.timing.hold_start_time = NaN;
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        %  Check if we have completed conditions; if so, we're finished.
        if(p.trial.pldaps.iTrial==length(p.conditions))
            p.trial.pldaps.quit=2;
        end
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update is called once after the last frame is done (or
        %  even before).  Get current eyepostion, curser position,
        %  keypresses, joystick position, etc.
        
        %  Grab a snapshot of the joystick data
        p.trial.stimulus.joystick.snapshot = joystick.get_joystick_status([p.trial.stimulus.rest_threshold p.trial.stimulus.deflection_threshold],p.trial.stimulus.orientation);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control.
        
        %  Determine joystick status
        if(p.trial.stimulus.joystick.snapshot.status(1)==0)
            p.trial.stimulus.joystick.current_status=p.trial.stimulus.joystick_states.JOYSTICK_RELEASED;
        elseif(abs(p.trial.stimulus.joystick.snapshot.status(2)==1))
            p.trial.stimulus.joystick.current_status=p.trial.stimulus.joystick_states.JOYSTICK_ENGAGED;
        else
            p.trial.stimulus.joystick.current_status=p.trial.stimulus.joystick_states.JOYSTICK_EQUIVOCAL;
        end
        
        %
        %  Control trial events based on trial state
        %
        
        switch p.trial.stimulus.state
            
            case p.trial.stimulus.trial_states.STATE_LEADIN
                
                %
                %  Current trial state is p.trial.stimulus.trial_states.STATE_LEADIN
                %
                
                %  Remember that the monkey may be doing whatever he
                %  pleases with the joystick in the rest time before the
                %  lead-in time, but he should have released it by the time
                %  the engage cue appears.  We'll give him a chance to
                %  release the joystick here and error him if he does not.
                %
                %  If at any time during the lead-in he engages the
                %  joystick the trial will proceed.  So, first check the
                %  joystick (unless this is the first time entering in
                %  which case we first start the timer).
                
                if(isnan(p.trial.stimulus.timing.leadin_start_time))
                    p.trial.stimulus.timing.leadin_start_time = GetSecs;
                    fprintf('Start lead-in state of %0.3f sec for trial %d\n',p.trial.stimulus.timing.leadin_time,p.trial.pldaps.iTrial);
                end
                
                %  Now check the joystick
                if(p.trial.stimulus.joystick.current_status==p.trial.stimulus.joystick_states.JOYSTICK_RELEASED)
                    fprintf('Monkey has released joystick.  Proceed to engage cue.\n');
                    p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_ENGAGE;
                    p.trial.stimulus.timing.leadin_start_time = NaN;
                else
                    %  Check time against the time limit.
                    if(p.trial.stimulus.timing.leadin_start_time < GetSecs-p.trial.stimulus.timing.leadin_time)
                        fprintf('Monkey has not released the joystick within the lead-in time.\n');
                        p.trial.stimulus.error_code = p.trial.stimulus.error_codes.ERROR_ENGAGE_AT_START;
                        p.trial.stimulus.timing.leadin_start_time = NaN;
                        if(isnan(p.trial.stimulus.timing.abort_time))
                            fprintf('Deliver warning tone and return to lead-in.\n');
                            pds.audio.play(p,'warning');
                            p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_LEADIN;
                        else
                            fprintf('Delver warning tone and abort trial.\n');
                            pds.audio.play(p,'warning');
                            p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_ABORT;
                        end
                    end
                end
                
                
            case p.trial.stimulus.trial_states.STATE_ENGAGE
                
                %
                %  Current trial state is p.trial.stimulus.trial_states.STATE_ENGAGE
                %
                
                %  Now the monkey is receiving an engage signal.  He should
                %  engage within the grace period.  If he doesn't, he will
                %  get an error signal and trial will abort.  If you do not
                %  want this to happen then remember to set the grace
                %  period to infinite or code something different.
                
                %  If this is the first time entering this state then start
                %  timer and give cue.
                
                if(isnan(p.trial.stimulus.timing.engage_start_time))
                    p.trial.stimulus.timing.engage_start_time = GetSecs;
                    fprintf('Give engage cue and start grace period of %0.3f sec.\n',p.trial.stimulus.timing.grace_to_engage);
                    p.trial.stimulus.timing.engage_cue_start_time = p.trial.stimulus.timing.engage_start_time;
                end
                DisplayEngageCue(p);
                
                %  Check joystick and determine if we stay in this state or
                %  proceed to hold state.
                
                if(p.trial.stimulus.joystick.current_status==p.trial.stimulus.joystick_states.JOYSTICK_ENGAGED)
                    %  Monkey has successfully engaged.  Advance to hold
                    %  state and start the hold timer.
                    p.trial.stimulus.timing.engage_start_time = NaN;
                    p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_HOLD;
                    fprintf('Monkey has engaged joystick.  Proceed to hold.\n');
                else
                    %  Monkey has not yet succesffuly engaged.  Let's give
                    %  him the grace time to engage.
                    
                    if(p.trial.stimulus.timing.engage_start_time < GetSecs-p.trial.stimulus.timing.grace_to_engage)
                        %  Monkey has elapsed grace time
                        p.trial.stimulus.timing.engage_start_time = NaN;
                        fprintf('Monkey failed to engage joystick.  Give warning tone and abort trial.\n');
                        pds.audio.play(p,'warning');
                        p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_ABORT;
                        p.trial.stimulus.error_code = p.trial.stimulus.error_codes.ERROR_FAIL_TO_ENGAGE;
                    end
                end
                
            case p.trial.stimulus.trial_states.STATE_HOLD
                
                %
                %  Current trial state is p.trial.stimulus.trial_states.STATE_HOLD
                %
                
                %  Now the monkey is holding the joystick.  He should
                %  release it when the hold cue is deactivated.  If there
                %  is a deflect reward, he will receive this as long as the
                %  joystick is deflected and the hold cue is present.
                %
                %  If he does not release the joystick at the end of the
                %  release grace period the trial will abort.
                
                %  If this is the first time entering this state then start
                %  timer.
                
                if(isnan(p.trial.stimulus.timing.hold_start_time))
                    p.trial.stimulus.timing.hold_start_time = GetSecs;
                    fprintf('Monkey engaged joystick.  Start hold cue for %0.3f sec.\n',p.trial.stimulus.timing.hold_time);
                end
                
                %  Show the cue
                DisplayEngageCue(p);
                                
                %  First determine if we are still in the hold time.
                if(p.trial.stimulus.timing.hold_start_time >= GetSecs-p.trial.stimulus.timing.hold_time)
                    %  We are still within the hold time so proceed with
                    %  joystick check.
                    
                    if(p.trial.stimulus.joystick.current_status==p.trial.stimulus.joystick_states.JOYSTICK_ENGAGED)
                        %  Since joystick is engaged, we can give him a reward
                        %  here
                        if(p.trial.stimulus.deflect_reward_amount>0)
                            if(isnan(p.trial.stimulus.deflect_reward_time))
                                pds.behavior.reward.give(p,p.trial.stimulus.deflect_reward_amount);
                                fprintf('Monkey gets a reward for engaging joystick.\n');
                                p.trial.stimulus.deflect_reward_time = GetSecs;
                            else
                                %  Check the deflect reward timer
                                if(p.trial.stimulus.deflect_reward_time < GetSecs-p.trial.stimulus.deflect_reward_period)
                                    p.trial.stimulus.deflect_reward_time = NaN;
                                end
                            end
                        end
                    else
                        %  Monkey has released the joystick prematurely.  Abort
                        %  trial.
                        p.trial.stimulus.timing.hold_start_time = NaN;
                        fprintf('Monkey released joystick early.  Abort trial.\n');
                        pds.audio.play(p,'warning');
                        p.trial.stimulus.error_code = p.trial.stimulus.error_codes.ERROR_EARLY_RELEASE;
                        p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_ABORT;
                    end
                else
                    %  Hold time has elapsed.  Proceeed to release state.
                    p.trial.stimulus.timing.hold_start_time = NaN;
                    p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_RELEASE;
                end
                
            case p.trial.stimulus.trial_states.STATE_RELEASE
                
                %
                %  Current trial state is p.trial.stimulus.trial_states.STATE_RELEASE
                %
                
                %  Now it is time for the monkey to release the joystick.
                %  If this is first time through then start timer.
                %
                %  If monkey has released joystick within the alloted time
                %  give him his release reward.  Otherwise give him the
                %  grace period.  If he does not release within the grace
                %  period then give warning tone and abor trial.
                
                if(isnan(p.trial.stimulus.timing.release_start_time))
                    p.trial.stimulus.timing.release_start_time = GetSecs;
                    fprintf('Time to release joystick\n');
                end
                
                %  Start with check on joystick state.
                if(p.trial.stimulus.joystick.current_status==p.trial.stimulus.joystick_states.JOYSTICK_RELEASED)
                    %  He's released!  Give him his reward and move on to rest
                    %  state
                    pds.behavior.reward.give(p,p.trial.stimulus.release_reward_amount);
                    fprintf('Monkey has released the joystick within the grace period.  Monkey gets a reward!\n');
                    p.trial.stimulus.release_start_time = NaN;
                    p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_REST;
                else
                    %  Since not released check timer
                    if(p.trial.stimulus.timing.release_start_time < GetSecs-p.trial.stimulus.timing.grace_to_release)
                        p.trial.stimulus.timing.release_start_time = NaN;
                        fprintf('Monkey did not release joystick in time.  Abort trial.\n');
                        pds.audio.play(p,'warning');
                        p.trial.stimulus.error_code = p.trial.stimulus.error_codes.ERROR_FAIL_TO_RELEASE;
                        p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_ABORT;
                    end
                end
                
            case p.trial.stimulus.trial_states.STATE_REST
                
                %
                %  Current trial state is p.trial.stimulus.trial_states.STATE_REST
                %
                
                %  For now the monkey will get a rest.
                %  End trial when timer is elapsed.
                
                if(isnan(p.trial.stimulus.timing.rest_start_time))
                    p.trial.stimulus.timing.rest_start_time = GetSecs;
                    fprintf('Rest for %0.3f sec\n',p.trial.stimulus.timing.rest_time);
                end
                
                %  Check time
                if(p.trial.stimulus.timing.rest_start_time < GetSecs-p.trial.stimulus.timing.rest_time)
                    %  Rest time has elapsed.  Time to move on to next
                    %  trial!
                    fprintf('Rest time has elapsed.  Move on to next trial.\n');
                    p.trial.flagNextTrial = true;
                end
                
                %
                %  Current trial state is p.trial.stimulus.trial_states.STATE_ABORT
                %
                
            case p.trial.stimulus.trial_states.STATE_ABORT
                
                %  The monkey triggered an error so trial aborted.  He may
                %  be given a time out at which point the trial will go to
                %  lead-in.
                
                if(isnan(p.trial.stimulus.timing.abort_start_time))
                    fprintf('Trial aborted with error code %d, penalty %0.3f sec.\n',p.trial.stimulus.error_code,p.trial.stimulus.timing.abort_time);
                    p.trial.stimulus.timing.abort_start_time=GetSecs;
                else
                    if(isnan(p.trial.stimulus.timing.abort_time) || p.trial.stimulus.timing.abort_start_time < GetSecs-p.trial.stimulus.timing.abort_time)
                        fprintf('Abort penalty time elapsed.  Move on to lead-in.\n');
                        p.trial.stimulus.timing.abort_start_time = NaN;
                        p.trial.stimulus.state = p.trial.stimulus.trial_states.STATE_LEADIN;
                    end
                end
        end
end
end

%  FUNCTIONS TO DO SOME FRAME DRAWING

function p = DisplayEngageCue(p)
%  DisplayEngageCue
%
%  This function should draw a rectangle as the cue to engage the joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr
%
%  I want a rectangle drawn as a cue to engage the joystick.  I will make
%  it 100 pixels wide and 100 pixels tall.  It will be white and centered
%  in the middle of the screen, where there is not currently a fixation
%  point but at some point in the future there will be.  I don't need it
%  smoothed.

width = p.trial.stimulus.features.engage_cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

display_time = p.trial.stimulus.features.engage_cue_period*p.trial.stimulus.features.engage_cue_duty_cycle;
cue_period = p.trial.stimulus.features.engage_cue_period;

if(p.trial.stimulus.state==p.trial.stimulus.trial_states.STATE_HOLD)
    Screen('FrameRect',p.trial.display.ptr,[1 1 1],centeredRect);
elseif(p.trial.stimulus.state==p.trial.stimulus.trial_states.STATE_ENGAGE)
    if(isnan(p.trial.stimulus.timing.engage_cue_start_time))
        p.trial.stimulus.timing.engage_cue_start_time = GetSecs;
        Screen('FrameRect',p.trial.display.ptr,[1 1 1],centeredRect);
    elseif(p.trial.stimulus.timing.engage_cue_start_time > GetSecs-display_time)
        Screen('FrameRect',p.trial.display.ptr,[1 1 1],centeredRect);
    elseif(p.trial.stimulus.timing.engage_cue_start_time <= GetSecs-cue_period)
        p.trial.stimulus.timing.engage_cue_start_time = NaN;
    end
end
end