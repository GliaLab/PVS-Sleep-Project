function beautify_data(trial)

ts = trial.tseries;
ts.clear_var('aqua_events');
ts.clear_var('aqua_data');

%%
opts = ts.load_var('aqua_opts');
total_frames = opts.total_frames;
fs = opts.frameRate;

ftsLstE = ts.load_var('aqua_events_struct');

t_start_idx = ftsLstE.loc.t0';
t_end_idx = ftsLstE.loc.t1';
area = ftsLstE.basic.area';
area_pix = area / ts.dx / ts.dx;
tseries_last_frame = zeros(length(area),1);
tseries_last_frame(:) = total_frames;
tseries_fs = zeros(length(area),1);
tseries_fs(:) = fs;

aqua_events = table(t_start_idx,t_end_idx,area,area_pix);

[~,I] = sort(aqua_events.t_start_idx);
aqua_events = aqua_events(I,:);

ts.save_var(aqua_events);
%%
mat = ts.get_mat(1,1);
fov = (size(mat,1) - opts.regMaskGap) * (size(mat,2) - opts.regMaskGap) * ts.dx * ts.dx;

t = 1:total_frames;

aqua_data = struct;
aqua_data.frequency_trace = histcounts(aqua_events.t_start_idx,t);
aqua_data.fs = fs;
aqua_data.fov = fov;

ts.save_var(aqua_data);


end

