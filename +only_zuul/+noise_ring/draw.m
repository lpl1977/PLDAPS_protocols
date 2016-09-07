function draw(window,cue_lum,background,sigma,center)
%DRAW Draw the symbol masks using the PTB DrawDots function
    
%  Get coordinates of dots and logical index of cue dots
[xy,cue_pixel_index] = only_zuul.noise_ring.pixel_coords;
N = length(cue_pixel_index);

%  Generate the noise
rng(only_zuul.noise_ring.preserve_seed);
dot_lum = background + sigma*randn(1,N);
only_zuul.noise_ring.preserve_seed(rng);

%  Add in the cue
dot_lum(cue_pixel_index) = dot_lum(cue_pixel_index) + cue_lum;

%  Threshold and convert to RGB triplets
dot_lum(dot_lum>1) = 1;
dot_lum(dot_lum<0) = 0;
dot_lum = repmat(dot_lum,3,1);

%  Dot sizes, for now single pixel squares
sizes = ones(1,N);
shape = 0;

%  Draw the dots
Screen('DrawDots',window,xy,sizes,dot_lum,center,shape);
end