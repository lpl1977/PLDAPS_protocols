classdef state_variables
    %STATE_VARIABLES State variables with trials of Only_Zuul
    %   All the state variables for controlling a trial
    
    properties        
        noise_frame = 0;
        trial_state = 'start';
        release_trial 
        press_trial 
        current_symbol = 1;
        
        wait_for_release = false;
        wait_for_fixation
        wait_for_engage  
        
        joystick_released
        joystick_engaged
        joystick_pressed
        joystick_press_buffer
        joystick_release_buffer
        
        fixating
        
        set_trial
        notset_trial
        mask_trial
    end
    
    methods 
        %  Class constructor
        function obj = state_variables(condition)
            obj.release_trial = strcmp('release',condition.trial_type);
            obj.press_trial = ~obj.release_trial;
            
            obj.set_trial = strcmp('set',condition.sequence_type);
            obj.notset_trial = strcmp('notset',condition.sequence_type);
            obj.mask_trial = strcmp('mask',condition.sequence_type);
        end
    end
    
end

