function tbl_out = spesific_sleep_transitions(tbl)

% Find what the sleep episodes transitions from.
I = ismember(tbl.state,{'nrem','is','rem'});
tbl_out = tbl(I,:);
tbl_out.state_previous = categorical(repmat({''},height(tbl_out),1));

begonia.util.logging.backwrite();
for i = 2:height(tbl_out)
    begonia.util.logging.backwrite(1,'%6.2f%%',i/height(tbl_out)*100);
    if tbl_out.trial(i) ~= tbl_out.trial(i-1)
        % If the previous epsiode was in another trial, label the previous
        % episode as 'unspecified';
        prev_state = 'unspecified';
    elseif tbl_out.state_start(i) - tbl_out.state_end(i-1) > 5
        % If the previous episode ended more than X seconds before, label the
        % previous episode as 'unspecified'.
        prev_state = 'unspecified';
    else
        prev_state = tbl_out.state(i-1);
    end
    
    tbl_out.state_previous(i) = prev_state;
end
end

