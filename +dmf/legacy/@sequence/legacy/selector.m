function [sequences,subS] = selector(S,rules)
%sequence.selector select sequences from S satisfying rules
%
%  [sequences,subS] = sequence.selector(S,rules)
%
%  Input:
%  S--structure from the generator function
%  S.features -- cell array of features
%  S.symbols_indx -- matrix of indices into feature cell array (symbols are
%  rows)
%  S.sequence_indx -- matrix of indices into rows of symbols index.
%
%  rules is a character code string to select sequences based on whether or
%  not their symbols share specific features.  Position of the character
%  determines the feature to which it applies.  Rules are specified as
%  follows:
%  0:  no symbols share the feature
%  1:  first and second symbols share the feature
%  2:  first and third symbols share the feature
%  3:  second and third symbols share the feature
%  4:  all three symbols share the feature
%  otherwise:  no rule is applied to this position
%
%  NB:  rules is a string with the same number sequences = S(indx,:);of characters as features.
%  If you specify too few characters then only those features will be
%  processed.  If you specify too many, the excess will be ignored.
%
%  Output:
%  sequences-cell array including the sequences satisfying the UNION of the
%  rule strings
%  subS -- structure same form as S containing sequence_indx corresponding
%  to sequences cell array.
%
%  Examples:
%
%  '400'--only the first feature is shared in all symbols
%  '412'--all three symbols share the first feature; first and second share
%  the second feature; first and third share the third feature.
%  '0000'--none of the symbols share any of four possible features.

%  Number of sequences, rules, and features
nsequences = size(S.sequence_indx,1);
nrules = size(rules,1);
if nrules==1
    rules = {rules};
end
nfeatures = length(S.features);

%  Short names for the sake of simplicity
symb = S.symbols_indx;
seq = S.sequence_indx;

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
subS = S;
subS.sequence_indx = subS.sequence_indx(indx,:);

%  Generate feature list
symb = subS.symbols_indx;
seq = subS.sequence_indx;
sequences = cell(size(seq,1),3);
for i=1:size(sequences,1)
    for j=1:3
        sequences{i,j} = cell(1,nfeatures);
        for k=1:nfeatures
            sequences{i,j}(k) = subS.features{k}(symb(seq(i,j),k));
        end
    end
end