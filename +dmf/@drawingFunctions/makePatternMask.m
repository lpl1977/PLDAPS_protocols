function mask = makePatternMask(obj,pattern)
%  makePatternMask Produce alpha masking pattern

D = 2*obj.features.symbolRadius;
nSpatialCycles = obj.features.nSpatialCycles;
nThetaCycles = obj.features.nThetaCycles;

[x,y] = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
[th,r] = cart2pol(x,y);
mask = 255*ones(D,D,2);

switch pattern
    case 'concentricCircles'
        mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*r)));
    case 'spiral'
        mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*r + nThetaCycles*th)));
    case 'horizontalLines'
        mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*r)));
    case 'verticalLines'
        mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*x)));
    case 'waffle'
        mask(:,:,2) = mask(:,:,2).*(0.25*(1-cos(pi*nSpatialCycles*x)).*(1-cos(pi*nSpatialCycles*y)));
end
end

