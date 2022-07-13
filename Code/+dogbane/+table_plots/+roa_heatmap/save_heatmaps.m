function save_heatmaps(tbl)

output_folder = '~/Desktop/sleep_project/roa_heatmaps/heatmaps_from_table';
begonia.path.make_dirs(output_folder);

for i = 1:height(tbl)
    img_freq = tbl.img_roa_frequency{i};
    img_freq = begonia.mat_functions.normalize(img_freq*60,'limits',[0,2]);
    dim = size(img_freq);

    f = figure;

    imagesc(img_freq);
    colormap(begonia.colormaps.turbo);

    axis equal

    a = gca;

    a.XTickLabel = [];
    a.YTickLabel = [];
    a.XLim = [0,dim(1)];
    a.YLim = [0,dim(2)];
    
    str = sprintf('fov_%d_%s_%s_num_%0.4d_dur_%03.0f.png', ...
        tbl.fov_id(i), ...
        tbl.genotype(i), ...
        tbl.state(i), ...
        i, ...
        tbl.state_duration(i));
    str = fullfile(output_folder,str);
    
    pause(0.2);
    export_fig(f,str,'-native');
    
    close(f)
end


end

