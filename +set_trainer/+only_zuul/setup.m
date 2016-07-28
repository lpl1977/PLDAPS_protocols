function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  set_trainer
%  TRIAL FUNCTION:  only_zuul

%  Set trial master function
p.trial.pldaps.trialFunction = 'set_trainer.only_zuul.only_zuul';

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
% 
% %  Hold cue
% p.trial.task.features.hold = p.trial.task.features.ready;
% p.trial.task.features.hold.color = [0.5 0.5 0.5];

%  Response Cue
p.trial.task.features.response = p.trial.task.features.ready;
p.trial.task.features.response.linewidth = 10;
p.trial.task.features.response.color = [0 0 0];

%  Symbol
p.trial.task.features.symbol = p.trial.task.features.response;
p.trial.task.features.symbol.linewidth = 10;
p.trial.task.features.symbol.width = 140;

%  Trial duration information
p.trial.pldaps.maxTrialLength = 1000;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

p.trial.stimulus.error_code = 0;

p.trial.stimulus.exit_flag = 0;

        
%  Subject specific parameters / actions
feval(str2func(strcat('set_trainer.only_zuul.',p.trial.session.subject)),p);
        
%  Set up symbol sequences
[training_set,training_notset] = set.generator({'B','S','P'},{'O','Y','G'},{'C','S','T'},'1-set-training',2);
nset = size(training_set,1);
nnotset = size(training_notset,1);

training_notset = Shuffle(training_notset);

%  Set up log coherences
nlog_c = length(p.trial.task.log_contrast_list);
log_c_indx = repmat(1:nlog_c,1,nset/nlog_c);

%  Set up for blocks
nblocks = nnotset/nset;

%  Signal present v signal absent
nsamps = 15;
ntest_trials = nlog_c*nsamps;

%  Noise sequence parameters
nsamps = 1 + ceil(sum(p.trial.task.timing.response.duration)/p.trial.task.log_contrast_delta);

%  1 block has
%  all training_set (nset)
%  nset drawn from the training_notset
%  comparator trials (nset)

c = cell(2*nset + 2*ntest_trials,nblocks);
for i=1:nblocks
    
    %  sets
    for j=1:nset
        c{j,i}.trial_type = 'set';
        c{j,i}.symbols = training_set(j,:);
        c{j,i}.log_c_indx = log_c_indx(j);
        c{j,i}.log_c_noise = normrnd(0,1,nsamps,1);
    end
    
    %  notset
    for j=1:nset
        c{j+nset,i}.trial_type = 'notset';
        c{j+nset,i}.symbols = training_notset((i-1)*nset+j,:);
        c{j+nset,i}.log_c_noise = normrnd(0,1,nsamps,1);
    end
    
    %  signal present
    for j=1:ntest_trials
        c{j+2*nset,i}.trial_type = 'signal_present';
        c{j+2*nset,i}.log_c_indx = log_c_indx(j);
        c{j+2*nset,i}.log_c_noise = normrnd(0,1,nsamps,1);
    end
    
    %  signal absent
    for j=1:ntest_trials
        c{j+2*nset+ntest_trials,i}.trial_type = 'signal_absent';
        c{j+2*nset+ntest_trials,i}.log_c_noise = normrnd(0,1,nsamps,1);
    end
    
    %  Shuffle block
    c(:,i) = Shuffle(c(:,i));
end
p.conditions = c;

%  Maximum number of trials
p.trial.pldaps.finish = numel(c);

