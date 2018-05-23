function y = get_output_within_possible_outcomes(possible_outcomes,outputs)
% counts outputs within possible outcomes
outcome_counts = ...
    countmember(possible_outcomes,outputs);

% check if occurences of the outputs are multiple
[bincounts,idx] = histc(outcome_counts,unique(outcome_counts));
counts_outcome = bincounts(idx);

if any(counts_outcome>1)
    % sort in the decend direction
    [~,idx_descend] = sort(outcome_counts,'descend');

    % check if there is other indices which gives
    % the idx which occurs maximully
    idx_max = ...
        find(outcome_counts(idx_descend(1))==outcome_counts...
        ==1);

    % randomlly pick one as eye-brow expression
    y = possible_outcomes...
        (idx_max(randi(length(idx_max))));
else
    [~,tmp_idx] = max(outcome_counts);
    y = possible_outcomes(tmp_idx);
end
end                
%=========================================================================%