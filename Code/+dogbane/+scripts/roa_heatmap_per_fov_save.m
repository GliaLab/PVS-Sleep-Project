tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.roa_measurements(tm);
%%
heatmaps = dogbane.tables.roa_heatmap.roa_heatmap_per_episode(tm);

I = ismember(heatmaps.state,{'locomotion','whisking','quiet','nrem','is','rem'});
heatmaps = heatmaps(I,:);

I = heatmaps.genotype == 'wt_dual';
heatmaps = heatmaps(I,:);
%%
[G,heatmaps_per_fov] = findgroups(heatmaps(:,{'genotype','fov_id','state'}));

heatmaps_per_fov.img_roa_frequency = splitapply(@merge_img,heatmaps.img_roa_frequency,heatmaps.state_duration,G);
heatmaps_per_fov.img_roa_density = splitapply(@merge_img,heatmaps.img_roa_density,heatmaps.state_duration,G);
heatmaps_per_fov.state_duration = splitapply(@sum,heatmaps.state_duration,G);
%%
begonia.util.logging.backwrite();
for i = 1:height(heatmaps_per_fov) 
    begonia.util.logging.backwrite(1,'%d/%d',i,height(heatmaps_per_fov));
    path = '/Users/danielmb_adm/Desktop/sleep_project/dogbane/roa_density_heatmaps_per_fov/';
    filename = sprintf('%s fov %d %s.png', ...
        heatmaps_per_fov.genotype(i), ...
        heatmaps_per_fov.fov_id(i), ...
        heatmaps_per_fov.state(i));
    path = fullfile(path,filename);
    
    f = figure;
    begonia.plot.imagesc_toiyt(heatmaps_per_fov.img_roa_density{i});
    colorbar;
    begonia.path.make_dirs(path);
    export_fig(f,path,'-native');
    close(f);
end
%
begonia.util.logging.backwrite();
for i = 1:height(heatmaps_per_fov) 
    begonia.util.logging.backwrite(1,'%d/%d',i,height(heatmaps_per_fov));
    path = '/Users/danielmb_adm/Desktop/sleep_project/dogbane/roa_frequency_heatmaps_per_fov/';
    filename = sprintf('%s fov %d %s.png', ...
        heatmaps_per_fov.genotype(i), ...
        heatmaps_per_fov.fov_id(i), ...
        heatmaps_per_fov.state(i));
    path = fullfile(path,filename);
    
    f = figure;
    begonia.plot.imagesc_toiyt(heatmaps_per_fov.img_roa_frequency{i});
    colorbar;
    begonia.path.make_dirs(path);
    export_fig(f,path,'-native');
    close(f);
end

%%
function img = merge_img(imgs,weights)
img = cat(3,imgs{:});
weights = reshape(weights,1,1,[]);
img = sum(img .* weights,3) / sum(weights);
img = {img};
end

