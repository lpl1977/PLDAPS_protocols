function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  analogStick.debug

%
%  Capture some data for analog stick debugging.
%

%  Create the initial trial structure
p = pdsDefaultTrialStructure(p);

%  Set trial master function, this gets called each trial
p.defaultParameters.pldaps.trialFunction = 'analogStick.debug.trialFunction';

%  Trial duration information--10 seconds
p.trial.pldaps.maxTrialLength = 10;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Set up condition array
%  Only one condition
p.conditions=cell(1);

%  Maximum number of trials
p.defaultParameters.pldaps.finish = 1;