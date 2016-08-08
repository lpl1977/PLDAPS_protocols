function p = setup_v02(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  set_trainer
%  TRIAL FUNCTION:  there_is_no_set.only_zuul

%
%  This version of the setup file has a conditions matrix which has trials
%  randomly shuffled within blocks.  There is as of yet no noise and I only
%  anticipate one or a few very easilty distinguishable contrasts.
%

%  Set trial master function
p.trial.pldaps.trialFunction = 'set_trainer.there_is_no_set.only_zuul';

%  Get default colors and put the default bit names in
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

p.trial.display.humanCLUT(17:25,:) = ...
     [    0    0.4470    0.7410     %  Blue
    0.8500    0.3250    0.0980      %  Orange
    0.9290    0.6940    0.1250      %  Yellow
    0.4940    0.1840    0.5560      %  Purple
    0.4660    0.6740    0.1880      %  Green
    0.3010    0.7450    0.9330      %  Cyan
    0.6350    0.0780    0.1840      %  Scarlet
    p.trial.display.bgColor        %  Gray
    1.000     0         0];         %  Red   
p.trial.display.monkeyCLUT(17:25,:) = p.trial.display.humanCLUT(17:25,:);

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

p.trial.display.clut.bRed = 24*[1 1 1]';

p.trial.sound.useForReward = 0;
p.trial.control_flags.use_eyepos = false;


%
%  JOYSTICK
%

%  Load the joystick calibration file
switch p.trial.session.subject
    case 'Meatball'
        p.trial.joystick.default.beta = getfield(load('/home/astaroth/Documents/MATLAB/settings/JoystickSettings_Meatball.mat','beta'),'beta');        
    otherwise
        p.trial.joystick.default.beta = getfield(load('/home/astaroth/Documents/MATLAB/settings/JoystickSettings.mat','beta'),'beta');
end

%  Thresholds between zones
%  Zone 1--joystick released [-Inf 2]
%  Zone 2--release buffer [2 4]
%  Zone 3--joystick engaged [4 8]
%  Zone 4--press buffer [8 12]
%  Zone 5--joystick pressed [12 Inf]

p.trial.joystick.default.threshold = [2 8 14.5 15];
p.trial.joystick.warning = p.trial.joystick.default;
p.trial.joystick.warning.threshold = [2 10 14 15];
p.trial.joystick.engage = p.trial.joystick.warning;

%
%  TIMING
%

p.trial.task.timing.engage.start_time = NaN;
p.trial.task.timing.engage.cue_start_time = NaN;
p.trial.task.timing.engage.cue_display_time = 0.25;
p.trial.task.timing.engage.cue_extinguish_time = 0.25;

p.trial.task.timing.delay.start_time = NaN;

p.trial.task.timing.symbol.start_time = NaN;

p.trial.task.timing.warning.start_time = NaN;

p.trial.task.timing.reward.start_time = NaN;

p.trial.task.timing.response.start_time = NaN;
p.trial.task.timing.response.start_frame = NaN;

p.trial.task.timing.timeout.start_time = NaN;

p.trial.task.timing.error_penalty.start_time = NaN;

p.trial.task.timing.reward_delay.start_time = NaN;

p.trial.task.timing.error_delay.start_time = NaN;

p.trial.task.timing.buffer.start_time = NaN;
p.trial.task.timing.buffer.maximum_time = 10/120;

p.trial.task.timing.response.grace = 20;

p.trial.task.timing.warning.duration = 10;

p.trial.task.timing.timeout.duration = 2;

p.trial.task.timing.error_penalty.duration = 0.5;

%
%  FEATURES
%

%  Fixation cue
p.trial.task.features.fixation.width = 12;
p.trial.task.features.fixation.linewidth = 3;
p.trial.task.features.fixation.color = p.trial.display.clut.bWhite;

%  Engage
p.trial.task.features.engage = p.trial.task.features.fixation;
p.trial.task.features.engage.color = p.trial.display.clut.bYellow;

%  Warning cue
p.trial.task.features.warning = p.trial.task.features.fixation;
p.trial.task.features.warning.color = p.trial.display.clut.bRed;

%  Response cue
p.trial.task.features.response.diameter = 100;
p.trial.task.features.response.linewidth = 10;

%  Noise annulus
p.trial.task.features.annulus.outer_diameter = 150;
p.trial.task.features.annulus.inner_diameter = 60;
p.trial.task.features.annulus.noise_sigma = 0.2149;


%  Symbols / Symbol Masks
p.trial.task.features.symbol.colors = [16 18 19 20 21 22];
p.trial.task.features.symbol.background = 23;
p.trial.task.features.symbol.outer_diameter = 200;
p.trial.task.features.symbol.inner_diameter = p.trial.task.features.symbol.outer_diameter/sqrt(2);
p.trial.task.features.symbol.radius = 200;

diameter = p.trial.task.features.symbol.outer_diameter;
baseRect = [0 0 diameter diameter];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
radius = p.trial.task.features.symbol.radius;
dx = radius*cos(pi/6);
dy = radius*sin(pi/6);
p.trial.task.features.symbol.positions = [centeredRect + [-dx -dy -dx -dy]; centeredRect + [dx -dy dx -dy]; centeredRect + [0 radius 0 radius]];

%  Trial duration information
p.trial.pldaps.maxTrialLength = 5*60;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%
%  Constants
%
p.trial.task.constants.minTrialTime = 60;
p.trial.task.constants.TrialsPerBlock = [];
p.trial.task.constants.maxBlocks = [];
p.trial.task.constants.maxTrials = [];

%  Subject specific timing parameters / actions
feval(str2func(strcat('set_trainer.there_is_no_set.',p.trial.session.subject)),p);

%
%  CONDITIONS MATRIX
%

%  The trials are organized into blocks.  There are nblocks and
%  2*nlum*nreps trials per block.  Within a block the trials will be
%  shuffled.  There are ninstructors for press at log10C = -0.5 and
%  ninstructors for release at log10C = -Inf at the start of each block.

%  Set up conditions matrix
log10C = p.trial.task.features.log10C;
lum = p.trial.display.bgColor(1) + (1-p.trial.display.bgColor(1))*power(10,log10C);
nlum = length(lum);

p.trial.task.features.instructor_log10C = -0.5;
instructor_lum = p.trial.display.bgColor(1) + (1-p.trial.display.bgColor(1))*power(10,p.trial.task.features.instructor_log10C);

ninstructors = 4;
nreps = 10;
ntotal = 1000;

p.trial.task.constants.TrialsPerBlock = 2*nlum*nreps + 2*ninstructors;

nblocks = floor(ntotal/p.trial.task.constants.TrialsPerBlock);

p.trial.task.constants.maxBlocks = nblocks;

p.trial.task.constants.maxTrials = p.trial.task.constants.maxBlocks*p.trial.task.constants.TrialsPerBlock;

nshufflegroups = 2;

%  Column order:
%  1--luminance
%  2--log10C
%  3--luminance index -- into matrix for performance display purposes
%  4--choice (1==press, 0==release)
%  5--within block trial number
%  6--block number
%  7--shuffle group (all trials within a block of a given shuffle group can
%  be shuffled together, but not with trials of a different shuffle group).

A = zeros(p.trial.task.constants.TrialsPerBlock,7);

%  Release instructors
A(1:ninstructors,1) = p.trial.display.bgColor(1);
A(1:ninstructors,2) = -Inf;
A(1:ninstructors,3) = 1;
A(1:ninstructors,4) = 0;

%  Press Instructors
A(ninstructors+1:2*ninstructors,1) = instructor_lum;
A(ninstructors+1:2*ninstructors,2) = p.trial.task.features.instructor_log10C;
A(ninstructors+1:2*ninstructors,3) = nlum+3;
A(ninstructors+1:2*ninstructors,4) = 1;

A(1:2*ninstructors,5) = (1:2*ninstructors)';
A(1:2*ninstructors,7) = 1;

%  Release trials
A(2*ninstructors+1:2*ninstructors+nlum*nreps,1) = p.trial.display.bgColor(1);
A(2*ninstructors+1:2*ninstructors+nlum*nreps,2) = -Inf;
A(2*ninstructors+1:2*ninstructors+nlum*nreps,3) = 2;
A(2*ninstructors+1:2*ninstructors+nlum*nreps,4) = 0;

%  Press trials
A(2*ninstructors+nlum*nreps+1:2*ninstructors+2*nlum*nreps,1) = repmat(lum(:),nreps,1);
A(2*ninstructors+nlum*nreps+1:2*ninstructors+2*nlum*nreps,2) = repmat(log10C(:),nreps,1);
A(2*ninstructors+nlum*nreps+1:2*ninstructors+2*nlum*nreps,3) = repmat((3:nlum+2)',nreps,1);
A(2*ninstructors+nlum*nreps+1:2*ninstructors+2*nlum*nreps,4) = 1;

A(1:2*ninstructors+2*nlum*nreps,5) = (1:2*ninstructors+2*nlum*nreps)';

A(2*ninstructors+1:2*ninstructors+2*nlum*nreps,7) = 2;

A = repmat(A,nblocks,1);

blocknum = repmat(1:nblocks,2*ninstructors+2*nlum*nreps,1);
A(:,6) = blocknum(:);

%  Now go through and shuffle the trials within the blocks.
for i=1:nblocks
    for j=1:nshufflegroups
        indx = A(:,6)==i & A(:,7)==j;
        A(indx,1:4) = Shuffle(A(indx,1:4),2);
    end
end

%  Features of the trials
%
%  luminance -- for stimulus preparation
%  log10C -- for display
%  lum_indx -- for record keeping
%  trial_type -- press or release
%  symbol_type -- mask versus the symbol code
%  repeat_priority -- allows selective repeats of trials

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
    c{i}.symbol_type = 'mask';
    c{i}.trial_number = A(i,5);
    c{i}.block_number = A(i,6);
    c{i}.repeat_priority = A(i,7);
end
p.conditions = c;

%  Maximum number of trials
p.trial.pldaps.finish = Inf;

