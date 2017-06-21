classdef graphicsManager < handle
    %graphicsManager Generate and display graphics for dmf
    %   Produce symbol textures and graphics for trials of the dmf task
    %
    %  Lee Lovejoy
    %  ll2833@columbia.edu
    %  June 2017
    
    properties
        symbolTextures
        symbolFeatures
        symbolCodes
        symbolRadius
        symbolCenters
        
        patternProperties
        
        pedestalTexture
        pedestalColor = [0.4 0.4 0.4];
        pedestalRadius
        pedestalRect
        
        colorLibrary
        backgroundColor = [0.5 0.5 0.5];
        
        windowPtr
        
        textureWidth
        
        frameTextures
        frameConfig
    end
    
    methods
        
        %  Class constructor
        %
        %  Produce symbol textures
        function obj = graphicsManager(varargin)
            
            %  Input arguments
            for i=1:2:nargin
                obj.(varargin{i}) = varargin{i+1};
            end
            
            obj.textureWidth = 2*obj.pedestalRadius;
            obj.pedestalRect = [0 0 obj.textureWidth obj.textureWidth];
            
            %  Generate pedestal texture
            obj.pedestalTexture = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor,obj.pedestalRect);
            Screen('FillOval',obj.pedestalTexture,obj.pedestalColor,obj.pedestalRect);
            
            %  Generate symbol textures
            nSymbols = size(obj.symbolCodes,1);
            obj.symbolTextures = zeros(nSymbols,1);
            for i=1:nSymbols
                
                %  Symbol features
                symbolColor = obj.colorLibrary.(obj.symbolFeatures.colors{obj.symbolCodes(i,1)});
                symbolPattern = obj.symbolFeatures.patterns{obj.symbolCodes(i,2)};
                symbolShape = obj.symbolFeatures.shapes{obj.symbolCodes(i,3)};
                
                %  Create a texture into which we will write the symbol
                obj.symbolTextures(i) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor,obj.pedestalRect);
                
                %  Write the pedestal into the texture.
                Screen('FillOval',obj.symbolTextures(i),obj.pedestalColor,obj.pedestalRect);
                
                %  Write the shape into the texture with the specified
                %  color
                Screen('FillPoly',obj.symbolTextures(i),symbolColor,polygonVertices(symbolShape));
                
                %  Create a mask texture that has the same color as the
                %  pedestal and write it into the texture.  Note that we
                %  don't want to change the destination texture's alpha
                %  channel.
                Screen('Blendfunction',obj.symbolTextures(i),'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA',[1 1 1 0]);
                Screen('DrawTexture',obj.symbolTextures(i),Screen('MakeTexture',obj.windowPtr,patternMask(symbolPattern)),[],[],[],[],[],obj.pedestalColor);
                
                %  Add an outline to the symbol
                Screen('FramePoly',obj.symbolTextures(i),symbolColor,polygonVertices(symbolShape),2);
            end
            
            %
            %  Nested functions for class constructor
            %
            
            %  nested function polygonVertices
            function vertices = polygonVertices(shape)
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
                x = sin(angles).*obj.symbolRadius;
                y = cos(angles).*obj.symbolRadius;
                vertices = [x ; y]';
                vertices = vertices + repmat([obj.pedestalRadius obj.pedestalRadius],size(vertices,1),1);
            end
            
            %  nested function alpha mask for pattern
            function mask = patternMask(pattern)
                
                d = obj.pedestalRadius/obj.symbolRadius;
                [x,y] = meshgrid(linspace(-d,d,obj.textureWidth),linspace(-d,d,obj.textureWidth));
                [~,r] = cart2pol(x,y);
                mask = ones(obj.textureWidth,obj.textureWidth,2);
                
                switch pattern
                    case 'concentricCircles'
                        mask(:,:,2) = 0.5*(1-cos(pi*obj.patternProperties(1)*r)).*(r<1);
                    case 'horizontalLines'
                        mask(:,:,2) = 0.5*(1-cos(pi*obj.patternProperties(1)*y)).*(r<1);
                    case 'verticalLines'
                        mask(:,:,2) = 0.5*(1-cos(pi*obj.patternProperties(1)*x)).*(r<1);
                    case 'waffle'
                        mask(:,:,2) = (1 - 0.5*max((1-cos(pi*obj.patternProperties(1)*x)),(1-cos(pi*obj.patternProperties(1)*y)))).*(r<1);
                    case 'solid'
                        mask(:,:,2) = 0;
                    case 'blank'
                        mask(:,:,2) = r<1;
                end
                mask = 255*max(min(mask,1),0);
            end
        end
        
        %  initializeFrameTextures
        %
        %  Call during setup to association state names and configurations
        %  with textures
        function obj = initializeFrameTextures(obj,states,config,centers)
            
            %  Create structure from frame textures
            for i = 1:length(states)
                obj.frameTextures.(states{i}) = [];
                obj.frameConfig.(states{i}) = config{i};
            end
            
            obj.symbolCenters = centers;
        end
        
        %  getFrameTexture
        %
        %  function to retrieve the named frame texture
        function texture = getFrameTexture(obj,state)
            
            %  Check state against list
            if(~isfield(obj.frameTextures,state))
                obj.frameTextures.(state) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor);
            end
            texture = obj.frameTextures.(state);
        end
        
        %  prepareFrameTextures
        %
        %  Call during trial preparation to produce frame textures for
        %  display
        function obj = prepareFrameTextures(obj,selectedSet)
            
            %  Iterate over frames specified in the configuration
            states = fieldnames(obj.frameConfig);
            for i=1:length(states)
                
                %  Close texture pointer and recreate it
                obj.frameTextures.(states{i}) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor);
                
                %  Iterate over positions in the configuration
                for j=1:3
                    centeredRect = CenterRectOnPoint(obj.pedestalRect,obj.symbolCenters(j,1),obj.symbolCenters(j,2));                    
                    if(obj.frameConfig.(states{i})(j))
                        Screen('DrawTexture',obj.frameTextures.(states{i}),obj.symbolTextures(selectedSet(j)),[],centeredRect);
                    else
                        Screen('DrawTexture',obj.frameTextures.(states{i}),obj.pedestalTexture,[],centeredRect);
                    end
                end
            end
        end
        
        %  trialCleanUp
        %
        %  Close frame textures to prevent excessive buildup
        function obj = trialCleanUp(obj)
           
            %  Iterate over frames specified in the configuration
            states = fieldnames(obj.frameConfig);
            for i=1:length(states)
                Screen('Close',obj.frameTextures.(states{i}));
            end
        end
        
        %  cleanUp
        %
        %  close all texture pointers
        function obj = cleanUp(obj)
            Screen('Close',obj.pedestalTexture);
            Screen('Close',obj.symbolTextures);
        end
    end
end


