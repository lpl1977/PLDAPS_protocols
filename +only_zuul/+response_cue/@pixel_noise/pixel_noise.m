classdef pixel_noise < handle
    %PIXEL_NOISE Handle class for tracking coordinates and rng seeds
    %   At start of experiment the pixel coordinates are calculated and the
    %   random number generator is seeded.  We need to keep these
    %   throughout the experiment and will use handle class to do it
    %
    %   Lee Lovejoy
    %   ll2833@columbia.edu
    %   September 2016
    
    
    properties
        pixel_coords
        cue_pixel_indx
        initial_seed
        current_seed
    end
    
    methods
        %  Class constructor
        function obj = pixel_noise(annulus,response_cue,rng_seed)
            
            %  Extract dimensions
            annulus_outer_diameter = annulus(1);
            annulus_inner_diameter = annulus(2);
            
            response_cue_outer_diameter = response_cue(1);
            response_cue_inner_diameter = response_cue(2);            
            
            %  Get coordinates and radii of dots
            [x,y] = meshgrid(1:annulus_outer_diameter,1:annulus_outer_diameter);
            x = x(:) - annulus_outer_diameter/2;
            y = y(:) - annulus_outer_diameter/2;
            r = sqrt(x.^2 + y.^2);
            
            %  Store coordinates of dots included within noise annulus
            indx = r <= annulus_outer_diameter/2 & r >= annulus_inner_diameter/2;
            obj.pixel_coords = [x(indx)'; y(indx)'];
            
            %  Store indices dots within cue
            obj.cue_pixel_indx = r(indx) <= response_cue_outer_diameter/2 & r(indx) >= response_cue_inner_diameter/2;     
            
            %  Store random number generator seed
            obj.initial_seed = rng_seed;
            obj.current_seed = rng_seed;
        end
        
        %  Draw function
        %  Draw the noise and response cue using PTB DrawDots
        function draw(obj,window,cue_lum,background,sigma,center)
            
            %  Get coordinates of dots and logical index of cue dots
            xy = obj.pixel_coords;
            indx = obj.cue_pixel_indx;
            N = length(indx);
            seed = obj.current_seed;
            
            %  Generate the noise
            rng(seed);
            dot_lum = background + sigma*randn(1,N);
            obj.current_seed = rng;
            
            %  Add in the cue
            dot_lum(indx) = dot_lum(indx) + cue_lum;
            
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
    end
end

