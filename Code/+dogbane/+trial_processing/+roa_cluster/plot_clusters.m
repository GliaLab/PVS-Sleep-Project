function plot_clusters(trial)
ts = trial.tseries;
tr = trial.rec_rig_trial;


tbl = ts.load_var('roa_cluster_number_density');
bins = ts.load_var('roa_cluster_number_density_bins');
bins(end) = [];

I = tbl.p <= 0.5;
% I = ismembertol(tbl.p,[0.01,0.05,0.10,0.20],0.02);
tbl = tbl(I,:);

colors = begonia.colormaps.turbo(height(tbl)+1);
colors(end,:) = [];

figure;
hold on
for i = 1:height(tbl)
    p = plot(bins,tbl.n(i,:),'-o','DisplayName',sprintf('p = %.2f',tbl.p(i)));
    p.Color = colors(i,:);
    p.MarkerEdgeColor = colors(i,:);
end
legend

set(gca,'YScale','log')
set(gca,'XScale','log')

end

