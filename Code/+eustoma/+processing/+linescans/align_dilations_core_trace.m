begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('dilation_timepoints'));
scans = scans(scans.has_var('core_trace'));
%%

sec_before = 20;
sec_after = 20;
% Pick a constant sampling rate. 80 because that was the lowest in the 15
% trials I checked.
fs = 80;

for i = 1:length(scans)
    begonia.logging.log(1,"Trial %d/%d",i,length(scans));
    
    dilation_timepoints = scans(i).load_var('dilation_timepoints');
    
    core_trace = scans(i).load_var("core_trace");
    
    % Resample the traces so it is the same for all the trials.
    diam_t = (0:length(core_trace.core_trace{1})-1) / core_trace.vessel_fs;
    trace = core_trace.core_trace{1};
    trace = resample(trace,diam_t,fs);
    
    % Calculate time vector of the aligned signal.
    n = round((sec_before + sec_after) * fs) + 1;
    t = (0:n-1) / fs;
    t = t - sec_before;
    
    % Make a struct that keeps information about the table.
    core_trace_dilation = struct;
    core_trace_dilation.fs = fs;
    core_trace_dilation.sec_before = sec_before;
    core_trace_dilation.sec_after = sec_after;
    core_trace_dilation.t = t;
    
    % Make a copy of the dilation table that will be used to append
    % additional data associated with the dilations.
    tbl = dilation_timepoints;
    
    % Calculate the indices of slices around the dilation timepoints.
    tbl.st = round((tbl.t0 - sec_before) * fs) + 1;
    tbl.en = tbl.st + n - 1;
    
    % Remove dilation timepoints that are too close to the edges.
    tbl(tbl.st < 1,:) = [];
    tbl(tbl.en > length(trace),:) = [];
    
    % Slice the diameter traces.
    tbl.core_trace = nan(height(tbl),n);
    for j = 1:height(tbl)
        tbl.core_trace(j,:) = trace(tbl.st(j):tbl.en(j));
    end
    
    % Remove the slice indices.
    tbl.st = [];
    tbl.en = [];
    
    % Calculate dilation change
    mid = round(sec_before * fs) + 1;
    tbl.core_trace = tbl.core_trace ./ tbl.core_trace(:,mid) - 1;
    
    % Save the data.
    core_trace_dilation_tbl = tbl;
    scans(i).save_var(core_trace_dilation);
    scans(i).save_var(core_trace_dilation_tbl);
end