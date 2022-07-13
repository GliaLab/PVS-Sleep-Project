function tab_review = check_sample_rates(trials, treshold)
    if nargin < 2
        treshold = 0.02;
    end
    
    disp("== Checking trials for slow wheel sample rates ==")
    for i = 1:length(trials)
        trial = trials(i);
        files = begonia.path.find_files(trial.Path, 'Wheel.csv');
        file = files{1};

        % Read the file. 
        data = readtable(file, "PreserveVariableNames", true);
        
        value_cnt = length(data.dt);
        high_dt_cnt = length(data.dt(data.dt > 51));
        problem_pct = high_dt_cnt / value_cnt;
       
        high_dt(i,:) = problem_pct > treshold;
        percentage(i,:) = problem_pct * 100;
        path(i,:) = string(trial.path); %#ok<*NASGU>
        name(i,:) = string(trial.name);
        disp(trial.name + " has " + (problem_pct * 100) + "% values => " + trial.path);
    end
    if any(high_dt)
        warning("Your trials have trials with high sample rates");
    end
    
    tab_review = table(name, high_dt, percentage, path);
end

