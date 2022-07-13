
begonia.logging.set_level(1);

trials = eustoma.get_endfoot_recrigs(true);

begonia.logging.backwrite();
for i = 1:length(trials)
    begonia.logging.backwrite(1,'Ephys %d/%d',i,length(trials));
    trial = trials(i);

    ephys_idx = trial.load_var('ephys_idx',[]);

    if isempty(ephys_idx)
        continue;
    end

    % Find file
    files = begonia.path.find_files(trial.Path, 'eeg.csv');
    assert(~isempty(files), 'eeg.csv not found.');
    assert(length(files) == 1, ' Multiple eeg.csv found.');
    eeg_file = files{1};

    % Read dt from somewhere in the file. 
    dt = dlmread(eeg_file, ',', [20,1, 20, 1]);

    % Load csv, skip the 24 first lines. 
    M = dlmread(eeg_file, ',', 24, 1);
    M = single(M);

    t = (0:size(M,1)-1) * dt;

    new_fs = 512;
    M = resample(M,t,new_fs);

    ecog = M(:,ephys_idx.eeg_idx);
    emg = M(:,ephys_idx.emg_idx);

    ephys = timetable(ecog,emg,'SampleRate',new_fs);

    trial.save_var(ephys);
end
