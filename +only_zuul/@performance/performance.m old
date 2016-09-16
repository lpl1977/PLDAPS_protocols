classdef (InferiorClasses = {?outcome}) performance
    %PERFORMANCE Summary data regarding trial outcomes
    %   Summary for outcomes of trial collected as a class so that I can
    %   easily separate out sequence types
    
    properties
        attempted = 0;
        correct = 0;
        completed = 0;
        
        fixation_break = 0;
        failed_to_initiate = 0;
        joystick_warning_elapsed = 0;
        eye_warning_elapsed = 0;
        early_release = 0;
        early_press = 0;
        release_drift_error = 0;
        press_drift_error = 0;
        miss = 0;
        
        repeats
        
        matrix
    end
    
    properties (Hidden = true)
        abort_types = {...
            'fixation_break','failed_to_initiate',...
            'joystick_warning_elapsed','eye_warning_elapsed',...
            'early_release','early_press','release_drift_error',...
            'press_drift_error','miss'};
    end
    
    methods
        %  Class constructor
        function obj = performance(nrows)
            obj.matrix = zeros(nrows,3);
        end
    end
    
    methods (Static)
        %  Update performance based on outcome
        function p_obj = update(p_obj,o_obj,condition)
            p_obj.attempted = p_obj.attempted+1;
            
            row = condition.lum_indx;
            rtrial = strcmp(condition.trial_type,'release');
            
            p_obj.correct = p_obj.correct + o_obj.correct;
            p_obj.completed = p_obj.completed + o_obj.completed;
            p_obj.fixation_break = p_obj.fixation_break + o_obj.fixation_break;
            p_obj.failed_to_initiate = p_obj.failed_to_initiate+ o_obj.failed_to_initiate;
            p_obj.joystick_warning_elapsed = p_obj.joystick_warning_elapsed + o_obj.joystick_warning_elapsed;
            p_obj.eye_warning_elapsed = p_obj.eye_warning_elapsed + o_obj.eye_warning_elapsed;
            p_obj.early_release = p_obj.early_release + o_obj.early_release;
            p_obj.early_press = p_obj.early_press + o_obj.early_press;
            p_obj.release_drift_error = p_obj.release_drift_error + o_obj.release_drift_error;
            p_obj.press_drift_error = p_obj.press_drift_error + o_obj.press_drift_error;
            p_obj.miss = p_obj.miss + o_obj.miss;
            
            if(o_obj.completed)
                p_obj.matrix(row,1) = p_obj.matrix(row,1)+((o_obj.correct && rtrial) || (~o_obj.correct && ~rtrial));
                p_obj.matrix(row,2) = p_obj.matrix(row,2)+((o_obj.correct && ~rtrial) || (~o_obj.correct && rtrial));
                p_obj.matrix(row,3) = p_obj.matrix(row,3)+1;
            end
        end
        
        function p_obj = track_repeats(p_obj)
            p_obj.repeats = p_obj.repeats+1;
        end
        
        %  Display performance
        function print_summary_performance(obj)
            %  obj_struct is a structure of performance objects
            fnames = fieldnames(obj);
            
            fprintf('Cumulative performance:\n');
            fprintf('\t                     ');
            for i=1:length(fnames)
                n1 = length(num2str(obj.(fnames{i}).completed));
                n2 = length(num2str(obj.(fnames{i}).attempted));
                fprintf('%-*s  ',n1+n2+10,fnames{i});
            end
            fprintf('\n');
            fprintf('\tCompleted:           ');
            for i=1:length(fnames)
                n1 = length(num2str(obj.(fnames{i}).completed));
                n2 = length(num2str(obj.(fnames{i}).attempted));
                fprintf('%*d of %*d (%3.2f) ',n1,obj.(fnames{i}).completed,n2,obj.(fnames{i}).attempted,obj.(fnames{i}).completed/obj.(fnames{i}).attempted);
                if(obj.(fnames{i}).completed==0 || obj.(fnames{i}).attempted==0)
                    fprintf(' ');
                end
            end
            fprintf('\n');
            fprintf('\tCorrectly completed: ');
            for i=1:length(fnames)
                n1 = length(num2str(obj.(fnames{i}).completed));
                n2 = length(num2str(obj.(fnames{i}).attempted));
                fprintf('%*d of %*d (%3.2f) ',n1,obj.(fnames{i}).correct,n2,obj.(fnames{i}).completed,obj.(fnames{i}).correct/obj.(fnames{i}).completed);
                if(obj.(fnames{i}).completed==0 || obj.(fnames{i}).attempted==0)
                    fprintf(' ');
                end
            end
            fprintf('\n\n');
        end
        
        %  Display trial aborts
        function print_summary_trial_aborts(obj)
            %  obj_struct is a structure of performance objects
            
            fnames = fieldnames(obj);
            nfields = length(fnames);
            nchar = zeros(nfields,1);
            for i=1:nfields
                nchar(i) = length(fnames{i});
            end
            n1 = max(nchar)+1;
            
            abort_types = obj.(fnames{1}).abort_types;
            ntypes = length(abort_types);
            nchar = zeros(ntypes,1);
            for j=1:ntypes
                nchar(j) = length(abort_types{j});
            end
            n2 = max(nchar);
            
            fprintf('Trial Aborts:\n');
            fprintf('%*s',n2+3,' ');
            
            for i=1:nfields
                fprintf('%-*s',n1,fnames{i});
            end
            fprintf('\n');
            
            for j=1:length(abort_types)
                fprintf('%-*s  ',n2+1,strcat(abort_types{j},':'));
                for i=1:nfields
                    fprintf('%-*d',n1,obj.(fnames{i}).(abort_types{j}));
                end
                fprintf('\n');
            end
            fprintf('\n');
        end
    end
end

