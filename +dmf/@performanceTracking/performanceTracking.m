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
        responses
        abortMessages = cell(0);
        messageLength = 0;
    end
        
    
    methods
        
        %  Class constructor
        %
        %  use rewardedResponses array to initialize tracking properties
        function obj = performanceTracking(varargin)
            obj.responses = varargin{1};
            obj.fields = cell(1+length(obj.responses),1);
            obj.fields{1} = 'total';
            obj.fields(2:end) = obj.responses;
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
                obj.numTrialsAttempted.(outcome.rewardedResponse) = obj.numTrialsAttempted.(outcome.rewardedResponse) + 1;
                if(~outcome.trialAborted)
                    obj.numTrialsCompleted.total = obj.numTrialsCompleted.total+1;
                    obj.numTrialsCompleted.(outcome.rewardedResponse) = obj.numTrialsCompleted.(outcome.rewardedResponse)+1;
                    obj.numCorrect.total = obj.numCorrect.total + outcome.correct;
                    obj.numCorrect.(outcome.rewardedResponse) = obj.numCorrect.(outcome.rewardedResponse)+outcome.correct;
                    if(~isempty(outcome.response))
                        obj.responseFrequency.total.(outcome.response) = obj.responseFrequency.total.(outcome.response) + 1;
                        obj.responseFrequency.(outcome.rewardedResponse).(outcome.response) = obj.responseFrequency.(outcome.rewardedResponse).(outcome.response)+1;
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
            
            
            fieldWidth = floor(log10(obj.numTrialsAttempted.total))+1;
            
            %  Trials attempted
            fprintf('Trials attempted:\n');
            for i=1:length(obj.fields)
                fprintf('%10s:  (%*d/%*d) %0.2f\n',obj.fields{i},fieldWidth,obj.numTrialsCompleted.(obj.fields{i}),fieldWidth,obj.numTrialsAttempted.(obj.fields{i}),obj.numTrialsCompleted.(obj.fields{i})/max(1,obj.numTrialsAttempted.(obj.fields{i})));
            end            
            
            %  Propertion correct
            fprintf('Proportion correct:\n');
            for i=1:length(obj.fields)
                fprintf('%10s:  (%*d/%*d) %0.2f\n',obj.fields{i},fieldWidth,obj.numCorrect.(obj.fields{i}),fieldWidth,obj.numTrialsCompleted.(obj.fields{i}),obj.numCorrect.(obj.fields{i})/max(1,obj.numTrialsCompleted.(obj.fields{i})));
            end
            
            %  Response frequencies
            fprintf('Response frequencies:\n');
            for i=1:length(obj.fields)
                fprintf('%10s:  ',obj.fields{i});
                for j=1:length(obj.responses)
                    fprintf('(%*d/%*d) %0.2f ',fieldWidth,obj.responseFrequency.(obj.fields{i}).(obj.responses{j}),fieldWidth,obj.numTrialsCompleted.(obj.fields{i}),obj.responseFrequency.(obj.fields{i}).(obj.responses{j})/max(1,obj.numTrialsCompleted.(obj.fields{i})));
                end
                fprintf('\n');
            end
            
            %  Trial aborts
            if(~isempty(obj.abortMessages))
                fprintf('Trial aborts:\n');
                for i=1:length(obj.abortMessages)
                    fprintf('%*s:  %d\n',obj.messageLength+2,obj.abortMessages{i},obj.numAborts(i));
                end
            end
        end
    end
end