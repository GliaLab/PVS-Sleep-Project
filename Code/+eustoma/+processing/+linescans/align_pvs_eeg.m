begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('pvs_timepoints'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);
%%

sec_before = 20;
sec_after = 20;

for i = 1:length(scans)
    begonia.logging.log(1,"Trial %d/%d",i,length(scans));
    
    pvs_timepoints = scans(i).load_var('pvs_timepoints');
    
    ephys = scans(i).find_dnode('recrig').load_var('ephys');
    
    % Calculate the spectrogram for the eeg.
    flims = [0.01,50];
    fb = cwtfilterbank('SignalLength',length(ephys.ecog), ...
        'SamplingFrequency',ephys.Properties.SampleRate,...
        'FrequencyLimits',flims);

    [wt,f] = cwt(ephys.ecog,'FilterBank',fb);
    wt = abs(wt);
    
    % Calculate time vector of the aligned signal.
    n = round((sec_before + sec_after) * ephys.Properties.SampleRate) + 1;
    t = (0:n-1) / ephys.Properties.SampleRate;
    t = t - sec_before;
    
    eeg_pvs = struct;
    eeg_pvs.fs = ephys.Properties.SampleRate;
    eeg_pvs.f = f;
    eeg_pvs.sec_before = sec_before;
    eeg_pvs.sec_after = sec_after;
    eeg_pvs.t = t;
    
    % Make a copy of the dilation table that will be used to append
    % additional data about the eeg associated with the dilations.
    eeg_pvs_tbl = pvs_timepoints;
    
    % Calculate indices of the slices around the dilations. Store it in the
    % table because it's easier to filter the table.
    eeg_pvs_tbl.st = round((eeg_pvs_tbl.t0 - sec_before) * ephys.Properties.SampleRate) + 1;
    eeg_pvs_tbl.en = eeg_pvs_tbl.st + n - 1;
    
    % Remove dilation timepoints that are too close to the edges.
    eeg_pvs_tbl(eeg_pvs_tbl.st < 1,:) = [];
    eeg_pvs_tbl(eeg_pvs_tbl.en > size(wt,2),:) = [];
    
    % Assign the spectrogram.
    eeg_pvs_tbl.spectrogram = cell(height(eeg_pvs_tbl),1);
    for j = 1:height(eeg_pvs_tbl)
        eeg_pvs_tbl.spectrogram{j} = wt(:,eeg_pvs_tbl.st(j):eeg_pvs_tbl.en(j));
    end
    
    % Calculate slow delta amplitude time series.
    trace = bandpass(ephys.ecog, [0.2,4], ephys.Properties.SampleRate);
    trace = hilbert(trace);
    trace = abs(trace);
    % Smooth with 4 seconds.
    trace = smooth(trace,round(ephys.Properties.SampleRate * 4));
    eeg_pvs_tbl.slow_delta = nan(height(eeg_pvs_tbl),n);
    for j = 1:height(eeg_pvs_tbl)
        eeg_pvs_tbl.slow_delta(j,:) = trace(eeg_pvs_tbl.st(j):eeg_pvs_tbl.en(j));
    end
    
    % Remove the slice indices.
    eeg_pvs_tbl.st = [];
    eeg_pvs_tbl.en = [];
    
    scans(i).save_var(eeg_pvs);
    scans(i).save_var(eeg_pvs_tbl);
end