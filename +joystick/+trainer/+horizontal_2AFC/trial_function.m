function p = trial_function(p,state)
%  PLDAPS TRIAL FUNCTION FILE
%  PACKAGE:  joystick.trainer.horizontal_2AFC

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
        
        %  Set stimulus features
        joystick.trainer.horizontal_2AFC.features(p);
        
        %  Condition from cell array
        p.trial.condition = p.conditions{p.trial.pldaps.iTrial};
        
        %  Initialize trial state variables
        p.functionHandles.state_variables = joystick.trainer.horizontal_2AFC.state_variables(p.trial.condition);
        
        p.functionHandles.timing.response_start = NaN;
        p.functionHandles.nWrongTrials = 1 ;
        fprintf('TRIAL %d:\n',p.trial.pldaps.iTrial);
        fprintf('Move the joystick to a target on the %s.\n\n',p.trial.condition.direction);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        %
        %  Perform any steps that should happen upon completion of a trial
        
        fprintf('Current performance:  %d correct, %d incorrect (%0.2f)\n\n',p.functionHandles.correct,p.functionHandles.incorrect,p.functionHandles.correct/(p.functionHandles.correct+p.functionHandles.incorrect));
        
    case p.trial.pldaps.trialStates.frameDraw
        %  Final image has been calculated and will now be drawn
        %
        %  This is where all calls to Screen should be done.
        
        %  Draw the target here
        switch p.functionHandles.state_variables.next_state
            case {'pre_choice','choice','reward'}
                ShowTargets;
                ShowCue;
        end
        
    case p.trial.pldaps.trialStates.frameDrawingFinished
        %  Here we could do any steps that need to be done immediately
        %  prior to the flip.
        
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update is called once after the last frame is done (or
        %  even before).  Get current eyepostion, curser position,
        %  keypresses, joystick position, etc. in preparation for the
        %  subsequent trial
        
        %  Check if joystick is at the ready
        p.functionHandles.state_variables.joystick_ready = analog_stick.atCenter(p);
        
        %  Check if joystick is in left target
        xpos = p.functionHandles.analog_stick.xypos(1);
        if(xpos > p.trial.display.ctr(1)-p.trial.features.target_radius-0.5*p.trial.features.target_diameter && xpos < p.trial.display.ctr(1)-p.trial.features.target_radius+0.5*p.trial.features.target_diameter)
            p.functionHandles.state_variables.joystick_left = true;
            p.functionHandles.state_variables.joystick_right = false;
        elseif(xpos > p.trial.display.ctr(1)+p.trial.features.target_radius-0.5*p.trial.features.target_diameter && xpos < p.trial.display.ctr(1)+p.trial.features.target_radius+0.5*p.trial.features.target_diameter)
            p.functionHandles.state_variables.joystick_left = false;
            p.functionHandles.state_variables.joystick_right = true;
        else
            p.functionHandles.state_variables.joystick_left = false;
            p.functionHandles.state_variables.joystick_right = false;
        end
        
        %  Check if joystick is in right target
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control (just don't actually make the Screen calls
        %  here).
        
        %  Make sure we don't accidentally over-run the data buffer
        if(p.trial.ttime >= p.trial.pldaps.maxTrialLength-p.trial.display.ifi)
            p.trial.flagNextTrial = true;
        end
                
        %  Control trial progress with trial state variables
        
        switch p.functionHandles.state_variables.next_state
            
            case 'start'
                
                %  STATE:  start
                %
                %  First check and see if monkey has deflected joystick.
                %  If it is at rest (i.e. at neutral position and not
                %  moving) then proceed.  Otherwise go to warning.
                
                fprintf('START state\n');
                p.functionHandles.nWrongTrials = p.functionHandles.nWrongTrials * .5 ;
                p.functionHandles.state_variables.current_state = 'start';
                
                %  Note that we do not show the joystick cursor in this
                %  state
                
                p.trial.analog_stick.cursor.use = false;
                
                
                %  Set state based on if the joystick is in the ready position
                
                if(p.functionHandles.state_variables.joystick_ready)
                    p.functionHandles.state_variables.next_state = 'pre_choice';
                else
                    p.functionHandles.state_variables.next_state = 'joystick_warning';
                end
                
                
            case 'pre_choice'
                
                %  Gabe's edit 11/16/16. Have target come on screen before
                %  cursor.
                %  STATE:   pre_choice
                
                %  Monkey enters this state after start state if joystick
                %  is ready.
                
                if(~strcmp(p.functionHandles.state_variables.next_state,p.functionHandles.state_variables.current_state))
                    p.functionHandles.state_variables.current_state = 'pre_choice';
                    p.functionHandles.timer = GetSecs;
                    p.trial.analog_stick.cursor.use = false;                   
                    p.functionHandles.state_variables.joystick_ready = analog_stick.atCenter(p);
                        if(~p.functionHandles.state_variables.joystick_ready)
                            p.functionHandles.state_variables.next_state = 'joystick_warning';
                        end
                elseif(GetSecs-p.functionHandles.timer > 0.3)
                    p.functionHandles.state_variables.next_state = 'choice' ;
                end
                
                
%                 
%                 pause(.5);
%                 p.functionHandles.state_variables.joystick_ready = analog_stick.atCenter(p);
%                 if(p.functionHandles.state_variables.joystick_ready)
%                     p.functionHandles.state_variables.next_state = 'choice';                       
%                 else
%                     p.functionHandles.state_variables.next_state = 'joystick_warning';
%                 end
                
                
            case 'joystick_warning'
                
                %  STATE:  joystick_warning
                
                %  Monkey enters this state if he does not have the
                %  joystick at the rest position when the trial starts
                
                if(~strcmp(p.functionHandles.state_variables.next_state,p.functionHandles.state_variables.current_state))
                    fprintf('Started JOYSTICK WARNING state.\n');
                    p.functionHandles.state_variables.current_state = 'joystick_warning';
                    
                    %  Start warning tone
                    pds.audio.play(p,'joystick_warning',Inf);
                end
                
                %  Check if he has returned joystick to rest position and
                %  proceed once that has happened
                p.functionHandles.state_variables.joystick_ready = analog_stick.atCenter(p);
                if(p.functionHandles.state_variables.joystick_ready)
                    %  Stop warning tone
                    fprintf('Joystick back at ready.\n');
                    pds.audio.stop(p,'joystick_warning');
                    pause(0.05) ;
                    p.functionHandles.state_variables.next_state = 'pre_choice';
                end
                
            case 'choice'
                
                if(~strcmp(p.functionHandles.state_variables.next_state,p.functionHandles.state_variables.current_state))
                    p.trial.analog_stick.cursor.use = true;
                    p.functionHandles.state_variables.current_state = 'choice';
                end
                
                %  Check if he's made a decision
                if(p.functionHandles.state_variables.left_choice && p.functionHandles.state_variables.joystick_left)
                    p.functionHandles.state_variables.next_state = 'reward';
                    p.functionHandles.correct = p.functionHandles.correct+1;
                elseif(p.functionHandles.state_variables.left_choice && p.functionHandles.state_variables.joystick_right)
                    p.functionHandles.state_variables.next_state = 'error';
                    p.functionHandles.incorrect = p.functionHandles.incorrect+1;
                elseif(p.functionHandles.state_variables.right_choice && p.functionHandles.state_variables.joystick_right)
                    p.functionHandles.state_variables.next_state = 'reward';
                    p.functionHandles.correct = p.functionHandles.correct+1;
                elseif(p.functionHandles.state_variables.right_choice && p.functionHandles.state_variables.joystick_left)
                    p.functionHandles.state_variables.next_state = 'error';
                    p.functionHandles.incorrect = p.functionHandles.incorrect+1;
                end
                
                
            case 'reward'
                
                if(~strcmp(p.functionHandles.state_variables.next_state,p.functionHandles.state_variables.current_state))
                    fprintf('Good job monkey!\n');
                    p.functionHandles.state_variables.current_state = 'reward';
                    %p.trial.analog_stick.cursor.use = false;
                    p.functionHandles.timer = GetSecs;
%                     if p.functionHandles.nWrongTrials == 1
                        pds.behavior.reward.give(p,p.functionHandles.nWrongTrials + (randi(8,1) / 75));
%                         fprintf('First Try! \n') ;
                        pds.audio.play(p,'reward',1);
%                     else
%                         pds.behavior.reward.give(p,0.2);
%                         fprintf('Not First Try \n') ;
%                         pds.audio.play(p,'reward',1);
%                     end
                elseif(GetSecs-p.functionHandles.timer > 0.5)
                    p.trial.flagNextTrial = true;
                end
                
                            case 'error'
                
                if(~strcmp(p.functionHandles.state_variables.next_state,p.functionHandles.state_variables.current_state))
                    fprintf('STOOPID monkey.\n');
                    p.trial.analog_stick.cursor.use = false;
                    p.functionHandles.state_variables.current_state = 'error';
                    p.functionHandles.timer = GetSecs;
                    pds.audio.play(p,'incorrect',1);
                elseif(GetSecs-p.functionHandles.timer > 0.5)
%                     p.trial.flagNextTrial = true;

                    % Gabe's edit: If monkey is wrong, start trial over
                    % again after a delay
                    p.functionHandles.state_variables.next_state = 'start';
                    pause(1);
                end
 
        end
        
        
end

%         elseif(~isnan(p.functionHandles.rstart) && GetSecs - 0.5 >= p.functionHandles.rstart)
%             p.trial.flagNextTrial = true;
%         elseif(isnan(p.functionHandles.rstart))
%             %  Here I will check the joystick position and reward him if he
%             %  gets it right
%
%             xpos = p.trial.joystick.xypos(1);
%             center = p.trial.condition.center + p.trial.display.ctr(1);
%             a = center - p.trial.condition.diameter/2;
%             b = center + p.trial.condition.diameter/2;
%
%             if(xpos > a && xpos < b)
%
%                 pds.behavior.reward.give(p,0.5);
%                 pds.audio.play(p,'reward',1);
%                 p.functionHandles.rstart = GetSecs;
%             end
%
%         end


%  NESTED FUNCTIONS BELOW

%  Draw the target
    function ShowTargets
        win = p.trial.display.ptr;
        color = p.trial.features.target_color;
        baseRect = [0 0 p.trial.features.target_diameter p.trial.features.target_diameter];
        centeredRect = [CenterRectOnPoint(baseRect,p.trial.features.target_radius + p.trial.display.ctr(1),p.trial.display.ctr(2)); CenterRectOnPoint(baseRect,p.trial.display.ctr(1) - p.trial.features.target_radius,p.trial.display.ctr(2))]';
        Screen('FrameOval',win,color,centeredRect,p.trial.features.target_linewidth);
    end

    function ShowCue
        win = p.trial.display.ptr;
        color = p.trial.features.cue_color;
        baseRect = [0 0 p.trial.features.cue_diameter p.trial.features.cue_diameter];
        switch p.trial.condition.direction
            case 'left'
                centeredRect = [CenterRectOnPoint(baseRect,-p.trial.features.cue_radius + p.trial.display.ctr(1),p.trial.display.ctr(2)); CenterRectOnPoint(baseRect,p.trial.display.ctr(1),p.trial.display.ctr(2))]';
            otherwise
                centeredRect = [CenterRectOnPoint(baseRect,p.trial.features.cue_radius + p.trial.display.ctr(1),p.trial.display.ctr(2)); CenterRectOnPoint(baseRect,p.trial.display.ctr(1),p.trial.display.ctr(2))]';
        end
        Screen('FillOval',win,color,centeredRect);
    end
        
end