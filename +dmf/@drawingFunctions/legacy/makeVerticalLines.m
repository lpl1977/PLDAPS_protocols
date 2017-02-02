function maskTexture = makeVerticalLines(windowPointer,features)
%  makeVerticalLines Produce vertical lines masking pattern

D = 2*features.symbolRadius;
nSpatialCycles = features.nSpatialCycles;

x = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
mask = 255*ones(D,D,2);

mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*x)));

maskTexture = Screen('MakeTexture',windowPointer,mask);

end

