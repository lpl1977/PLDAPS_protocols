function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  joystick.calibration
%
%  Calibrate the 2-axis joystick

%  Create the initial trial structure
pdsDefaultTrialStructure(p);

%  Set trial master function, this gets called each trial
p.defaultParameters.pldaps.trialFunction = 'joystick.calibration.trialFunction';

%  Trial duration information--10 seconds
p.trial.pldaps.maxTrialLength = 10;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Set up condition array
%  Five conditions:  center, left, right, up, down
%  Last, move it all around
c = cell(1,6);
c{1}.text = 'center';
c{2}.text = 'left';
c{3}.text = 'right';
c{4}.text = 'up';
c{5}.text = 'down';
c{6}.text = 'move it to all the corners';
p.conditions=c;

%  Maximum number of trials
p.trial.pldaps.finish = length(p.conditions);