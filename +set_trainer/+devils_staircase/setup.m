function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  set_trainer
%  TRIAL FUNCTION:  devils_staircase

%  Set trial master function
p.trial.pldaps.trialFunction = 'set_trainer.devils_staircase.devils_staircase';

%  Load the joystick calibration file
switch p.trial.session.subject
    case 'Meatball'
        p.trial.joystick.beta = getfield(load('/home/astaroth/Documents/MATLAB/settings/JoystickSettings_Meatball.mat','beta'),'beta');
        
    otherwise
        p.trial.joystick.beta = getfield(load('/home/astaroth/Documents/MATLAB/settings/JoystickSettings.mat','beta'),'beta');
end

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

p.trial.display.humanCLUT(17:24,:) = ...
     [    0    0.4470    0.7410     %  Blue
    0.8500    0.3250    0.0980      %  Orange
    0.9290    0.6940    0.1250      %  Yellow
    0.4940    0.1840    0.5560      %  Purple
    0.4660    0.6740    0.1880      %  Green
    0.3010    0.7450    0.9330      %  Cyan
    0.6350    0.0780    0.1840      %  Scarlet
    0.7500    0.7500    0.750];    %  Gray
p.trial.display.monkeyCLUT(17:24,:) = p.trial.display.humanCLUT(17:24,:);

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
p.trial.display.clut.bGray = 23*[1 1 1]';

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
p.trial.task.features.fixation.width = 10;
p.trial.task.features.fixation.linewidth = 2;
p.trial.task.features.fixation.color = p.trial.display.clut.bWhite;

%  Joystick engage cue (Ready)
p.trial.task.features.ready.width = 175;
p.trial.task.features.ready.linewidth = 2;
p.trial.task.features.ready.color = [1 1 1];

%  Joystick continue hold cue
p.trial.task.features.continue_hold.width = 175;
p.trial.task.features.continue_hold.linewidth = 2;
p.trial.task.features.continue_hold.color = [0.75 0.75 0.75];

%  Hold cue
p.trial.task.features.hold = p.trial.task.features.ready;
p.trial.task.features.hold.color = [0.5 0.5 0.5];

%  Release Cue
p.trial.task.features.release = p.trial.task.features.hold;
p.trial.task.features.release.linewidth = 10;
p.trial.task.features.release.color = [0 0 0];

%  Symbol
p.trial.task.features.symbol = p.trial.task.features.release;
p.trial.task.features.symbol.linewidth = 10;
p.trial.task.features.symbol.width = 140;

%  Trial duration information
p.trial.pldaps.maxTrialLength = 1000;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

p.trial.stimulus.error_code = 0;

p.trial.stimulus.exit_flag = 0;

%  Set up condition array
[training_set,training_noset] = set_generator({'B','S','P'},{'O','Y','G'},{'C','S','T'},'1-set-training',2);

nsets = size(training_set,1);
c = cell(1,2*nsets);
for i=1:nsets
    c{i}.symbols = training_set(i,:);
    c{i}.trial_type = 'set';
    c{i+nsets}.symbols = training_noset(i,:);
    c{i+nsets}.trial_type = 'noset';
end
%c = repmat(c,1,2);
p.conditions=Shuffle(c);

%  Maximum number of trials
p.trial.pldaps.finish = 2*length(c);

%  Condition specific control parameters
p.trial.task.control_variables.fields = {'set','noset'};
p.trial.task.control_variables.set.release_probability = 0.8;
p.trial.task.control_variables.noset.release_probability = 0.2;
p.trial.task.control_variables.set.M_down = 1;
p.trial.task.control_variables.set.step_spread_ratio = 0.5;
p.trial.task.control_variables.noset.M_down = 1;
p.trial.task.control_variables.noset.step_spread_ratio = 0.5;
