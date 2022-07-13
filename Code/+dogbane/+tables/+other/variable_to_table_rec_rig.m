function tbl = variable_to_table_rec_rig(tm,variable_name,skip_missing)
if nargin < 3
    skip_missing = true;
end

trials = tm.get_trials();
tr = [trials.rec_rig_trial];

tbl = begonia.data_management.var2table(tr,variable_name,[],skip_missing);
assert(~isempty(tbl));
tbl.tr_uuid = tbl.uuid;
tbl.uuid = [];

tbl_ids = alyssum_v2.tables.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);

end

