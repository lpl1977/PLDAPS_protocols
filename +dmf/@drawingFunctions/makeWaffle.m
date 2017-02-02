function maskTexture = makeWaffle(windowPointer,features)
%  makeWaffle Produce waffle masking pattern

D = 2*features.symbolRadius;
nSpatialCycles = features.nSpatialCycles;

[x,y] = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
mask = 255*ones(D,D,2);

mask(:,:,2) = mask(:,:,2).*(0.25*(1-cos(pi*nSpatialCycles*x)).*(1-cos(pi*nSpatialCycles*y)));

maskTexture = Screen('MakeTexture',windowPointer,mask);

end

