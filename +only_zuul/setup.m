function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  only_zuul
%  TRIAL FUNCTION:  trial_function

%
%  This version of the setup file has SET and NOTSET trials with symbols
%  that vary based on color, shape, and fill
%

%
%  PLDAPS specific settings (settings PLDAPS expects to have been set)
%

%  Set trial master function
p.trial.pldaps.trialFunction = 'only_zuul.trial_function';

%  Get default colors and put the default bit names
p = defaultColors(p);
p = defaultBitNames(p);

% dot sizes for drawing
p.trial.stimulus.eyeW = 8;      % eye indicator width in pixels (for console display)
p.trial.stimulus.cursorW = 8;   % cursor width in pixels (for console display)

%  Trial duration information
p.trial.pldaps.maxTrialLength = 5*60;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

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

%  For the sake of convenience define some names to references to the
%  colors.  Remember hWhite means human white whereas bWhite means both
%  white.  m{color} seems like a really bad idea.
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

%
%  Custom settings (settings for only_zuul)
%

%
%  Subject specific timing parameters / actions.  This should be called
%  first in case the subsequent lines require a subject specific setting
%
feval(str2func(strcat('only_zuul.',p.trial.session.subject)),p);

%
%  JOYSTICK
%

%  Load the joystick calibration file
switch p.trial.session.subject
    case 'Meatball'
        p.trial.joystick.default.beta = getfield(load('~/Documents/MATLAB/settings/JoystickSettings_Meatball.mat','beta'),'beta');        
    case 'Murray'
        p.trial.joystick.default.beta = getfield(load('~/Documents/MATLAB/settings/JoystickSettings_Murray.mat','beta'),'beta');
end

%  Thresholds between zones
%  Zone 1--joystick released [-Inf 2]
%  Zone 2--release buffer [2 4]
%  Zone 3--joystick engaged [4 8]
%  Zone 4--press buffer [8 12]
%  Zone 5--joystick pressed [12 Inf]

p.trial.joystick.default.threshold = [2 8 14.5 15];
p.trial.joystick.joystick_warning = p.trial.joystick.default;
p.trial.joystick.joystick_warning.threshold = [2 10 14 15];
p.trial.joystick.engage = p.trial.joystick.joystick_warning;
p.trial.joystick.response_cue = p.trial.joystick.default;

%
%  TIMING
%

p.trial.specs.timing.engage.start_time = NaN;
p.trial.specs.timing.engage.cue_start_time = NaN;
p.trial.specs.timing.engage.cue_display_time = 0.25;
p.trial.specs.timing.engage.cue_extinguish_time = 0.25;

p.trial.specs.timing.delay.start_time = NaN;

p.trial.specs.timing.symbol.start_time = NaN;

p.trial.specs.timing.joystick_warning.start_time = NaN;
p.trial.specs.timing.joystick_warning.duration = 10;

p.trial.specs.timing.eye_warning.start_time = NaN;
p.trial.specs.timing.eye_warning.duration = 10;
p.trial.specs.timing.eye_warning.cue_start_time = NaN;
p.trial.specs.timing.eye_warning.cue_display_time = 0.25;
p.trial.specs.timing.eye_warning.cue_extinguish_time = 0.25;

p.trial.specs.timing.reward.start_time = NaN;

p.trial.specs.timing.response_cue.start_time = NaN;
p.trial.specs.timing.response_cue.start_frame = NaN;
p.trial.specs.timing.response_cue.grace = 20;
p.trial.specs.timing.response_cue.buffer_entry_time = NaN;
p.trial.specs.timing.response_cue.buffer_maximum_time = 10/120;

p.trial.specs.timing.timeout.start_time = NaN;
p.trial.specs.timing.timeout.duration = 2;

p.trial.specs.timing.error_penalty.start_time = NaN;
p.trial.specs.timing.error_penalty.duration = 0.5;

p.trial.specs.timing.reward_delay.start_time = NaN;
p.trial.specs.timing.reward_delay.eligible_start_time = NaN;

p.trial.specs.timing.error_delay.start_time = NaN;
p.trial.specs.timing.error_delay.eligible_start_time = NaN;

p.trial.specs.timing.buffer.start_time = NaN;
p.trial.specs.timing.buffer.maximum_time = 10/120;

%
%  FEATURES
%

%  Fixation cue
p.trial.specs.features.fixation.width = 12;
p.trial.specs.features.fixation.linewidth = 3;
p.trial.specs.features.fixation.color = p.trial.display.clut.bWhite;

%  Engage
p.trial.specs.features.engage = p.trial.specs.features.fixation;
p.trial.specs.features.engage.color = p.trial.display.clut.bYellow;

%  Warning cue
p.trial.specs.features.warning = p.trial.specs.features.fixation;
p.trial.specs.features.joystick_warning.color = p.trial.display.clut.bRed;

%  Response cue
p.trial.specs.features.response_cue.outer_diameter = 120;
p.trial.specs.features.response_cue.inner_diameter = 90;

%  Noise annulus
p.trial.specs.features.annulus.outer_diameter = 150;
p.trial.specs.features.annulus.inner_diameter = 60;
p.trial.specs.features.annulus.noise_sigma = 0.2149;

%  Symbols
%
%  Shapes are Circles, Squares, and Diamonds
%  Patterns are Filled, Open, and Concentric
p.trial.specs.features.symbol.color_indx = [16 17 18 19 20 21 22];
p.trial.specs.features.symbol.color_names = {'B','O','Y','P','G','C','S'};

p.trial.specs.features.symbol.background = 23;
p.trial.specs.features.symbol.max_diameter = 225;
p.trial.specs.features.symbol.radius = 220;

p.trial.specs.features.symbol.colors = {'P','G','O'};
p.trial.specs.features.symbol.shapes = {'C','S','D'};
p.trial.specs.features.symbol.patterns = {'F','O','C'};

%  Geometry for symbols
radius = p.trial.specs.features.symbol.radius;
dx = radius*cos(pi/6);
dy = radius*sin(pi/6);
ctr = [p.trial.display.ctr(1) p.trial.display.ctr(2)];

p.trial.specs.features.symbol.polar = {sprintf('210%c',char(176)), sprintf('-30%c',char(176)), sprintf('90%c',char(176)), sprintf('150%c',char(176)), sprintf('-90%c',char(176)), sprintf('30%c',char(176))};
p.trial.specs.features.symbol.centers = [ctr + [-dx -dy] ; ctr + [dx -dy] ; ctr + [0 radius] ; ctr + [-dx dy] ; ctr + [0 -radius] ; ctr + [dx dy]];

%
%  Generate the sequences
%

S = only_zuul.sequence.generator(p.trial.specs.features.symbol.colors,p.trial.specs.features.symbol.shapes,p.trial.specs.features.symbol.patterns);

%  For now, sets will be sequences which share the same color but neither
%  shape nor pattern, nor do any symbols in the sequence share shape or
%  pattern.
setrulecodes = only_zuul.sequence.combvec({4,0,0});
nsetrules = size(setrulecodes,2);
setrules = cell(nsetrules,1);
for i=1:nsetrules
    setrules{i} = sprintf('%d%d%d',setrulecodes(:,i));
end
sets = only_zuul.sequence.selector(S,setrules);

%  In addition, I want to use only sets of purple (all notsets will have
%  the first two symbols be purple).
sets = sets(strncmp(sets(:,1),'P',1),:);
nsets = size(sets,1);
p.trial.specs.features.sets = sets;

%  For now, notsets will be sequences in which symbols share a color
%  feature with at most one other symbol in the sequence, but not either
%  shape or pattern.
notsetrulecodes = only_zuul.sequence.combvec({[0 1 2 3],0,0});
nnotsetrules = size(notsetrulecodes,2);
notsetrules = cell(nnotsetrules,1);
for i=1:nnotsetrules
    notsetrules{i} = sprintf('%d%d%d',notsetrulecodes(:,i));
end
notsets = only_zuul.sequence.selector(S,notsetrules);

%  As above, I want to use notsets in which the first two symbols are purple
notsets = notsets(strncmp(notsets(:,1),'P',1) & strncmp(notsets(:,2),'P',1),:);
nnotsets = size(notsets,1);
p.trial.specs.features.notsets = notsets;

%
%  CONDITIONS MATRIX
%

%  There are a huge number of conditions!  There may be too many for me to
%  get repetitions of any unique trial in a block let alone a single
%  session. I am grouping them into shuffle groups.  If I want to have
%  multiple repetitions of a trial within a shuffle group a hack may be to
%  just clone the set and notset lists.
nreps = 4;
sets = sets(repmat((1:nsets)',nreps,1),:);
nsets = size(sets,1);
notsets = notsets(repmat((1:nnotsets)',nreps,1),:);
nnotsets = size(notsets,1);

%
%  Contrasts
% 
log10C = p.trial.specs.features.log10C;
nlum = length(log10C);
bgColor =  p.trial.display.bgColor(1);
lum = bgColor(1) - (1-bgColor(1))*power(10,log10C);

%  Set up trial counts
ntrials = lcm(nlum,lcm(nsets,nnotsets));

%  Matrix for trial specifiers
%
%  Column order:
%  1--index into luminance list (or 0 for background)
%  2--trial class (1==set/release, 2==notset/press)
%  3--sequence index
%  4--shuffle group

%  Set trials
Aset = zeros(ntrials,4);
Aset(:,1) = repmat((1:nlum)',ntrials/nlum,1);
Aset(:,2) = 1;
Aset(:,3) = reshape(repmat(1:nsets,ntrials/nsets,1),ntrials,1);
Aset(:,4) = reshape(repmat(1:ntrials/(nlum*nreps),nlum*nreps,1),ntrials,1);

%  I need to shuffle the order of sequences within this subset
Aset(:,3) = Shuffle(Aset(:,3));

%  Notset trials
Anotset = zeros(ntrials,4);
Anotset(:,1) = 0;
Anotset(:,2) = 2;
Anotset(:,3) = repmat((1:nnotsets)',ntrials/nnotsets,1);
Anotset(:,4) = Aset(:,4);

%  I need to shuffle the order of sequences within this subset
Anotset(:,3) = Shuffle(Anotset(:,3));

%  all trials
A = [Aset ; Anotset];

%  Regroup based on shuffle group
A = sortrows(A,[4 1]);

%
%  Prepare PLDAPS conditions cell array
%

%  Features of the trials
%
%  luminance -- for stimulus preparation
%  log10C -- for display
%  sequence_type -- set or notset
%  set_type -- for now ignored
%  symbol_codes -- array of strings describing symbols
%  response_type -- release or press
%  shuffle_group -- trials to shuffle together when reshuffling

c = cell(1,2*ntrials);
for i=1:2*ntrials
    
    luminance_indx = A(i,1);
    trial_class = A(i,2);
    sequence_indx = A(i,3);
    shuffle_group = A(i,4);
        
    if(luminance_indx)
        c{i}.luminance = lum(luminance_indx);
        c{i}.log10C = log10C(luminance_indx);
    else
        c{i}.luminance = bgColor;
        c{i}.log10C = -Inf;
    end
    
    switch trial_class
        case 1
            c{i}.sequence_type = 'set';
            c{i}.symbol_codes = {sets{sequence_indx,1},sets{sequence_indx,2},sets{sequence_indx,3}};
            c{i}.response_type = 'release';
        case 2
            c{i}.sequence_type = 'notset';
            c{i}.symbol_codes = {notsets{sequence_indx,1},notsets{sequence_indx,2},notsets{sequence_indx,3}};
            c{i}.response_type = 'press';
    end
    c{i}.shuffle_group = shuffle_group;
end
p.conditions = c;

%  Maximum number of trials -- set this to a number bigger than ntrials so
%  that PLDAPS doesn't automatically quit on us
p.trial.pldaps.finish = 4*ntrials;

%
%  Constants
%

p.trial.specs.constants.min_trial_time = 60;
p.trial.specs.constants.trials_per_block = ntrials*nlum/nsets;
p.trial.specs.constants.num_blocks = 2*nsets/nlum;
p.trial.specs.constants.num_trials = 2*ntrials;

%
%  TELEMETRY
%

%  Initialize trial indexing
p.functionHandles.indexing = only_zuul.indexing(A(:,4));

%  Initialize performance tracking
p.functionHandles.performance = only_zuul.performance; %(p.trial.specs.features.log10C);
