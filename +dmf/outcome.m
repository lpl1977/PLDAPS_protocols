classdef outcome < handle
    %outcome object for recording trial outcome
    %
    %  Lee Lovejoy
    %  January 27, 2017
    %  ll2833@columbia.edu
    
    properties (SetAccess = private)
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
    end
    
    methods
        
        %  Class constructor
        function obj = outcome(varargin)
            obj.rewardedResponse = varargin{1};
        end
        
        %  trial response
        function obj = recordResponse(obj,response)
            obj.response = response;
            obj.responseTime = GetSecs;
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
        
        function outcome = get.correct(obj)
            if(isempty(obj.response))
                outcome = [];
            else
                outcome = strcmpi(obj.response,obj.rewardedResponse);
            end
        end
        
        function output = commit(obj)
            if(obj.trialAborted)
                output.abortState = obj.abortState;
                output.abortTime = obj.abortTime;
                output.abortMessage = obj.abortMessage;
            elseif(obj.trialInterrupted)
                output.interruptMessage = obj.interruptMessage;
            else
                output.response = obj.response;
                output.rewardedResponse = obj.rewardedResponse;
                output.correct = obj.correct;
            end
        end
    end    
end

