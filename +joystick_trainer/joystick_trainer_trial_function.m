function p = joystick_trainer_trial_function(p,state)
%joystick_trial_function(p,state)
%
%  PLDAPS trial function for joystick training

%  Call default trial function for state dependent steps
pldapsDefaultTrialFunction(p,state);

%  Basic structure of a trial:
%
%  State is either baited, hold, rewarded release, or unbaited.  If baited,
%  then engaging joystick could lead to a reward.  State will then
%  transition to hold.  After a randomized delay, state transitions back
%  unbaited and monkey will receive a reward for releasing the joystick.
%  After an additional randomized delay, the state will transition back to
%  baited.
%
%  A different visual cue instructs monkey if the state is baited, hold, or
%  unbaited.
%
%  When the state transitions from unbaited to hold, there is a grace
%  period in which he can engage the joystick.
%
%  After a randomized hold time, the state will transition back to
%  unbaited.  The monkey should release the joystick within a certain
%  period of time to obtain the release reward.  Initially the hold time
%  will be quite short and the grace period will also be quite long.  After
%  release, there will be a randomized amount of time until the state
%  transitions back to baited.

%  Trial state summary:
%
%  1.  STATE_BAITED This state starts after a randomized time from the
%  previous unbaited state and if the joystick is fully released. The state
%  will remain baited for a randomized period of time before transitioning
%  back to unbaited (this would be an aborted trial).  For now this grace
%  period to engage the joystick will be quite long.

STATE_BAITED = 1000;

%  2.  STATE_HOLD This state starts upon engagement of the joystick.
%  Monkey may receive an engage reward and then must hold for a randomized
%  period of time (initially quite short).  After the state ends he should
%  release the joystick to receive a release reward.  He will have a
%  limited period of time to do so but for now this period will be quite
%  long.  If he releases during the hold period he will not get the release
%  reward.  In the future this will lead to trial abort but for now it will
%  lead to trial unbaited.

STATE_HOLD = 1010;

%  3.  STATE_REWARDED_RELEASE This state starts at end of the hold period
%  and the release reward can come as soon as he releases the joystick.
%  After he releases transition to unbaited state.  There will be a maximum
%  grace period in which he can release the joystick prior to transitioning
%  to unbaited state.

STATE_REWARDED_RELEASE = 1020;

%  3.  STATE_UNBAITED This state starts at release of the joystick.  After
%  a random time, the state will transition back to unbaited as long as the
%  joystick is not engaged.
%
%  Trial will start in the unbaited mode.

STATE_UNBAITED = 1030;

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
        
        %
        %  Make sure that the timing parameters are set
        %
        
        p.trial.stimulus.timing.hold_time = unifrnd(p.trial.stimulus.timing.min_hold_time,p.trial.stimulus.timing.max_hold_time);
        
        p.trial.stimulus.timing.unbaited_time = unifrnd(p.trial.stimulus.timing.min_unbaited_time,p.trial.stimulus.timing.max_unbaited_time);
        
        p.trial.stimulus.timing.baited_start_time = NaN;
        p.trial.stimulus.timing.hold_start_time = NaN;
        p.trial.stimulus.timing.unbaited_start_time = NaN;
        
        p.trial.stimulus.timing.engage_start_time = NaN;
        p.trial.stimulus.timing.release_start_time = NaN;
        
        p.trial.stimulus.timing.baited_cue_start_time = NaN;

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
        p.trial.stimulus.joystick.snapshot = joystick.get_joystick_status([p.trial.stimulus.rest_threshold p.trial.stimulus.deflection_threshold],p.trial.stimulus.orientation);
        
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
                %  Current trial state is STATE_BAITED
                %
                
                %  We only reached this state because the unbaited time
                %  elapsed and the monkey had joystick released.
                
                %  Start timer
                if(isnan(p.trial.stimulus.timing.baited_start_time))
                    p.trial.stimulus.timing.baited_start_time = GetSecs;
                    fprintf('Start baited state for trial %d\n',p.trial.pldaps.iTrial);
                end
                
                %  Show monkey the baited cue
                ShowBaitedCue(p);
                
                %  If at any time during the baited state monkey engages
                %  joystick the trial will proceed.  Otherwise check
                %  against the grace period.
                
                if(p.trial.stimulus.joystick.state==JOYSTICK_ENGAGED)
                    fprintf('Monkey engaged joystick after %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.baited_start_time);
                    p.trial.stimulus.timing.baited_start_time = NaN;
                    p.trial.stimulus.trial_state = STATE_HOLD;
                else
                    %  Check time against the time limit.
                    if(p.trial.stimulus.timing.baited_start_time < GetSecs-p.trial.stimulus.timing.grace_to_engage)
                        fprintf('Monkey has not engaged the joystick within the grace time.\n');
                        
                        %  NOT IMPLEMENTED YET
                    end
                end
                
            case STATE_HOLD
                
                %
                %  STATE_HOLD
                %
                
                %  He should hold it as long as the hold cue appears.
                
                %  Start timer
                if(isnan(p.trial.stimulus.timing.hold_start_time))
                    p.trial.stimulus.timing.hold_start_time = GetSecs;
                    fprintf('Start hold cue for %0.3f sec.\n',p.trial.stimulus.timing.hold_time);
                end
                
                %  Show the cue
                ShowHoldCue(p);
                
                %  Determine if we are still in the hold time.
                if(p.trial.stimulus.timing.hold_start_time > GetSecs-p.trial.stimulus.timing.hold_time)
                    %  We are still within the hold time so proceed with
                    %  joystick check.
                    
                    if(p.trial.stimulus.joystick.state~=JOYSTICK_ENGAGED)
                        %  Monkey has released the joystick prematurely.
                        
                        p.trial.stimulus.timing.hold_start_time = NaN;
                        fprintf('Monkey released joystick early.  Proceed directly to unbaited state for next trial.\n');
                        p.trial.stimulus.state = STATE_UNBAITED;
                        p.trial.flagNextTrial = true;
                    end
                else
                    %  Hold time has elapsed.  He can get a reward if he releases in time...
                    fprintf('Monkey held joystick to end of hold time.  Proceed to rewarded release state.\n');
                    p.trial.stimulus.timing.hold_start_time = NaN;
                    p.trial.stimulus.trial_state = STATE_REWARDED_RELEASE;
                end
                
            case STATE_REWARDED_RELEASE
                
                %
                %  Current trial state is STATE_REWARDED_RELEASE
                %
                
                %  Show the unbaited cue
                ShowUnbaitedCue(p);
                
                if(isnan(p.trial.stimulus.timing.release_start_time))
                    p.trial.stimulus.timing.release_start_time = GetSecs;
                end
                
                if(p.trial.stimulus.timing.release_start_time > GetSecs-p.trial.stimulus.timing.grace_to_release)
                    
                    %  Show hold cue until monkey releases joystick.
                    
                    if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
                        fprintf('Good monkey released joystick in time and gets a reward!\n');
                        pds.behavior.reward.give(p,p.trial.stimulus.release_reward_amount);
                        p.trial.stimulus.timing.release_start_time = NaN;
                        p.trial.stimulus.trial_state = STATE_UNBAITED;
                        
                        fprintf('Proceed to next trial.\n');
                        p.trial.flagNextTrial = true;
                    end
                else
                    fprintf('Monkey did not release joystick in time.\n');
                    p.trial.stimulus.timing.release_start_time = NaN;
                    p.trial.stimulus.trial_state = STATE_UNBAITED;
                    
                    
                    fprintf('Proceed to next trial.\n');
                    p.trial.flagNextTrial = true;
                end
                
            case STATE_UNBAITED
                
                %
                %  Current trial state is STATE_UNBAITED
                %
                
                %  Show the unbaited cue
                ShowUnbaitedCue(p);
                
                if(isnan(p.trial.stimulus.timing.unbaited_start_time))
                    p.trial.stimulus.timing.unbaited_start_time = GetSecs;
                    fprintf('Start unbaited state for %0.3f sec\n',p.trial.stimulus.timing.unbaited_time);
                end
                
                %  Wait for the requisite amount of time then transition to
                %  baited (as long as the joystick is not engaged).
                %
                %  At some point I will have to decide if he must have the
                %  joystick released the entire time or it just doesn't
                %  give him a reward for engaging in this time; for now it
                %  can't transition to baited with the joystick engaged.
                
                if(p.trial.stimulus.timing.unbaited_start_time <= GetSecs-p.trial.stimulus.timing.unbaited_time)                    
                    if(p.trial.stimulus.joystick.state==JOYSTICK_RELEASED)
                        fprintf('Proceed to baited state!\n');
                        p.trial.stimulus.trial_state = STATE_BAITED;
                        p.trial.stimulus.timing.unbaited_start_time = NaN;
                    end
                end
        end
end
end

%  FUNCTIONS TO DO SOME FRAME DRAWING

function ShowBaitedCue(p)
%  ShowBaitedCue
%
%  This function should draw a rectangle as the cue to engage the joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr
%
%  I want a square drawn as a cue to engage the joystick.  It will be white
%  and centered in the middle of the screen, where there is not currently a
%  fixation point but at some point in the future there will be.  I don't
%  need it smoothed.

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

function ShowHoldCue(p)
%  ShowHoldCue
%
%  This function should draw a rectangle as the cue to hold the joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr
%
%  I want a square drawn as a cue to hold the joystick.  It will be white
%  and centered in the middle of the screen, where there is not currently a
%  fixation point but at some point in the future there will be.  I don't
%  need it smoothed.
%
%  It won't blink

width = p.trial.stimulus.features.hold.cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.hold.cue_color,centeredRect,p.trial.stimulus.features.hold.cue_linewidth);
end

function ShowUnbaitedCue(p)
%  ShowHoldCue
%
%  This function should draw a rectangle as the cue to hold the joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr
%
%  I want a square drawn as a cue to hold the joystick.  It will be white
%  and centered in the middle of the screen, where there is not currently a
%  fixation point but at some point in the future there will be.  I don't
%  need it smoothed.
%
%  It won't blink
%
%  To convey the fact that it is not baited there will be a big X in the
%  center

width = p.trial.stimulus.features.hold.cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

cue_linewidth = p.trial.stimulus.features.unbaited.cue_linewidth;
baseX = [cue_linewidth width-cue_linewidth cue_linewidth width-cue_linewidth ;...
    cue_linewidth width-cue_linewidth width-cue_linewidth cue_linewidth];

Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.unbaited.cue_color,centeredRect,cue_linewidth);
Screen('DrawLines',p.trial.display.ptr,baseX,cue_linewidth,p.trial.stimulus.features.unbaited.cue_color,p.trial.display.ctr(1:2)-0.5*width);
end
