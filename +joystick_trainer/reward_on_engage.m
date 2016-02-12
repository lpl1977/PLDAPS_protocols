function p = reward_on_engage(p,state)
%reward_on_engage(p,state)
%
%  PLDAPS trial function for joystick training
%
%  Reward when joystick engaged, give visual feedback

%  Call default trial function for state dependent steps
pldapsDefaultTrialFunction(p,state);

%  Basic structure of a trial:
%
%  States are baited, engage, unbaited, released.  If baited, then engaging
%  joystick leads to a reward.  Reward is delivered as long as the joystick
%  is engaged and remains in the engage state.  Once engage state is over
%  transitions to unbaited and then after released can transition back to
%  baited.
%
%  A different visual cue instructs monkey if the state is baited, engage,
%  unbaited, and released.

%  Trial state summary:
%
%  1.  STATE_BAITED This state starts after the previous release state.  If
%  the monkey engages the joystick during this time state will transition
%  to engage.  Otherwise transition to unbaited state.

STATE_BAITED = 1000;

%  2.  STATE_ENGAGED This state starts when the monkey engages the joystick
%  during the baited state. Monkey may receive little rewards as long as
%  joystick is engaged and it remains baited (this is the time during which
%  other stimuli would be presented).

STATE_ENGAGED = 1010;

%  3.  STATE_UNBAITED This state precedes the baited period.  Monkey should
%  have joystick disengaged for this entire time.  If he re-engages then
%  the unbaited period will restart with an error.

STATE_UNBAITED = 1020;

%  4.  STATE_RELEASE This state starts after the engaged period and
%  includes an instruction to release the joystick; if he does so prior to
%  the grace he may receive a release reward.

STATE_RELEASE = 1030;

%  Joystick state summary:
%
%  1.  JOYSTICK_RELEASED Joystick is currently not exceeding the rest
%  threshold.

JOYSTICK_RELEASED = 0;

%  2.  JOYSTICK_ENGAGED Joystick is currently exceeding the engage
%  threshold.

JOYSTICK_ENGAGED = 1;

%  3.  JOYSTICK_EQUIVOCAL Joystick is past release threshold and not
%  exceeding engage threshold. This is here to prevent the monkey from
%  holding the joystick at threshold and allowing it to trigger off noise.

JOYSTICK_EQUIVOCAL = 2;

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
        
        %  Set timing parameters.  The total time for the baited and hold
        %  states is grace_to_engage.  This encourages monkey to engage as
        %  quickly as possible to maximize reward.  The release time only
        %  starts upon release, however, and encourages monkey to release
        %  joystick as soon as possible to maximize reward.  If he releases
        %  during the hold time, he effectively has a time out by returning
        %  to release time.
        
        %  Baited state
        p.trial.stimulus.timing.grace_to_engage = 30;
        p.trial.stimulus.timing.baited_start_time = NaN;
        p.trial.stimulus.timing.baited_cue_start_time = NaN;
        
        %  Engaged state
        p.trial.stimulus.timing.min_engaged_time = 4;
        p.trial.stimulus.timing.max_engaged_time = 8;
        p.trial.stimulus.timing.engaged_time = unifrnd(p.trial.stimulus.timing.min_engaged_time,p.trial.stimulus.timing.max_engaged_time);
        p.trial.stimulus.timing.engaged_start_time = NaN;
        
        %  Engaged reward timing
        p.trial.stimulus.timing.engaged_reward_time = NaN;
        p.trial.stimulus.timing.min_engaged_reward_interval = 1;
        p.trial.stimulus.timing.max_engaged_reward_interval = 2;
        p.trial.stimulus.timing.engaged_reward_interval = 0.5*unifrnd(p.trial.stimulus.timing.min_engaged_reward_interval,p.trial.stimulus.timing.max_engaged_reward_interval);
        
        %  Unbaited state
        p.trial.stimulus.timing.unbaited_start_time = NaN;
        p.trial.stimulus.timing.unbaited_cue_start_time = NaN;
        
        %  Released state
        p.trial.stimulus.timing.grace_to_release = 5;
        p.trial.stimulus.timing.min_released_time = 0.25;
        p.trial.stimulus.timing.max_released_time = 0.5;
        p.trial.stimulus.timing.released_time = unifrnd(p.trial.stimulus.timing.min_released_time,p.trial.stimulus.timing.max_released_time);
        p.trial.stimulus.timing.released_start_time = NaN;

        %  Initialize joystick status tracking variables
        p.trial.stimulus.joystick.engaged_threshold = 5;
        p.trial.stimulus.joystick.released_threshold = 2;
        p.trial.stimulus.joystick.orientation = 0;
        
        %  Reward amounts
        p.trial.stimulus.min_reward_amount = 0.1;
        p.trial.stimulus.max_reward_amount = 0.4;
        p.trial.stimulus.engaged_reward_amount = p.trial.stimulus.min_reward_amount;
        p.trial.stimulus.release_reward_amount = p.trial.stimulus.max_reward_amount;
        
        p.trial.stimulus.reward_for_engage = true;
        p.trial.stimulus.reward_for_release = true;
        
        %
        %  Initialize trial state
        %
        p.trial.stimulus.trial_state = STATE_UNBAITED;
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
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
        
        %  Grab a snapshot of the joystick data
        p.trial.stimulus.joystick.snapshot = joystick.get_joystick_status([p.trial.stimulus.joystick.released_threshold p.trial.stimulus.joystick.engaged_threshold],p.trial.stimulus.joystick.orientation);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control.
        
        %  Determine joystick status
        if(p.trial.stimulus.joystick.snapshot.status(1)==0)
            p.trial.stimulus.joystick.state=JOYSTICK_RELEASED;
        elseif(abs(p.trial.stimulus.joystick.snapshot.status(2)==1))
            p.trial.stimulus.joystick.state=JOYSTICK_ENGAGED;
        else
            p.trial.stimulus.joystick.state=JOYSTICK_EQUIVOCAL;
        end
        
        %
        %  Control trial events based on trial state
        %
        
        switch p.trial.stimulus.trial_state
            
            case STATE_BAITED
                
                %
                %  STATE_BAITED
                %
                
                %  We only reached this state because the unbaited time
                %  elapsed.

                %  Show the cue to indicate that we are in baited state
                %  (blinking white square).
                ShowBaitedCue(p);

                %  Start timer
                if(isnan(p.trial.stimulus.timing.baited_start_time))
                    p.trial.stimulus.timing.baited_start_time = GetSecs;
                    fprintf('Start baited state (%0.3f sec max duration) for trial %d\n',p.trial.stimulus.timing.grace_to_engage,p.trial.pldaps.iTrial);
                else                                        
                    %  Baited state will last for grace_to_engage then
                    %  transition to unbaited if monkey fails to engage.
                    %
                    %  If monkey engages joystick during baited time then
                    %  switch to engaged state.
                    
                    if(p.trial.stimulus.timing.baited_start_time > GetSecs-p.trial.stimulus.timing.grace_to_engage)
                        %  Still can engage, so check
                        if(p.trial.stimulus.joystick.state==JOYSTICK_ENGAGED)
                            fprintf('Monkey engaged joystick after %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.baited_start_time);
                            p.trial.stimulus.timing.baited_start_time = NaN;
                            p.trial.stimulus.trial_state = STATE_ENGAGED;
                        end
                    else
                        %  Monkey never engaged so go to unbaited state
                        fprintf('Monkey failed to engage joystick in time; end trial and return to unbaited state.\n');
                        pds.audio.play(p,'fail_to_engage');
                        p.trial.stimulus.timing.baited_start_time = NaN;
                        p.trial.stimulus.trial_state = STATE_UNBAITED;
                        p.trial.flagNextTrial = true; 
                    end
                end
                
            case STATE_ENGAGED
                
                %
                %  STATE_ENGAGED
                %
                
                %  Show the cue to continue holding the joystick
                ShowHoldCue(p);
                
                %  Start timer
                if(isnan(p.trial.stimulus.timing.engage_start_time))
                    p.trial.stimulus.timing.engage_start_time = GetSecs;
                    fprintf('Start engage cue for %0.3f sec.\n',p.trial.stimulus.timing.engaged_time);
                    if(p.trial.stimulus.reward_for_engaged)
                        fprintf('Monkey elligible for rewards.\n');
                        p.trial.stimulus.timing.engaged_reward_time = GetSecs;
                        fprintf('First reward occurs in %0.3f sec.\n',p.trial.stimulus.timing.engaged_reward_interval);
                    end
                else
                    if(p.trial.stimulus.reward_for_engage)
                        %  Continue rewarding periodically
                        if(p.trial.stimulus.timing.engaged_reward_time <= GetSecs - p.trial.stimulus.timing.engaged_reward_interval)
                            p.trial.stimulus.timing.engaged_reward_time = GetSecs;
                            pds.behavior.reward.give(p,p.trial.stimulus.engaged_reward_amount);
                            p.trial.stimulus.timing.engaged_reward_interval = unifrnd(p.trial.stimulus.timing.min_engaged_reward_interval,p.trial.stimulus.timing.max_engaged_reward_interval);
                            fprintf('Next reward occurs in %0.3f sec.\n',p.trial.stimulus.timing.engaged_reward_interval);
                        end
                    end
                    %  Check engage time
                    if(p.trial.stimulus.timing.engaged_start_time > GetSecs-p.trial.stimulus.timing.engaged_time)
                        %  We are still within the engage time
                        
                        if(p.trial.stimulus.joystick.state~=JOYSTICK_ENGAGED)
                            %  Monkey has released the joystick prematurely.
                            fprintf('Monkey released joystick early (%0.3f sec).  Terminate trial and return to unbaited state.\n',GetSecs-p.trial.stimulus.timing.engage_start_time);
                            pds.audio.play(p,'early_release');
                            p.trial.stimulus.timing.engaged_reward_time = NaN;
                            p.trial.stimulus.timing.engaged_start_time = NaN;
                            p.trial.stimulus.trial_state = STATE_UNBAITED;
                            p.trial.flagNextTrial = true;
                        end
                    else
                        %  engage time has elapsed.
                        fprintf('Monkey held joystick to end of engaged time.\n');
                        p.trial.stimulus.timing.engaged_reward_time = NaN;
                        p.trial.stimulus.timing.engaged_start_time = NaN;
                        p.trial.stimulus.trial_state = STATE_RELEASE;
                    end
                end
                
            case STATE_RELEASE
                
                %
                %  STATE_RELEASE
                %
                
                %  Show release cue
                ShowReleaseCue(p);
                
                if(isnan(p.trial.stimulus.timing.released_start_time))
                    p.trial.stimulus.timing.released_start_time = GetSecs;
                    fprintf('Monkey should release joystick within %0.3f sec to get a release reward.\n',p.trial.stimulus.timing.released_time);
                else                    
                    %  Check joystick; if he re-engages during the
                    %  mandatory released state then transition back to
                    %  unbaited.
                    %
                    %  If he leaves released for required time then go back
                    %  to baited state.
                    
                    if(p.trial.stimulus.timing.released_start_time > GetSecs-p.trial.stimulus.timing.released_time)
                        %  Still in mandatory released time
                        if(p.trial.stimulus.joystick.state~=JOYSTICK_RELEASED)
                            p.trial.stimulus.timing.released_start_time = GetSecs;
                        end
                    else
                        %  Mandatory released time expired without monkey
                        %  engaging the joystick.
                        fprintf('Monkey left joystick released for requisite time.  Proceed to baited state!\n');
                        p.trial.stimulus.timing.released_start_time = NaN;
                        p.trial.stimulus.trial_state = STATE_BAITED;
                    end
                end
                if(isnan(p.trial.stimulus.timing.unbaited_start_time))
                    fprintf('Start unbaited state.\n');
                    if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
                        p.trial.stimulus.trial_state = STATE_RELEASE;
                        p.trial.flagNextTrial = true;
                    else
                        p.trial.stimulus.timing.unbaited_start_time = GetSecs;
                        fprintf('Wait for monkey to release joystick.\n');
                    end
                else
                    
                    %  If monkey releases joystick prior to the grace time
                    %  he will get a reward; otherwise he gets a warning
                    %  sound
                    if(p.trial.stimulus.reward_for_release)
                        if(p.trial.stimulus.timing.unbaited_start_time >= GetSecs - p.trial.stimulus.timing.grace_to_release)
                            if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
                                fprintf('Monkey released joystick after %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.unbaited_start_time);
                                pds.behavior.reward.give(p,p.trial.stimulus.release_reward_amount);
                                fprintf('Monkey earned a release reward!\n');
                                p.trial.stimulus.timing.unbaited_start_time = NaN;
                                p.trial.stimulus.trial_state = STATE_RELEASE;
                                p.trial.flagNextTrial = true;
                            end
                        else
                            fprintf('Monkey did not release in time to get a reward.\n');
                            pds.audio.play(p,'release_warning');
                        end
                    else
                        if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
                            fprintf('Monkey released joystick after %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.unbaited_start_time);
                            p.trial.stimulus.timing.unbaited_start_time = NaN;
                            p.trial.stimulus.trial_state = STATE_RELEASE;
                            p.trial.flagNextTrial = true;
                        end
                    end
                end
        

%                     %  Check joystick; once he releases go to released state
%                     
%                     if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
%                         fprintf('Monkey released joystick after %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.unbaited_start_time);
%                         
%                         
%                         if(p.trial.stimulus.reward_for_release)
%                             if(p.trial.stimulus.timing.unbaited_start_time >= GetSecs - p.trial.stimulus.timing.grace_to_release)
%                                 
%                                 pds.behavior.reward.give(p,p.trial.stimulus.release_reward_amount);
%                                 fprintf('Monkey earned a release reward!\n');
%                             else
%                                 fprintf('Monkey did not release in time to get a reward.\n');
%                             end
%                         end
%                         
%                         p.trial.stimulus.timing.unbaited_start_time = NaN;
%                         p.trial.stimulus.trial_state = STATE_RELEASED;
%                         p.trial.flagNextTrial = true;
%                     end
%                 end
                case STATE_RELEASE
                
                %
                %  STATE_RELEASE
                %
                
                %  Show release cue
                ShowReleaseCue(p);
                
                if(isnan(p.trial.stimulus.timing.unbaited_start_time))
                    fprintf('Start unbaited state.\n');
                    if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
                        p.trial.stimulus.trial_state = STATE_RELEASE;
                        p.trial.flagNextTrial = true;
                    else
                        p.trial.stimulus.timing.unbaited_start_time = GetSecs;
                        fprintf('Wait for monkey to release joystick.\n');
                    end
                else
                    
                    %  If monkey releases joystick prior to the grace time
                    %  he will get a reward; otherwise he gets a warning
                    %  sound
                    if(p.trial.stimulus.reward_for_release)
                        if(p.trial.stimulus.timing.unbaited_start_time >= GetSecs - p.trial.stimulus.timing.grace_to_release)
                            if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
                                fprintf('Monkey released joystick after %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.unbaited_start_time);
                                pds.behavior.reward.give(p,p.trial.stimulus.release_reward_amount);
                                fprintf('Monkey earned a release reward!\n');
                                p.trial.stimulus.timing.unbaited_start_time = NaN;
                                p.trial.stimulus.trial_state = STATE_RELEASE;
                                p.trial.flagNextTrial = true;
                            end
                        else
                            fprintf('Monkey did not release in time to get a reward.\n');
                            pds.audio.play(p,'release_warning');
                        end
                    else
                        if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
                            fprintf('Monkey released joystick after %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.unbaited_start_time);
                            p.trial.stimulus.timing.unbaited_start_time = NaN;
                            p.trial.stimulus.trial_state = STATE_RELEASE;
                            p.trial.flagNextTrial = true;
                        end
                    end
                end
                
            case STATE_UNBAITED
                
                %
                %  STATE_UNBAITED
                %
                                
                %  Show release instruction
                %ShowReleaseCue(p);
                
                %  Show a blank screen; this merges into the delay between
                %  trials.
                
                
        end
end
end

%  FUNCTIONS TO DO SOME FRAME DRAWING

function ShowBaitedCue(p)
%  ShowBaitedCue
%
%  This function should draw a blinking rectangle as the cue to engage the
%  joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr

width = p.trial.stimulus.features.baited.cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

display_time = p.trial.stimulus.features.baited.cue_period*p.trial.stimulus.features.baited.cue_duty_cycle;
cue_period = p.trial.stimulus.features.baited.cue_period;
if(isnan(p.trial.stimulus.timing.baited_cue_start_time))
    p.trial.stimulus.timing.baited_cue_start_time = GetSecs;
    Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.baited.cue_color,centeredRect,p.trial.stimulus.features.baited.cue_linewidth);
else
    if(p.trial.stimulus.timing.baited_cue_start_time > GetSecs-display_time)
        Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.baited.cue_color,centeredRect,p.trial.stimulus.features.baited.cue_linewidth);
    elseif(p.trial.stimulus.timing.baited_cue_start_time <= GetSecs-cue_period)
        p.trial.stimulus.timing.baited_cue_start_time = NaN;
    end
end
end

function ShowEngageCue(p)
%  ShowEngageCue
%
%  This function should draw a white rectangle as the cue to continue
%  holding the joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr
%
%  I want a square drawn as a cue to engage the joystick.  It will be white
%  and centered in the middle of the screen, where there is not currently a
%  fixation point but at some point in the future there will be.  I don't
%  need it smoothed.

width = p.trial.stimulus.features.engage.cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.engage.cue_color,centeredRect,p.trial.stimulus.features.engage.cue_linewidth);
end

function ShowReleaseCue(p)
%  ShowReleaseCue
%
%  This function should draw a black rectangle as the cue that the joystick
%  is released.
%
%  I want a square drawn as a cue indicating release of joystick.  It will
%  be black and centered in the middle of the screen, where there is not
%  currently a fixation point but at some point in the future there will
%  be.  I don't need it smoothed.


width = p.trial.stimulus.features.unbaited.cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.unbaited.cue_color,centeredRect,p.trial.stimulus.features.unbaited.cue_linewidth);
end
