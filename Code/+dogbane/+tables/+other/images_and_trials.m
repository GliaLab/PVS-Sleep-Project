function tbl = images_and_trials(tm)

ts = tm.get_trials();
ts = [ts.tseries];

o = struct;
begonia.util.logging.backwrite();
for i = 1:length(ts)
    begonia.util.logging.backwrite(1,'%d/%d',i,length(ts));
    o(i).avg_img = ts(i).get_avg_img(1,1);
    o(i).ts_uuid = ts(i).uuid;
    o(i).fov_id = ts(i).load_var('fov_id',nan);
    o(i).fov_offset = ts(i).load_var('fov_offset',[nan,nan]);
    o(i).tseries = {ts(i)};
end

tbl = struct2table(o,'AsArray',true);
tbl.ts_uuid = categorical(tbl.ts_uuid);

tbl_ids = dogbane.tables.other.trial_ids(tm);
tbl = innerjoin(tbl_ids,tbl);

% [~,I] = sort(tbl.trial);
% tbl = tbl(I,:);
end

