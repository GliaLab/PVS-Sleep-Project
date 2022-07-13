begonia.logging.set_level(1);

trials = eustoma.get_endfoot_recrigs(true);
%%
for i = 1:length(trials)
    if i == 1 || i == length(trial) || toc > 5
        tic
        begonia.logging.log(1,"Trial %d/%d",i,length(trials));
    end
    trial = trials(i);
    
    % Find the file. 
    files = begonia.path.find_files(trial.Path, 'Wheel.csv');
    assert(~isempty(files), ' Wheel.csv not found.');
    assert(length(files) == 1, ' Multiple Wheel.csv found.')
    file = files{1};

    % Read the file. 
    data = readtable(file, "PreserveVariableNames", true);
    
    wheel_t = cumsum(data.dt) / 1000;
    wheel_t = wheel_t - wheel_t(1);
    
    % 50 Millisecond sampling rate
    fs = 1000/50;
    
    wheel_speed = resample(data.da,wheel_t,fs);
    wheel_speed = abs(wheel_speed);
    
    wheel = timetable(wheel_speed,'SampleRate',fs);
    
    trials(i).save_var(wheel);
end