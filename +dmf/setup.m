function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  dmf

%  This setup file is for the delayed match to feature task.  Individual
%  training steps can be controlled via subject specific files.

%  Set trial master function
p.trial.pldaps.trialFunction = 'dmf.trialFunction';

%  Get default colors and put the default bit names
defaultColors(p);
defaultBitNames(p);

% Dot sizes for drawing
p.trial.stimulus.eyeW = 8;      % eye indicator width in pixels (for console display)
p.trial.stimulus.cursorW = 8;   % cursor width in pixels (for console display)

%  Custom colors that I have defined
LovejoyDefaultColors(p);

%  Trial duration information--he'll have 5 minutes to figure it out per
%  trial
p.trial.pldaps.maxTrialLength = 5*60;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Geometry of stimuli
p.functionHandles.geometry.symbolDisplacement = 350;
p.functionHandles.geometry.symbolRadius = 150;
p.functionHandles.geometry.center = p.trial.display.ctr(1:2);
p.functionHandles.geometry.symbolCenters = [...
    p.functionHandles.geometry.center(1)-p.functionHandles.geometry.symbolDisplacement p.functionHandles.geometry.center(2);...
    p.functionHandles.geometry.center(1) p.functionHandles.geometry.center(2); ...
    p.functionHandles.geometry.center(1)+p.functionHandles.geometry.symbolDisplacement p.functionHandles.geometry.center(2)];

%  Symbol features
p.functionHandles.features.symbolRadius = p.functionHandles.geometry.symbolRadius;
p.functionHandles.features.nSpatialCycles = 16;
p.functionHandles.features.nThetaCycles = 8;

%  Background color
p.functionHandles.colors.background = p.trial.display.bgColor;

%  Cursor colors
p.functionHandles.colors.cursor.start = [0 0 0];
p.functionHandles.colors.cursor.engage = [0 0.8 0];
p.functionHandles.colors.cursor.hold = [0.8 0.8 0.8];
p.functionHandles.colors.cursor.proposition = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.postPropositionDelay = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.argument = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.postArgumentDelay = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.presentation = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.presentation = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.presentation = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.delay = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.probe = p.functionHandles.colors.cursor.hold;
p.functionHandles.colors.cursor.response = [0 0 0];
p.functionHandles.colors.cursor.warning = [0.8 0 0];
p.functionHandles.colors.cursor.return = [0 0 0];
p.functionHandles.colors.cursor.penalty = [0 0 0];
p.functionHandles.colors.cursor.reward = [0 0 0];
p.functionHandles.colors.cursor.error = [0 0 0];

%  Pedestal color
p.functionHandles.colors.pedestal = [0.4 0.4 0.4];
p.functionHandles.features.pedestalRadius = p.functionHandles.features.symbolRadius + 20;


%  Timing
p.functionHandles.timing.responseDuration = 10;
p.functionHandles.timing.rewardDuration = 0.7;
p.functionHandles.timing.errorDuration = p.functionHandles.timing.rewardDuration;
p.functionHandles.timing.errorPenaltyDuration = 2;
p.functionHandles.timing.penaltyDuration = 10;
p.functionHandles.timing.holdDelay = 0;
p.functionHandles.timing.presentationDuration = 0;
p.functionHandles.timing.delayDuration = 0.1;
p.functionHandles.timing.probeDuration = 0;

p.functionHandles.stateTiming.hold = 0.1;
p.functionHandles.stateTiming.proposition = 0.5;
p.functionHandles.stateTiming.postPropositionDelay = 0.5;
p.functionHandles.stateTiming.argument = 0.5;
p.functionHandles.stateTiming.postArgumentDelay = 0.5;
p.functionHandles.stateTiming.response = 10;
p.functionHandles.stateTiming.reward = 0.7;
p.functionHandles.stateTiming.error = 0.7;
p.functionHandles.stateTiming.penalty = 2;

%  Set subject dependent parameters
dmf.adjustableParameters(p);

%
%  CONDITIONS
%

%  Possibilities currently defined:
%  colors:  {'blue','orange','yellow','purple','green','cyan','scarlet'}
%  patterns:  {'dots','spiral','horizontalLines','verticalLines','waffle','concentricCircles','solid'}
%  shapes:  {'circle','square','diamond','triangle','pentagon','hexagon'}

colors = {'blue','scarlet','yellow'};
patterns = {'solid'};
shapes = {'triangle','diamond','pentagon'};

p.functionHandles.setObj = dmf.set('colors',colors,'patterns',patterns,'shapes',shapes);

[selectedSets.left,setSymbolCodes.left,selectionCodes.left,matchedFeatures.left] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.left);
[selectedSets.right,setSymbolCodes.right,selectionCodes.right,matchedFeatures.right] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.right);
[selectedSets.center,setSymbolCodes.center,selectionCodes.center,matchedFeatures.center] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.center); 

nSetsPerResponse = lcm(lcm(size(selectedSets.left,1),size(selectedSets.right,1)),size(selectedSets.center,1));
selectedSets.left = repmat(selectedSets.left,nSetsPerResponse/size(selectedSets.left,1),1);
selectedSets.right = repmat(selectedSets.right,nSetsPerResponse/size(selectedSets.right,1),1);
selectedSets.center = repmat(selectedSets.center,nSetsPerResponse/size(selectedSets.center,1),1);

selectionCodes.left = repmat(selectionCodes.left,nSetsPerResponse/size(selectionCodes.left,1),1);
selectionCodes.right = repmat(selectionCodes.right,nSetsPerResponse/size(selectionCodes.right,1),1);
selectionCodes.center = repmat(selectionCodes.center,nSetsPerResponse/size(selectionCodes.center,1),1);

setSymbolCodes.left = repmat(setSymbolCodes.left,nSetsPerResponse/size(setSymbolCodes.left,1),1);
setSymbolCodes.right = repmat(setSymbolCodes.right,nSetsPerResponse/size(setSymbolCodes.right,1),1);
setSymbolCodes.center = repmat(setSymbolCodes.center,nSetsPerResponse/size(setSymbolCodes.center,1),1);

matchedFeatures.left = repmat(matchedFeatures.left,nSetsPerResponse/size(matchedFeatures.left,1),1);
matchedFeatures.right = repmat(matchedFeatures.right,nSetsPerResponse/size(matchedFeatures.right,1),1);
matchedFeatures.center = repmat(matchedFeatures.center,nSetsPerResponse/size(matchedFeatures.center,1),1);

p.functionHandles.possibleResponses = {'left','center','right'};
if(~isfield(p.functionHandles,'includedResponses'))
    p.functionHandles.includedResponses = unique(p.functionHandles.possibleResponses);
end

c = cell(nSetsPerResponse*numel(p.functionHandles.includedResponses),1);
for i=1:length(p.functionHandles.includedResponses)
    for j=1:nSetsPerResponse
        c{(i-1)*nSetsPerResponse+j}.selectedSet = selectedSets.(p.functionHandles.includedResponses{i})(j,:);
        c{(i-1)*nSetsPerResponse+j}.setSymbolCode = setSymbolCodes.(p.functionHandles.includedResponses{i}){j};
        c{(i-1)*nSetsPerResponse+j}.rewardedResponse = p.functionHandles.includedResponses{i};
        c{(i-1)*nSetsPerResponse+j}.selectionCode = selectionCodes.(p.functionHandles.includedResponses{i}){j};
        c{(i-1)*nSetsPerResponse+j}.matchedFeatures = matchedFeatures.(p.functionHandles.includedResponses{i}){j};
    end
end
p.conditions = cell(numel(c)*10,1);

%  Session termination criteria--set finish to Inf because we are using the
%  trial manager
p.trial.pldaps.finish = Inf;

%  Generate symbol textures
p.functionHandles.graphicsManagerObj = dmf.graphicsManager(...
    'symbolFeatures',p.functionHandles.setObj.symbolFeatures,...
    'symbolCodes',p.functionHandles.setObj.symbolCodes,...
    'symbolRadius',p.functionHandles.features.symbolRadius,...
    'symbolCenters',p.functionHandles.geometry.symbolCenters,...
    'colorLibrary',p.trial.display.colors,...
    'windowPtr',p.trial.display.ptr,...
    'pedestalRadius',p.functionHandles.features.pedestalRadius,...
    'patternProperties',p.functionHandles.features.nSpatialCycles,...
    'stateNames',{'proposition','argument','response','return'},...
    'configuration',{[1 0 1],[0 1 0],[1 0 1],[1 0 1]});

%  Initialize trial management
p.functionHandles.trialManagerObj = trialManager('conditions',c,'maxSequentialErrors',3,'numDecks',2);
p.functionHandles.trialManagerObj.tokenize('selectionCode','matchedFeatures');

%  Initialize performance tracking
p.functionHandles.performanceTrackingObj = dmf.performanceTracking(...
    'trackedOutcomes',[p.functionHandles.selectionCodes.left p.functionHandles.selectionCodes.center p.functionHandles.selectionCodes.right]);
p.functionHandles.performanceTrackingObj.tallyTrials(p.functionHandles.trialManagerObj.conditions);
