function draw(window,centers,indx)
%DRAW Draw the symbol masks using the PTB DrawDots function

%  Get dot coordinates with respect to center
[xy,ndots] = only_zuul.symbol_masks.pixel_coords;

%  Replicate dot coordinates and offset with centers
nmasks = length(indx);
centers = [reshape(repmat(centers(indx,1)',ndots,1),[],1)' ; reshape(repmat(centers(indx,2)',ndots,1),[],1)'];
xy = repmat(xy,1,nmasks) + centers;

%  Generate dot colors
dot_colors = repmat(only_zuul.symbol_masks.pixel_color_list(indx-3*(indx>3)),3,1);

%  For now dots are single square pixels
sizes = ones(1,ndots*nmasks);
shape = 0;

%  Draw the dots
Screen('DrawDots',window,xy,sizes,dot_colors,[1 0],shape);
end