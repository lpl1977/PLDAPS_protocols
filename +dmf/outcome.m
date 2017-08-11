classdef outcome < handle
    %outcome object for recording trial outcome
    %
    %  Lee Lovejoy
    %  January 27, 2017
    %  ll2833@columbia.edu
    
    properties (SetAccess = private)
        trialNumber
        response
        responseTime
        rewardedResponse
        rewardDuration
        trialAborted = false;
        abortState
        abortTime
        abortMessage
        trialInterrupted = false;
        interruptMessage
        correctionLoopTrial
        selectionCode
    end
    
    properties (Dependent)
        correct
        trialCompleted
        responseRecorded
    end
    
    methods
        
        %  Class constructor
        function obj = outcome(varargin)
            for i=1:2:nargin
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        
        %  recordResponse
        function obj = recordResponse(obj,varargin)
            for i=1:2:nargin-1
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.trialAborted = false;
            obj.trialInterrupted = false;
        end
        
        %  recordAborts
        function obj = recordAbort(obj,varargin)
            obj.trialAborted = true;
            for i=1:2:nargin-1
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        
        %  recordInterrupts
        function obj = recordInterrupt(obj,varargin)
            obj.trialInterrupted = true;
            for i=1:2:nargin-1
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        
        %  Get function for correct
        function outcome = get.correct(obj)
            if(isempty(obj.response))
                outcome = [];
            else
                outcome = strcmpi(obj.response,obj.rewardedResponse);
            end
        end
        
        %  Get function for trialCompleted
        function outcome = get.trialCompleted(obj)
            outcome = ~(obj.trialAborted || obj.trialInterrupted);
        end                
        
        %  Get function for responseRecorded
        function outcome = get.responseRecorded(obj)
            outcome = ~isempty(obj.response);
        end
        
        %  commit
        %
        %  commit the trial outcome to output
        function output = commit(obj)
            output.trialNumber = obj.trialNumber;
            output.rewardedResponse = obj.rewardedResponse;
            output.rewardDuration = obj.rewardDuration;
            output.correctionLoopTrial = obj.correctionLoopTrial;
            if(obj.trialAborted)
                output.abortState = obj.abortState;
                output.abortTime = obj.abortTime;
                output.abortMessage = obj.abortMessage;
            elseif(obj.trialInterrupted)
                output.interruptMessage = obj.interruptMessage;
            else
                output.response = obj.response;
                output.correct = obj.correct;
            end
        end
    end    
end

