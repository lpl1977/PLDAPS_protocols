classdef performance < handle
    %PERFORMANCE Class for keeping summary of performance on task
    %   Summary for outcomes of trials collected as a class as well as
    %   display functions
    %
    %  There are two trial types:  set and notset
    %  Contrasts are in log10C; only set trials have varying contrast
    %
    %  I would like to see total number of attempts, total completed, total
    %  correct, performance by trial type and contrast, and total aborts
    
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
        
        %  Update with an outcome
        function update(obj,condition,outcome)
            ix = obj.log10C == condition.log10C;
            
            if(isfield(outcome,'completed'))
                obj.attempted = obj.attempted + 1;
                obj.completed.total = obj.completed.total + outcome.completed;
                switch condition.sequence_type
                    case 'set'
                        obj.completed.set(ix) = obj.completed.set(ix) + outcome.completed;
                    case 'notset'
                        obj.completed.notset = obj.completed.notset + outcome.completed;
                end
                
                if(outcome.completed)
                    obj.correct.total = obj.correct.total + outcome.correct;
                    switch condition.sequence_type
                        case 'set'
                            obj.correct.set(ix) = obj.correct.set(ix) + outcome.correct;
                        case 'notset'
                            obj.correct.notset = obj.correct.notset + outcome.correct;
                    end
                else
                    mssg = strrep(outcome.abort.message,' ','_');
                    if(~isfield(obj.aborts,mssg))
                        obj.aborts.(mssg) = 1;
                    else
                        obj.aborts.(mssg) = obj.aborts.(mssg) + 1;
                    end
                end
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
end
