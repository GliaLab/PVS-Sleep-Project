tm.set_filter('genotype','wt_dual');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
dogbane.guis.roa_measurements(tm);
%%
tbl_roa_heatmaps_per_ep = dogbane.tables.roa_heatmap.roa_heatmap_per_episode(tm);

I = ismember(tbl_roa_heatmaps_per_ep.state,{'nrem','is','rem'});
tbl_roa_heatmaps_per_ep = tbl_roa_heatmaps_per_ep(I,:);

I = tbl_roa_heatmaps_per_ep.genotype == 'wt_dual';
tbl_roa_heatmaps_per_ep = tbl_roa_heatmaps_per_ep(I,:);
%%
corr = dogbane.table_processing.roa_heatmap.correlation_all_episodes( ...
    tbl_roa_heatmaps_per_ep);

corr.fov_id = categorical(corr.fov_id);

corr_per_mouse = begonia.statistics.grpstats(corr,{'genotype','mouse','combination'},'coeff');
corr_per_fov_id = begonia.statistics.grpstats(corr,{'genotype','mouse','combination','fov_id'},'coeff');

%%
begonia.plot.scatterbox(corr_per_mouse.coeff, ...
    corr_per_mouse.combination, ...
    corr_per_mouse.mouse, ...
    'overlay','sem')
set(gca,'FontSize',20)
%%
[estimates,p_values,model] = begonia.statistics.est( ...
    corr_per_fov_id.coeff+1, corr_per_fov_id.combination, ...
    'log_transform',true);
estimates.estimate = estimates.estimate - 1;
estimates.estimate_lower = estimates.estimate_lower - 1;
estimates.estimate_upper = estimates.estimate_upper - 1;

begonia.statistics.plot_estimates(estimates,p_values);
begonia.statistics.plot_residuals(model);