function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  joystick.test
%
%  Test the 2-axis joystick

%  Create the initial trial structure
pdsDefaultTrialStructure(p);

%  Set trial master function, this gets called each trial
p.defaultParameters.pldaps.trialFunction = 'joystick.test.trialFunction';

%  Trial duration information--10 seconds
p.trial.pldaps.maxTrialLength = 10;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Set up condition array
%  Five conditions:  center, left, right, up, down
%  Last, move it all around
c = cell(1,1);
c{1}.text = 'Move the joystick';
p.conditions=c;

%  Maximum number of trials
p.trial.pldaps.finish = length(p.conditions);

%  Settings for cursor
p.functionHandles.analogStick.cursor = struct(...
        'function','analogStick.defaultCursor',...
        'windowPointer',p.trial.display.ptr,...
        'linewidth',6,...
        'height',20,...
        'color',[0 0 0]);