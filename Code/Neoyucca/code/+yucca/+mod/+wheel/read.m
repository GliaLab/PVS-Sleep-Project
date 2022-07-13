function [wheel_da, first_tick, speed_ts] = read(trial, correct_negative)
    if nargin < 2
        correct_negative = false;
    end

    % Find the file. 
    files = begonia.path.find_files(trial.Path, 'Wheel.csv');
    assert(~isempty(files), ' Wheel.csv not found.');
    assert(length(files) == 1, ' Multiple Wheel.csv found.')
    file = files{1};

    % Read the file. 
    %result = dlmread(file, '\t', 1, 0);
    data = readtable(file, "PreserveVariableNames", true);
    if correct_negative
        data.da = data.da * -1;
    end
    
    % corret for variable sample rate:
    wheel_da = (data.da ./ data.dt) * 50;
    dist = data.dist_tot;
    dist = dist - dist(1);
    
    % time vectors
    wheel_t = data.tick/1000;
    first_tick = wheel_t(1);
    wheel_t = cumsum(data.dt) / 1000;

    angle_ts = timeseries(wheel_da, wheel_t,'Name','Delta angle');
    speed_ts = timeseries(wheel_da * 20, wheel_t,'Name','Degrees/sec');
    
    %angle_ts = angle_ts.setuniformtime('Interval',0.1);


    total_dist_ts = timeseries(dist, wheel_t,'Name','Distance');
    %total_dist_ts = total_dist_ts.setuniformtime('Interval',0.1);
    
    [angle_ts, total_dist_ts] = synchronize(angle_ts,total_dist_ts,'Uniform','Interval',0.05);

     wheel_da = tscollection({total_dist_ts, angle_ts}, 'Name', 'Wheel data');
end

