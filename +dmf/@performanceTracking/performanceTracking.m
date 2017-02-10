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
        trialTypes
        responses
        abortMessages = cell(0);
        messageLength = 0;
    end
    
    
    methods
        
        %  Class constructor
        %
        %  use rewardedResponses array to initialize tracking properties
        function obj = performanceTracking(varargin)
            obj.trialTypes = varargin{1};
            obj.responses = varargin{2};
            obj.fields = cell(1+length(obj.responses),1);
            obj.fields{1} = 'total';
            obj.fields(2:end) = strcat(obj.responses,obj.trialTypes);
            obj.trialTypes = unique(obj.trialTypes);
            obj.responses = unique(obj.responses);
            for i=1:length(obj.fields)
                obj.numTrialsAttempted.(obj.fields{i}) = 0;
                obj.numTrialsCompleted.(obj.fields{i}) = 0;
                obj.numCorrect.(obj.fields{i}) = 0;
                obj.responseFrequency.(obj.fields{i}) = cell2struct(cell(size(obj.responses)),obj.responses,2);
                for j=1:length(obj.responses)
                    obj.responseFrequency.(obj.fields{i}).(obj.responses{j}) = 0;
                end
            end
        end
        
        %  Update performance tracking
        function obj = update(obj,outcome)
            if(~outcome.trialInterrupted)
                obj.numTrialsAttempted.total = obj.numTrialsAttempted.total + 1;
                obj.numTrialsAttempted.(strcat(outcome.rewardedResponse,outcome.trialType)) = obj.numTrialsAttempted.(strcat(outcome.rewardedResponse,outcome.trialType)) + 1;
                if(~outcome.trialAborted)
                    obj.numTrialsCompleted.total = obj.numTrialsCompleted.total+1;
                    obj.numTrialsCompleted.(strcat(outcome.rewardedResponse,outcome.trialType)) = obj.numTrialsCompleted.(strcat(outcome.rewardedResponse,outcome.trialType))+1;
                    obj.numCorrect.total = obj.numCorrect.total + outcome.correct;
                    obj.numCorrect.(strcat(outcome.rewardedResponse,outcome.trialType)) = obj.numCorrect.(strcat(outcome.rewardedResponse,outcome.trialType))+outcome.correct;
                    if(~isempty(outcome.response))
                        obj.responseFrequency.total.(outcome.response) = obj.responseFrequency.total.(outcome.response) + 1;
                        obj.responseFrequency.(strcat(outcome.rewardedResponse,outcome.trialType)).(outcome.response) = obj.responseFrequency.(strcat(outcome.rewardedResponse,outcome.trialType)).(outcome.response)+1;
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
                fprintf('%*s:  (%*d/%*d) %0.2f\n',textFieldWidth,obj.fields{i},numFieldWidth,obj.numTrialsCompleted.(obj.fields{i}),numFieldWidth,obj.numTrialsAttempted.(obj.fields{i}),obj.numTrialsCompleted.(obj.fields{i})/max(1,obj.numTrialsAttempted.(obj.fields{i})));
            end
            fprintf('\n');
            
            %  Propertion correct
            fprintf('%*s:\n',textFieldWidth,'Proportion Correct');
            for i=1:length(obj.fields)
                fprintf('%*s:  (%*d/%*d) %0.2f\n',textFieldWidth,obj.fields{i},numFieldWidth,obj.numCorrect.(obj.fields{i}),numFieldWidth,obj.numTrialsCompleted.(obj.fields{i}),obj.numCorrect.(obj.fields{i})/max(1,obj.numTrialsCompleted.(obj.fields{i})));
            end
            fprintf('\n');
            
            %  Response frequencies
            fprintf('%*s:\n',textFieldWidth,'Response Frequencies');
            for i=1:length(obj.fields)
                fprintf('%*s:  ',textFieldWidth,obj.fields{i});
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