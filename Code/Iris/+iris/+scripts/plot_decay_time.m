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

%%
decay_threshold = 0.20;
decay_time_series.decay_time = nan(height(decay_time_series),1);
for i = 1:height(decay_time_series)
    y = decay_time_series.y{i};
    
    if isempty(y)
        continue;
    end
    
    % Calculate time to decay threshold.
    I = begonia.util.val2idx(y,decay_threshold * y(1));
    if I == length(y)
        decay_time_series.decay_time(i) = nan;
        decay_time_series.max(i) = nan;
    else
        decay_time_series.decay_time(i) = I / decay_time_series.fs(i);
        decay_time_series.max(i) = y(1);
    end
end

decay_coefficients = decay_time_series;
decay_coefficients.x = [];
decay_coefficients.y = [];
decay_coefficients.fs = [];
decay_coefficients.f0 = [];
decay_coefficients.ylabel = [];

%% 
% tbl = stack(decay_coefficients,["a","b","c","d"], ...
%     "NewDataVariableName","coeff","IndexVariableName","coeff_name");
%% Plot the coefficients.
close all
clear g
g = gramm('x',categorical(decay_coefficients.genotype),'y',decay_coefficients.decay_time,'color',categorical(decay_coefficients.mouse));
g.geom_jitter();
g.facet_grid(categorical(decay_coefficients.name),[]);
g.set_names('x','','y','Decay time (s)','color','Mouse')
f = figure('Position',[100 100 800 550]);
g.draw();

% Save
filename = fullfile(get_project_path, "Plot", "Decay time","Decay coefficients.png");
begonia.path.make_dirs(filename);
exportgraphics(f,filename);
close(f)

%%

filename = fullfile(get_project_path, "Plot", "Decay time","Decay coeffcients.csv");
begonia.path.make_dirs(filename);
writetable(decay_coefficients, filename);