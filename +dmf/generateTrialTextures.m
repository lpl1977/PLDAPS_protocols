function trialTextures = generateTrialTextures(p)
%generateTrialTextures function to generate the textures for a trial
%
%  trialTextures = generateTrialTextures(p)
%
%  trialTextures is a structure of textures with field names corresponding
%  to trial frame states

%  Extract components of input structure
symbolCenters = p.functionHandles.geometry.symbolCenters;
selectedSet = p.trial.condition.selectedSequence;
symbolsTextures = p.functionHandles.textures.symbols;
baseRect = [0 0 2*p.functionHandles.geometry.symbolRadius 2*p.functionHandles.geometry.symbolRadius];
bgColor = p.functionHandles.features.bgColor;
pedestalsTexture = p.functionHandles.textures.pedastals;

%  trial States
trialTextures.start = [];
trialTextures.warning = [];
trialTextures.engage = [];
trialTextures.penalty = [];
trialTextures.reward = [];
trialTextures.error = [];

%  hold
trialTextures.hold = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
Screen('DrawTexture',trialTextures.hold,pedestalsTexture);

%  presentation
trialTextures.presentation = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
Screen('DrawTexture',trialTextures.presentation,pedestalsTexture);
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(1,1),symbolCenters(1,2));
Screen('DrawTexture',trialTextures.presentation,symbolsTextures(selectedSet(1)),centeredRect);
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(3,1),symbolCenters(3,2));
Screen('DrawTexture',trialTextures.presentation,symbolsTextures(selectedSet(3)),centeredRect);

%  delay
trialTextures.delay = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
Screen('DrawTexture',trialTextures.delay,pedestalsTexture);

%  probe
trialTextures.probe = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
Screen('DrawTexture',trialTextures.probe,pedestalsTexture);
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(2,1),symbolCenters(2,2));
Screen('DrawTexture',trialTextures.probe,symbolsTextures(selectedSet(2)),centeredRect);

%  response
trialTextures.response = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
Screen('DrawTexture',trialTextures.response,pedestalsTexture);
% centeredRect = CenterRectOnPoint(baseRect,symbolCenters(1,1),symbolCenters(1,2));
% Screen('DrawTexture',trialTextures.response,symbolsTextures(selectedSet(1)),centeredRect);
% centeredRect = CenterRectOnPoint(baseRect,symbolCenters(2,1),symbolCenters(2,2));
% Screen('DrawTexture',trialTextures.response,symbolsTextures(selectedSet(2)),centeredRect);
% centeredRect = CenterRectOnPoint(baseRect,symbolCenters(3,1),symbolCenters(3,2));
% Screen('DrawTexture',trialTextures.response,symbolsTextures(selectedSet(3)),centeredRect);