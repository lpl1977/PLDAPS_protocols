function mask = makeConcentricCircles(obj)
%  makeConcentricCircles produce concentric circles alpha masking pattern

D = 2*obj.features.symbolRadius;
nSpatialCycles = obj.features.nSpatialCycles;

[x,y] = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
[~,r] = cart2pol(x,y);
mask = 255*ones(D,D,2);

mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*r)));

end

