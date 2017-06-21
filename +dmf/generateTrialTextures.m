function p = generateTrialTextures(p)
%generateTrialTextures function to generate the textures for a trial
%
%  p = dmf.generateTrialTextures(p)
%
%  p.functionHandles.trialTextures is a structure of textures with field
%  names corresponding to trial frame states

%  Extract components of input structure
symbolCenters = p.functionHandles.geometry.symbolCenters;
selectedSet = p.trial.condition.selectedSet;

symbolsTextures = p.functionHandles.graphicsManagerObj.symbolTextures;

%symbolsTextures = p.functionHandles.symbolTextures;
symbolBaseRect = [0 0 2*p.functionHandles.geometry.symbolRadius 2*p.functionHandles.geometry.symbolRadius];
pedestalBaseRect = 0.5*symbolBaseRect;
bgColor = p.functionHandles.colors.background;
pedestalColor = p.functionHandles.colors.pedestal;

%  Generate intermediate pedestal texture
pedestalTexture = p.functionHandles.graphicsManagerObj.pedestalTexture;
% pedestalsTexture = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
% for i=1:3
%     centeredRect = CenterRectOnPoint(pedestalBaseRect,symbolCenters(i,1),symbolCenters(i,2));
%     Screen('FillOval',pedestalsTexture,pedestalColor,centeredRect);
% end

%  Initialize pointers for textures for each state
p.functionHandles.trialTextures.start = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.engage = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.hold = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.presentation = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.delay = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.probe = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.response = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.reward = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.error = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.warning = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.penalty = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
p.functionHandles.trialTextures.return = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);

%  presentation
centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(1,1),symbolCenters(1,2));
Screen('DrawTexture',p.functionHandles.trialTextures.presentation,symbolsTextures(selectedSet(1)),[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(2,1),symbolCenters(2,2));
Screen('DrawTexture',p.functionHandles.trialTextures.presentation,pedestalTexture,[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(3,1),symbolCenters(3,2));
Screen('DrawTexture',p.functionHandles.trialTextures.presentation,symbolsTextures(selectedSet(3)),[],centeredRect);

%  delay
centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(1,1),symbolCenters(1,2));
Screen('DrawTexture',p.functionHandles.trialTextures.delay,pedestalTexture,[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(2,1),symbolCenters(2,2));
Screen('DrawTexture',p.functionHandles.trialTextures.delay,pedestalTexture,[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(3,1),symbolCenters(3,2));
Screen('DrawTexture',p.functionHandles.trialTextures.delay,pedestalTexture,[],centeredRect);

%  probe
centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(1,1),symbolCenters(1,2));
Screen('DrawTexture',p.functionHandles.trialTextures.probe,pedestalTexture,[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(2,1),symbolCenters(2,2));
Screen('DrawTexture',p.functionHandles.trialTextures.probe,symbolsTextures(selectedSet(2)),[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(3,1),symbolCenters(3,2));
Screen('DrawTexture',p.functionHandles.trialTextures.probe,pedestalTexture,[],centeredRect);

%  response
centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(1,1),symbolCenters(1,2));
Screen('DrawTexture',p.functionHandles.trialTextures.response,pedestalTexture,[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(2,1),symbolCenters(2,2));
Screen('DrawTexture',p.functionHandles.trialTextures.response,pedestalTexture,[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(3,1),symbolCenters(3,2));
Screen('DrawTexture',p.functionHandles.trialTextures.response,pedestalTexture,[],centeredRect);

% centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(1,1),symbolCenters(1,2));
% Screen('DrawTexture',p.functionHandles.trialTextures.response,symbolsTextures(selectedSet(1)),[],centeredRect);
% centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(2,1),symbolCenters(2,2));
% Screen('DrawTexture',p.functionHandles.trialTextures.response,symbolsTextures(selectedSet(2)),[],centeredRect);
% centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(3,1),symbolCenters(3,2));
% Screen('DrawTexture',p.functionHandles.trialTextures.response,symbolsTextures(selectedSet(3)),[],centeredRect);

%  return
centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(1,1),symbolCenters(1,2));
Screen('DrawTexture',p.functionHandles.trialTextures.return,pedestalTexture,[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(2,1),symbolCenters(2,2));
Screen('DrawTexture',p.functionHandles.trialTextures.return,pedestalTexture,[],centeredRect);

centeredRect = CenterRectOnPoint(symbolBaseRect,symbolCenters(3,1),symbolCenters(3,2));
Screen('DrawTexture',p.functionHandles.trialTextures.return,pedestalTexture,[],centeredRect);
