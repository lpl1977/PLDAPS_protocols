function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  eyeLinkCalibration

%  This setup file is for checking the eyeLink calibration

%  Set trial master function
p.trial.pldaps.trialFunction = 'eyeLinkCalibration.trialFunction';

%  Get default colors and put the default bit names
defaultColors(p);
defaultBitNames(p);

% Dot sizes for drawing (included so PLDAPS doesn't barf)
p.trial.stimulus.eyeW = 8;      % eye indicator width in pixels (for console display)
p.trial.stimulus.cursorW = 8;   % cursor width in pixels (for console display)

%  Custom colors that I have defined
LovejoyDefaultColors(p);

%  Trial duration information.  Trials shouldn't be longer than 5 minutes.
p.trial.pldaps.maxTrialLength = 5*60;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
        
%  Conditions
c = cell(1);
c.xPos = [959 115 115 959 1803 959 115 1803 1803];
c.yPos = [539 539 91 987 987 91 987 539 91];
p.conditions = cell(10,1);

%  Session termination criteria--set finish to Inf because we are using the
%  trial manager
p.trial.pldaps.finish = Inf;

%  Initialize trial management
p.functionHandles.trialManagerObj = trialManager(...
    'conditions',c,...
    'useSequentialErrorTracking',false);

%  Initialize reward manager
p.functionHandles.rewardManagerObj = rewardManager('systemName','datapixx','systemParams',{'sampleRate',1000','ttlAmp',5,'channel',3});

%  Initialize window manager for eye position
p.functionHandles.eyeWindowManagerObj = windowManager(...
    'overlayPtr',p.trial.display.overlayptr,...
    'displayAreaSize',p.trial.display.winRect,...
    'displayAreaLocation',p.trial.display.ctr([1 2]),...
    'useDisplayAreaOutline',false,...
    'useNormalizedPosition',false,...
    'useTrajectoryTrace',false,...
    'useCurrentPosition',false,...
    'trajectoryColor',p.trial.display.clut.hWhite,...
    'currentColor',p.trial.display.clut.hGreen,...
    'borderColor',p.trial.display.clut.hCyan,...
    'activeWindowColor',p.trial.display.clut.hRed,...
    'enabledWindowColor',p.trial.display.clut.hBlue,...
    'disabledWindowColor',p.trial.display.clut.hBlack);

%  Geometry of stimuli
p.functionHandles.geometry.targetWindow = [0 0 10 10];

% 
% %  Initialize window manager for analog stick
% p.functionHandles.analogStickWindowManagerObj = windowManager(...
%             'windowPtr',p.trial.display.overlayptr,...
%             'displayAreaSize',[300 300],...
%             'displayAreaCenter',[200 800],...
%             'trajectoryColor',p.trial.display.clut.hWhite,...
%             'currentColor',p.trial.display.clut.hGreen,...
%             'borderColor',p.trial.display.clut.hCyan,...
%             'activeWindowColor',p.trial.display.clut.hRed,...
%             'enabledWindowColor',p.trial.display.clut.hBlue,...
%             'disabledWindowColor',p.trial.display.clut.hBlack);

% %  Geometry of stimuli
% p.functionHandles.geometry.symbolDisplacement = 350;
% p.functionHandles.geometry.symbolRadius = 150;
% p.functionHandles.geometry.center = p.trial.display.ctr(1:2);
% p.functionHandles.geometry.symbolCenters = [...
%     p.functionHandles.geometry.center(1)-p.functionHandles.geometry.symbolDisplacement p.functionHandles.geometry.center(2);...
%     p.functionHandles.geometry.center(1) p.functionHandles.geometry.center(2); ...
%     p.functionHandles.geometry.center(1)+p.functionHandles.geometry.symbolDisplacement p.functionHandles.geometry.center(2)];
% 
% %  Symbol features
% p.functionHandles.features.symbolRadius = p.functionHandles.geometry.symbolRadius;

%  Background color
%p.functionHandles.colors.background = p.trial.display.bgColor;

% %  Cursor colors
% p.functionHandles.colors.cursor.start = [0 0 0];
% p.functionHandles.colors.cursor.engage = [0 0.8 0];
% p.functionHandles.colors.cursor.hold = [0.8 0.8 0.8];
% p.functionHandles.colors.cursor.symbols = p.functionHandles.colors.cursor.hold;
% p.functionHandles.colors.cursor.delay = p.functionHandles.colors.cursor.hold;
% p.functionHandles.colors.cursor.response = [0 0 0];
% p.functionHandles.colors.cursor.commit = [0 0 0];
% p.functionHandles.colors.cursor.warning = [0.8 0 0];
% p.functionHandles.colors.cursor.return = [0 0 0];
% p.functionHandles.colors.cursor.penalty = [0 0 0];
% p.functionHandles.colors.cursor.reward = [0 0 0];
% p.functionHandles.colors.cursor.error = [0 0 0];
% 
% %  Timing
% p.functionHandles.timing.responseDuration = 10;
% p.functionHandles.timing.rewardDuration = 0.7;
% p.functionHandles.timing.errorDuration = p.functionHandles.timing.rewardDuration;
% p.functionHandles.timing.errorPenaltyDuration = 2;
% p.functionHandles.timing.penaltyDuration = 10;
% p.functionHandles.timing.holdDelay = 0;
% p.functionHandles.timing.presentationDuration = 0;
% p.functionHandles.timing.delayDuration = 0.1;
% p.functionHandles.timing.probeDuration = 0;
% 
% p.functionHandles.stateTiming.hold = 0.1;
% p.functionHandles.stateTiming.proposition = 0.5;
% p.functionHandles.stateTiming.postPropositionDelay = 0.5;
% p.functionHandles.stateTiming.argument = 0.5;
% p.functionHandles.stateTiming.postArgumentDelay = 0.5;
% p.functionHandles.stateTiming.response = 10;
% p.functionHandles.stateTiming.commit = 2*p.trial.display.ifi;
% p.functionHandles.stateTiming.reward = 0.7;
% p.functionHandles.stateTiming.error = 0.7;
% p.functionHandles.stateTiming.penalty = 2;
% 
% %  Set subject dependent parameters
% dmf.adjustableParameters(p);

%
%  CONDITIONS
%

% %  Possibilities currently defined:
% %  colors:  {'blue','orange','yellow','purple','green','cyan','scarlet'}
% %  patterns:  {'solid','hollow','horizontalLines','verticalLines'}
% %  shapes:  {'circle','square','diamond','triangle','pentagon','hexagon'}
% % 
% % colors = {'blue','scarlet','yellow'};
% % patterns = {'solid'};
% % shapes = {'triangle','diamond','pentagon'};
% 
% %p.functionHandles.setObj = dmf.set('colors',colors,'patterns',patterns,'shapes',shapes);
% 
% [selectedSets.left,setSymbolCodes.left,selectionCodes.left,matchedFeatures.left] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.left);
% [selectedSets.right,setSymbolCodes.right,selectionCodes.right,matchedFeatures.right] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.right);
% [selectedSets.center,setSymbolCodes.center,selectionCodes.center,matchedFeatures.center] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.center); 
% 
% nSetsPerResponse = lcm(lcm(size(selectedSets.left,1),size(selectedSets.right,1)),size(selectedSets.center,1));
% selectedSets.left = repmat(selectedSets.left,nSetsPerResponse/size(selectedSets.left,1),1);
% selectedSets.right = repmat(selectedSets.right,nSetsPerResponse/size(selectedSets.right,1),1);
% selectedSets.center = repmat(selectedSets.center,nSetsPerResponse/size(selectedSets.center,1),1);
% 
% selectionCodes.left = repmat(selectionCodes.left,nSetsPerResponse/size(selectionCodes.left,1),1);
% selectionCodes.right = repmat(selectionCodes.right,nSetsPerResponse/size(selectionCodes.right,1),1);
% selectionCodes.center = repmat(selectionCodes.center,nSetsPerResponse/size(selectionCodes.center,1),1);
% 
% setSymbolCodes.left = repmat(setSymbolCodes.left,nSetsPerResponse/size(setSymbolCodes.left,1),1);
% setSymbolCodes.right = repmat(setSymbolCodes.right,nSetsPerResponse/size(setSymbolCodes.right,1),1);
% setSymbolCodes.center = repmat(setSymbolCodes.center,nSetsPerResponse/size(setSymbolCodes.center,1),1);
% 
% matchedFeatures.left = repmat(matchedFeatures.left,nSetsPerResponse/size(matchedFeatures.left,1),1);
% matchedFeatures.right = repmat(matchedFeatures.right,nSetsPerResponse/size(matchedFeatures.right,1),1);
% matchedFeatures.center = repmat(matchedFeatures.center,nSetsPerResponse/size(matchedFeatures.center,1),1);
% 
% p.functionHandles.possibleResponses = {'left','center','right'};
% if(~isfield(p.functionHandles,'includedResponses'))
%     p.functionHandles.includedResponses = unique(p.functionHandles.possibleResponses);
% end
% 
% c = cell(nSetsPerResponse*numel(p.functionHandles.includedResponses),1);
% for i=1:length(p.functionHandles.includedResponses)
%     for j=1:nSetsPerResponse
%         c{(i-1)*nSetsPerResponse+j}.selectedSet = selectedSets.(p.functionHandles.includedResponses{i})(j,:);
%         c{(i-1)*nSetsPerResponse+j}.setSymbolCode = setSymbolCodes.(p.functionHandles.includedResponses{i}){j};
%         c{(i-1)*nSetsPerResponse+j}.rewardedResponse = p.functionHandles.includedResponses{i};
%         c{(i-1)*nSetsPerResponse+j}.selectionCode = selectionCodes.(p.functionHandles.includedResponses{i}){j};
%         c{(i-1)*nSetsPerResponse+j}.matchedFeatures = matchedFeatures.(p.functionHandles.includedResponses{i}){j};
%     end
% end
% p.conditions = cell(numel(c)*10,1);
% 
% %  Session termination criteria--set finish to Inf because we are using the
% %  trial manager
% p.trial.pldaps.finish = Inf;
% 
% %  Generate symbol textures
% p.functionHandles.graphicsManagerObj = dmf.graphicsManager(...
%     'symbolFeatures',p.functionHandles.setObj.symbolFeatures,...
%     'symbolCodes',p.functionHandles.setObj.symbolCodes,...
%     'symbolRadius',p.functionHandles.features.symbolRadius,...
%     'symbolCenters',p.functionHandles.geometry.symbolCenters,...
%     'colorLibrary',p.trial.display.colors,...
%     'windowPtr',p.trial.display.ptr,...
%     'nLines',8,...
%     'borderWidth',2,...
%     'stateConfig',{'symbols01',[1 1 1],'delay01',[1 1 1],'symbols02',[1 1 1],'delay02',[1 1 1],'symbols03',[1 1 1],'delay03',[1 1 1],'response',[1 1 1],'commit',[1 1 1],'return',[1 1 1]});
% 
% %  Initialize trial management
% p.functionHandles.trialManagerObj = trialManager('conditions',c,'maxSequentialErrors',3,'numDecks',2);
% p.functionHandles.trialManagerObj.tokenize('selectionCode','matchedFeatures');
% 
% %  Initialize performance tracking
% p.functionHandles.performanceTrackingObj = dmf.performanceTracking(...
%     'trackedOutcomes',[p.functionHandles.selectionCodes.left p.functionHandles.selectionCodes.center p.functionHandles.selectionCodes.right]);
% p.functionHandles.performanceTrackingObj.tallyTrials(p.functionHandles.trialManagerObj.conditions);
% 
% %  Initialize reward maanger
% p.functionHandles.rewardManagerObj = rewardManager('systemName','datapixx','systemParams',{'sampleRate',1000','ttlAmp',5,'channel',3});
% 
% %  Initialize window manager for analog stick
% p.functionHandles.analogStickWindowManagerObj = windowManager(...
%             'windowPtr',p.trial.display.overlayptr,...
%             'displayAreaSize',[300 300],...
%             'displayAreaCenter',[200 800],...
%             'trajectoryColor',p.trial.display.clut.hWhite,...
%             'currentColor',p.trial.display.clut.hGreen,...
%             'borderColor',p.trial.display.clut.hCyan,...
%             'activeWindowColor',p.trial.display.clut.hRed,...
%             'enabledWindowColor',p.trial.display.clut.hBlue,...
%             'disabledWindowColor',p.trial.display.clut.hBlack);
