function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  set_trainer
%  TRIAL FUNCTION:  stairway_to_heaven

%  Set trial master function
p.trial.pldaps.trialFunction = 'set_trainer.stairway_to_heaven.stairway_to_heaven';

%  Load the joystick calibration file
p.trial.joystick.beta = getfield(load('/home/astaroth/Documents/MATLAB/settings/JoystickSettings.mat','beta'),'beta');

%  Get default colors and put the default bit names in
p = defaultColors(p);
p = defaultBitNames(p);

% dot sizes for drawing
p.trial.stimulus.eyeW      = 8;    % eye indicator width in pixels
%p.trial.stimulus.fixdotW   = 8;    % width of the fixation dot
%p.trial.stimulus.targdotW  = 8;    % width of the target dot
%p.trial.stimulus.cursorW   = 8;   % cursor width in pixels

%  Put additional colors into the human and monkey CLUT
p.trial.display.humanCLUT(16,:) = [0 0 1];
p.trial.display.monkeyCLUT(16,:) = p.trial.display.bgColor;

p.trial.display.humanCLUT(17:23,:) = ...
     [    0    0.4470    0.7410     %  Blue
    0.8500    0.3250    0.0980      %  Orange
    0.9290    0.6940    0.1250      %  Yellow
    0.4940    0.1840    0.5560      %  Purple
    0.4660    0.6740    0.1880      %  Green
    0.3010    0.7450    0.9330      %  Cyan
    0.6350    0.0780    0.1840];    %  Scarlet
p.trial.display.monkeyCLUT(17:23,:) = p.trial.display.humanCLUT(17:23,:);

%  For the sake of convenience define some references to the colors
p.trial.display.clut.hWhite = 5*[1 1 1]';
p.trial.display.clut.bWhite = 7*[1 1 1]';
p.trial.display.clut.hCyan = 8*[1 1 1]';
p.trial.display.clut.bBlack = 9*[1 1 1]';
p.trial.display.clut.hGreen = 12*[1 1 1]';
p.trial.display.clut.hRed = 13*[1 1 1]';
p.trial.display.clut.hBlack =14*[1 1 1]';
p.trial.display.clut.hBlue = 15*[1 1 1]';

p.trial.display.clut.bBlue = 16*[1 1 1]';
p.trial.display.clut.bOrange = 17*[1 1 1]';
p.trial.display.clut.bYellow = 18*[1 1 1]';
p.trial.display.clut.bPurple = 19*[1 1 1]';
p.trial.display.clut.bGreen = 20*[1 1 1]';
p.trial.display.clut.bCyan = 21*[1 1 1]';
p.trial.display.clut.bScarlet = 22*[1 1 1]';

p.trial.sound.useForReward = 0;
p.trial.control_flags.use_eyepos = false;

%
%  Reward sounds
%
p.trial.behavior.fail_to_release.sound.file = 'breakfix';
p.trial.behavior.early_release.sound.file = 'incorrect';
p.trial.behavior.fail_to_engage.sound.file = 'incorrect';
p.trial.behavior.reward.sound.file = 'reward';

%
%  Features
%

%  Fixation cue
p.trial.temp.features.fixation.width = 10;
p.trial.temp.features.fixation.linewidth = 2;
p.trial.temp.features.fixation.color = p.trial.display.clut.bWhite;

%  Joystick engage cue
p.trial.temp.features.ready.width = 175;
p.trial.temp.features.ready.linewidth = 2;
p.trial.temp.features.ready.color = [1 1 1];

%  Hold cue
p.trial.temp.features.hold = p.trial.temp.features.ready;
p.trial.temp.features.hold.color = [0.5 0.5 0.5];

%  Release Cue
p.trial.temp.features.release = p.trial.temp.features.hold;
p.trial.temp.features.release.linewidth = 10;
p.trial.temp.features.release.color = [0 0 0];

%  Symbol
p.trial.temp.features.symbol = p.trial.temp.features.release;
p.trial.temp.features.symbol.linewidth = 10;
p.trial.temp.features.symbol.width = 140;

%  Trial duration information
p.trial.pldaps.maxTrialLength = 1000;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

p.trial.stimulus.error_code = 0;

p.trial.stimulus.exit_flag = 0;

%  Performance tracking
p.trial.temp.hits = 0;
p.trial.temp.misses = 0;
p.trial.temp.false_alarms = 0;
p.trial.temp.correct_rejects = 0;
p.trial.temp.early_releases = 0;
p.trial.temp.delay_errors = 0;
p.trial.temp.fixation_breaks = 0;

%  Set up condition array
[training_set,training_noset] = set_generator({'B','S','P'},{'C','Y','G'},{'C','S','T'});

nsets = size(training_set,1);
c = cell(1,2*nsets);
for i=1:nsets
    c{i}.symbols = training_set(i,:);
    c{i}.release = true;
    c{i+nsets}.symbols = training_noset(i,:);
    c{i+nsets}.release = false;
end
p.conditions=Shuffle(c);

%  Maximum number of trials
p.trial.pldaps.finish = length(c);
