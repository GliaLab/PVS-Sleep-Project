% This script loads the voltage recording file from the unaligned tseries
% directly into the "save_var" of the aligned tseries.

clear all

%% Load tseries
ts_unaligned = get_tseries_unaligned(true);
ts = get_tseries(true);

ts = ts(ts.has_var("trial_id"));

%%
tic
for i = 1:length(ts_unaligned)
    if i == 1 || i == length(ts_unaligned) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts_unaligned))
    end

    % Find the associated aligned trial.
    I = ismember({ts.uuid}, ts_unaligned(i).uuid);
    if ~any(I)
        continue;
    end
    
    % Find the voltage recording file.
    filename = begonia.path.find_files(ts_unaligned(i).path,".csv");
    filename = string(filename);
    if isempty(filename)
        continue;
    end

    % Read voltage data.
    warning off
    tbl = readtable(filename);
    warning on

    % Create a time series table of the data.
    voltage_recording = table;
    voltage_recording.trial_id = string(ts(I).load_var("trial_id"));
    voltage_recording.y = {tbl.Input1};
    voltage_recording.x = {tbl.Time_ms_ / 1000}; % Convert from ms to seconds.
    voltage_recording.fs = 1 / (tbl.Time_ms_(2) - tbl.Time_ms_(1)) * 1000;
    voltage_recording.ylabel = "Voltage recording (mV)";
    voltage_recording.name = "Voltage recording";
    ts(I).save_var(voltage_recording);

end
