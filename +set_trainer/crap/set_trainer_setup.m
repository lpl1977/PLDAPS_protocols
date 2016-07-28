function p = set_trainer_setup(p)
%set_trainer_setup a PLDAPS experiment setup file for set game training

%  Create the initial trial structure
%p = pdsDefaultTrialStructure(p);

%  Set trial master function
p.trial.pldaps.trialFunction = 'set_trainer.set_trainer';

%  Get default colors and put the default bit names in for now
p = defaultColors(p);
p = defaultBitNames(p);

% dot sizes for drawing
p.trial.stimulus.eyeW      = 8;    % eye indicator width in pixels
p.trial.stimulus.fixdotW   = 8;    % width of the fixation dot
p.trial.stimulus.targdotW  = 8;    % width of the target dot
p.trial.stimulus.cursorW   = 8;   % cursor width in pixels

%  Put additional colors into the human and monkey CLUT
p.trial.display.humanCLUT(16:22,:) = ...
     [    0    0.4470    0.7410     %  Blue
    0.8500    0.3250    0.0980      %  Orange
    0.9290    0.6940    0.1250      %  Yellow
    0.4940    0.1840    0.5560      %  Purple
    0.4660    0.6740    0.1880      %  Green
    0.3010    0.7450    0.9330      %  Cyan
    0.6350    0.0780    0.1840];    %  Scarlet
p.trial.display.monkeyCLUT(16:22,:) = p.trial.display.humanCLUT(16:22,:);

%  Set up blend from background to scarlet in positions 23 to 123.
w1 = linspace(0,1,100)';
w2 = 1-w1;
w1 = repmat(w1,1,3);
w2 = repmat(w2,1,3);

p.trial.display.humanCLUT(22:121,:) = repmat([0.635 0.078 0.184],100,1).*w2 + repmat([0.5 0.5 0.5],100,1).*w1;
p.trial.display.monkeyCLUT(22:121,:) = p.trial.display.humanCLUT(22:121,:);

%  For the sake of convenience define some references to the colors
p.trial.display.clut.hWhite = 5*[1 1 1]';
p.trial.display.clut.bWhite = 7*[1 1 1]';
p.trial.display.clut.hCyan = 8*[1 1 1]';
p.trial.display.clut.bBlack = 9*[1 1 1]';
p.trial.display.clut.hGreen = 12*[1 1 1]';
p.trial.display.clut.hRed = 13*[1 1 1]';
p.trial.display.clut.hBlack =14*[1 1 1]';

p.trial.display.clut.B = 15*[1 1 1]';
p.trial.display.clut.O = 16*[1 1 1]';
p.trial.display.clut.Y = 17*[1 1 1]';
p.trial.display.clut.P = 18*[1 1 1]';
p.trial.display.clut.G = 19*[1 1 1]';
p.trial.display.clut.C = 20*[1 1 1]';
p.trial.display.clut.S = 21*[1 1 1]';

p.trial.sound.useForReward = 0;
p.trial.control_flags.use_eyepos = true;

%
%  SYMBOLS
%




%
%  FEATURES
%

%  Fixation square
p.trial.stimulus.features.fixation.width = 10;
p.trial.stimulus.features.fixation.linewidth = 2;
p.trial.stimulus.features.fixation.color = p.trial.display.clut.bWhite;

%  Engage cue
p.trial.stimulus.states.engage.features.width = 150;
p.trial.stimulus.states.engage.features.linewidth = 8;
p.trial.stimulus.states.engage.features.color = p.trial.display.clut.bWhite;

%  Release Cue
p.trial.stimulus.states.release.features = p.trial.stimulus.states.engage.features;
p.trial.stimulus.states.release.features.color = p.trial.display.clut.bBlack;

%
%  TIMING
%

%  Engage cue
p.trial.stimulus.states.engage.timing.start_time = NaN;
p.trial.stimulus.states.engage.timing.cue_start_time = NaN;
p.trial.stimulus.states.engage.timing.cue_display_time = 0.5;
p.trial.stimulus.states.engage.timing.cue_period = 1;
p.trial.stimulus.states.engage.timing.engage_time = NaN;
p.trial.stimulus.states.engage.timing.post_engage_delay = 0.5;

%  Release
p.trial.stimulus.states.feedback_delay.timing.start_time = NaN;
p.trial.stimulus.states.feedback_delay.timing.delay = 0.5;

%  Timeout
p.trial.stimulus.states.timeout.timing.start_time = NaN;
p.trial.stimulus.states.timeout.timing.max_duration = 1.5*5;
p.trial.stimulus.states.timeout.timing.duration = 1;

%  Symbols
p.trial.stimulus.states.symbols.timing.start_time = NaN;
p.trial.stimulus.states.symbols.timing.display_time = 0.5;
p.trial.stimulus.states.symbols.timing.total = 1.5;


%
%  Flow control
%

%  Symbols
p.trial.stimulus.flow_control.current_symbol = 1;
p.trial.stimulus.flow_control.min_symbols = 3;

%  Trial
p.trial.stimulus.flow_control.trial_state = NaN;

%  Error type
p.trial.stimulus.flow_control.error_code = NaN;

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
p.trial.pldaps.finish = Inf;
