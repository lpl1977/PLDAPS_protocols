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
        numRepetitions
        responseFrequency
        numAborts
    end
    
    properties (Hidden)
        trackedOutcomes
        abortMessages = cell(0);
        messageLength = 0;
    end
    
    properties (Hidden,Constant)
        possibleResponses = {'total','left','center','right'};
    end
    
    
    methods
        
        %  Class constructor
        %
        %  use possibleResponses array to initialize tracking properties
        function obj = performanceTracking(varargin)
            for i=1:2:nargin
                obj.(varargin{i}) = varargin{i+1};
            end
            if(~isempty(obj.trackedOutcomes))
                obj.trackedOutcomes = strcat('trackedOutcomes',unique(obj.trackedOutcomes));
            end
            for i=1:length(obj.possibleResponses)
                obj.numTrialsAttempted.(obj.possibleResponses{i}) = 0;
                obj.numTrialsCompleted.(obj.possibleResponses{i}) = 0;
                obj.numCorrect.(obj.possibleResponses{i}) = 0;
                obj.numRepetitions.(obj.possibleResponses{i}) = 0;
                obj.responseFrequency.(obj.possibleResponses{i}) = struct('left',0,'center',0,'right',0);
            end
            for i=1:length(obj.trackedOutcomes)
                obj.numTrialsAttempted.(obj.trackedOutcomes{i}) = 0;
                obj.numTrialsCompleted.(obj.trackedOutcomes{i}) = 0;
                obj.numCorrect.(obj.trackedOutcomes{i}) = 0;
                obj.numRepetitions.(obj.trackedOutcomes{i}) = 0;
                obj.responseFrequency.(obj.trackedOutcomes{i}) = struct('left',0,'center',0,'right',0);
            end
        end
        
        %  Update performance tracking
        function obj = update(obj,outcome)
            if(~outcome.trialInterrupted && ~outcome.trialAborted)
                rewardedResponse = outcome.rewardedResponse;
                selectionCode = strcat('trackedOutcomes',outcome.selectionCode);
                if(outcome.repetitionNumber==0)
                    obj.numTrialsAttempted.total = obj.numTrialsAttempted.total + 1;
                    obj.numTrialsAttempted.(rewardedResponse) = obj.numTrialsAttempted.(rewardedResponse) + 1;
                    obj.numTrialsAttempted.(selectionCode) = obj.numTrialsAttempted.(selectionCode) + 1;
                    obj.numTrialsCompleted.total = obj.numTrialsCompleted.total+1;
                    obj.numTrialsCompleted.(rewardedResponse) = obj.numTrialsCompleted.(rewardedResponse)+1;
                    obj.numTrialsCompleted.(selectionCode) = obj.numTrialsCompleted.(selectionCode)+1;
                    obj.numCorrect.total = obj.numCorrect.total + outcome.correct;
                    obj.numCorrect.(rewardedResponse) = obj.numCorrect.(rewardedResponse)+outcome.correct;
                    obj.numCorrect.(selectionCode) = obj.numCorrect.(selectionCode)+outcome.correct;
                    obj.responseFrequency.total.(outcome.response) = obj.responseFrequency.total.(outcome.response) + 1;
                    obj.responseFrequency.(rewardedResponse).(outcome.response) = obj.responseFrequency.(rewardedResponse).(outcome.response)+1;
                    obj.responseFrequency.(selectionCode).(outcome.response) = obj.responseFrequency.(selectionCode).(outcome.response)+1;
                else
                    obj.numRepetitions.total = obj.numRepetitions.total + 1;
                    obj.numRepetitions.(rewardedResponse) = obj.numRepetitions.(rewardedResponse) + 1;
                    obj.numRepetitions.(selectionCode) = obj.numRepetitions.(selectionCode) + 1;
                end
            elseif(outcome.trialAborted)
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
        
        %  write to screen
        function obj = output(obj)
            
            %  Field widths
            numFieldWidth = floor(log10(obj.numTrialsAttempted.total))+1;
            textFieldWidth = 20;
            
            for i=1:length(obj.possibleResponses)
                textFieldWidth = max(textFieldWidth,length(obj.possibleResponses{i}));
            end
            for i=1:length(obj.trackedOutcomes)
                textFieldWidth = max(textFieldWidth,length(strrep(obj.trackedOutcomes{i},'trackedOutcomes','')));
            end
            
            %  Trials attempted
            fprintf('%*s:\n',textFieldWidth,'Trials Completed | Repeated');
            for i=1:length(obj.possibleResponses)
                fprintf('%*s:  (%*d/%*d) %0.2f | %d\n',textFieldWidth,obj.possibleResponses{i},numFieldWidth,obj.numTrialsCompleted.(obj.possibleResponses{i}),numFieldWidth,obj.numTrialsAttempted.(obj.possibleResponses{i}),obj.numTrialsCompleted.(obj.possibleResponses{i})/max(1,obj.numTrialsAttempted.(obj.possibleResponses{i})),obj.numRepetitions.(obj.possibleResponses{i}));
            end
            fprintf('\n');
            for i=1:length(obj.trackedOutcomes)
                fprintf('%*s:  (%*d/%*d) %0.2f | %d\n',textFieldWidth,strrep(obj.trackedOutcomes{i},'trackedOutcomes',''),numFieldWidth,obj.numTrialsCompleted.(obj.trackedOutcomes{i}),numFieldWidth,obj.numTrialsAttempted.(obj.trackedOutcomes{i}),obj.numTrialsCompleted.(obj.trackedOutcomes{i})/max(1,obj.numTrialsAttempted.(obj.trackedOutcomes{i})),obj.numRepetitions.(obj.trackedOutcomes{i}));
            end
            fprintf('\n');
            
            %  Propertion correct
            fprintf('%*s:\n',textFieldWidth,'Proportion Correct');
            for i=1:length(obj.possibleResponses)
                fprintf('%*s:  (%*d/%*d) %0.2f, p = %0.3g\n',textFieldWidth,obj.possibleResponses{i},numFieldWidth,obj.numCorrect.(obj.possibleResponses{i}),numFieldWidth,obj.numTrialsCompleted.(obj.possibleResponses{i}),obj.numCorrect.(obj.possibleResponses{i})/max(1,obj.numTrialsCompleted.(obj.possibleResponses{i})),binocdf(obj.numCorrect.(obj.possibleResponses{i}),max(1,obj.numTrialsCompleted.(obj.possibleResponses{i})),1/3,'upper'));
            end
            fprintf('\n');
            for i=1:length(obj.trackedOutcomes)
                fprintf('%*s:  (%*d/%*d) %0.2f, p = %0.3g\n',textFieldWidth,strrep(obj.trackedOutcomes{i},'trackedOutcomes',''),numFieldWidth,obj.numCorrect.(obj.trackedOutcomes{i}),numFieldWidth,obj.numTrialsCompleted.(obj.trackedOutcomes{i}),obj.numCorrect.(obj.trackedOutcomes{i})/max(1,obj.numTrialsCompleted.(obj.trackedOutcomes{i})),binocdf(obj.numCorrect.(obj.trackedOutcomes{i}),max(1,obj.numTrialsCompleted.(obj.trackedOutcomes{i})),1/3,'upper'));
            end
            fprintf('\n');
            
            %  Response frequencies
            fprintf('%*s:  ',textFieldWidth,'Response Frequencies');
            for i=2:length(obj.possibleResponses)
                fprintf('%-*s ',2*numFieldWidth+8,obj.possibleResponses{i});
            end
            fprintf('\n');
            for i=1:length(obj.possibleResponses)
                fprintf('%*s:  ',textFieldWidth,obj.possibleResponses{i});
                for j=2:length(obj.possibleResponses)
                    fprintf('(%*d/%*d) %0.2f ',numFieldWidth,obj.responseFrequency.(obj.possibleResponses{i}).(obj.possibleResponses{j}),numFieldWidth,obj.numTrialsCompleted.(obj.possibleResponses{i}),obj.responseFrequency.(obj.possibleResponses{i}).(obj.possibleResponses{j})/max(1,obj.numTrialsCompleted.(obj.possibleResponses{i})));
                end
                fprintf('\n');
            end
            fprintf('\n');
            for i=1:length(obj.trackedOutcomes)
                fprintf('%*s:  ',textFieldWidth,strrep(obj.trackedOutcomes{i},'trackedOutcomes',''));
                for j=2:length(obj.possibleResponses)
                    fprintf('(%*d/%*d) %0.2f ',numFieldWidth,obj.responseFrequency.(obj.trackedOutcomes{i}).(obj.possibleResponses{j}),numFieldWidth,obj.numTrialsCompleted.(obj.trackedOutcomes{i}),obj.responseFrequency.(obj.trackedOutcomes{i}).(obj.possibleResponses{j})/max(1,obj.numTrialsCompleted.(obj.trackedOutcomes{i})));
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