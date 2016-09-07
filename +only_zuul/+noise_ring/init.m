function init(noise_dim,cue_dim,rng_seed)
%INIT Initialize the noise ring package
%  Prior to any other call to noise ring functions, init generates the
%  coordinates of the noise and signal pixels and stores the random number
%  generator seed for subsequent use.
%
%  Input arguments:
%  noise_dim--inner and outer diameter of the noise ring
%  cue_dim--inner and outer diameter of the cue ring
%  rng_seed--random number generator seed
%
%  Output arguments:
%  For now, none

%  Determine and store initial dot coordinates
only_zuul.noise_ring.pixel_coords(noise_dim,cue_dim);

%  Store initial random number generator seed
only_zuul.noise_ring.preserve_seed(rng_seed);
end