classdef sequence < handle
    %sequence class for generating symbol sequences in feature matching
    %  S = sequence({'a1','a2',...},{'b1','b2',...},{'c1','c2',...},...)
    %
    %  Input arguments are cell arrays of all possible examples for each
    %  feature.
    %
    %  [selectedSequences,satisfiedSelectionCodes] = S.selector(selectionCodes)
    %
    %  selectionCodes is a character code string or cell array of strings
    %  to select sequences based on whether or not their symbols share
    %  specific features.  Position of the character determines the feature
    %  to which it applies. Selection codes are specified as follows:
    %  0--no symbols share the feature
    %  1--first and second symbols share the feature
    %  2--first and third symbols share the feature
    %  3--second and third symbols share the feature
    %  4--all three symbols share the feature
    %
    %  Examples:
    %  '400'--only the first feature is shared in all symbols
    %  '412'--all three symbols share the first feature; first and second
    %  share the second feature; first and third share the third feature.
    %  '0000'--none of the symbols share any of four possible features.
    
    properties
        features
        featureNames
        symbolCodes
        sequences
    end
    
    methods
        
        %  Class constructor
        %
        %  Produce all possible sequences of three symbols
        function obj = sequence(varargin)
            
            %  Import feature names and cell arrays
            for i=1:2:nargin
                obj.features.(varargin{i}) = varargin{i+1};
            end
            
            %  Determine number of examples of each feature
            obj.featureNames = fieldnames(obj.features);
            nFeatures = length(obj.featureNames);
            nExamples = zeros(nFeatures,1);
            for i=1:nFeatures
                nExamples(i) = length(obj.features.(obj.featureNames{i}));
            end
            
            %  Generate a list of all possible combinations of features
            %  (all possible symbols)
            obj.symbolCodes = obj.comblist(nExamples);
            nsymbols = size(obj.symbolCodes,1);
            
            %  Generate a list of all possible sequences of three symbols
            obj.sequences = obj.comblist(nsymbols*ones(1,3));
        end
        
        %  Selector
        %
        %  Select possible sequences based on selection codes.  If multiple
        %  codes are provided then the output will reflect all sequences
        %  that satisfy at least one of the codes.
        function [selectedSequences,sequenceSymbolCodes,satisfiedSelectionCodes,matchedFeatures] = selector(obj,selectionCodes)
            
            %  Number of sequences, selectionCodes, and features
            nSequences = size(obj.sequences,1);
            if(~iscell(selectionCodes))
                selectionCodes = {selectionCodes};
            end
            
            %  Create logical index vector indicating satisfaction of the
            %  UNION of the selection codes.
            indx = false(nSequences,1);
            
            %  Track which selection codes were satisfied
            satisfiedSelectionCodes = cell(nSequences,1);
            
            %  Track matched features
            matchedFeatures = cell(nSequences,1);
            
            %  Apply the selection codes sequentially to each feature of
            %  each sequence
            for i=1:nSequences
                j = 0;
                while ~indx(i) && j<length(selectionCodes)
                    j = j+1;
                    k = 1;
                    indx(i) = true;
                    while indx(i) && k<=min(length(selectionCodes{j}),size(obj.symbolCodes,2))
                        switch selectionCodes{j}(k)
                            case '0'
                                indx(i) = obj.symbolCodes(obj.sequences(i,1),k)~=obj.symbolCodes(obj.sequences(i,2),k) && obj.symbolCodes(obj.sequences(i,1),k)~=obj.symbolCodes(obj.sequences(i,3),k) && obj.symbolCodes(obj.sequences(i,2),k)~=obj.symbolCodes(obj.sequences(i,3),k);
                            case '1'
                                indx(i) = obj.symbolCodes(obj.sequences(i,1),k)==obj.symbolCodes(obj.sequences(i,2),k) && obj.symbolCodes(obj.sequences(i,1),k)~=obj.symbolCodes(obj.sequences(i,3),k) && obj.symbolCodes(obj.sequences(i,2),k)~=obj.symbolCodes(obj.sequences(i,3),k);
                            case '2'
                                indx(i) = obj.symbolCodes(obj.sequences(i,1),k)~=obj.symbolCodes(obj.sequences(i,2),k) && obj.symbolCodes(obj.sequences(i,1),k)==obj.symbolCodes(obj.sequences(i,3),k) && obj.symbolCodes(obj.sequences(i,2),k)~=obj.symbolCodes(obj.sequences(i,3),k);
                            case '3'
                                indx(i) = obj.symbolCodes(obj.sequences(i,1),k)~=obj.symbolCodes(obj.sequences(i,2),k) && obj.symbolCodes(obj.sequences(i,1),k)~=obj.symbolCodes(obj.sequences(i,3),k) && obj.symbolCodes(obj.sequences(i,2),k)==obj.symbolCodes(obj.sequences(i,3),k);
                            case '4'
                                indx(i) = obj.symbolCodes(obj.sequences(i,1),k)==obj.symbolCodes(obj.sequences(i,2),k) && obj.symbolCodes(obj.sequences(i,1),k)==obj.symbolCodes(obj.sequences(i,3),k) && obj.symbolCodes(obj.sequences(i,2),k)==obj.symbolCodes(obj.sequences(i,3),k);
                        end
                        switch selectionCodes{j}(k)
                            case {'1','2','3'}
                                matchedFeatures{i}{end+1} = obj.features.(obj.featureNames{k}){obj.symbolCodes(obj.sequences(i,2),k)};
                        end
                        k = k+1;
                    end
                end
                satisfiedSelectionCodes{i} = selectionCodes{j};
            end
            
            %  Generate list of selected sequences
            selectedSequences = obj.sequences(indx,:);
            satisfiedSelectionCodes = satisfiedSelectionCodes(indx);
            matchedFeatures = matchedFeatures(indx);
            sequenceSymbolCodes = cell(sum(indx),1);
            for i=1:length(sequenceSymbolCodes)
                sequenceSymbolCodes{i} = zeros(size(selectedSequences,2),size(obj.symbolCodes,2));
                for j=1:size(selectedSequences,2)
                    sequenceSymbolCodes{i}(j,:) = obj.symbolCodes(selectedSequences(i,j),:);
                end
            end
        end
    end
    
    methods (Static)
        
        %  comblist
        %
        %  generate all possible combinations of feature example lists
        %
        %  Input:
        %  nExamples--length N vector indicating number of examples
        %
        %  Output:
        %  A--matrix containing all possible combination of indices into
        %  the lists.  A is prod(N) by N.
        function A = comblist(nExamples)
            
            %  Number of lists
            N = length(nExamples);
            
            %  Number of combinations
            M = prod(nExamples);
            
            %  Matrix containing possible combinations
            A = zeros(prod(nExamples),N);
            
            %  Iterate over features to populate matrix
            inc = [1 ; cumprod(nExamples(:))];
            for i=1:N
                Ai = repmat(1:nExamples(i),inc(i),M/(inc(i)*nExamples(i)));
                A(:,i) = Ai(:);
            end
        end
    end
end