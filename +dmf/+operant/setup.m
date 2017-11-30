function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  dmf.operant

%  This setup file is for training the operant response for the delayed
%  match to feature task.

%  Trial master function, will run at order NaN
p.trial.pldaps.trialFunction = 'dmf.operant.trialFunction';

%  Set colors
defaultColors(p);
lplColors(p);

%  Default bit names
defaultBitNames(p);

%  Trial duration information
p.trial.pldaps.maxTrialLength = 60;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Conditions
%  Only one condition--release the lever for reward.  Trials vary based on
%  delay duration, which I plan to assign at time of trial.  Task will run
%  until p.trial.pldaps.iTrial reaches p.trial.pldaps.finish

c = cell(1000,1);
p.conditions = c;
p.trial.pldaps.finish = numel(c);

% c = cell(nSetsPerResponse*numel(p.functionHandles.possibleResponses),1);
% for i=1:length(p.functionHandles.possibleResponses)
%     for j=1:nSetsPerResponse
%         c{(i-1)*nSetsPerResponse+j}.selectedSet = selectedSets.(p.functionHandles.possibleResponses{i})(j,:);
%         c{(i-1)*nSetsPerResponse+j}.setSymbolCode = setSymbolCodes.(p.functionHandles.possibleResponses{i}){j};
%         c{(i-1)*nSetsPerResponse+j}.rewardedResponse = p.functionHandles.possibleResponses{i};
%         c{(i-1)*nSetsPerResponse+j}.selectionCode = selectionCodes.(p.functionHandles.possibleResponses{i}){j};
%         c{(i-1)*nSetsPerResponse+j}.matchedFeatures = matchedFeatures.(p.functionHandles.possibleResponses{i}){j};
%     end
% end
% p.conditions = cell(numel(c)*10,1);
% 



%  Above here is setup generally required for all tasks
%  *****************************
%  Below here is setup more unique to this task

%  Time intervals
p.trial.stimulus.timing.iti = 1;
p.trial.stimulus.timing.maxEngageInterval = 1;
p.trial.stimulus.timing.minEngageInterval = 0.1;
p.trial.stimulus.timing.preReleaseDelay = 0.1;
p.trial.stimulus.timing.releaseInterval = 10;
p.trial.stimulus.timing.rewardDelay = 0.2;

p.trial.stimulus.reward = 0.45;


%  Create eye position window manager
p.functionHandles.windowManagerObj.createGroup(...
    'groupName','eye',...
    'positionFunc',@() [p.trial.eyeX p.trial.eyeY],...
    'windowPtr',p.trial.display.overlayptr,...
    'displayAreaSize',[p.trial.display.pWidth p.trial.display.pHeight],...
    'displayAreaCenter',p.trial.display.ctr([1 2]),...
    'horizontalDataRange',[0 p.trial.display.pWidth],...
    'verticalDataRange',[0 p.trial.display.pHeight],...
    'dataOrigin',p.trial.display.ctr([1 2]),...
    'trajectoryColor',p.trial.display.clut.hWhite,...
    'maxTrajectorySamples',60,...
    'showTrajectoryTrace',true,...
    'showCurrentPosition',true,...
    'showDisplayAreaOutline',false,...
    'showDisplayAreaAxes',false,...
    'useInvertedVerticalAxis',false,...
    'currentColor',p.trial.display.clut.hGreen,...
    'windowColor',p.trial.display.clut.hCyan);

%  Add the fixation window
p.functionHandles.windowManagerObj.eye.add('fixation',[860 1060 440 640]);

%  Create analog stick window manager
p.functionHandles.windowManagerObj.createGroup(...
    'groupName','analogStick',...
    'positionFunc',@() [0 p.functionHandles.analogStickObj.position],...
    'windowPtr',p.trial.display.overlayptr,...
    'displayAreaSize',[20 200],...
    'displayAreaCenter',[100 905],...
    'horizontalDataRange',[-1 1],...
    'verticalDataRange',[0 5],...
    'dataOrigin',[0 2.5],...
    'trajectoryColor',p.trial.display.clut.hWhite,...
    'maxTrajectorySamples',60,...
    'currentColor',p.trial.display.clut.hGreen,...
    'borderColor',p.trial.display.clut.hBlue,...
    'windowColor',p.trial.display.clut.hCyan,...
    'showTrajectoryTrace',true,...
    'showCurrentPosition',true,...
    'showDisplayAreaOutline',true,...
    'showDisplayAreaAxes',true,...
    'useInvertedVerticalAxis',true);

%  Add neutral and engaged
p.functionHandles.windowManagerObj.analogStick.add('neutral',[-1 1 2 3]);
p.functionHandles.windowManagerObj.analogStick.add('engaged',[-1 1 0 0.5]);

%  Write windows to terminal
p.functionHandles.windowManagerObj.disp;

% c = cell(nSetsPerResponse*numel(p.functionHandles.possibleResponses),1);
% for i=1:length(p.functionHandles.possibleResponses)
%     for j=1:nSetsPerResponse
%         c{(i-1)*nSetsPerResponse+j}.selectedSet = selectedSets.(p.functionHandles.possibleResponses{i})(j,:);
%         c{(i-1)*nSetsPerResponse+j}.setSymbolCode = setSymbolCodes.(p.functionHandles.possibleResponses{i}){j};
%         c{(i-1)*nSetsPerResponse+j}.rewardedResponse = p.functionHandles.possibleResponses{i};
%         c{(i-1)*nSetsPerResponse+j}.selectionCode = selectionCodes.(p.functionHandles.possibleResponses{i}){j};
%         c{(i-1)*nSetsPerResponse+j}.matchedFeatures = matchedFeatures.(p.functionHandles.possibleResponses{i}){j};
%     end
% end
% p.conditions = cell(numel(c)*10,1);
% 
% %  Session termination criteria--set finish to Inf because we are using the
% %  trial manager
% p.trial.pldaps.finish = Inf;


% 
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
% 
% %  Background color
% p.functionHandles.colors.background = p.trial.display.bgColor;
% 
% %  Cursor colors
% p.functionHandles.colors.cursor.start = [0 0 0];
% p.functionHandles.colors.cursor.engage = [0 0.8 0];
% p.functionHandles.colors.cursor.hold = [0.8 0.8 0.8];
% p.functionHandles.colors.cursor.symbols = p.functionHandles.colors.cursor.hold;
% p.functionHandles.colors.cursor.delay = p.functionHandles.colors.cursor.hold;
% p.functionHandles.colors.cursor.response = [0 0 0];
% p.functionHandles.colors.cursor.warning = [0.8 0 0];
% p.functionHandles.colors.cursor.return = [0 0 0];
% p.functionHandles.colors.cursor.penalty = [0 0 0];
% p.functionHandles.colors.cursor.wait = [0.8 0.8 0.8];
% p.functionHandles.colors.cursor.feedback = p.functionHandles.colors.cursor.wait;
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
% % 
% % p.functionHandles.stateTiming.hold = 0.1;
% % p.functionHandles.stateTiming.proposition = 0.5;
% % p.functionHandles.stateTiming.postPropositionDelay = 0.5;
% % p.functionHandles.stateTiming.argument = 0.5;
% % p.functionHandles.stateTiming.postArgumentDelay = 0.5;
% % p.functionHandles.stateTiming.response = 10;
% % p.functionHandles.stateTiming.commit = 4*p.trial.display.ifi;
% % p.functionHandles.stateTiming.reward = 0.7;
% % p.functionHandles.stateTiming.error = 0.7;
% % p.functionHandles.stateTiming.penalty = 2;
% % p.functionHandles.stateTiming.feedbackDelay = 0.1;
% % p.functionHandles.stateTiming.feedbackDelivery = 0.7;
% 
% %
% %  CONDITIONS
% %
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
% p.functionHandles.possibleResponses = {'left','center','right'};
%             
% [selectedSets.left,setSymbolCodes.left,selectionCodes.left,matchedFeatures.left] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.left);
% [selectedSets.center,setSymbolCodes.center,selectionCodes.center,matchedFeatures.center] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.center);
% [selectedSets.right,setSymbolCodes.right,selectionCodes.right,matchedFeatures.right] = p.functionHandles.setObj.selector(p.functionHandles.selectionCodes.right);
% 
% nSetsPerResponse = lcm(lcm(size(selectedSets.left,1),size(selectedSets.right,1)),size(selectedSets.center,1));
% selectedSets.left = repmat(selectedSets.left,nSetsPerResponse/size(selectedSets.left,1),1);
% selectedSets.center = repmat(selectedSets.center,nSetsPerResponse/size(selectedSets.center,1),1);
% selectedSets.right = repmat(selectedSets.right,nSetsPerResponse/size(selectedSets.right,1),1);
% 
% selectionCodes.left = repmat(selectionCodes.left,nSetsPerResponse/size(selectionCodes.left,1),1);
% selectionCodes.center = repmat(selectionCodes.center,nSetsPerResponse/size(selectionCodes.center,1),1);
% selectionCodes.right = repmat(selectionCodes.right,nSetsPerResponse/size(selectionCodes.right,1),1);
% 
% setSymbolCodes.left = repmat(setSymbolCodes.left,nSetsPerResponse/size(setSymbolCodes.left,1),1);
% setSymbolCodes.center = repmat(setSymbolCodes.center,nSetsPerResponse/size(setSymbolCodes.center,1),1);
% setSymbolCodes.right = repmat(setSymbolCodes.right,nSetsPerResponse/size(setSymbolCodes.right,1),1);
% 
% matchedFeatures.left = repmat(matchedFeatures.left,nSetsPerResponse/size(matchedFeatures.left,1),1);
% matchedFeatures.center = repmat(matchedFeatures.center,nSetsPerResponse/size(matchedFeatures.center,1),1);
% matchedFeatures.right = repmat(matchedFeatures.right,nSetsPerResponse/size(matchedFeatures.right,1),1);
% 
% c = cell(nSetsPerResponse*numel(p.functionHandles.possibleResponses),1);
% for i=1:length(p.functionHandles.possibleResponses)
%     for j=1:nSetsPerResponse
%         c{(i-1)*nSetsPerResponse+j}.selectedSet = selectedSets.(p.functionHandles.possibleResponses{i})(j,:);
%         c{(i-1)*nSetsPerResponse+j}.setSymbolCode = setSymbolCodes.(p.functionHandles.possibleResponses{i}){j};
%         c{(i-1)*nSetsPerResponse+j}.rewardedResponse = p.functionHandles.possibleResponses{i};
%         c{(i-1)*nSetsPerResponse+j}.selectionCode = selectionCodes.(p.functionHandles.possibleResponses{i}){j};
%         c{(i-1)*nSetsPerResponse+j}.matchedFeatures = matchedFeatures.(p.functionHandles.possibleResponses{i}){j};
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
%     'stateConfig',{'symbols01',[1 1 1],'symbols02',[1 1 1],'symbols03',[1 1 1],'symbols04',[1 1 1],'symbols05',[1 1 1],'symbols06',[1 1 1],'response',[1 1 1]},...
%     'fixationDotColor',[1 0 0],...
%     'fixationDotWidth',20);
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
%     'windowPtr',p.trial.display.overlayptr,...
%     'displayAreaSize',[250 250],...
%     'displayAreaCenter',[175 905],...
%     'trajectoryColor',p.trial.display.clut.hWhite,...
%     'maxTrajectorySamples',10/p.trial.display.ifi,...
%     'currentColor',p.trial.display.clut.hGreen,...
%     'borderColor',p.trial.display.clut.hCyan,...
%     'activeWindowColor',p.trial.display.clut.hRed,...
%     'enabledWindowColor',p.trial.display.clut.hBlue,...
%     'disabledWindowColor',p.trial.display.clut.hBlack);
% 
% %  Initialize window manager for eye position
% p.functionHandles.eyePositionWindowManagerObj = windowManager(...
%     'windowPtr',p.trial.display.overlayptr,...
%     'displayAreaSize',[p.trial.display.pWidth p.trial.display.pHeight],...
%     'displayAreaCenter',p.trial.display.ctr([1 2]),...
%     'horizontalDisplayRange',[0 p.trial.display.pWidth],...
%     'verticalDisplayRange',[0 p.trial.display.pHeight],...
%     'trajectoryColor',p.trial.display.clut.hYellow,...
%     'maxTrajectorySamples',10/p.trial.display.ifi,...
%     'showTrajectoryTrace',true,...
%     'showDisplayAreaOutline',false,...
%     'showDisplayAreaAxes',false,...
%     'useInvertedVerticalAxis',false,...
%     'currentColor',p.trial.display.clut.hCyan,...
%     'activeWindowColor',p.trial.display.clut.hRed,...
%     'enabledWindowColor',p.trial.display.clut.hBlue,...
%     'disabledWindowColor',p.trial.display.clut.hBlack);
