classdef sequence < handle
    %sequence class for generating symbol sequences in feature matching
    %  S = sequence({'a1','a2',...},{'b1','b2',...},{'c1','c2',...},...)
    %
    %  Input arguments are cell arrays of all possible examples for each
    %  feature.
    %
    %  sequences = S.selector(rules)
    %
    %  rules is a character code string to select sequences based on
    %  whether or not their symbols share specific features.  Position of
    %  the character determines the feature to which it applies.  Rules are
    %  specified as follows:
    %  0--no symbols share the feature
    %  1--first and second symbols share the feature
    %  2--first and third symbols share the feature
    %  3--second and third symbols share the feature
    %  4-all three symbols share the feature
    %
    %  NB:  rules is a string with the same number of characters as
    %  features. If you specify too few characters then only those features
    %  will be processed.  If you specify too many, the excess will be
    %  ignored.
    %
    %  Examples:
    %  '400'--only the first feature is shared in all symbols
    %  '412'--all three symbols share the first feature; first and second
    %  share the second feature; first and third share the third feature.
    %  '0000'--none of the symbols share any of four possible features.
    
    properties
        features
        symbolCodes
        sequenceCodes
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
            fieldNames = fieldnames(obj.features);
            nfeatures = length(fieldNames);
            nexamples = zeros(nfeatures,1);
            for i=1:nfeatures
                nexamples(i) = length(obj.features.(fieldNames{i}));
            end
            
            %  Generate a list of all possible combinations of features (all possible
            %  symbols)
            obj.symbolCodes = obj.comblist(nexamples);
            nsymbols = size(obj.symbolCodes,1);
            
            %  Generate a list of all possible sequences of three symbols
            obj.sequenceCodes = obj.comblist(nsymbols*ones(1,3));
        end
        
        %  Selector
        %
        %  Select possible sequences based on rules
        function [sequences,selectedCodes] = selector(obj,rules)
            
            %  Number of sequences, rules, and features
            nsequences = size(obj.sequenceCodes,1);
            nrules = size(rules,1);
            if nrules==1
                rules = {rules};
            end
            fieldNames = fieldnames(obj.features);
            nfeatures = length(fieldNames);
            
            %  Short names for the sake of simplicity
            symb = obj.symbolCodes;
            seq = obj.sequenceCodes;
            
            %  Create logical index vector indicating satisfaction of the UNION of the
            %  rules.
            indx = false(nsequences,1);
            
            %  Apply the rules sequentially to each feature of each sequence
            for j=1:nsequences
                k = 1;
                while ~indx(j) && k<=nrules
                    indx(j) = true;
                    i = 1;
                    while indx(j) && i<=min(nfeatures,length(rules{k}))
                        switch rules{k}(i)
                            case '0'
                                indx(j) = symb(seq(j,1),i)~=symb(seq(j,2),i) && symb(seq(j,1),i)~=symb(seq(j,3),i) && symb(seq(j,2),i)~=symb(seq(j,3),i);
                            case '1'
                                indx(j) = symb(seq(j,1),i)==symb(seq(j,2),i) && symb(seq(j,1),i)~=symb(seq(j,3),i) && symb(seq(j,2),i)~=symb(seq(j,3),i);
                            case '2'
                                indx(j) = symb(seq(j,1),i)~=symb(seq(j,2),i) && symb(seq(j,1),i)==symb(seq(j,3),i) && symb(seq(j,2),i)~=symb(seq(j,3),i);
                            case '3'
                                indx(j) = symb(seq(j,1),i)~=symb(seq(j,2),i) && symb(seq(j,1),i)~=symb(seq(j,3),i) && symb(seq(j,2),i)==symb(seq(j,3),i);
                            case '4'
                                indx(j) = symb(seq(j,1),i)==symb(seq(j,2),i) && symb(seq(j,1),i)==symb(seq(j,3),i) && symb(seq(j,2),i)==symb(seq(j,3),i);
                        end
                        i = i+1;
                    end
                    k = k+1;
                end
            end
            
            %  Generate feature list
            selectedCodes = obj.sequenceCodes(indx,:);
            sequences = cell(size(selectedCodes,1),3);
            for i=1:size(sequences,1)
                for j=1:3
                    sequences{i,j} = cell(1,nfeatures);
                    for k=1:nfeatures
                        sequences{i,j}(k) = obj.features.(fieldNames{k})(symb(selectedCodes(i,j),k));
                    end
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
        %  nexamples--length N vector indicating number of examples
        %
        %  Output:
        %  A--matrix containing all possible combination of indices into
        %  the lists.  A is prod(N) by N.        
        function A = comblist(nexamples)
            
            %  Number of lists
            N = length(nexamples);
            
            %  Number of combinations
            M = prod(nexamples);
            
            %  Matrix containing possible combinations
            A = zeros(prod(nexamples),N);
            
            %  Iterate over features to populate matrix
            inc = [1 ; cumprod(nexamples(:))];
            for i=1:N
                Ai = repmat(1:nexamples(i),inc(i),M/(inc(i)*nexamples(i)));
                A(:,i) = Ai(:);
            end
        end
    end
end