function p = setup_v01(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  set_trainer
%  TRIAL FUNCTION:  there_is_no_set.only_zuul

%  Set trial master function
p.trial.pldaps.trialFunction = 'set_trainer.there_is_no_set.only_zuul';

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
%  TIMING
%

p.trial.task.timing.start.start_time = NaN;
p.trial.task.timing.start.cue_start_time = NaN;
p.trial.task.timing.start.cue_display_time = 0.5;
p.trial.task.timing.start.cue_period = 1;

p.trial.task.timing.delay.start_time = NaN;

p.trial.task.timing.forward_mask.start_time = NaN;

p.trial.task.timing.reward.start_time = NaN;
p.trial.task.timing.reward.cue_display_time = 0.5;

%
%  FEATURES
%

%  Fixation cue
p.trial.task.features.fixation.width = 10;
p.trial.task.features.fixation.linewidth = 2;
p.trial.task.features.fixation.color = p.trial.display.clut.bWhite;

%  Response cue
p.trial.task.features.response.diameter = 100;
p.trial.task.features.response.linewidth = 10;

%  Trial duration information
p.trial.pldaps.maxTrialLength = 1000;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

p.trial.stimulus.error_code = 0;

p.trial.stimulus.exit_flag = 0;

%  Subject specific parameters / actions
feval(str2func(strcat('set_trainer.there_is_no_set.',p.trial.session.subject)),p);

%  Set up conditions matrix
log10C = p.trial.task.features.log10C;
lum = 0.5*(1+power(10,log10C));
nlum = length(lum);

nreps = 10;
nblocks = 100;

%  Column order:
%  1--luminance
%  2--log10C
%  3--luminance index
%  4--choice (0==press, 1==release)
%  5--within block trial number
%  6--block number

A = zeros(2*nlum*nreps,6);
A(1:nlum*nreps,1) = repmat(1-lum(:),nreps,1);
A(1:nlum*nreps,2) = repmat(log10C(:),nreps,1);
A(1:nlum*nreps,3) = repmat((1:nlum)',nreps,1);
A(1:nlum*nreps,4) = zeros(nlum*nreps,1);
A(1:nlum*nreps,5) = (1:nlum*nreps)';

A(nlum*nreps+1:2*nlum*nreps,1) = repmat(lum(:),nreps,1);
A(nlum*nreps+1:2*nlum*nreps,2) = repmat(log10C(:),nreps,1);
A(nlum*nreps+1:2*nlum*nreps,3) = repmat((1+nlum:2*nlum)',nreps,1);
A(nlum*nreps+1:2*nlum*nreps,4) = ones(nlum*nreps,1);
A(nlum*nreps+1:2*nlum*nreps,5) = (1:nlum*nreps)';

A = repmat(A,nblocks,1);

blocknum = repmat(1:nblocks,2*nlum*nreps,1);
A(:,6) = blocknum(:);

ntrials = size(A,1);
c = cell(1,ntrials);
for i=1:ntrials
    c{i}.luminance = A(i,1);
    c{i}.log10C = A(i,2);
    c{i}.lum_indx = A(i,3);
    if(A(i,4))
        c{i}.trial_type = 'press';
    else
        c{i}.trial_type = 'release';
    end
    c{i}.trial_number = A(i,5);
    c{i}.block_number = A(i,6);    
end
p.conditions = c;

%  Maximum number of trials
p.trial.pldaps.finish = numel(c);

