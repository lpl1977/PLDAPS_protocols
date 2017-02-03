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

%  Trial duration information--he'll have 2 minutes to figure it out per
%  trial
p.trial.pldaps.maxTrialLength = 2*60;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%
%  CONDITIONS
%

%  Possibilities currently defined:
%  colors:  {'blue','orange','yellow','purple','green','cyan','scarlet'}
%  patterns:  {'dots','spiral','horizontalLines','verticalLines','waffle','concentricCircles'}
%  shapes:  {'circle','square','diamond','triangle','pentagon','hexagon'}

colors = {'blue','scarlet','yellow'};
patterns = {'waffle','concentricCircles','spiral'};
shapes = {'triangle','diamond','pentagon'};

S = dmf.sequence('colors',colors,'patterns',patterns,'shapes',shapes);
nSymbols = size(S.symbolCodes,1);

%rewardedResponses = {'left','center','right'};
%rewardedResponses = {'left', 'left', 'center', 'right', 'right'};
rewardedResponses = {'center'};

p.functionHandles.sequences = S;

c = cell(nSymbols*length(rewardedResponses),1);
for i=1:nSymbols
    for j=1:length(rewardedResponses)
        c{i+(j-1)*nSymbols}.symbolIndex = i;
        c{i+(j-1)*nSymbols}.symbol.color = S.features.colors{S.symbolCodes(i,1)};
        c{i+(j-1)*nSymbols}.symbol.pattern = S.features.patterns{S.symbolCodes(i,2)};
        c{i+(j-1)*nSymbols}.symbol.shape = S.features.shapes{S.symbolCodes(i,3)};
        c{i+(j-1)*nSymbols}.rewardedResponse = rewardedResponses{j};
    end
end
c = repmat(c,20,1);   


c = Shuffle(c);

p.conditions = c; 
p.trial.pldaps.finish = length(p.conditions);

%  Initialize performance tracking
p.functionHandles.performance = dmf.performanceTracking({'left','center','right'});


%  Geometry of stimuli
p.functionHandles.geometry.symbolDisplacement = 350;
p.functionHandles.geometry.symbolRadius = 150;
p.functionHandles.geometry.center = [959.5 539.5];
p.functionHandles.geometry.symbolCenters.left = [p.functionHandles.geometry.center(1)-p.functionHandles.geometry.symbolDisplacement p.functionHandles.geometry.center(2)];
p.functionHandles.geometry.symbolCenters.center = [p.functionHandles.geometry.center(1) p.functionHandles.geometry.center(2)];
p.functionHandles.geometry.symbolCenters.right = [p.functionHandles.geometry.center(1)+p.functionHandles.geometry.symbolDisplacement p.functionHandles.geometry.center(2)];

%  Features
p.functionHandles.features.symbolRadius = p.functionHandles.geometry.symbolRadius;
p.functionHandles.features.nSpatialCycles = 16;
p.functionHandles.features.nThetaCycles = 8;
p.functionHandles.features.bgColor = p.trial.display.bgColor;

% leftColorMatchTrials{i}.symbol.(pos{j}).color = leftColorSequences{i,j}{1};
% leftColorMatchTrials{i}.symbol.(pos{j}).pattern = leftColorSequences{i,j}{2};

% 
% leftColorSequences = S.selector('300');
% nColorSequences = size(leftColorSequences,1);
% leftMaskSequences = S.selector('030');
% nMaskSequences = size(leftMaskSequences,1);
% leftShapeSequences = S.selector('003');
% nShapeSequences = size(leftShapeSequences,1);
% 
% rightColorSequences = S.selector('200');
% rightMaskSequences = S.selector('020');
% rightShapeSequences = S.selector('002');
% 
% NonMatchSequences = S.selector('000');
% nNonMatchSequences = size(NonMatchSequences,1);

%p.functionHandles.sequences = S;

% S = sequence.generator(colors,patterns,shapes);
% leftColorSequences = sequence.selector(S,'300');
% nColorSequences = size(leftColorSequences,1);
% leftMaskSequences = sequence.selector(S,'030');
% nMaskSequences = size(leftMaskSequences,1);
% leftShapeSequences = sequence.selector(S,'003');
% nShapeSequences = size(leftShapeSequences,1);
% 
% rightColorSequences = sequence.selector(S,'200');
% rightMaskSequences = sequence.selector(S,'020');
% rightShapeSequences = sequence.selector(S,'002');
% 
% NonMatchSequences = sequence.selector(S,'000');
% nNonMatchSequences = size(NonMatchSequences,1);
% 
% pos = {'right', 'left','center'};
% 
% %  COLOR MATCH CONDITIONS
% leftColorMatchTrials = cell(nColorSequences,1);
% rightColorMatchTrials = cell(nColorSequences,1);
% for i=1:nColorSequences
%     for j=1:3
%         leftColorMatchTrials{i}.symbol.(pos{j}).color = leftColorSequences{i,j}{1};
%         leftColorMatchTrials{i}.symbol.(pos{j}).pattern = leftColorSequences{i,j}{2};
%         leftColorMatchTrials{i}.symbol.(pos{j}).shape = leftColorSequences{i,j}{3};
%         rightColorMatchTrials{i}.symbol.(pos{j}).color = rightColorSequences{i,j}{1};
%         rightColorMatchTrials{i}.symbol.(pos{j}).pattern = rightColorSequences{i,j}{2};
%         rightColorMatchTrials{i}.symbol.(pos{j}).shape = rightColorSequences{i,j}{3};
%     end
%     leftColorMatchTrials{i}.rewardedResponse = 'left';
%     leftColorMatchTrials{i}.matchType = 'left color';
%     leftColorMatchTrials{i}.displayPosition.left = true;
%     leftColorMatchTrials{i}.displayPosition.center = true;
%     leftColorMatchTrials{i}.displayPosition.right = false;    
%     rightColorMatchTrials{i}.rewardedResponse = 'right';
%     rightColorMatchTrials{i}.matchType = 'right color';
%     rightColorMatchTrials{i}.displayPosition.left = false;
%     rightColorMatchTrials{i}.displayPosition.center = true;
%     rightColorMatchTrials{i}.displayPosition.right = true;
% end

% %  SHAPE MATCH CONDITIONS
% ShapeMatchTrials = cell(2*nShapeSequences,1);
% for i=1:nShapeSequences
%     for j=1:3
%         ShapeMatchTrials{i}.symbol.(pos{j}).color = leftShapeSequences{i,j}{1};
%         ShapeMatchTrials{i}.symbol.(pos{j}).mask = leftShapeSequences{i,j}{2};
%         ShapeMatchTrials{i}.symbol.(pos{j}).shape = leftShapeSequences{i,j}{3};        
%         ShapeMatchTrials{i+nShapeSequences}.symbol.(pos{j}).color = rightShapeSequences{i,j}{1};
%         ShapeMatchTrials{i+nShapeSequences}.symbol.(pos{j}).mask = rightShapeSequences{i,j}{2};
%         ShapeMatchTrials{i+nShapeSequences}.symbol.(pos{j}).shape = rightShapeSequences{i,j}{3};
%     end    
%     ShapeMatchTrials{i}.rewardedResponse = 'left';
%     ShapeMatchTrials{i}.matchType = 'shape';
%     ShapeMatchTrials{i}.displayPosition.left = true;
%     ShapeMatchTrials{i}.displayPosition.center = true;
%     ShapeMatchTrials{i}.displayPosition.right = false;    
%     ShapeMatchTrials{i+nShapeSequences}.rewardedResponse = 'right';
%     ShapeMatchTrials{i+nShapeSequences}.matchType = 'shape';
%     ShapeMatchTrials{i+nShapeSequences}.displayPosition.left = false;
%     ShapeMatchTrials{i+nShapeSequences}.displayPosition.center = true;
%     ShapeMatchTrials{i+nShapeSequences}.displayPosition.right = true;
% end
% 
% %  MASK MATCH CONDITIONS
% MaskMatchTrials = cell(2*nMaskSequences,1);
% for i=1:nMaskSequences
%     for j=1:3
%         MaskMatchTrials{i}.symbol.(pos{j}).color = leftMaskSequences{i,j}{1};
%         MaskMatchTrials{i}.symbol.(pos{j}).mask = leftMaskSequences{i,j}{2};
%         MaskMatchTrials{i}.symbol.(pos{j}).shape = leftMaskSequences{i,j}{3};
%         MaskMatchTrials{i+nMaskSequences}.symbol.(pos{j}).color = rightMaskSequences{i,j}{1};
%         MaskMatchTrials{i+nMaskSequences}.symbol.(pos{j}).mask = rightMaskSequences{i,j}{2};
%         MaskMatchTrials{i+nMaskSequences}.symbol.(pos{j}).shape = rightMaskSequences{i,j}{3};
%     end
%     MaskMatchTrials{i}.rewardedResponse = 'left';
%     MaskMatchTrials{i}.matchType = 'mask';
%     MaskMatchTrials{i}.displayPosition.left = true;
%     MaskMatchTrials{i}.displayPosition.center = true;
%     MaskMatchTrials{i}.displayPosition.right = false;    
%     MaskMatchTrials{i+nMaskSequences}.rewardedResponse = 'right';
%     MaskMatchTrials{i+nMaskSequences}.matchType = 'mask';
%     MaskMatchTrials{i+nMaskSequences}.displayPosition.left = false;
%     MaskMatchTrials{i+nMaskSequences}.displayPosition.center = true;
%     MaskMatchTrials{i+nMaskSequences}.displayPosition.right = true;    
% end
% 
% %  NON MATCH TRIALS
% leftNonMatchTrials = cell(nNonMatchSequences,1);
% rightNonMatchTrials = cell(nNonMatchSequences,1);
% for i=1:nNonMatchSequences
%     for j=1:3
%         leftNonMatchTrials{i}.symbol.(pos{j}).color = NonMatchSequences{i,j}{1};
%         leftNonMatchTrials{i}.symbol.(pos{j}).pattern = NonMatchSequences{i,j}{2};
%         leftNonMatchTrials{i}.symbol.(pos{j}).shape = NonMatchSequences{i,j}{3};
%         rightNonMatchTrials{i}.symbol.(pos{j}).color = NonMatchSequences{i,j}{1};
%         rightNonMatchTrials{i}.symbol.(pos{j}).pattern = NonMatchSequences{i,j}{2};
%         rightNonMatchTrials{i}.symbol.(pos{j}).shape = NonMatchSequences{i,j}{3};
%     end
%     leftNonMatchTrials{i}.rewardedResponse = 'center';
%     leftNonMatchTrials{i}.matchType = 'left catch';
%     leftNonMatchTrials{i}.displayPosition.left = true;
%     leftNonMatchTrials{i}.displayPosition.center = true;
%     leftNonMatchTrials{i}.displayPosition.right = false;
%     rightNonMatchTrials{i}.rewardedResponse = 'center';
%     rightNonMatchTrials{i}.matchType = 'right catch';
%     rightNonMatchTrials{i}.displayPosition.left = false;
%     rightNonMatchTrials{i}.displayPosition.center = true;
%     rightNonMatchTrials{i}.displayPosition.right = true;
% end
% 
% %  Group trials together for desired task combination
% 
% %  Blocks will include equal numbers of match and non-match trials per
% %  side.
% 
% %  Shuffle the trials within their class
% leftColorMatchTrials = Shuffle(leftColorMatchTrials);
% rightColorMatchTrials = Shuffle(rightColorMatchTrials);
% leftNonMatchTrials = Shuffle(leftNonMatchTrials);
% rightNonMatchTrials = Shuffle(rightNonMatchTrials);
% 
% %  Generate blocking index
% leftBlockIndex = repmat(1:2:2*27,8,1);
% leftBlockIndex = leftBlockIndex(:);
% rightBlockIndex = repmat(2:2:2*27,8,1);
% rightBlockIndex = rightBlockIndex(:);
% for i=1:nColorSequences
%     leftColorMatchTrials{i}.blockIndex = leftBlockIndex(i);
%     rightColorMatchTrials{i}.blockIndex = rightBlockIndex(i);
%     leftNonMatchTrials{i}.blockIndex = leftBlockIndex(i);
%     rightNonMatchTrials{i}.blockIndex = rightBlockIndex(i);
% end
% 
% c = cell(0,1);
% for i=1:2:2*27
%     ix1 = leftBlockIndex==i;
%     ix2 = rightBlockIndex==(i+1);
%         cTemp1 = Shuffle([leftColorMatchTrials(ix1) ; leftNonMatchTrials(ix1)]);
%         cTemp2 = Shuffle([rightColorMatchTrials(ix2) ; rightNonMatchTrials(ix2)]);
%     c = [c ; cTemp1 ; cTemp2];
% end
% 
% % %  This is the color and non-match combination with equal number of trials
% % %  in which the symbols are a left-side pair and a right-side pair for both
% % %  color and non-match 
% % nTrialsPerGroup = lcm(nColorSequences,nNonMatchSequences);
% % c = [repmat(ColorMatchTrials,nTrialsPerGroup/nNonMatchSequences,1) ; repmat(NonMatchTrials,nTrialsPerGroup/nColorSequences,1)];
% 


%  Set up for performance tracking
%p.functionHandles.performance = dmf.performance(p.conditions,'matchType','rewardedResponse');

% %  Reward
% p.functionHandles.reward = 0.3;
% 
% %  Timing
% p.functionHandles.timing.errorPenalty = 2;
% p.functionHandles.timing.errorDuration = 0.7;  %  This is the duration of the incorrect tone
% p.functionHandles.timing.minSymbolDelay = 0.5;

% p.functionHandles.timing.maxSymbolDelay = 4;
% if(p.functionHandles.controlFlags.useInterSymbolInterval)
%     p.functionHandles.timing.interSymbolInterval = 0.5;
% else
%     p.functionHandles.timing.interSymbolInterval = 0;
% end

% p.functionHandles.timing.minSelectionTime = 2*p.trial.display.ifi;  %  Target will be short maybe 250 msec?
% p.functionHandles.timing.maxSelectionTime = max(5,p.functionHandles.timing.minSelectionTime);
% p.functionHandles.timing.trialAbortPenalty = 2;
% p.functionHandles.timing.minStartDelay = 0.5;
% p.functionHandles.timing.maxStartDelay = 1.0;
% p.functionHandles.timing.responseDuration = 10;
% p.functionHandles.timing.rewardDuration = 0.5;
% p.functionHandles.timing.errorDuration = p.functionHandles.timing.rewardDuration;
% p.functionHandles.timing.errorPenaltyDuration = 2;
% p.functionHandles.timing.invalidResponsePenaltyDuration = 5;

% p.functionHandles.features.rewardRegionBuffer = 50;
% p.functionHandles.features.rewardRegionPenWidth = 12;
% p.functionHandles.features.rewardRegionBorderColor = [0.75 0.75 0.75];
% p.functionHandles.features.rewardRegionSelectedBorderColor = [0.25 0.25 0.25];
% p.functionHandles.features.secondaryReinforcerWidth = 250;
% p.functionHandles.features.secondaryReinforcerHeight = 30;
% p.functionHandles.features.secondaryReinforcerBorderColor = [0.375 0.375 0.375];
% p.functionHandles.features.secondaryReinforcerInteriorColor = [127 255 212]/255;
% p.functionHandles.features.secondaryReinforcerPenWidth = 4;
