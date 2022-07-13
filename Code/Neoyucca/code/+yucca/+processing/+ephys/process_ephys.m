function process_ephys(trials, new_sampling_rate)
if nargin < 2
    new_sampling_rate = 512;
end

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
    M = double(M);

    t = (0:size(M,1)-1) * dt;

    M = resample(M,t,new_sampling_rate);
    M = single(M);

    ecog = M(:,2);
    emg = M(:,1);

    ephys = timetable(ecog,emg,'SampleRate',new_sampling_rate);

    trial.save_var(ephys);
end

end

