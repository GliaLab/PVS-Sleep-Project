function load_wheel(tr)
% Load wheel data from the labview trial folder.

% Find the file. 
files = begonia.path.find_files(tr.Path, 'Wheel.csv');
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
wheel_speed = reshape(wheel_speed,1,[]);
% Calculate the speed in degrees per second. Original data is the change in
% degrees since last timepoint.
wheel_speed =  wheel_speed * fs;

t = (0:length(wheel_speed)-1) / fs;

% Save as time series format.
wheel = table;
wheel.y = {wheel_speed};
wheel.x = {t};
wheel.fs = fs;
wheel.ylabel = "Wheel speed (deg/s)";
wheel.name = "Wheel speed";

tr.save_var(wheel);

end

