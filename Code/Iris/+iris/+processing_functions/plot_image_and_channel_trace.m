function plot_image_and_channel_trace(ts)

average_images = ts.load_var("average_images");
channel_time_series = ts.load_var("channel_time_series");

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
filename = fullfile(get_project_path, "Plot", "Average image and trace", trial_id);
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
savefig(f,filename+".fig")
close(f)

end

