function p = joystick_trainer_setup(p)
%joystick_setup a PLDAPS experiment setup file for initial joystick
%testing and training.

%  Create the initial trial structure
p = pdsDefaultTrialStructure(p);

%  Setup default trial values in p.trial
p = joystick_trainer.joystick_defaultTrialVariables(p);

%  Set trial master function, this gets called each trial
p.defaultParameters.pldaps.trialFunction = 'joystick_trainer.joystick_trainer_trial_function';

%  Try and set this (not sure yet what it's for):
p.trial.display.clut.fixationColor = p.trial.display.clut.bg;

%
%  USER DEFINED CONSTANTS
%

%
%  JOYSTICK STATES
%
p.trial.stimulus.joystick_states.JOYSTICK_RELEASED = 0;
p.trial.stimulus.joystick_states.JOYSTICK_ENGAGED = 1;
p.trial.stimulus.joystick_states.JOYSTICK_EQUIVOCAL = 2;

%
%  ERROR TYPES
%
p.trial.stimulus.error_codes.ERROR_ENGAGE_AT_START = 1001;
p.trial.stimulus.error_codes.ERROR_FAIL_TO_ENGAGE = 1002;
p.trial.stimulus.error_codes.ERROR_EARLY_RELEASE = 1003;
p.trial.stimulus.error_codes.ERROR_FAIL_TO_RELEASE = 1004;

%
%  TRIAL STATES
%
p.trial.stimulus.trial_states.STATE_LEADIN = 2001;
p.trial.stimulus.trial_states.STATE_ENGAGE = 2002;
p.trial.stimulus.trial_states.STATE_HOLD = 2010;
p.trial.stimulus.trial_states.STATE_RELEASE = 2020;
p.trial.stimulus.trial_states.STATE_REST = 2030;
p.trial.stimulus.trial_states.STATE_ABORT = 2040;

%
%  User defined variables (these are stored in the trial structure)
%
p.trial.stimulus.timing.leadin_time = 1;
p.trial.stimulus.timing.grace_to_engage = Inf;
p.trial.stimulus.timing.min_hold_time = 6;
p.trial.stimulus.timing.max_hold_time = 8;
p.trial.stimulus.timing.hold_time = NaN;
p.trial.stimulus.timing.grace_to_release = Inf;
p.trial.stimulus.timing.min_rest_time = 0.5;
p.trial.stimulus.timing.max_rest_time = 1;
p.trial.stimulus.timing.rest_time = NaN;
p.trial.stimulus.timing.abort_time = NaN;  % This can flag not to give an abort penalty

%
%  Timers for timing control
%
p.trial.stimulus.timing.leadin_start_time = NaN;
p.trial.stimulus.timing.engage_start_time = NaN;
p.trial.stimulus.timing.release_start_time = NaN;
p.trial.stimulus.timing.rest_start_time = NaN;
p.trial.stimulus.timing.abort_start_time = NaN;
p.trial.stimulus.timing.hold_start_time = NaN;

p.trial.stimulus.timing.engage_cue_start_time = NaN;

%
%  Features of stimulus
%
p.trial.stimulus.features.engage_cue_width = 50;
p.trial.stimulus.features.engage_cue_duty_cycle = 0.75;
p.trial.stimulus.features.engage_cue_period = 0.5;
p.trial.stimulus.features.abort_flash_period = 0.1;
p.trial.stimulus.features.abort_flash_color = [1 0 0];

%
%  Reward sounds
%
p.trial.behavior.reward.sound.file = 'reward';
p.trial.behavior.early_release.sound.file = 'breakfix';
p.trial.behavior.overhold.sound.file = 'incorrect';
p.trial.behavior.reentry.sound.file = 'incorrect';
p.trial.behavior.failtoengage.sound.file = 'incorrect';
p.trial.behavior.trial_abort.sound.file = 'breakfix';
p.trial.behavior.warning.sound.file = 'incorrect';

%  Trial duration information
p.trial.pldaps.maxTrialLength = 1000;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

p.trial.stimulus.error_code = 0;



%
%  Initialize joystick status tracking variables
%
p.trial.stimulus.joystick.current_status = 0;

p.trial.stimulus.deflection_threshold = 5;
p.trial.stimulus.rest_threshold = 4;
p.trial.stimulus.orientation = 0;

%  Reward counts and amounts
p.trial.stimulus.min_reward_amount = 0.05;
p.trial.stimulus.max_reward_amount = 0.1;
p.trial.stimulus.deflect_reward_amount = p.trial.stimulus.min_reward_amount;
p.trial.stimulus.release_reward_amount = p.trial.stimulus.max_reward_amount;

p.trial.stimulus.deflect_reward_period = 1;
p.trial.stimulus.deflect_reward_time = NaN;


p.trial.stimulus.min_reward_wait_time = 1;

p.trial.stimulus.exit_flag = 0;

%  Set up condition array
%  Only one condition--push the joystick
c = cell(1);
c{1}.Nr=1;
p.conditions=repmat(c,1,1000);

%  Maximum number of trials
p.trial.pldaps.finish = 1000;
