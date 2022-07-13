function tbl = valid_trial(trials)

has_recrig    = ~cellfun(@isempty,{trials.rec_rig_trial})';
has_tseries   = ~cellfun(@isempty,{trials.tseries})';

valid_trial = has_recrig & has_tseries;

tbl = table(valid_trial,has_recrig,has_tseries);

end

