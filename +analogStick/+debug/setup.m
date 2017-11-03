function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  analogStick.debug

%
%  Capture some data for analog stick debugging.
%

%  Set trial master function, this gets called each trial
p.defaultParameters.pldaps.trialFunction = 'analogStick.debug.trialFunction';

defaultColors(p);
lplDefaultColors(p);

% Dot sizes for drawing
p.trial.stimulus.eyeW = 8;      % eye indicator width in pixels (for console display)
p.trial.stimulus.cursorW = 8;   % cursor width in pixels (for console display)

%  Trial duration information--10 seconds
p.trial.pldaps.maxTrialLength = 10;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Set up condition array
%  Only one condition
p.conditions=cell(1);

%  Maximum number of trials
p.defaultParameters.pldaps.finish = 1;

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

p.functionHandles.windowManagerObj.disp;