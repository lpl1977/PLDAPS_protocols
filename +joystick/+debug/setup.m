function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  joystick_training.debug

%
%  This version of the setup file is, for now, for joystick data collection
%  debugging.
%

%  Create the initial trial structure
p = pdsDefaultTrialStructure(p);

%  Set trial master function, this gets called each trial
p.defaultParameters.pldaps.trialFunction = 'joystick.debug.trial_function';

%  Trial duration information--10 seconds
p.trial.pldaps.maxTrialLength = 10;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

p.trial.display.clut.bBlack = 9*[1 1 1]';
p.trial.display.clut.hBlack =14*[1 1 1]';

%  Set up condition array
%  Only one condition
c = cell(1,10);
p.conditions=c;

%  Maximum number of trials
p.trial.pldaps.finish = 10;