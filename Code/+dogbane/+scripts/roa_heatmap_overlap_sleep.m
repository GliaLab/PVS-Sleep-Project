tm.set_filter('genotype','wt_dual');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
dogbane.guis.roa_measurements(tm);
%%
heatmaps_sleep = dogbane.tables.roa_heatmap.roa_heatmap_per_episode(tm);

I = ismember(heatmaps_sleep.state,{'nrem','is','rem'});
heatmaps_sleep = heatmaps_sleep(I,:);

I = heatmaps_sleep.genotype == 'wt_dual';
heatmaps_sleep = heatmaps_sleep(I,:);

%%

[con_overlap_100,I_100] = dogbane.table_processing.roa_heatmap.overlap_consecutive_episodes( ...
    heatmaps_sleep,100);
[con_overlap_5,I_5] = dogbane.table_processing.roa_heatmap.overlap_consecutive_episodes( ...
    heatmaps_sleep,5);

con_overlap_100.transition = con_overlap_100.state_1 .* con_overlap_100.state_2;

I = ismember(con_overlap_100.transition,{'nrem nrem','is is','rem rem','nrem is','is rem'});
con_overlap_100 = con_overlap_100(I,:);
con_overlap_100 = begonia.util.removecats_table(con_overlap_100);

con_overlap_5.transition = con_overlap_5.state_1 .* con_overlap_5.state_2;
I = ismember(con_overlap_5.transition,{'nrem nrem','is is','rem rem','nrem is','is rem'});
con_overlap_5 = con_overlap_5(I,:);
con_overlap_5 = begonia.util.removecats_table(con_overlap_5);

output_folder = '~/Desktop/sleep_project/consecutive_overlap_100';
dogbane.table_plots.roa_heatmap.heatmap_overlap_stats(con_overlap_100,output_folder,100);

output_folder = '~/Desktop/sleep_project/consecutive_overlap_5';
dogbane.table_plots.roa_heatmap.heatmap_overlap_stats(con_overlap_5,output_folder,5);

%%
% Calculate how much of FOV has any activity. 
output_folder = '~/Desktop/sleep_project/percent_of_fov_active_per_ep_100';
dogbane.table_plots.roa_heatmap.percent_of_fov_active(heatmaps_sleep(I_100,:),output_folder,100);
output_folder = '~/Desktop/sleep_project/percent_of_fov_active_per_ep_5';
dogbane.table_plots.roa_heatmap.percent_of_fov_active(heatmaps_sleep(I_5,:),output_folder,5);
%%
overlap_sleep = dogbane.table_processing.roa_heatmap.overlap_all_episodes(heatmaps_sleep);

overlap_sleep_per_mouse = begonia.statistics.grpstats(overlap_sleep,{'genotype','mouse','combination'},'coeff');
overlap_sleep_per_fov_id = begonia.statistics.grpstats(overlap_sleep,{'genotype','mouse','combination','fov_id'},'coeff');

%%
begonia.plot.scatterbox(overlap_sleep_per_fov_id.coeff * 100, ...
    overlap_sleep_per_fov_id.combination, ...
    overlap_sleep_per_fov_id.mouse, ...
    'overlay','sem')
set(gca,'FontSize',20)
%%
begonia.plot.scatterbox(overlap_sleep_per_mouse.coeff * 100, ...
    overlap_sleep_per_mouse.combination, ...
    overlap_sleep_per_mouse.mouse, ...
    'overlay','sem')
set(gca,'FontSize',20)
%%
[estimates,p_values,model] = begonia.statistics.est( ...
    overlap_sleep_per_fov_id.coeff * 100, overlap_sleep_per_fov_id.combination, ...
    'log_transform',true);

begonia.statistics.plot_estimates(estimates,p_values);
begonia.statistics.plot_residuals(model);
%% Overlap without a mouse
tbl = overlap_sleep_per_fov_id;
tbl(tbl.mouse == 'wt_dual_NM16',:) = [];
[estimates,p_values,model] = begonia.statistics.est( ...
    tbl.coeff * 100, tbl.combination, ...
    'log_transform',true);


output_folder = '~/Desktop/sleep_project/heatmap_overlap_without_NM16';
begonia.statistics.plot_estimates(estimates,p_values,'output_folder',output_folder);
begonia.statistics.plot_residuals(model,output_folder);
%% Make an overview of how many states each FOV has
overlap_sleep_fov_comb = begonia.statistics.grpstats(overlap_sleep,{'genotype','mouse','fov_id'},'combination',@(x)length(unique(x)))
 

%%
tbl = overlap_sleep_fov_comb(overlap_sleep_fov_comb.combination == 6,:)

for i = 1:height(tbl)
    j = find(heatmaps_sleep.fov_id == tbl.fov_id(i),1,'first');
    img = heatmaps_sleep.avg_img{j};
    figure;
    imshow(img);
    set(gca,'CLim',[0,prctile(img(:),99)]);
    
    output_folder = '~/Desktop/sleep_project/heatmap_overlap_fovs_with_sleep';
    filename = sprintf('%s_fov_%d.png', ...
        heatmaps_sleep.mouse(j), ...
        heatmaps_sleep.fov_id(j));
    filename = fullfile(output_folder,filename);
    begonia.path.make_dirs(filename);
    export_fig(filename,'-native')
    close all
end

%% Show a heatmap with overlap

output_folder = '~/Desktop/sleep_project/heatmap_overlap_sleep_images_fov_392';
I = overlap_sleep.fov_id == 392;
tbl = overlap_sleep(I,:);
dogbane.table_plots.roa_heatmap.plot_overlapping_heatmap(tbl,heatmaps_sleep,output_folder)

output_folder = '~/Desktop/sleep_project/heatmap_overlap_sleep_images_fov_221';
I = overlap_sleep.fov_id == 221;
tbl = overlap_sleep(I,:);
dogbane.table_plots.roa_heatmap.plot_overlapping_heatmap(tbl,heatmaps_sleep,output_folder)

output_folder = '~/Desktop/sleep_project/heatmap_overlap_sleep_images_fov_93';
I = overlap_sleep.fov_id == 93;
tbl = overlap_sleep(I,:);
dogbane.table_plots.roa_heatmap.plot_overlapping_heatmap(tbl,heatmaps_sleep,output_folder)
%%
I = ismember(overlap_sleep.fov_id,[392,221,93]);
tbl = overlap_sleep(I,:);
begonia.plot.scatterbox(tbl.coeff * 100, ...
    tbl.combination, ...
    tbl.mouse .* categorical(tbl.fov_id), ...
    'overlay','sem')
ylabel('Overlap (%)')
set(gca,'FontSize',20)
