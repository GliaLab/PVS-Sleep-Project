function cell_table = append_trial_id(trial_ids,cell_table)
% Appends the string array of trial_ids to each table in the cell array of tables
% and each row in the tables.
% trial_ids and cell_table must have equal length.
if iscell(trial_ids)
    trial_ids = string(trial_ids);
end

for i = 1:length(trial_ids)
    tmp = cell_table{i};
    trial_id = repmat(trial_ids(i),height(tmp),1);
    cell_table{i} = [table(trial_id),tmp];
end

end

