
begonia.logging.set_level(1);

trials = eustoma.get_linescans_recrig(true);
%%
begonia.logging.backwrite();
for i = 1:length(trials)
    begonia.logging.backwrite(1,'Ephys %d/%d',i,length(trials));
    trial = trials(i);

    % Find file
    files = begonia.path.find_files(trial.Path, 'eeg.csv');
    files = files(~contains(files,'._'));
    assert(~isempty(files), 'eeg.csv not found.');
    assert(length(files) == 1, ' Multiple eeg.csv found.');
    eeg_file = files{1};

    % Read dt from somewhere in the file. 
    dt = dlmread(eeg_file, ',', [20,1, 20, 1]);

    % Load csv, skip the 24 first lines. 
    try
        M = dlmread(eeg_file, ',', 24, 1);
    catch e
        if isequal(e.identifier,'MATLAB:textscan:EmptyFormatString')
            % Skip reading if the file is empty.
            continue;
        else
            rethrow(e);
        end
    end

    t = (0:size(M,1)-1) * dt;

    new_fs = 512;
    M = resample(M,t,new_fs);

    ecog = M(:,2);
    emg = M(:,1);

    ephys = timetable(ecog,emg,'SampleRate',new_fs);

    trial.save_var(ephys);
end
