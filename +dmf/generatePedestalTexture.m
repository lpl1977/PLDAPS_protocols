function pedestalTexture = generatePedestalTexture(p)
%generatePedestals function to generate the pedestal background frame
%
%  pedestalTexture = generatePedestals(p)
%
%  pedestals is a texture pointer

%  Extract components of input structure
symbolCenters = p.functionHandles.geometry.symbolCenters;
baseRect = [0 0 2*p.functionHandles.geometry.symbolRadius 2*p.functionHandles.geometry.symbolRadius];
bgColor = p.functionHandles.features.bgColor;
pedestalColor = p.functionHandles.features.pedestalColor;

%  Write pedestals
pedestalTexture = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);

%  Write the pedestals into the texture
for i=1:3
    centeredRect = CenterRectOnPoint(baseRect,symbolCenters(i,1),symbolCenters(i,2));
    Screen('FillOval',pedestalTexture,pedestalColor,centeredRect);
end