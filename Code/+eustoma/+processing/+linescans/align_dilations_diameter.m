begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('dilation_timepoints'));
%%

sec_before = 20;
sec_after = 20;
% Pick a constant sampling rate. 80 because that was the lowest in the 15
% trials I checked.
fs = 80;

for i = 1:length(scans)
    begonia.logging.log(1,"Trial %d/%d",i,length(scans));
    
    dilation_timepoints = scans(i).load_var('dilation_timepoints');
    
    diameter_red = scans(i).load_var("diameter_red_baseline");
    diameter_green = scans(i).load_var("diameter_green_baseline");
    diameter_peri = scans(i).load_var("diameter_peri_baseline");
    
    % Resample the diameter traces so it is the same for all the trials.
    diam_t = (0:length(diameter_red.diameter{1})-1) / diameter_red.vessel_fs;
    red = diameter_red.diameter{1};
    green = diameter_green.diameter{1};
    peri = diameter_peri.diameter{1};
    
    red = resample(red,diam_t,fs);
    green = resample(green,diam_t,fs);
    peri = resample(peri,diam_t,fs);
    
    % Calculate time vector of the aligned signal.
    n = round((sec_before + sec_after) * fs) + 1;
    t = (0:n-1) / fs;
    t = t - sec_before;
    
    % Make a struct that keeps information about the table.
    diameter_dilation = struct;
    diameter_dilation.fs = fs;
    diameter_dilation.sec_before = sec_before;
    diameter_dilation.sec_after = sec_after;
    diameter_dilation.t = t;
    
    % Make a copy of the dilation table that will be used to append
    % additional data about the eeg associated with the dilations.
    tbl = dilation_timepoints;
    
    % Calculate the indices of slices around the dilation timepoints.
    tbl.st = round((tbl.t0 - sec_before) * fs) + 1;
    tbl.en = tbl.st + n - 1;
    
    % Remove dilation timepoints that are too close to the edges.
    tbl(tbl.st < 1,:) = [];
    tbl(tbl.en > length(red),:) = [];
    
    % Slice the diameter traces.
    tbl.red = nan(height(tbl),n);
    tbl.green = nan(height(tbl),n);
    tbl.peri = nan(height(tbl),n);
    for j = 1:height(tbl)
        tbl.red(j,:) = red(tbl.st(j):tbl.en(j));
        tbl.green(j,:) = green(tbl.st(j):tbl.en(j));
        tbl.peri(j,:) = peri(tbl.st(j):tbl.en(j));
    end
    
    % Remove the slice indices.
    tbl.st = [];
    tbl.en = [];
    
    % Calculate dilation difference
    mid = round(sec_before * fs) + 1;
    tbl.red = tbl.red - tbl.red(:,mid);
    tbl.green = tbl.green - tbl.green(:,mid);
    tbl.peri = tbl.peri - tbl.peri(:,mid);
    
    % Save the data.
    diameter_dilation_tbl = tbl;
    scans(i).save_var(diameter_dilation);
    scans(i).save_var(diameter_dilation_tbl);
end