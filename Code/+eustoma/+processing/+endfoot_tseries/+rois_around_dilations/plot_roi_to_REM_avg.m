begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_to_rem'));
ts = ts(ts.has_var('diam_to_REM'));
%%

roi_to_rem = ts.load_var('roi_to_rem');
roi_to_rem = cat(1, roi_to_rem{:});

roi_to_rem_struct = ts(1).load_var('roi_to_rem_struct');

roi_to_rem_start_avg = mean(roi_to_rem.signal_to_start,1);
roi_to_rem_end_avg = mean(roi_to_rem.signal_to_end,1);

roi_to_rem_t = (0:length(roi_to_rem_start_avg)-1) / roi_to_rem_struct.fs;
roi_to_rem_t = roi_to_rem_t - roi_to_rem_struct.sec_before_episode;

N_episodes = height(roi_to_rem);

roi_to_rem_start_std = std(roi_to_rem.signal_to_start,[],1);
roi_to_rem_start_confidence = 1.96 * roi_to_rem_start_std / sqrt(N_episodes);

roi_to_rem_end_std = std(roi_to_rem.signal_to_end,[],1);
roi_to_rem_end_confidence = 1.96 * roi_to_rem_end_std / sqrt(N_episodes);

%% Calculate diameter transitions
diam_to_REM = ts.load_var('diam_to_REM');
diam_to_REM = cat(1, diam_to_REM{:});

diam_to_REM_struct = ts(1).load_var('diam_to_REM_struct');

N_diam_to_REM = height(diam_to_REM);

diam_to_REM_start_avg = mean(diam_to_REM.diam_to_start,1);
diam_to_REM_start_std = std(diam_to_REM.diam_to_start,[],1);
diam_to_REM_start_confidence = 1.96 * diam_to_REM_start_std / sqrt(N_diam_to_REM);

diam_to_REM_end_avg = mean(diam_to_REM.diam_to_end,1);
diam_to_REM_end_std = std(diam_to_REM.diam_to_end,[],1);
diam_to_REM_end_confidence = 1.96 * diam_to_REM_end_std / sqrt(N_diam_to_REM);

diam_to_REM_t = diam_to_REM_struct.t;
%%

f = figure;
f.Position(3:4) = [1200,1200];
tiledlayout(4,1,"Padding","tight","TileSpacing","tight")

nexttile
p = plot(roi_to_rem_t,roi_to_rem_start_avg,'r');
yucca.plot.plot_around_line(p,roi_to_rem_start_confidence)
title(sprintf('Average ROI to REM start transition (average +/- 1.96 sem), N episodes = %.f',N_episodes))
hold on
y = ylim;
plot([0,0],[y(1),y(2)],'--k');
ylabel('Ratio difference from transition');
xlim([roi_to_rem_t(1),roi_to_rem_t(end)]);

nexttile
p = plot(diam_to_REM_t,diam_to_REM_start_avg,'r');
yucca.plot.plot_around_line(p,diam_to_REM_start_confidence)
title(sprintf('Average diameter to REM start transition (average +/- 1.96 sem), N episodes + vessels = %.f',N_diam_to_REM))
hold on
y = ylim;
plot([0,0],[y(1),y(2)],'--k');
ylabel('Diameter (um)');
xlim([diam_to_REM_t(1),diam_to_REM_t(end)]);

nexttile
p = plot(roi_to_rem_t,roi_to_rem_end_avg,'g');
yucca.plot.plot_around_line(p,roi_to_rem_end_confidence)
title(sprintf('Average ROI to REM end transition (average +/- 1.96 sem), N episodes = %.f',N_episodes))
hold on
y = ylim;
plot([0,0],[y(1),y(2)],'--k');
ylabel('Ratio difference from transition');
xlim([roi_to_rem_t(1),roi_to_rem_t(end)]);
xlabel('Seconds from REM transition (s)');

nexttile
p = plot(diam_to_REM_t,diam_to_REM_end_avg,'g');
yucca.plot.plot_around_line(p,diam_to_REM_end_confidence)
title(sprintf('Average diameter to REM end transition (average +/- 1.96 sem), N episodes + vessels = %.f',N_diam_to_REM))
hold on
y = ylim;
plot([0,0],[y(1),y(2)],'--k');
ylabel('Diameter (um)');
xlim([diam_to_REM_t(1),diam_to_REM_t(end)]);
xlabel('Seconds from REM transition (s)');

filename = fullfile(eustoma.get_plot_path,"Endfeet ROI to REM avg", ...
    "ROI to REM transition");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)

%% Write ROIs to table
roi_to_rem_t = roi_to_rem_t';

roi_to_rem_start_avg = roi_to_rem_start_avg';
roi_to_rem_start_std = roi_to_rem_start_std';
roi_to_rem_start_confidence = roi_to_rem_start_confidence';

roi_to_rem_end_avg = roi_to_rem_end_avg';
roi_to_rem_end_std = roi_to_rem_end_std';
roi_to_rem_end_confidence = roi_to_rem_end_confidence';

filename = fullfile(eustoma.get_plot_path,"Endfeet ROI to REM avg", ...
    "ROI to REM transition.csv");

roi_to_rem_table = table(roi_to_rem_t, ...
    roi_to_rem_start_avg,roi_to_rem_start_std,roi_to_rem_start_confidence, ...
    roi_to_rem_end_avg,roi_to_rem_end_std,roi_to_rem_end_confidence);
writetable(roi_to_rem_table,filename);

%% Write diameter to table
diam_to_REM_t = diam_to_REM_t';

diam_to_REM_start_avg = diam_to_REM_start_avg';
diam_to_REM_start_std = diam_to_REM_start_std';
diam_to_REM_start_confidence = diam_to_REM_start_confidence';

diam_to_REM_end_avg = diam_to_REM_end_avg';
diam_to_REM_end_std = diam_to_REM_end_std';
diam_to_REM_end_confidence = diam_to_REM_end_confidence';

filename = fullfile(eustoma.get_plot_path,"Endfeet ROI to REM avg", ...
    "diameter to REM transition.csv");
diam_to_REM_table = table(diam_to_REM_t, ...
    diam_to_REM_start_avg,diam_to_REM_start_std,diam_to_REM_start_confidence, ...
    diam_to_REM_end_avg,diam_to_REM_end_std,diam_to_REM_end_confidence);
writetable(diam_to_REM_table,filename);
