function maskTexture = makeSpiral(windowPointer,features)
%  makeSpiral Produce spiral alpha masking pattern

D = 2*features.symbolRadius;
nSpatialCycles = features.nSpatialCycles;
nThetaCycles = features.nThetaCycles;

[x,y] = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
[th,r] = cart2pol(x,y);
mask = 255*ones(D,D,2);

mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*r + nThetaCycles*th)));

maskTexture = Screen('MakeTexture',windowPointer,mask);

end

