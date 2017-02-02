function A = comblist(nexamples)
%comblist generate all possible combinations of indexed lists
%
%  A = sequence.comblist(nexamples)
%
%  Input:
%  nexamples--length N vector indicating number of examples of each feature
%
%  Output:
%  A--matrix containing all possible combination of indices into the
%  indexed lists.  A is prod(N) by N.

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