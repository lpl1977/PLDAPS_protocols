function S = generator(varargin)
%GENERATOR Generate sequences of 3 symbols based on possible features.
%
%  S = only_zuul.sequence.generator({'a1','a2',...},{'b1','b2',...},{'c1','c2',...},...)
%
%  Input:
%  Cell arrays of possible examples for each feature.
%
%  Output:
%  Cell array of all possible sequences of three symbols.

%  Get arguments
nfeatures = nargin;

features = cell(nfeatures,1);
nexamples = zeros(nfeatures,1);

for i=1:nfeatures
    features{i} = varargin{i};
    nexamples(i) = length(varargin{i});
end

%  Generate a list of the symbols
symbol_arg = cell(nfeatures,1);
for i=1:nfeatures
    symbol_arg{i} = 1:nexamples(i);
end

symbol_indexed = only_zuul.sequence.combvec(symbol_arg)';
nsymbol = size(symbol_indexed,1);
symbols = cell(nsymbol,1);
for i=1:nsymbol
    symbols(i) = features{1}(symbol_indexed(i,1));
    for j=2:nfeatures
        symbols(i) = strcat(symbols(i),features{j}(symbol_indexed(i,j)));
    end
end

%  Generate the sequences
set_arg = cell(3,1);
for i=1:3
    set_arg{i} = 1:nsymbol;
end
S_indexed = only_zuul.sequence.combvec(set_arg)';
nsequences = size(S_indexed,1);
S = cell(nsequences,3);

for i=1:nsequences
    S(i,:) = [symbols(S_indexed(i,1)),symbols(S_indexed(i,2)),symbols(S_indexed(i,3))];
end
end