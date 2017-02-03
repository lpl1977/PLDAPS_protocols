classdef drawingFunctions < handle
    %class for producing drawing functions in dmf task
    
    properties
        %         symbol = struct('radius',[],'displacement',[],'nSpatialCycles',[],'nThetaCycles',[]);
        %         reward_region = struct('border_color',[],'buffer',[],'penwidth',[]);
        %         secondary_reinforcer = struct('width',[],'height',[],'border_color',[],'interior_color',[],'penwidth',[]);
        features = struct(...
            'symbolRadius',[],...
            'nSpatialCycles',[],...
            'nThetaCycles',[],...
            'rewardRegionBuffer',[],...
            'rewardRegionBorderColor',[],...
            'rewardRegionSelectedBorderColor',[],...
            'rewardRegionPenWidth',[],...
            'bgColor',[],...
            'secondaryReinforcerWidth',[],...
            'secondaryReinforcerHeight',[],...
            'secondaryReinforcerBorderColor',[],...
            'secondaryReinforcerInteriorColor',[],...
            'secondaryReinforcerPenWidth',[]);
                
        maskTextures = struct(...
            'spiral',[],...
            'horizontalLines',[],...
            'verticalLines',[],...
            'waffle',[],...
            'concentricCircles',[]);
    end
    
    methods
        function obj = drawingFunctions(windowPointer,features)
            obj.maskTextures.spiral = dmf.drawingFunctions.makeSpiral(windowPointer,features);
            obj.maskTextures.horizontalLines = dmf.drawingFunctions.makeHorizontalLines(windowPointer,features);
            obj.maskTextures.verticalLines = dmf.drawingFunctions.makeVerticalLines(windowPointer,features);
            obj.maskTextures.waffle = dmf.drawingFunctions.makeWaffle(windowPointer,features);
            obj.maskTextures.concentricCircles = dmf.drawingFunctions.makeConcentricCircles(windowPointer,features);
            
            fields = fieldnames(obj.features);
            for i=1:length(fields)
                obj.features.(fields{i}) = features.(fields{i});
            end
        end
        drawShape(obj,windowPointer,x,y,color,shape)
        applyMask(obj,windowPointer,x,y,mask)
        drawRewardRegion(obj,windowPointer,x,y,selected)
    end
    
    methods(Static)
        maskTexture = makeSpiral(windowPointer,features)
        maskTexture = makeHorizontalLines(windowPointer,features)
        maskTexture = makeVerticalLines(windowPointer,features)
        maskTexture = makeWaffle(windowPointer,features)
        maskTexture = makeConcentricCircles(windowPointer,features)
    end
    
    
end
