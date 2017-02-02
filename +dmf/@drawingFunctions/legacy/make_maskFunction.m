function maskFunction = make_maskFunction(obj,pattern)
%  make_maskFunction Produce alpha masking function for pattern

D = 2*obj.symbol.radius;
nSpatialCycles = obj.symbol.nSpatialCycles;
nThetaCycles = obj.symbol.nThetaCycles;
windowPointer = obj.windowPointer;

[x,y] = meshgrid(linspace(-1,1,D),linspace(-1,1,D));
[th,r] = cart2pol(x,y);
mask = 255*ones(D,D,2);
alpha = 255*ones(D,D);

switch lower(pattern)
    case 'spiral'
        alpha = alpha.*(0.5*(1-cos(pi*nSpatialCycles*r + nThetaCycles*th)));
    case 'horizontal_lines'
        alpha = alpha.*(0.5*(1-cos(pi*nSpatialCycles*y)));
    case 'vertical_lines'
        alpha = alpha.*(0.5*(1-cos(pi*nSpatialCycles*x)));
    case 'waffle'
        alpha = alpha.*(0.25*(1-cos(pi*nSpatialCycles*x)).*(1-cos(pi*nSpatialCycles*y)));
    case 'concentric_circles'
        alpha = alpha.*(0.5*(1-cos(pi*nSpatialCycles*r)));
%     case 'horizontal_sinusoid'
%         alpha = alpha.*(0.5*(1-cos(pi*nSpatialCycles*y + cos(pi*nThetaCycles*x))));
%     case 'vertical_sinusoid'
%         alpha = alpha.*(0.5*(1-cos(pi*nSpatialCycles*x + cos(pi*nThetaCycles*y))));
end
mask(:,:,end) = alpha;

maskTexture = Screen('MakeTexture',windowPointer,mask);

maskFunction = @(c,x,y) Screen('DrawTexture',windowPointer,maskTexture,[],CenterRectOnPoint([0 0 D D],x,y)',[],[],[],c);

end

