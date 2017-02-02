function maskTexture = makeHorizontalLines(windowPointer,features)
%  makeHorizontalLines Produce horizontal lines masking pattern

D = 2*features.symbolRadius;
nSpatialCycles = features.nSpatialCycles;

[~,y] = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
mask = 255*ones(D,D,2);

mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*y)));

maskTexture = Screen('MakeTexture',windowPointer,mask);

end

