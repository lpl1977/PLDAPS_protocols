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

%  Features
p.functionHandles.features.symbolRadius = p.functionHandles.geometry.symbolRadius;
p.functionHandles.features.nSpatialCycles = 16;
p.functionHandles.features.nThetaCycles = 8;
p.functionHandles.features.bgColor = p.trial.display.bgColor;

%  Cursor colors
p.functionHandles.cursorColors.engage = [0 0.8 0];
p.functionHandles.cursorColors.hold = [0.8 0.8 0.8];
p.functionHandles.cursorColors.presentation = p.functionHandles.cursorColors.hold;
p.functionHandles.cursorColors.delay = p.functionHandles.cursorColors.hold;
p.functionHandles.cursorColors.probe = p.functionHandles.cursorColors.hold;
p.functionHandles.cursorColors.response = [0 0 0];
p.functionHandles.cursorColors.warning = [0.8 0 0];

%  symbolAlphas
p.functionHandles.symbolAlphas = struct('left',[],'center',[],'right',[]);


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

%  Initialize trial management
p.functionHandles.trialManagerObj = trialManager('conditions',c,'maxSequentialErrors',3,'numDecks',2);
p.functionHandles.trialManagerObj.tokenize('selectionCode','matchedFeatures');

%  Initialize performance tracking
p.functionHandles.performanceTrackingObj = dmf.performanceTracking(...
    'trackedOutcomes',[p.functionHandles.selectionCodes.left p.functionHandles.selectionCodes.center p.functionHandles.selectionCodes.right]);
p.functionHandles.performanceTrackingObj.tallyTrials(p.functionHandles.trialManagerObj.conditions);
