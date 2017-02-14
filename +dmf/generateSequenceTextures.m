function sequenceTextures = generateSequenceTextures(p)
%generateSequenceTextures function to generate the sequence textures for
%dmf
%
%  sequenceTextures = generateSequenceTextures(p)
%
%  sequenceTextures is a vector of three texture pointers

%  Extract components of input structure
symbolCenters = p.functionHandles.geometry.symbolCenters;
symbolAlphas = p.trial.condition.symbolAlphas;
symbolIndices = p.trial.condition.symbolIndices;
symbolTextures = p.functionHandles.symbolTextures;
baseRect = [0 0 2*p.functionHandles.geometry.symbolRadius 2*p.functionHandles.geometry.symbolRadius];
bgColor = p.functionHandles.features.bgColor;

%  There are three phases of display (S1, S2, S3) specified by symbolAlphas
sequenceTextures = zeros(3,1);
for i=1:3
    
    %  Open an off screen window into which to write the sequence
    sequenceTextures(i) = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
    
    %  Write the symbols into the texture; set alpha
    for j=1:3
        alpha = symbolAlphas(j,i);
        centeredRect = CenterRectOnPoint(baseRect,symbolCenters(j,1),symbolCenters(j,2));
        Screen('DrawTexture',sequenceTextures(i),symbolTextures(symbolIndices(j)),[],centeredRect,[],[],alpha);
    end
end