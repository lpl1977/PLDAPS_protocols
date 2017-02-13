classdef performanceTracking < handle
    %performanceTracking object for tracking performance on task
    %
    %  Lee Lovejoy
    %  January 2017
    %  ll2833@columbia.edu
    
    properties
        numTrialsAttempted
        numTrialsCompleted
        numCorrect
        responseFrequency
        numAborts
    end
    
    properties (Hidden)
        fields
        satisfiedRules
        responses
        abortMessages = cell(0);
        messageLength = 0;
    end
    
    
    methods
        
        %  Class constructor
        %
        %  use rewardedResponses array to initialize tracking properties
        function obj = performanceTracking(varargin)
            obj.satisfiedRules = varargin{1};
            obj.responses = varargin{2};
            obj.fields = cell(1+length(obj.responses),1);
            obj.fields{1} = 'total';
            obj.fields(2:end) = strcat(obj.responses,'_',obj.satisfiedRules);
            obj.satisfiedRules = unique(obj.satisfiedRules);
            obj.responses = unique(obj.responses);
            for i=1:length(obj.fields)
                obj.numTrialsAttempted.(obj.fields{i}) = 0;
                obj.numTrialsCompleted.(obj.fields{i}) = 0;
                obj.numCorrect.(obj.fields{i}) = 0;
                obj.responseFrequency.(obj.fields{i}) = cell2struct(cell(size(obj.responses)),obj.responses,1);
                for j=1:length(obj.responses)
                    obj.responseFrequency.(obj.fields{i}).(obj.responses{j}) = 0;
                end
            end
        end
        
        %  Update performance tracking
        function obj = update(obj,outcome)
            if(~outcome.trialInterrupted)
                field = strcat(outcome.rewardedResponse,'_',outcome.satisfiedRule);
                obj.numTrialsAttempted.total = obj.numTrialsAttempted.total + 1;
                obj.numTrialsAttempted.(field) = obj.numTrialsAttempted.(field) + 1;
                if(~outcome.trialAborted)
                    obj.numTrialsCompleted.total = obj.numTrialsCompleted.total+1;
                    obj.numTrialsCompleted.(field) = obj.numTrialsCompleted.(field)+1;
                    obj.numCorrect.total = obj.numCorrect.total + outcome.correct;
                    obj.numCorrect.(field) = obj.numCorrect.(field)+outcome.correct;
                    if(~isempty(outcome.response))
                        obj.responseFrequency.total.(outcome.response) = obj.responseFrequency.total.(outcome.response) + 1;
                        obj.responseFrequency.(field).(outcome.response) = obj.responseFrequency.(field).(outcome.response)+1;
                    end
                else
                    ix = strcmp(outcome.abortMessage,obj.abortMessages);
                    if(any(ix))
                        obj.numAborts(ix) = obj.numAborts(ix)+1;
                    else
                        obj.abortMessages{end+1} = outcome.abortMessage;
                        obj.numAborts(end+1) = 1;
                        obj.messageLength = max(obj.messageLength,length(outcome.abortMessage));
                    end
                end
            end
        end
        
        %  write to screen
        function obj = output(obj)
            
            %  Field widths
            numFieldWidth = floor(log10(obj.numTrialsAttempted.total))+1;
            textFieldWidth = 20;
            for i=1:length(obj.fields)
                textFieldWidth = max(textFieldWidth,length(obj.fields{i}));
            end
            
            %  Trials attempted
            fprintf('%*s:\n',textFieldWidth,'Trials Attempted');
            for i=1:length(obj.fields)
                fprintf('%*s:  (%*d/%*d) %0.2f\n',textFieldWidth,strrep(obj.fields{i},'_',' '),numFieldWidth,obj.numTrialsCompleted.(obj.fields{i}),numFieldWidth,obj.numTrialsAttempted.(obj.fields{i}),obj.numTrialsCompleted.(obj.fields{i})/max(1,obj.numTrialsAttempted.(obj.fields{i})));
            end
            fprintf('\n');
            
            %  Propertion correct
            fprintf('%*s:\n',textFieldWidth,'Proportion Correct');
            for i=1:length(obj.fields)
                fprintf('%*s:  (%*d/%*d) %0.2f\n',textFieldWidth,strrep(obj.fields{i},'_',' '),numFieldWidth,obj.numCorrect.(obj.fields{i}),numFieldWidth,obj.numTrialsCompleted.(obj.fields{i}),obj.numCorrect.(obj.fields{i})/max(1,obj.numTrialsCompleted.(obj.fields{i})));
            end
            fprintf('\n');
            
            %  Response frequencies
            fprintf('%*s:  ',textFieldWidth,'Response Frequencies');
            for j=1:length(obj.responses)
                fprintf('%-*s ',2*numFieldWidth+8,obj.responses{j});
            end
            fprintf('\n');
            for i=1:length(obj.fields)
                fprintf('%*s:  ',textFieldWidth,strrep(obj.fields{i},'_',' '));
                for j=1:length(obj.responses)
                    fprintf('(%*d/%*d) %0.2f ',numFieldWidth,obj.responseFrequency.(obj.fields{i}).(obj.responses{j}),numFieldWidth,obj.numTrialsCompleted.(obj.fields{i}),obj.responseFrequency.(obj.fields{i}).(obj.responses{j})/max(1,obj.numTrialsCompleted.(obj.fields{i})));
                end
                fprintf('\n');
            end
            fprintf('\n');
            
            %  Trial aborts
            if(~isempty(obj.abortMessages))
                fprintf('%*s:\n',textFieldWidth,'Trial Aborts');
                for i=1:length(obj.abortMessages)
                    fprintf('%*s:  %d\n',obj.messageLength+2,obj.abortMessages{i},obj.numAborts(i));
                end
            end
        end
    end
end