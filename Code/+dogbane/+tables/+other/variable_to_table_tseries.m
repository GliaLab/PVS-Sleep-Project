function tbl = variable_to_table_tseries(tm,variable_name,skip_missing)
if nargin < 3
    skip_missing = true;
end

trials = tm.get_trials();
tseries = [trials.tseries];

tbl = begonia.data_management.var2table(tseries,variable_name,{},skip_missing);
tbl.ts_uuid = tbl.uuid;
tbl.uuid = [];

tbl_ids = dogbane.tables.other.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);

end

