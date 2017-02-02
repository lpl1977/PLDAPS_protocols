function mask = makeVerticalLines(obj)
%  makeVerticalLines Produce vertical lines alpha masking pattern

D = 2*obj.features.symbolRadius;
nSpatialCycles = obj.features.nSpatialCycles;

x = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
mask = 255*ones(D,D,2);

mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*x)));

end

