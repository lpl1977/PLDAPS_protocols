function A = combvec(Acell)
%sequence.combvec generate all possible combinations of input vectors.
%
%  A = sequence.combvec(Acell)
%
%  Input:
%  Acell--cell array of matrices of column vectors to distribute:
%      Acell{1} - Matrix of N1 (column) vectors.
%      Acell{2} - Matrix of N2 (column) vectors.
%      ...
%    and returns a matrix of (N1*N2*...) column vectors, where the columns
%    consist of all possibilities of A2 vectors, appended to
%    A1 vectors, etc.
%
%  This function is a cell array version of the Neural Networks Toolbox
%  version and may significantly resemble it.

A = Acell{1};
for i=2:length(Acell)
    cur = Acell{i};
    A = [copyb(A,size(cur,2)); copyi(cur,size(A,2))];
end

%=========================================================
function b = copyb(mat,s)

[~,mc] = size(mat);
inds    = 1:mc;
inds    = inds(ones(s,1),:).';
b       = mat(:,inds(:));

%=========================================================
function b = copyi(mat,s)

[~,mc] = size(mat);
inds    = 1:mc;
inds    = inds(ones(s,1),:);
b       = mat(:,inds(:));