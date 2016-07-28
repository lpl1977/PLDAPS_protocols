function p = joystick_trainer_setup(p)
%joystick_setup a PLDAPS experiment setup file for initial joystick
%testing and training.


%  Create the initial trial structure
p = pdsDefaultTrialStructure(p);

%  Setup default trial values in p.trial
p = joystick_trainer.joystick_defaultTrialVariables(p);

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
% p.trial.display.humanCLUT(17:23,:) = ...
%      [    0    0.4470    0.7410     %  Blue
%     0.8500    0.3250    0.0980      %  Orange
%     0.9290    0.6940    0.1250      %  Yellow
%     0.4940    0.1840    0.5560      %  Purple
%     0.4660    0.6740    0.1880      %  Green
%     0.3010    0.7450    0.9330      %  Cyan
%     0.6350    0.0780    0.1840];    %  Scarlet
% p.trial.display.monkeyCLUT(17:23,:) = p.trial.display.humanCLUT(17:23,:);
% 
% %  Set up blend from background to scarlet in positions 23 to 123.
% w1 = linspace(0,1,100)';
% w2 = 1-w1;
% w1 = repmat(w1,1,3);
% w2 = repmat(w2,1,3);
% 
% p.trial.display.humanCLUT(22:121,:) = repmat([0.635 0.078 0.184],100,1).*w2 + repmat([0.5 0.5 0.5],100,1).*w1;
% p.trial.display.monkeyCLUT(22:121,:) = p.trial.display.humanCLUT(22:121,:);

%  For the sake of convenience define some references to the colors
p.trial.display.clut.hWhite = 5*[1 1 1]';
p.trial.display.clut.bWhite = 7*[1 1 1]';
p.trial.display.clut.hCyan = 8*[1 1 1]';
p.trial.display.clut.bBlack = 9*[1 1 1]';
p.trial.display.clut.hGreen = 12*[1 1 1]';
p.trial.display.clut.hRed = 13*[1 1 1]';
p.trial.display.clut.hBlack =14*[1 1 1]';
p.trial.display.clut.hBlue = 15*[1 1 1]';

p.trial.display.clut.B = 15*[1 1 1]';
p.trial.display.clut.O = 16*[1 1 1]';
p.trial.display.clut.Y = 17*[1 1 1]';
p.trial.display.clut.P = 18*[1 1 1]';
p.trial.display.clut.G = 19*[1 1 1]';
p.trial.display.clut.C = 20*[1 1 1]';
p.trial.display.clut.S = 21*[1 1 1]';
%  Set trial master function, this gets called each trial
%p.defaultParameters.pldaps.trialFunction = 'joystick_trainer.joystick_trainer_trial_function';

p.defaultParameters.pldaps.trialFunction = 'joystick_trainer.reward_on_release';

p.trial.sound.useForReward = 0;

%  Let's try and make the color purple
%p.defaultParameters.display.humanCLUT(15+1,:) = [147 112 219]/255;
%p.defaultParameters.display.monkeyCLUT(15+1,:) = [147 112 219]/255;


%  Try and set this (not sure yet what it's for):
p.trial.display.clut.fixationColor = p.trial.display.clut.bg;

%
%  State control
%

%  Trial
p.trial.stimulus.trial_state = NaN;

%  Joystick
p.trial.joystick.state = NaN;

%  Error type
p.trial.stimulus.error_code = NaN;

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

%  Set up condition array
%  Only one condition--push the joystick
c = cell(1);
c{1}.Nr=1;
p.conditions=repmat(c,1,1000);

%  Maximum number of trials
p.trial.pldaps.finish = 1000;
