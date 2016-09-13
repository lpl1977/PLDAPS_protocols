 function Meatball(p)
%  TRIAL PARAMETER FILE
%  PACKAGE:  only_zuul
%  TRIAL FUNCTION:  trial_function
%  SUBJECT:  Meatball (aka Spaghetti)

%
%  Debug flags
%
p.trial.debug_flags.joystick_zombie = false;

%
%  Training flags
%
p.trial.training_flags.repeat_errors = false;
p.trial.training_flags.continue_symbols = true;
p.trial.training_flags.release_for_reward = false;
p.trial.training_flags.shuffle_aborts = true;
p.trial.training_flags.shuffle_repeats = false;
p.trial.training_flags.relative_response_threshold = true;
p.trial.training_flags.enforce_fixation = true;

%
%  Constants for Eyelink calibration
%
p.trial.stimulus.fixdotW = 24;  % Calibration target size in pixels
p.trial.stimulus.fpWin = p.trial.display.ppd*[20 20]; % rectangular fixation window in pixels

%
%  REWARDS
%

%  Reward amounts
p.trial.stimulus.reward_amount = 0.4;

%
%  TIMING
%

p.trial.specs.timing.delay.duration = 0.75;
p.trial.specs.timing.symbol.display_time = 0.75;
p.trial.specs.timing.symbol.interval = 0;

%  Randomized reward / error delay duration.
max_delay = 1.25;
constant_part = 0;
mean_random_part = 0;
random_part = min(exprnd(mean_random_part),max_delay-constant_part);
p.trial.specs.timing.reward_delay.duration = constant_part + random_part;
p.trial.specs.timing.error_delay.duration = p.trial.specs.timing.reward_delay.duration;



%
%  Log contrast for release cue
%
%p.trial.specs.features.log10C = sort([-1 -1.25 -1.5 -1.75 -2],'descend');
p.trial.specs.features.log10C = sort([-1 -1.25 -1.5 -1.75],'descend');
%p.trial.specs.features.log10C = sort([-1 -1.25 -1.5],'descend');
