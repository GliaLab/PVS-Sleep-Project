function tbl = roa_ignore_mask(tm)
trials = tm.get_trials();

o = struct;
cnt = 1;

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,'%d/%d',i,length(trials));

    ts = trials(i).tseries;
    
    o(i).ts_uuid = ts.uuid;
    o(i).ignore_mask = {ts.load_var('roa_ignore_mask')};
end

tbl = struct2table(o);
tbl.ts_uuid = categorical(tbl.ts_uuid);
%%
tbl_ids = dogbane.tables.other.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);
end

