classdef state_variables
    %STATE_VARIABLES State variables for trials of only_zuul
    %   All the state variables for controlling a trial
    
    properties        
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
        
        show_fixation_cue = false;
        show_symbols = false;
        show_response_cue = false;
    end
    
    methods 
        %  Class constructor method
        function obj = state_variables(condition)
            obj.release_trial = strcmp('release',condition.response_type);
            obj.press_trial = ~obj.release_trial;
            
            obj.set_trial = strcmp('set',condition.sequence_type);
            obj.notset_trial = strcmp('notset',condition.sequence_type);
        end
    end
    
end

