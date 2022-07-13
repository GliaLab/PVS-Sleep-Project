function tbl = count_sleep_and_awakenings(tm)
tbl = dogbane.tables.other.variable_to_table_rec_rig(tm,'sleep_and_awakenings',true);

[G,genotype] = findgroups(tbl.genotype);

nrem_2_wake_frequency = splitapply(@(dur,cnt) sum(cnt)/sum(dur)*60*60,tbl.sleep_time,tbl.nrem_awakening_cnt,G);
is_2_wake_frequency = splitapply(@(dur,cnt) sum(cnt)/sum(dur)*60*60,tbl.sleep_time,tbl.is_awakening_cnt,G);
nrem_2_is_frequency = splitapply(@(dur,cnt) sum(cnt)/sum(dur)*60*60,tbl.sleep_time,tbl.nrem_2_is_cnt,G);
is_2_nrem_frequency = splitapply(@(dur,cnt) sum(cnt)/sum(dur)*60*60,tbl.sleep_time,tbl.is_2_nrem_cnt,G);

tbl = table(genotype, ...
    nrem_2_wake_frequency, ...
    is_2_wake_frequency, ...
    nrem_2_is_frequency, ...
    is_2_nrem_frequency);
end

