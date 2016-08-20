 function Meatball(p)
%  TRIAL PARAMETER FILE
%  PACKAGE:  only_zuul
%  TRIAL FUNCTION:  trial_function
%  SUBJECT:  Meatball (aka Spaghetti)

%
%  Constants for Eyelink calibration
%
p.trial.stimulus.fixdotW = 48;  % Calibration target size in pixels
p.trial.stimulus.fpWin = p.trial.display.ppd*[8 8]; % rectangular fixation window in pixels

%
%  REWARDS
%

%  Reward amounts
p.trial.stimulus.reward_amount = 0.3;

%
%  TIMING
%

p.trial.task.timing.delay.duration = 0.75;

p.trial.task.timing.symbol.duration = 0.75;

%  Randomized reward / error delay duration.
p.trial.task.timing.reward_delay.duration = min(exprnd(0.25),0);
p.trial.task.timing.error_delay.duration = p.trial.task.timing.reward_delay.duration;


%
%  Training flags
%
p.trial.task.training.repeat_priority = 0;
p.trial.task.training.use_symbol_masks = true;
p.trial.task.training.continue_symbols = true;
p.trial.task.training.release_for_reward = true;
p.trial.task.training.shuffle_aborts = false;
p.trial.task.training.shuffle_repeats = false;
p.trial.task.training.relative_response_threshold = true;
p.trial.task.training.enforce_fixation = false;



%
%  Log contrast for release cue
%
p.trial.task.features.log10C = sort([-1 -1.25 -1.5 -1.75 -2],'descend');
p.trial.task.features.instructor_log10C = -0.5;
p.trial.task.features.ninstructors = 0;
p.trial.task.features.nreps = 10;
p.trial.task.features.ntotal = 1000;
