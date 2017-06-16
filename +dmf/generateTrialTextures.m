function trialTextures = generateTrialTextures(p)
%generateTrialTextures function to generate the textures for a trial
%
%  trialTextures = generateTrialTextures(p)
%
%  trialTextures is a structure of textures with field names corresponding
%  to trial frame states

%  Extract components of input structure
symbolCenters = p.functionHandles.geometry.symbolCenters;
selectedSet = p.trial.condition.selectedSet;
symbolsTextures = p.functionHandles.textures.symbols;
baseRect = [0 0 2*p.functionHandles.geometry.symbolRadius 2*p.functionHandles.geometry.symbolRadius];
bgColor = p.functionHandles.colors.background;
pedestalsTexture = p.functionHandles.textures.pedestals;

%  Initialize pointers for textures for each state
trialTextures.start = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.engage = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.hold = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.presentation = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.delay = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.probe = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.response = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.reward = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.error = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.warning = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
trialTextures.penalty = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);

%  presentation
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(1,1),symbolCenters(1,2));
Screen('DrawTexture',trialTextures.presentation,symbolsTextures(selectedSet(1)),[],centeredRect);
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(3,1),symbolCenters(3,2));
Screen('DrawTexture',trialTextures.presentation,symbolsTextures(selectedSet(3)),[],centeredRect);

%  probe
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(2,1),symbolCenters(2,2));
Screen('DrawTexture',trialTextures.probe,symbolsTextures(selectedSet(2)),[],centeredRect);

%  response
Screen('DrawTexture',trialTextures.response,pedestalsTexture);
% centeredRect = CenterRectOnPoint(baseRect,symbolCenters(1,1),symbolCenters(1,2));
% Screen('DrawTexture',trialTextures.response,symbolsTextures(selectedSet(1)),[],centeredRect);
% centeredRect = CenterRectOnPoint(baseRect,symbolCenters(2,1),symbolCenters(2,2));
% Screen('DrawTexture',trialTextures.response,symbolsTextures(selectedSet(2)),[],centeredRect);
% centeredRect = CenterRectOnPoint(baseRect,symbolCenters(3,1),symbolCenters(3,2));
% Screen('DrawTexture',trialTextures.response,symbolsTextures(selectedSet(3)),[],centeredRect);

%  return
trialTextures.return = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
Screen('DrawTexture',trialTextures.return,pedestalsTexture);

