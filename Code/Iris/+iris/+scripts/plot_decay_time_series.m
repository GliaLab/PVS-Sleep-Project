clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("decay_time_series"));
ts = ts(ts.has_var("trial_group"));

%%
trial_group = ts.load_var("trial_group");
trial_group = cat(1,trial_group{:});

%%
decay_time_series = ts.load_var("decay_time_series");
decay_time_series = cat(1,decay_time_series{:});

decay_time_series = innerjoin(decay_time_series, trial_group);

% Manipulate the decay traces so they are all equal length, but padded with
% nan values. So the mean trace can be calculated.
[max_length, I] = max(cellfun(@length,decay_time_series.y));
x = decay_time_series.x{I};
for i = 1:height(decay_time_series)
    y = nan(1,max_length);
    y(1:length(decay_time_series.y{i})) = decay_time_series.y{i};
    decay_time_series.y{i} = y;
    decay_time_series.x{i} = x;

end

%%
decay_time_series_extended = ts.load_var("decay_time_series_extended");
decay_time_series_extended = cat(1,decay_time_series_extended{:});

decay_time_series_extended = innerjoin(decay_time_series_extended, trial_group);

% Manipulate the decay traces so they are all equal length, but padded with
% nan values. So the mean trace can be calculated.
[max_length, I] = max(cellfun(@length,decay_time_series_extended.y));
x = decay_time_series_extended.x{I};
for i = 1:height(decay_time_series_extended)
    y = nan(1,max_length);
    y(1:length(decay_time_series_extended.y{i})) = decay_time_series_extended.y{i};
    decay_time_series_extended.y{i} = y;
    decay_time_series_extended.x{i} = x;
end

% Normalize 1 to t=0 (max value) for alternative view.
for j = 1:height(decay_time_series_extended)
    decay_time_series_extended.y{j} = decay_time_series_extended.y{j} ./ decay_time_series_extended.y0(j);
end
decay_time_series_extended.ylabel(:) = "Max-normalized traces";

%%
close all force

channels = unique(decay_time_series.name);

% Init figure.
tiles = [2,length(channels)];
f = figure;
f.Position(3:4) = fliplr(tiles) * 300;
tiledlayout(tiles(1), tiles(2), "Padding", "tight", "TileSpacing", "tight");

% Plot channel, compare groups.
for i = 1:length(channels)
    % Select channel trace.
    tbl = decay_time_series(decay_time_series.name == channels(i),:);
    % Change the name to genotype for plotting.
    tbl.name = tbl.genotype;
    
    ax(i) = nexttile;
    iris.time_series.plot_time_series(tbl);
    title(channels(i));
end
linkaxes(ax,'xy');

% Plot channel, compare groups.
for i = 1:length(channels)
    % Select channel trace.
    tbl = decay_time_series_extended(decay_time_series_extended.name == channels(i),:);

    % Change the name to genotype for plotting.
    tbl.name = tbl.genotype;
    
    ax(i) = nexttile;
    iris.time_series.plot_time_series(tbl);
    title(channels(i));
end
linkaxes(ax,'xy');
ylim([-0.5,1.5])

% Save
filename = fullfile(get_project_path, "Plot", "Decay time series", "Average traces");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
