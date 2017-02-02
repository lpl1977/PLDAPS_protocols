function S = generator(varargin)
%sequence.generator produces all possible sequences of three symbols
%
%  S = sequence.generator({'a1','a2',...},{'b1','b2',...},{'c1','c2',...},...)
%
%  Input:
%  Cell arrays of possible examples for each feature.
%
%  Output:
%  S.features -- cell array of features (clone of input) S.symbols_indx --
%  matrix of possible symbols (each row are indices into the features cell
%  array). S.sequence_indx -- matrix of possible sequences (each row are
%  row indices into the symbols matrix).

%  Determine number of features
S.features = varargin;
nfeatures = nargin;

%  Determine number of examples of each feature
nexamples = zeros(nfeatures,1);
for i=1:nfeatures
    nexamples(i) = length(S.features{i});
end

%  Generate a list of all possible combinations of features (all possible
%  symbols)
S.symbols_indx = sequence.comblist(nexamples);
nsymbols = size(S.symbols_indx,1);

%  Generate a list of all possible sequences of three symbols
S.sequence_indx = sequence.comblist(nsymbols*ones(1,3));

end