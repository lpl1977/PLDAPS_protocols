function p = setup(p)
%PLDAPS setup file for hold_or_release

%  Set trial master function
p.trial.pldaps.trialFunction = 'set_trainer.hold_or_release.hold_or_release';

%  Load the joystick calibration file
p.trial.joystick.beta = getfield(load('/home/astaroth/Documents/MATLAB/settings/JoystickSettings.mat','beta'),'beta');

%  Get default colors and put the default bit names in for now
p = defaultColors(p);
p = defaultBitNames(p);

% dot sizes for drawing
p.trial.stimulus.eyeW      = 8;    % eye indicator width in pixels
p.trial.stimulus.fixdotW   = 8;    % width of the fixation dot
p.trial.stimulus.targdotW  = 8;    % width of the target dot
p.trial.stimulus.cursorW   = 8;   % cursor width in pixels

%  Put additional colors into the human and monkey CLUT
p.trial.display.humanCLUT(16,:) = [0 0 1];
p.trial.display.monkeyCLUT(16,:) = p.trial.display.bgColor;

%  For the sake of convenience define some references to the colors
p.trial.display.clut.hWhite = 5*[1 1 1]';
p.trial.display.clut.bWhite = 7*[1 1 1]';
p.trial.display.clut.hCyan = 8*[1 1 1]';
p.trial.display.clut.bBlack = 9*[1 1 1]';
p.trial.display.clut.hGreen = 12*[1 1 1]';
p.trial.display.clut.hRed = 13*[1 1 1]';
p.trial.display.clut.hBlack =14*[1 1 1]';
p.trial.display.clut.hBlue = 15*[1 1 1]';

p.trial.sound.useForReward = 0;
p.trial.control_flags.use_eyepos = false;

%
%  Reward sounds
%
p.trial.behavior.fail_to_release.sound.file = 'breakfix';
p.trial.behavior.early_release.sound.file = 'incorrect';
p.trial.behavior.fail_to_engage.sound.file = 'incorrect';
p.trial.behavior.reward.sound.file = 'reward';

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
%  Only one condition--push the joystick
c = cell(1,2);
c{1}.release = true;
c{1}.Nr = 1;
c{2}.release = false;
c{2}.Nr = 2;
c = repmat(c,1,500);
p.conditions=Shuffle(c);

%  Maximum number of trials
p.trial.pldaps.finish = length(c);
