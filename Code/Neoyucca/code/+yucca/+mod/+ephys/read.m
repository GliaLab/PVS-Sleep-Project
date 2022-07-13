function [ephys,ephys_down] = read(trial)

% Find file
files = begonia.path.find_files(trial.Path, 'eeg.csv');
assert(~isempty(files), 'eeg.csv not found.');
assert(length(files) == 1, ' Multiple eeg.csv found.')
eeg_file = files{1};

% Read dt from somewhere in the file. 
dt = dlmread(eeg_file, ',', [20,1, 20, 1]);

% Load csv, skip the 24 first lines. 
M = dlmread(eeg_file, ',', 24, 1);
M = single(M);
ephys = timeseries(M,'Name','EPhys');
ephys = ephys.setuniformtime('Interval',dt);
new_fs = 512;
new_dt = 1/new_fs;
ephys_down = ephys.resample(0:new_dt:ephys.TimeInfo.End);

end

