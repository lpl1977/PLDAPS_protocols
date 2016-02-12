function p = joystick_defaultTrialVariables(p)
% dv = joystick_defaultTrialVariables(dv)

%%% SET ITERATORS FOR TRIAL STATES %%
%   Stimulus display works by iterating between display 'states'. All of
%   iterators are important for keeping track of what state the stimulus
%   display is in at an Screen('Flip') call. 
p.trial.flagNextTrial  = 0; % flag for ending the trial
p.trial.flagBuzzer = 1;  % flag for playing the break fixation sounds
p.trial.iFrame     = 1;  % frame index
p.trial.iLoop      = 1;  % for pldaps while loop
p.trial.iSample    = 1;  % for sampling rate
p.trial.iPhotodiode = 1; % for photodiode flash 
p.trial.state     = p.trial.stimulus.states.START;
p.trial.stimulus.timeLastFrame   = 0;
p.trial.stimulus.timeLastEyePos  = 0;
p.trial.stimulus.timeBreakFix    = nan; 
p.trial.stimulus.timeComplete    = nan;
p.trial.stimulus.timeTargetOn    = nan;  % flips when the targets come on 
p.trial.stimulus.timeTargetOff   = nan;  % flips when the targets come on 
p.trial.stimulus.timeFpOn        = nan;
p.trial.stimulus.timeFpEntered   = nan;
p.trial.stimulus.timeFpOff       = nan;
p.trial.stimulus.timeStimOn      = nan; 
p.trial.stimulus.timeStimOff     = nan; 
p.trial.stimulus.timeChoice      = nan; 
p.trial.stimulus.frameTargetOn   = nan;  
p.trial.stimulus.frameTargetOff  = nan;  
p.trial.stimulus.frameFpOn       = nan;
p.trial.stimulus.frameFpOff      = nan; 
p.trial.stimulus.frameStimOn     = nan(1,100); 
p.trial.stimulus.frameStimOff    = nan(1,100); 

%%% SET COLOR FLAGS FOR HUMAN AND MONKEY LOOK UP TABLES %%%
% Initialize the color for all items to be drawn. Every item is drawn on 
% every flip even if it is invisible so that the computation time is
% identical every sample regardless of what is being drawn. To start off
% with, for example, the fixation point (f1color) is set to the background
% color, making it invisible to both the human and the monkey. 
p.trial.stimulus.colorCursorDot     = p.trial.display.clut.cursor;
p.trial.stimulus.colorEyeDot        = p.trial.display.clut.eyepos;
p.trial.stimulus.colorFixDot        = p.trial.display.clut.bg;
p.trial.stimulus.colorFixWindow     = p.trial.display.clut.bg;
p.trial.stimulus.colorTarget1Dot     = p.trial.display.clut.bg;  
p.trial.stimulus.colorTarget2Dot     = p.trial.display.clut.bg;  
p.trial.stimulus.colorTarget1Window  = p.trial.display.clut.bg;  
p.trial.stimulus.colorTarget2Window  = p.trial.display.clut.bg;  