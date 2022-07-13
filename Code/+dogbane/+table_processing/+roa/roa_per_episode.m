function tbl = roa_per_episode(roa_events,episodes,ts_info)

tbl = episodes;
tbl = innerjoin(tbl,ts_info);

tbl.freq = nan(height(tbl),1);
tbl.count = nan(height(tbl),1);
tbl.size = nan(height(tbl),1);
tbl.volume = nan(height(tbl),1);
tbl.duration = nan(height(tbl),1);

begonia.util.logging.backwrite();
for i = 1:height(tbl)
    begonia.util.logging.backwrite(1,'%d/%d',i,height(tbl));
    I_1 = roa_events.roa_t_start >= tbl.StateStart(i);
    I_2 = roa_events.roa_t_end < tbl.StateEnd(i);
    I_3 = roa_events.trial == tbl.trial(i);
    I = I_1 & I_2 & I_3;
    tbl.freq(i) = sum(I) / tbl.StateDuration(i) / tbl.roa_ignore_mask_area(i);
    tbl.count(i) = sum(I);
    tbl.size(i) = mean(roa_events.roa_xy_size(I));
    tbl.volume(i) = mean(roa_events.roa_vol_size(I));
    tbl.duration(i) = mean(roa_events.roa_dur(I));
end

end

