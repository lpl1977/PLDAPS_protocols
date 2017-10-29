function p = adjustableParameters(p,varargin)
%  PLDAPS SETUP FILE
%  PACKAGE:  dmf
%
%  This setup file is for the delayed match to feature task.  It contains
%  parameters which might be adjusted between trials (and are subject
%  dependent also).

if(nargin==1)
    
    %  Non state dependent steps--executed when we call this from the
    %  experiment setup function
    
    %  Left response:
    %  041 241 441  **Shape match
    %  140 142 144  **Color match
    %  141          **Co-incident shape and color match
    
    %  Center response:
    %  040 240 440
    %  042 242 442
    %  044 244 444
    %  143 341      **Conflicting shape and color match
    
    %  Right response:
    %  043 243 443  **Shape match
    %  340 342 344  **Color match
    %  343          **Co-incident shape and color match
    
    switch lower(p.trial.session.subject)
        case 'murray'
            colors = {'blue','scarlet','yellow'};
            patterns = {'solid'};
            shapes = {'triangle','diamond','pentagon'};
            
            p.functionHandles.selectionCodes.left = {'144'};
            p.functionHandles.selectionCodes.center = {'044','244','444'};
            p.functionHandles.selectionCodes.right = {'344'};
            %
            %             p.functionHandles.selectionCodes.left = {'441'};
            %             p.functionHandles.selectionCodes.center = {'440','442','444'};
            %             p.functionHandles.selectionCodes.right = {'443'};
            
            %             p.functionHandles.selectionCodes.left = {...
            %                 '140','142','144'};
            %             p.functionHandles.selectionCodes.center = {...
            %                 '040','240','440',...
            %                 '042','242','442',...
            %                 '044','244','444'};
            %             p.functionHandles.selectionCodes.right = {...
            %                 '340','342','344'};
            
            %             p.functionHandles.includedResponses = {'left','center','right'};
            %             p.functionHandles.selectionCodes.left = {...
            %                 '041','241','441'};
            %             p.functionHandles.selectionCodes.center = {...
            %                 '040','240','440',...
            %                 '042','242','442',...
            %                 '044','244','444'};
            %             p.functionHandles.selectionCodes.right = {...
            %                 '043','243','443'};
            
        case 'meatball'
            colors = {'blue','scarlet','yellow'};
            patterns = {'solid'};
            shapes = {'triangle','diamond','pentagon'};
            
            p.functionHandles.selectionCodes.left = {'144'};
            p.functionHandles.selectionCodes.center = {'044','244','444'};
            p.functionHandles.selectionCodes.right = {'344'};
            
            %             p.functionHandles.selectionCodes.left = {...
            %                 '140','142','144'};
            %             p.functionHandles.selectionCodes.center = {...
            %                 '040','240','440',...
            %                 '042','242','442',...
            %                 '044','244','444'};
            %             p.functionHandles.selectionCodes.right = {...
            %                 '340','342','344'};
            
        case 'splinter'
            p.functionHandles.selectionCodes.left = {'441'};
            p.functionHandles.selectionCodes.center = {'440','442','444'};
            p.functionHandles.selectionCodes.right = {'443'};
            
        case 'debug'
            colors = {'blue','scarlet','yellow'};
            patterns = {'solid','horizontalLines'};
            shapes = {'triangle','diamond','pentagon'};
            
            p.functionHandles.selectionCodes.left = {'144'};
            p.functionHandles.selectionCodes.center = {'044','244','444'};
            p.functionHandles.selectionCodes.right = {'344'};
            
            %             p.functionHandles.selectionCodes.left = {'414'};
            %             p.functionHandles.selectionCodes.center = {'404','424','444'};
            %             p.functionHandles.selectionCodes.right = {'434'};
            %
            %             p.functionHandles.selectionCodes.left = {'441'};
            %             p.functionHandles.selectionCodes.center = {'440','442','444'};
            %             p.functionHandles.selectionCodes.right = {'443'};
    end
    
    
    p.functionHandles.setObj = dmf.set('colors',colors,'patterns',patterns,'shapes',shapes);
    
else
    
    %  State dependent steps
    state = varargin{1};
    
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Here you could adjust windows, etc.
            switch lower(p.trial.session.subject)
                case 'murray'
                    p.functionHandles.eyePositionWindowManagerObj.useLogicalWindowing = false;
                                        
                    p.functionHandles.eyeLinkManagerObj.dotWidth = 20;
                    p.functionHandles.eyeLinkManagerObj.reward = 0.3;
                    
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols01 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols02 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols03 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols04 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols05 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols06 = [0 0 0];
                    p.functionHandles.graphicsManagerObj.stateConfig.response = [0 0 0];                    
                    
                    p.functionHandles.reinforcementRate = 1;
                    
                    %  Kludge to control sensitivity to analog stick
                    p.functionHandles.analogStickObj.pWidth = 1.25*p.functionHandles.analogStickObj.pWidth;
                    
                case 'meatball'
                    p.functionHandles.eyePositionWindowManagerObj.useLogicalWindowing = true;
                    
                    p.functionHandles.eyeLinkManagerObj.dotWidth = 20;
                    p.functionHandles.eyeLinkManagerObj.reward = 0.3;
                    
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols01 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols02 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols03 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols04 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols05 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols06 = [0 0 0];
                    p.functionHandles.graphicsManagerObj.stateConfig.response = [0 0 0];
                    
                    p.functionHandles.reinforcementRate = 1.0;
                    
                    %  Kludge to control sensitivity to analog stick
                    p.functionHandles.analogStickObj.pWidth = 1.25*p.functionHandles.analogStickObj.pWidth;
                    
                case 'splinter'
                case 'debug'
                    p.functionHandles.eyePositionWindowManagerObj.useLogicalWindowing = false;
                                        
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols01 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols02 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols03 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols04 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols05 = [1 1 1];
                    p.functionHandles.graphicsManagerObj.stateConfig.symbols06 = [0 0 0];
                    p.functionHandles.graphicsManagerObj.stateConfig.response = [0 0 0];
                    
                    %  Kludge to control gain on analogstick
                  %  p.functionHandles.analogStickObj.pWidth = 1.5*p.functionHandles.analogStickObj.pWidth;
                    
            end
            
        case p.trial.pldaps.trialStates.trialSetup
            
            %  Reward
            p.functionHandles.reward = 0.5;
            
            switch lower(p.trial.session.subject)
                case 'murray'
                    %  Careful!  Murray seems to boycott if the reward
                    %  volume is too low.  By giving him a variable
                    %  reinforcement schedule I can maintain reward volume
                    %  but drop his rate.
                    if(unifrnd(0,1)<=p.functionHandles.reinforcementRate)
                        p.functionHandles.reward = 0.5;
                    else
                        p.functionHandles.reward = 0;
                    end
                    p.functionHandles.stateTiming.hold = min(0.5,0.1 + exprnd(0.1));                                        
                    p.functionHandles.stateTiming.symbols01 = 0.4;
                    p.functionHandles.stateTiming.symbols02 = 0;
                    p.functionHandles.stateTiming.symbols03 = 0;
                    p.functionHandles.stateTiming.symbols04 = 0;
                    p.functionHandles.stateTiming.symbols05 = 0;
                    p.functionHandles.stateTiming.symbols06 = 0;
                    p.functionHandles.stateTiming.response = 10;
                    p.functionHandles.stateTiming.penalty = 2;
                    p.functionHandles.stateTiming.wait = unifrnd(0.1,0.2);
                    
                case 'meatball'
                    if(unifrnd(0,1)<=p.functionHandles.reinforcementRate)
                        p.functionHandles.reward = 0.5;
                    else
                        p.functionhandles.reward = 0;
                    end
                    p.functionHandles.stateTiming.hold = min(0.5,0.1 + exprnd(0.1));                    
                    p.functionHandles.stateTiming.symbols01 = 0.5;
                    p.functionHandles.stateTiming.symbols02 = 0;
                    p.functionHandles.stateTiming.symbols03 = 0;
                    p.functionHandles.stateTiming.symbols04 = 0;
                    p.functionHandles.stateTiming.symbols05 = 0;
                    p.functionHandles.stateTiming.symbols06 = 0;
                    p.functionHandles.stateTiming.response = 10;
                    p.functionHandles.stateTiming.penalty = 2;
                    p.functionHandles.stateTiming.wait = unifrnd(0.1,0.2);
                
                case 'splinter'
                    p.functionHandles.reward = 1.0;
                    p.functionHandles.stateTiming.hold = min(3,0.5 + exprnd(0.5));
                    p.functionHandles.stateTiming.wait = unifrnd(0.1,0.2);
                
                case 'debug'
                    p.functionHandles.reward = 0;
                    p.functionHandles.stateTiming.hold = min(0.5,0.1 + exprnd(0.1));
                    p.functionHandles.stateTiming.symbols01 = 0.5;
                    p.functionHandles.stateTiming.symbols02 = 0;
                    p.functionHandles.stateTiming.symbols03 = 0;
                    p.functionHandles.stateTiming.symbols04 = 0;
                    p.functionHandles.stateTiming.symbols05 = 0;
                    p.functionHandles.stateTiming.symbols06 = 0;
                    p.functionHandles.stateTiming.response = 10;
                    p.functionHandles.stateTiming.penalty = 2;
                    p.functionHandles.stateTiming.wait = unifrnd(0.1,0.2);
            end
    end
end
end
