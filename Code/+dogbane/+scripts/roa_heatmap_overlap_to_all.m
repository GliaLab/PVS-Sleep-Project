tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.roa_measurements(tm);
%%
heatmaps = dogbane.tables.roa_heatmap.roa_heatmap_per_episode(tm);
heatmaps.img_roa_density = [];

I = ismember(heatmaps.state,{'locomotion','whisking','quiet','nrem','is','rem'});
heatmaps = heatmaps(I,:);

I = heatmaps.genotype == 'wt_dual';
heatmaps = heatmaps(I,:);
%%
coeff = dogbane.table_processing.roa_heatmap.overlap_all_to_all(heatmaps);
%%
file_name = '~/Desktop/sleep_project/heatmap_overlap/overlap_all2all_matrix.csv';
begonia.path.make_dirs(file_name);
if exist(file_name, 'file')==2
  delete(file_name);
end
writematrix(coeff,file_name)

%%
tbl = heatmaps;
tbl.ratio_activation = cellfun(@(x)sum(x(:)>0)/numel(x),tbl.img_roa_frequency);
tbl.img_roa_frequency = [];
tbl.state_start = [];
tbl.state_end = [];
tbl.avg_img = [];
tbl.roa_ignore_mask = [];
file_name = '~/Desktop/sleep_project/heatmap_overlap/overlap_all2all_table.csv';
begonia.path.make_dirs(file_name);
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)