function [wheel, first_tick] = read(trial)
    warning("THIS VERSION OF READ DOES NOT PRODUCED VALID RESULTS")
    % Find the file. 
    files = begonia.path.find_files(trial.Path, 'Wheel.csv');
    assert(~isempty(files), ' Wheel.csv not found.');
    assert(length(files) == 1, ' Multiple Wheel.csv found.')
    file = files{1};

    % Read the file. 
    result = dlmread(file, '\t', 1, 0);
    wheel = result(:,3);
    dist = result(:,6);
    dist = dist - dist(1);
    
    % Time vector.
    wheel_t = result(:,1)/1000;
    first_tick = wheel_t(1);
    wheel_t = wheel_t - wheel_t(1);

    angle_ts = timeseries(wheel, wheel_t,'Name','Delta angle');
    %angle_ts = angle_ts.setuniformtime('Interval',0.1);


    total_dist_ts = timeseries(dist, wheel_t,'Name','Distance');
    %total_dist_ts = total_dist_ts.setuniformtime('Interval',0.1);
    
    [angle_ts, total_dist_ts] = synchronize(angle_ts,total_dist_ts,'Uniform','Interval',0.05);

     wheel = tscollection({total_dist_ts, angle_ts}, 'Name', 'Wheel data');
end

