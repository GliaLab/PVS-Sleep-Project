function load_ephys(tr, new_sampling_frequency)
if nargin < 2
    new_sampling_frequency = 512;
end

% Load wheel data from the labview trial folder.

% Find file
files = begonia.path.find_files(tr.Path, 'eeg.csv');
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
        % Skip reading without error if the file is empty.
        return;
    else
        rethrow(e);
    end
end
M = double(M);

t = (0:size(M,1)-1) * dt;

% Save as time series format.
emg = table;
emg.y = {M(:,1)};
emg.x = {t};
emg.fs = 1/dt;
emg.ylabel = "EMG (a.u.)";
emg.name = "EMG";
% Resample to lower the file size.
if ~isempty(new_sampling_frequency)
    emg = iris.time_series.resample(emg, new_sampling_frequency);
end
% Center y_data.
emg.y{1} = emg.y{1} - median(emg.y{1});

% Save as time series format.
ecog = table;
ecog.y = {M(:,2)};
ecog.x = {t};
ecog.fs = 1/dt;
ecog.ylabel = "ECoG (a.u.)";
ecog.name = "ECoG";
% Resample to lower the file size.
if ~isempty(new_sampling_frequency)
    ecog = iris.time_series.resample(ecog, new_sampling_frequency);
end
% Center y_data.
ecog.y{1} = ecog.y{1} - median(ecog.y{1});

tr.save_var(emg);
tr.save_var(ecog);

end

