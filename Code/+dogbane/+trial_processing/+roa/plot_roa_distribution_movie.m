function plot_roa_distribution_movie(trial)
%%

window = 10; %s

tr = trial.rec_rig_trial;
ts = trial.tseries;

roa_table = ts.load_var('highpass_roa_table');
roa_density_trace = ts.load_var('highpass_roa_density_trace');

% fov_pixels = round(ts.load_var('roa_ignore_mask_area') / ts.dx / ts.dx);
% window_frames = round(window*2 / ts.dt);
%%
roa_density_trace_t = (0:length(roa_density_trace)-1)*ts.dt;

% edges = logspace(-3,6,9*5-1);
edges = 10 .^ (-2:1/5:6);
edges_diff = diff(edges);
y = histcounts(roa_table.roa_xy_size,edges);
y = y./edges_diff;

x = edges(2:end);

%% Plot
f = figure;
f.Position(3:4) = [1000,800];

ax(1) = subplot(3,1,1:2);

p = plot(x,y,'-o','DisplayName','Highpass');
p.LineWidth = 3;
p.MarkerSize = 6;
p.MarkerEdgeColor = 'none';
p.MarkerFaceColor = 'k';

legend();
ylabel('#Events (sort of)');
xlabel('ROA Size (um^2)');

th = title(sprintf('ROA Size Histogram'),'interpreter','none');

a = gca;
a.FontSize = 20;

% ylim([1e-12,1e-3]);
ylim([1e-4,1e5]);
xlim([1e-2,1e6])
a.XScale = 'log';
a.YScale = 'log';

hold on
tau = 187/91;
% tau = 2.0;
log_line = x.^(-tau);
y_not_zero = find(y ~= 0,1);
log_line = log_line / log_line(1) * y(y_not_zero);
p_log_line = plot(x,log_line,'DisplayName',sprintf('Power Law (\\tau = %.4f)',tau));

ax(2) = subplot(3,1,3);
plot(roa_density_trace_t,roa_density_trace);
hold on;
p_line = plot([0,0],[0,1]);
p_line.LineWidth = 2;
p_line.Color = 'b';

%%

for t_cur = 0:1:seconds(ts.duration)
    I = roa_table.roa_t_start < (t_cur + window) & roa_table.roa_t_start > (t_cur - window);
    y = histcounts(roa_table.roa_xy_size(I),edges);
    y = y./edges_diff;
%     y = y/fov_pixels/window_frames;
%     y = y/sum(y);

    p.YData = y;

    y_not_zero = find(y ~= 0,1);
    log_line = x.^(-tau);
    log_line = log_line / log_line(y_not_zero) * y(y_not_zero);
    p_log_line.YData = log_line;
    
    p_line.XData = [t_cur,t_cur];
    
    th.String = sprintf('Time = %d s',t_cur);

    pause(1/10);
end


end

