function maskTexture = makeConcentricCircles(windowPointer,features)
%  makeSpiral Produce concentric circles alpha masking pattern

D = 2*features.symbolRadius;
nSpatialCycles = features.nSpatialCycles;

[x,y] = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
[~,r] = cart2pol(x,y);
mask = 255*ones(D,D,2);

mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*r)));

maskTexture = Screen('MakeTexture',windowPointer,mask);

end

