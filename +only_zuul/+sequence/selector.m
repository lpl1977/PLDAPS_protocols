function sequences = selector(S,rules)
%SELECTOR Select sequences satisfying rules
%
%  sequences = only_zuul.sequence.selector(S,rules)
%
%  rules is a three character code instructing whether the selected
%  sequences should have same or different features.  Position of the
%  character determines the feature to which it applies.  Rules are
%  specified as follows:
%  0:  no symbols share the feature
%  1:  first and second symbols share the feature
%  2:  first and third symbols share the feature
%  3:  second and third symbols share the feature
%  4:  all three symbols share the feature
%  otherwise:  no rule is applied to this position
%
%  Input:
%  S--cell array of all possible sequences of three symbols
%  rules--cell array of rule strings to apply
%
%  Output:
%  sequences-cell array including the sequences satisfying the UNION of the
%  rules
%
%  Examples:
%
%  400--only the first feature is shared in all symbols
%  412--all three symbols share the first feature; first and second share
%  the second feature; first and third share the third feature.

%  Number of sequences and rules
nsequences = size(S,1);
nrules = size(rules,1);

%  Create logical index vector
indx = false(nsequences,1);

%  Apply the rules sequentially to each feature of each sequence
for j=1:nsequences
    for k=1:nrules
        ix = true;
        for i=1:3
            switch rules{k}(i)
                case '0'
                    ix = ix && ((S{j,1}(i) ~= S{j,2}(i)) && (S{j,1}(i) ~= S{j,3}(i)) && (S{j,2}(i) ~= S{j,3}(i)));
                case '1'
                    ix = ix && ((S{j,1}(i) == S{j,2}(i)) && (S{j,1}(i) ~= S{j,3}(i)) && (S{j,2}(i) ~= S{j,3}(i)));
                case '2'
                    ix = ix && ((S{j,1}(i) ~= S{j,2}(i)) && (S{j,1}(i) == S{j,3}(i)) && (S{j,2}(i) ~= S{j,3}(i)));
                case '3'
                    ix = ix && ((S{j,1}(i) ~= S{j,2}(i)) && (S{j,1}(i) ~= S{j,3}(i)) && (S{j,2}(i) == S{j,3}(i)));
                case '4'
                    ix = ix && ((S{j,1}(i) == S{j,2}(i)) && (S{j,1}(i) == S{j,3}(i)) && (S{j,2}(i) == S{j,3}(i)));
            end
            if(~ix)
                break;
            end
        end
        indx(j) = ix;
        if(indx(j))
            break;
        end
    end
end
sequences = S(indx,:);