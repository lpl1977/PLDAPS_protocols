classdef outcome
    %OUTCOME Data regarding outcome of the trial
    %   Data for outcome of the trial collected as a class so that I can
    %   easily separate masks from sets and notsets
    
    properties
        correct = false;
        completed = false;
        fixation_break = false;
        failed_to_initiate = false;
        joystick_warning_elapsed = false;
        eye_warning_elapsed = false;
        early_release = false;
        early_press = false;
        release_drift_error = false;
        press_drift_error = false;
        miss = false;
        
        abort_state = '';
        abort_time = NaN;

        reaction_time = NaN;
    end
    
    methods
    end
    
end

