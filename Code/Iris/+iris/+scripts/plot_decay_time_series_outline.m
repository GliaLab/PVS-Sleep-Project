clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("channel_time_series"));
ts = ts(ts.has_var("baseline_and_decay"));
%%
close all force
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts));
    end
    
    baseline_and_decay = ts(i).load_var("baseline_and_decay");
    channel_time_series = ts(i).load_var("channel_time_series");
    
    % Init figure.
    tiles = [2,4];
    f = figure;
    f.Position(3:4) = fliplr(tiles) * 300;
    tiledlayout(tiles(1), tiles(2), "Padding", "tight", "TileSpacing", "tight");

    nexttile([1,4]);
    iris.time_series.plot_separate(channel_time_series);
    iris.episodes.plot_episodes(baseline_and_decay);
    title(channel_time_series.trial_id(1),"Interpreter","none")

    nexttile([1,4]);
    for j = 1:height(channel_time_series)
        I = baseline_and_decay.ep == "Baseline";
        st = round(baseline_and_decay.ep_start(I) * channel_time_series.fs(j)) + 1;
        en = round(baseline_and_decay.ep_end(I) * channel_time_series.fs(j)) + 1;
        f0 = mean(channel_time_series.y{j}(st:en));
        channel_time_series.y{j} = channel_time_series.y{j} / f0 - 1;
        channel_time_series.ylabel(j) = "df/f0";
    end
    iris.time_series.plot_separate(channel_time_series);
    iris.episodes.plot_episodes(baseline_and_decay);
    title("df/f0")
    
    % Save
    trial_id = channel_time_series.trial_id(1);
    filename = fullfile(get_project_path, "Plot", "Decay time series outline", trial_id);
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    close(f)
end