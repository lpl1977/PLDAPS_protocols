function symbolTextures = generateSymbolTextures(p)
%generateSymbolTextures function to generate symbol textures for dmf
%
%  symbolTextures = generateSymbolTextures(p)
%
%  symbolTextures is a vector of texture pointers

%  Extract components of input structures
R = p.functionHandles.features.symbolRadius;
nSpatialCycles = p.functionHandles.features.nSpatialCycles;
nThetaCycles = p.functionHandles.features.nThetaCycles;
bgColor = p.functionHandles.features.bgColor;

symbolFeatures = p.functionHandles.sequenceObj.features;
symbolCodes = p.functionHandles.sequenceObj.symbolCodes;

%  insertShape
%
%  Nested function to insert shape into the symbol texture pointer

    function insertShape(texturePointer,shape,color)
        if(strcmp(shape,'circle'))
            Screen('FillOval',texturePointer,color);
        else
            switch shape
                case 'square'
                    nvert = 4;
                    rot = pi/4;
                case 'diamond'
                    nvert = 4;
                    rot = pi/2;
                case 'triangle'
                    nvert = 3;
                    rot = pi/2;
                case 'pentagon'
                    nvert = 5;
                    rot = pi/2;
                case 'hexagon'
                    nvert = 6;
                    rot = pi/2;
            end
            angles = (pi/2) + linspace(0,2*pi,nvert+1)+rot;
            x = sin(angles).*R;
            y = cos(angles).*R;
            vertices = [x ; y]';
            vertices = vertices + repmat([R R],size(vertices,1),1);
            Screen('FillPoly',texturePointer,color,vertices,1);
        end
    end

%  makeAlphaMask
%
%  Nested function to produce the desired alpha mask

    function mask = makeAlphaMask(pattern)
        
        [x,y] = meshgrid(linspace(-1,1,2*R),linspace(-1,1,2*R));
        [th,r] = cart2pol(x,y);
        mask = 255*ones(2*R,2*R,2);
        
        switch pattern
            case 'concentricCircles'
                mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*r)));
            case 'horizontalLines'
                mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*y)));
            case 'spiral'
                mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*r + nThetaCycles*th)));
            case 'verticalLines'
                mask(:,:,2) = mask(:,:,2).*(0.5*(1-cos(pi*nSpatialCycles*x)));
            case 'waffle'
                mask(:,:,2) = mask(:,:,2).*(0.5*max((1-cos(pi*nSpatialCycles*x)),(1-cos(pi*nSpatialCycles*y))));
            case 'dots'
                mask(:,:,2) = mask(:,:,2).*(0.25*(1-cos(pi*nSpatialCycles*x)).*(1-cos(pi*nSpatialCycles*y)));
                
        end
    end

%  Generate the alpha masks
for i=1:length(symbolFeatures.patterns)
    alphaMask.(symbolFeatures.patterns{i}) = makeAlphaMask(symbolFeatures.patterns{i});
end

%  Read through list of symbol codes and produce corresponding texture
%  pointers
nSymbols = size(symbolCodes,1);
symbolTextures = zeros(nSymbols,1);
for i=1:nSymbols
    
    %  Open off screen window into which we will draw; it should be
    %  fully transparent but have the regular background color.
    symbolTextures(i) = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 0],[0 0 2*R 2*R]);
    
    %  Write the shape into the texture pointer
    insertShape(symbolTextures(i),symbolFeatures.shapes{symbolCodes(i,3)},p.trial.display.colors.(symbolFeatures.colors{symbolCodes(i,1)}));
    
    %  Set the alpha blending on the symbol texture such that only the
    %  alpha channel is modified when we write the mask into it.
    Screen('Blendfunction',symbolTextures(i),[],[],[0,0,0,1]);
    
    %  Write the alpha mask texture into the symbol
    alphaMaskTexture = Screen('MakeTexture',p.trial.display.ptr,alphaMask.(symbolFeatures.patterns{symbolCodes(i,2)}));
    Screen('DrawTexture',symbolTextures(i),alphaMaskTexture);
end
end

