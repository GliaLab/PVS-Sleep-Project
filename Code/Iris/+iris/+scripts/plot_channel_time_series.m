clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("average_images"));
ts = ts(ts.has_var("channel_time_series"));
%%
close all force
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts));
    end
    
    average_images = ts(i).load_var("average_images");
    channel_time_series = ts(i).load_var("channel_time_series");
    
    % Init figure.
    tiles = [height(average_images),4];
    f = figure;
    f.Position(3:4) = fliplr(tiles) * 300;
    tiledlayout(tiles(1), tiles(2), "Padding", "tight", "TileSpacing", "tight");
    
    for ch = 1:height(average_images)
        nexttile
        iris.image.plot_image(average_images(ch,:));
        title(sprintf("Channel %d",ch));
        
        nexttile([1,3]);
        iris.time_series.plot_time_series(channel_time_series(ch,:));
        
    end
    
    % Save
    trial_id = average_images.trial_id(1);
    filename = fullfile(get_project_path, "Plot", "Channel time series", trial_id);
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    close(f)
end