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
        function print_performance(obj,log10C)
            %  obj_struct is a structure of performance objects including
            %  total, mask, notset, and set
            fnames = {'mask','set','notset'};
            
            fprintf('Cumulative total performance:\n');
            n1 = length(num2str(obj.total.completed));
            n2 = length(num2str(obj.total.attempted));
            fprintf('\tCompleted:           %*d of %*d (%3.2f)\n',n1,obj.total.completed,n2,obj.total.attempted,obj.total.completed/obj.total.attempted);
            fprintf('\tCorrectly completed: %*d of %*d (%3.2f)\n',n1,obj.total.correct,n2,obj.total.completed,obj.total.correct/obj.total.completed);
            fprintf('\n');
            fprintf('Cumulative performance by condition:\n');
            fprintf('\t                     ');
            for i=1:3
                n1 = length(num2str(obj.(fnames{i}).completed));
                n2 = length(num2str(obj.(fnames{i}).attempted));
                fprintf('%-*s  ',n1+n2+10,fnames{i});
            end
            fprintf('\n');                
            fprintf('\tCompleted:           ');
            for i=1:3
                n1 = length(num2str(obj.(fnames{i}).completed));
                n2 = length(num2str(obj.(fnames{i}).attempted));
                fprintf('%*d of %*d (%3.2f) ',n1,obj.(fnames{i}).completed,n2,obj.(fnames{i}).attempted,obj.(fnames{i}).completed/obj.(fnames{i}).attempted);
                if(obj.(fnames{i}).completed==0 || obj.(fnames{i}).attempted==0) fprintf(' '); end
            end
            fprintf('\n');
            fprintf('\tCorrectly completed: ');
            for i=1:3
                n1 = length(num2str(obj.(fnames{i}).completed));
                n2 = length(num2str(obj.(fnames{i}).attempted));
                fprintf('%*d of %*d (%3.2f) ',n1,obj.(fnames{i}).correct,n2,obj.(fnames{i}).completed,obj.(fnames{i}).correct/obj.(fnames{i}).completed);
                if(obj.(fnames{i}).completed==0 || obj.(fnames{i}).attempted==0) fprintf(' '); end
            end
            fprintf('\n');
            
            fprintf('Trial Aborts:\n');
            fprintf('\t                          ');
            for i=1:3
                fprintf('%-8s',fnames{i});
            end
            fprintf('\n');
            fprintf('\tfixation break:           ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).fixation_break);
            end
            fprintf('\n');
            fprintf('\tfailed to initiate trial: ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).failed_to_initiate);
            end
            fprintf('\n');
            fprintf('\tjoystick warning elapsed: ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).joystick_warning_elapsed);
            end
            fprintf('\n');
            fprintf('\teye warning elapsed:      ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).eye_warning_elapsed);
            end
            fprintf('\n');
            fprintf('\tearly release:            ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).early_release);
            end
            fprintf('\n');
            fprintf('\tearly press:              ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).early_press);
            end
            fprintf('\n');
            fprintf('\trelease drift error:      ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).release_drift_error);
            end
            fprintf('\n');
            fprintf('\tpress drift error:        ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).press_drift_error);
            end
            fprintf('\n');
            fprintf('\tmiss:                     ');
            for i=1:3
                fprintf('%-8d',obj.(fnames{i}).miss);
            end
            fprintf('\n');            
            fprintf('\n');
%             if(length(log10C) > 1 || ~isinf(log10C))
%                 for i=1:length(log10C)
%                     fprintf('         R (%5.2f):  %4d R %4d P %4d T, %5.2f correct | %5.2f R\n',log10C(i),obj.matrix(i,:),obj.matrix(i,1)/obj.matrix(i,3),obj.matrix(i,1)/obj.matrix(i,3));
%                 end
%             end
%             if((length(log10C) >1 && isinf(log10C(end))) || (length(log10C)==1 && isinf(log10C)))
%                 fprintf('         P (%5.2f):  %4d R %4d P %4d T, %5.2f correct | %5.2f R\n',-Inf,obj.matrix(end,:),obj.matrix(end,2)/obj.matrix(end,3),obj.matrix(end,1)/obj.matrix(end,3));
%             end
%             fprintf('\n');
        end
    end
    
end

