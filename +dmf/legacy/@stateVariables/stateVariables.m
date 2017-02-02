classdef stateVariables < handle
    %stateVariables State variables for trials of dmf
    %   All the state variables for controlling a trial
    
    properties
        currentState = '';
        nextState = 'start';
        
        rewardedResponse = struct('left',false,'center',false,'right',false);
        
        matchType
        
        displayPosition = struct('left',false,'center',false,'right',false);
        
        joystickEngaged
        
        joystickCenter = false;
        joystickLeft = false;
        joystickRight = false;
        
        joystickLateral = false;
        joystickMedial = true;
        joystickInRegion = false;
        joystickInRewardedRegion = false;

        joystickOvershot = false;
        
        showSymbol = struct('left',false,'center',false,'right',false);
        showCursor = false;
        showStimuli = false;
        
        rewardRemaining = 0;
        rewardReceived = 0;
        rewardElapsed = 0;
        rewardInProgress = false;
        
        rewardInRegionReceived = 0;
        rewardAtReturnReceived = 0;

        selectionInProgress = false;
        
        penaltyDuration
        timer = zeros(10,1);
        
        response
        penalty
        
        trialCorrect = false;
        trialCompleted = false;
    end
    
    properties (Hidden)
        bound
        displacementRange
        verticalThreshold
    end
    
    properties (Dependent = true)
        firstEntryIntoState
    end
    
    methods
        %  Class constructor method
        function obj = stateVariables(p)
            obj.rewardedResponse.left = strcmp('left',p.trial.condition.rewardedResponse);
            obj.rewardedResponse.center = strcmp('center',p.trial.condition.rewardedResponse);
            obj.rewardedResponse.right = strcmp('right',p.trial.condition.rewardedResponse);
            
            obj.matchType = p.trial.condition.matchType;
            
            obj.displayPosition.left = p.trial.condition.displayPosition.left;
            obj.displayPosition.center = p.trial.condition.displayPosition.center;
            obj.displayPosition.right = p.trial.condition.displayPosition.right;
            
            obj.bound = p.functionHandles.geometry.symbolRadius + 0.5*p.functionHandles.geometry.rewardRegionBuffer;
            obj.displacementRange = (p.functionHandles.geometry.symbolDisplacement + [-obj.bound obj.bound])/p.trial.display.pWidth;            
            obj.verticalThreshold = p.functionHandles.geometry.verticalThreshold;            
        end
        
        %  State transition control
        function outcome = get.firstEntryIntoState(obj)
            outcome = ~strcmpi(obj.nextState,obj.currentState);
            if(outcome)
                obj.currentState = obj.nextState;
            end
        end
        
        %  Update state variables
        function obj = update(obj,p)
            
            %  Normalized analog stick position
            normX = p.functionHandles.analogStick.normalizedXPosition;
            normY = p.functionHandles.analogStick.normalizedYPosition;
            
            %  First check whether or not the joystick is pressed far
            %  enough to trigger the engaged state.  If it is, then
            %  proceed with position and state checking.
            obj.joystickEngaged = normY < obj.verticalThreshold;
            
            if(obj.joystickEngaged)
                
                
                %  Check position with respect to center
                obj.joystickCenter = abs(xpos) < obj.bound;
                if(obj.joystickCenter)
                    obj.joystickInRegion = true;
                    obj.joystickInRewardedRegion = obj.rewardedResponse.center;
                    obj.joystickLeft = false;
                    obj.joystickRight = false;
                    obj.joystickLateral = false;
                    obj.joystickMedial = false;
                else
                    %  If not at center, where is the joystick?
                    obj.joystickLeft = xpos<0;
                    obj.joystickRight = ~obj.joystickLeft;
                    obj.joystickLateral = abs(xpos) > obj.displacementRange(2);
                    obj.joystickMedial = ~obj.joystickInRegion && ~obj.joystickLateral;
                    obj.joystickInRegion = prod(obj.displacementRange-abs(xpos))<=0;
                    obj.joystickInRewardedRegion = obj.joystickInRegion && ((obj.rewardedResponse.left && obj.joystickLeft) || (obj.rewardedResponse.right && obj.joystickRight));
                    if(~obj.joystickOvershot && obj.joystickLateral && obj.trialCompleted)
                        obj.joystickOvershot = true;
                    end
                end
            end
        end
        %  Commit the outcome to the total
        function obj = commitOutcome(obj,varargin)
            if(nargin==1)
                %  Monkey successfully completed the trial.  Was he
                %  correct, and what was his resposne?
                obj.trialCompleted = true;
                obj.trialCorrect = obj.joystickInRewardedRegion;
                if(obj.joystickLeft)
                    obj.response = 'left';
                elseif(obj.joystickRight)
                    obj.response = 'right';
                else
                    obj.response = 'center';
                end
            else
                obj.penalty = varargin{1};
            end
        end
        
        %  Update state variables related to reward
        function obj = rewardUpdate(obj,rewardDelta,rewardReceived,rewardElapsed)
            obj.rewardRemaining = max(0,obj.rewardRemaining + rewardDelta);
            obj.rewardReceived = obj.rewardReceived + rewardReceived;
            obj.rewardElapsed = obj.rewardElapsed + rewardElapsed;
        end
    end
    
end

