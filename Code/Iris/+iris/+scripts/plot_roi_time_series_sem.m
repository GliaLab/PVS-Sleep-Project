clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("average_images"));
ts = ts(ts.has_var("roi_time_series"));

%%
close all force
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts));
    end
    
    average_images = ts(i).load_var("average_images");
    roi_time_series = ts(i).load_var("roi_time_series");
    
    % Change the name column so plot_time_series plots the different types
    % of ROIs differently.
    roi_time_series.name = roi_time_series.roi_group;
    
    % Init figure.
    tiles = [height(average_images),4];
    f = figure;
    f.Position(3:4) = fliplr(tiles) * 300;
    tiledlayout(tiles(1), tiles(2), "Padding", "tight", "TileSpacing", "tight");
    
    for ch = 1:height(average_images)
        I = roi_time_series.channel == ch;
        
        nexttile
        iris.image.plot_image(average_images(ch,:));
        iris.roi.plot_rois(roi_time_series(I,:));
        title(sprintf("Channel %d",ch));
        
        nexttile([1,3]);
        I = roi_time_series.channel == ch;
        iris.time_series.plot_time_series(roi_time_series(I,:));
        
    end
    
    % Save
    trial_id = average_images.trial_id(1);
    filename = fullfile(get_project_path, "Plot", "ROI time series sem", trial_id);
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    savefig(f,filename+".fig")
    close(f)
end
