classdef performance < handle
    %PERFORMANCE Class for keeping summary of performance on task
    %   Summary for outcomes of trials collected as a class as well as
    %   display functions
    
    properties
        attempted = 0;
        completed = struct('total',0,'set',[],'notset',0);
        correct = struct('total',0,'set',[],'notset',0);
        aborts
        log10C
    end
    
    methods
        %  Class constructor
        function obj = performance(log10C)
            obj.log10C = sort(log10C,'descend');
            obj.completed.set = zeros(numel(log10C),1);
            obj.correct.set = zeros(numel(log10C),1);
        end
        
        %  Create outcome for aborted trial and update performance
        function s = aborted_trial(obj,p,mssg)
            s = struct(...
                'completed',false,...
                'abort',struct(...
                'state',p.functionHandles.state_variables.trial_state,...
                'time',GetSecs - p.trial.trstart,...
                'message',mssg));
            
            mssg = strrep(mssg,' ','_');
            if(~isfield(obj.aborts,mssg))
                obj.aborts.(mssg) = 1;
            else
                obj.aborts.(mssg) = obj.aborts.(mssg) + 1;
            end
        end
        
        %  Create outcome for completed trial and update performance
        function s = completed_trial(obj,p,correct)
            s = struct(...
                'completed',true,...
                'correct',correct,...
                'reaction_time',p.trial.specs.timing.response_cue.reaction_time);
            
            ix = obj.log10C == p.trial.condition.log10C;
            
            obj.attempted = obj.attempted + 1;
            obj.completed.total = obj.completed.total + 1;
            switch p.trial.condition.sequence_type
                case 'set'
                    obj.completed.set(ix) = obj.completed.set(ix) + 1;
                case 'notset'
                    obj.completed.notset = obj.completed.notset + 1;
            end
            
            obj.correct.total = obj.correct.total + correct;
            switch p.trial.condition.sequence_type
                case 'set'
                    obj.correct.set(ix) = obj.correct.set(ix) + correct;
                case 'notset'
                    obj.correct.notset = obj.correct.notset + correct;
            end
        end
        
        %  Display summary performance on the task
        function display_performance(obj)
            
            %  Cumulative performance
            
            n1 = length(num2str(obj.completed.total));
            n2 = length(num2str(obj.attempted));
            
            fprintf('Cumulative performance:\n');
            fprintf('\tCompleted:  %*d of %*d attempted trials (%3.2f)\n',n1,obj.completed.total,n2,obj.attempted,obj.completed.total/obj.attempted);
            fprintf('\tCorrect:    %*d of %*d completed trials (%3.2f)\n',n1,obj.correct.total,n2,obj.completed.total,obj.correct.total/obj.completed.total);
            fprintf('\n');
            
            %  set / notset trials
            fprintf('Set trials:\n');
            for i=1:length(obj.log10C)
                fprintf('\t%5.2f %*d of %*d (%3.2f)\n',obj.log10C(i),n2,obj.correct.set(i),n2,obj.completed.set(i),obj.correct.set(i)/obj.completed.set(i));
            end
            fprintf('Notset trials:\n');
            fprintf('\t%5.2f %*d of %*d (%3.2f)\n',-Inf,n2,obj.correct.notset,n2,obj.completed.notset,obj.correct.notset/obj.completed.notset);
            fprintf('\n');
            
            %  Trial aborts
            if(isstruct(obj.aborts))
                fprintf('Trial aborts:\n');
                fnames = fieldnames(obj.aborts);
                nfields = length(fnames);
                nchar = zeros(nfields,1);
                for i=1:nfields
                    nchar(i) = length(fnames{i});
                end
                n3 = max(nchar)+1;
                
                for i=1:nfields
                    fprintf('%*s:  %*d\n',n3,strrep(fnames{i},'_',' '),n2,obj.aborts.(fnames{i}));
                end
                fprintf('\n');
            end
        end
    end
    
    methods (Static)
        
        %  Create outcome for interrupted trial and update performance
        function s = interrupted_trial(type)
            if(type==1)
                s = struct('interrupt','pause');
            else
                s = struct('interrupt','quit');
            end
        end
    end
end
