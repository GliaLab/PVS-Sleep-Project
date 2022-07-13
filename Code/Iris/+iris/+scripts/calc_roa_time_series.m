clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("trial_id"));
ts = ts(ts.has_var("roa_param"));
ts = ts(ts.has_var("roa_mask"));

%%

tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    trial_id = ts(i).load_var("trial_id");
    trial_id = string(trial_id);

    % Load data.
    roa_mask = ts(i).load_var('roa_mask');
    roa_param = ts(i).load_var('roa_param');

    % Calculate area of FOV in pixels.
    dim = size(roa_mask);
    area = (dim(1)-roa_param.roa_ignore_border) * (dim(2)-roa_param.roa_ignore_border);

    % Calculate ROA density.
    y = sum(sum(roa_mask,2), 1) ./ area;
    y = reshape(y,1,[]);

    x = (0:length(y)-1) / roa_param.fs;
    
    roa_density = table;
    roa_density.trial_id = trial_id;
    roa_density.x = {x};
    roa_density.y = {y};
    roa_density.fs = roa_param.fs;
    roa_density.dx = roa_param.dx;
    roa_density.ylabel = "ROA density (%)";
    roa_density.name = "ROA density of channel " + roa_param.channel;
    ts(i).save_var(roa_density);

    % Calculate roa frequency.
    roa_table = begonia.processing.roa.extract_roa_events(roa_mask,roa_param.dx,roa_param.dx,1/roa_param.fs);
    area_um = area * roa_param.dx * roa_param.dx;
    
    t = 0:size(roa_mask,3);
    roa_frequency_count = histcounts(roa_table.roa_start_frame,t);
    y = roa_frequency_count * roa_param.fs / area_um;

    roa_frequency = table;
    roa_frequency.trial_id = trial_id;
    roa_frequency.x = {x};
    roa_frequency.y = {y};
    roa_frequency.fs = roa_param.fs;
    roa_frequency.dx = roa_param.dx;
    roa_frequency.area_um = area_um;
    roa_frequency.ylabel = "ROA frequency (events / s / um2)";
    roa_frequency.name = "ROA frequency of channel " + roa_param.channel;
    ts(i).save_var(roa_frequency);
end
