classdef outcome < handle
    %outcome object for recording trial outcome
    %
    %  Lee Lovejoy
    %  January 27, 2017
    %  ll2833@columbia.edu
    
    properties (SetAccess = private)
        trialNumber
        repetitionNumber = 0;
        selectionCode
        response
        responseTime
        rewardedResponse
        trialAborted = false;
        abortState
        abortTime
        abortMessage
        trialInterrupted = false;
        interruptMessage
    end
    
    properties (Dependent)
        correct
        trialCompleted
    end
    
    properties (Hidden)
        responseLog = struct('response',[],'responseTime',[],'correct',[]);
        numResponses = 0;
    end
    
    methods
        
        %  Class constructor
        function obj = outcome(varargin)
            for i=1:2:nargin
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        
        %  trial response
        function obj = recordResponse(obj,response)
            obj.response = response;
            obj.responseTime = GetSecs;
            
            obj.numResponses = obj.numResponses+1;
            obj.responseLog.response{obj.numResponses} = obj.response;
            obj.responseLog.responseTime(obj.numResponses) = obj.responseTime;
            obj.responseLog.correct(obj.numResponses) = obj.correct;

            obj.trialAborted = false;
            obj.trialInterrupted = false;
        end
        
        %  Trial aborts
        function obj = recordAbort(obj,varargin)
            obj.abortState = varargin{1};
            obj.trialAborted = true;
            obj.abortTime = GetSecs;
            if(nargin > 1)
                obj.abortMessage = varargin{2};
            end
        end
        
        %  Trial interrupts
        function obj = recordInterrupt(obj,varargin)
            obj.trialInterrupted = true;
            if(nargin>1)
                obj.interruptMessage = varargin{1};
            end
        end
        
        %  Trial correct?
        function outcome = get.correct(obj)
            if(isempty(obj.response))
                outcome = [];
            else
                outcome = strcmpi(obj.response,obj.rewardedResponse);
            end
        end
        
        %  Trial completed?
        function outcome = get.trialCompleted(obj)
            outcome = ~(obj.trialAborted || obj.trialInterrupted);
        end
                
        
        %  commit
        %
        %  commit the trial outcome to output
        function output = commit(obj)
            output.trialNumber = obj.trialNumber;
            output.selectionCode = obj.selectionCode;
            output.rewardedResponse = obj.rewardedResponse;
            output.repetitionNumber = obj.repetitionNumber;
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
            output.responseLog = obj.responseLog;
        end
    end    
end

