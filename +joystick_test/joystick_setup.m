function p = joystick_setup(p)
%joystick_setup a PLDAPS experiment setup file for initial joystick
%testing and training.

%  Create the initial trial structure
p = pdsDefaultTrialStructure(p);

%  Set trial master function, this gets called each trial
p.defaultParameters.pldaps.trialFunction = 'joystick_test.joystick_trial_function';

%  Trial duration information
p.trial.pldaps.maxTrialLength = 10;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Try and set this:
p.trial.display.clut.fixationColor = p.trial.display.clut.bg;

%  Initialize joystick state
p.trial.stimulus.joystick_status = 0;
p.trial.stimulus.joystick_ready = 1;

%  Set up condition array
%  Only one condition--push the joystick
c = cell(1);
c{1}.Nr=1;
p.conditions=repmat(c,1,1000);

%  Maximum number of trials
p.trial.pldaps.finish = 1000;

%  Setup default trial values in p.trial
p = defaultTrialVariables(p);