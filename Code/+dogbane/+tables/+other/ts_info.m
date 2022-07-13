function tbl = ts_info(tm)
trials = tm.get_trials();
tr = [trials.rec_rig_trial];
ts = [trials.tseries];

dx = [ts.dx]';
dx_squared = dx.*dx;
trial = tr.load_var('trial')';
trial = categorical(trial);

roa_ignore_mask_area = ts.load_var('roa_ignore_mask_area',nan);
roa_ignore_mask_area = cell2mat(roa_ignore_mask_area)';

tbl = table(trial,dx_squared,roa_ignore_mask_area);

end

