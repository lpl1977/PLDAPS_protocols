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

p.functionHandles.sequenceObj = dmf.sequence('colors',colors,'patterns',patterns,'shapes',shapes);

[selectedSequences.left,sequenceSymbolCodes.left,selectionCodes.left] = p.functionHandles.sequenceObj.selector('140');
[selectedSequences.right,sequenceSymbolCodes.right,selectionCodes.right] = p.functionHandles.sequenceObj.selector('340');
[selectedSequences.center,sequenceSymbolCodes.center,selectionCodes.center] = p.functionHandles.sequenceObj.selector({'040','240','440'}); 

nSequencesPerResponse = lcm(lcm(size(selectedSequences.left,1),size(selectedSequences.right,1)),size(selectedSequences.center,1));
selectedSequences.left = repmat(selectedSequences.left,nSequencesPerResponse/size(selectedSequences.left,1),1);
selectedSequences.right = repmat(selectedSequences.right,nSequencesPerResponse/size(selectedSequences.right,1),1);
selectedSequences.center = repmat(selectedSequences.center,nSequencesPerResponse/size(selectedSequences.center,1),1);

selectionCodes.left = repmat(selectionCodes.left,nSequencesPerResponse/size(selectionCodes.left,1),1);
selectionCodes.right = repmat(selectionCodes.right,nSequencesPerResponse/size(selectionCodes.right,1),1);
selectionCodes.center = repmat(selectionCodes.center,nSequencesPerResponse/size(selectionCodes.center,1),1);

sequenceSymbolCodes.left = repmat(sequenceSymbolCodes.left,nSequencesPerResponse/size(sequenceSymbolCodes.left,1),1);
sequenceSymbolCodes.right = repmat(sequenceSymbolCodes.right,nSequencesPerResponse/size(sequenceSymbolCodes.right,1),1);
sequenceSymbolCodes.center = repmat(sequenceSymbolCodes.center,nSequencesPerResponse/size(sequenceSymbolCodes.center,1),1);

p.functionHandles.possibleResponses = {'left','center','right'};
if(~isfield(p.functionHandles,'includedResponses'))
    p.functionHandles.includedResponses = unique(p.functionHandles.possibleResponses);
end

c = cell(nSequencesPerResponse*numel(p.functionHandles.includedResponses),1);
for i=1:length(p.functionHandles.includedResponses)
    for j=1:nSequencesPerResponse
        c{(i-1)*nSequencesPerResponse+j}.selectedSequence = selectedSequences.(p.functionHandles.includedResponses{i})(j,:);
        c{(i-1)*nSequencesPerResponse+j}.sequenceSymbolCode = sequenceSymbolCodes.(p.functionHandles.includedResponses{i}){j};
        c{(i-1)*nSequencesPerResponse+j}.rewardedResponse = p.functionHandles.includedResponses{i};
        c{(i-1)*nSequencesPerResponse+j}.selectionCode = selectionCodes.(p.functionHandles.includedResponses{i}){j};
    end
end
p.conditions = Shuffle(c);
p.conditions = repmat(p.conditions,2,1);

%  Session termination criteria--set finish to Inf because we are using the
%  trial manager
p.trial.pldaps.finish = Inf;

%  Initialize trial management
p.functionHandles.trialManagerObj = trialManager('maxTrials',numel(c),'maxRepetitions',p.functionHandles.maxRepetitions);

%  Initialize performance tracking
% uniqueSequenceCodes = [];
% for i=1:length(p.functionHandles.possibleResponses)
%     temp = unique(selectionCodes.(p.functionHandles.possibleResponses{i}));
%     uniqueSequenceCodes = [uniqueSequenceCodes; strcat('code',temp)];
% end
p.functionHandles.performanceTrackingObj = dmf.performanceTracking(...
    'trackedOutcomes',{'140','340','040','240','440'});
