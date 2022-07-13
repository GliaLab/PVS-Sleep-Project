function plot_roa_dur_distribution_freq(trial)
tr = trial.rec_rig_trial;
ts = trial.tseries;

roa_distributions = ts.load_var('roa_distributions');

roa_distributions(roa_distributions.state == 'undefined',:) = [];

%% Plot
f = figure;
f.Position(3:4) = [1000,800];

hold on
for i = 1:height(roa_distributions)
    x = roa_distributions.roa_dur_bin_edges(i,2:end);
    y = roa_distributions.roa_dur_N_norm(i,:) * 100 * 60;
    state = char(roa_distributions.state(i));
    
    state_color = alyssum_v2.constants.state_names_short2colors(state);
    state = alyssum_v2.constants.state_names_short2long(state);
    
    p = plot(x,y,'-o','DisplayName',state);
    p.LineWidth = 3;
    p.MarkerSize = 6;
    p.MarkerEdgeColor = 'none';
    p.MarkerFaceColor = 'k';
    p.Color = state_color;
end
l = legend();
l.Interpreter = 'none';
ylabel('Frequency (events / 100um^2 / min)');
xlabel('ROA Duration (s)');

title(sprintf('ROA Frequency by Duration'),'interpreter','none');

a = gca;
a.FontSize = 20;

xlim([1e-2,1e2])
a.XScale = 'log';
a.YScale = 'log';

end

