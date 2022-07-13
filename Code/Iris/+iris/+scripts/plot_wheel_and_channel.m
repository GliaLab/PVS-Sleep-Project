clear all

%% Load tseries
ts = get_tseries();
tr = get_labview_trials();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(tr);
dloc_list.add(ts);

ts = ts(ts.has_var("average_images"));
ts = ts(ts.has_var("channel_time_series"));
ts = ts(ts.has_var("labview"));
ts = ts(ts.find_dnode("labview").has_var("wheel"));
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
    wheel = ts(i).find_dnode("labview").load_var("wheel");
    
    % Init figure.
    tiles = [height(average_images)+1,4];
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
    
    nexttile();
    nexttile([1,3]);
    iris.time_series.plot_time_series(wheel);
    
    % Save
    trial_id = average_images.trial_id(1);
    filename = fullfile(get_project_path, "Plot", "Wheel and channel", trial_id);
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    savefig(f,filename+".fig")
    close(f)
end