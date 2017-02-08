function module(p,state)
%MODULE Setup and drawing of response cue with noise stimulus
%
%  only_zuul.response_cue.module(p,state)
%
%  This is a PLDAPS module for the openReception branch.  This produces the
%  pixel coordinates and stores the seed for the random number generator
%  prior to the first trial and then also can save the seed at the end of
%  the experiment.

switch state
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        disp('****************************************************************')
        disp('Executing module pixelNoise at state experimentPostOpenScreen')
        disp('Creating pixel coordinates and storing rng seed for response cue')
        disp('****************************************************************')
        annulus_dimensions = [p.trial.specs.features.annulus.outer_diameter p.trial.specs.features.annulus.inner_diameter];
        response_cue_dimensions = [p.trial.specs.features.response_cue.outer_diameter p.trial.specs.features.response_cue.inner_diameter];
        p.functionHandles.rch = only_zuul.response_cue.pixel_noise(annulus_dimensions,response_cue_dimensions,rng);
        
    case p.trial.pldaps.trialStates.experimentCleanUp
        disp('****************************************************************')
        disp('Executing module pixelNoise at state experimentCleanUp')
        disp('Store random number generator seed from noise stimuli')
        disp('****************************************************************')
        p.trial.specs.rng_seed = p.functionHandles.rch.initial_seed;
        delete(p.functionHandles.rch);
end
end