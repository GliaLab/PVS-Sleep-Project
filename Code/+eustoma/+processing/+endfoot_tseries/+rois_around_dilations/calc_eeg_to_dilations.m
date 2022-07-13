begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('recrig'));
ts = ts(ts.has_var('dilation_episodes'));

trials = eustoma.get_endfoot_recrigs();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(ts);

%%
sec_before_episode = 15;
sec_after_episode = 15;

for i = 1:length(ts)
    begonia.logging.log(1,"TSeries (%d/%d)",i,length(ts));
    
    ephys = ts(i).find_dnode('recrig').load_var('ephys_norm',[]);
    eeg_dilation_ep = ts(i).load_var('dilation_episodes');
    
    if isempty(ephys)
        continue;
    end
    
    % Calculate the spectrogram for the eeg.
    flims = [0.1,50];
    fb = cwtfilterbank('SignalLength',length(ephys.ecog), ...
        'SamplingFrequency',ephys.Properties.SampleRate,...
        'FrequencyLimits',flims);

    [wt,f] = cwt(ephys.ecog,'FilterBank',fb);
    wt = abs(wt);
    
    eeg_dilation = table;
    eeg_dilation.fs = ephys.Properties.SampleRate;
    eeg_dilation.f = f';
    
    eeg_dilation_ep.st = round((eeg_dilation_ep.ep_start - sec_before_episode) * ephys.Properties.SampleRate) + 1;
    eeg_dilation_ep.en = eeg_dilation_ep.st + round((sec_before_episode + sec_after_episode) * ephys.Properties.SampleRate);
    eeg_dilation_ep(eeg_dilation_ep.st < 1,:) = [];
    eeg_dilation_ep(eeg_dilation_ep.en > size(wt,2),:) = [];
    
    eeg_dilation_ep.spectrogram = cell(height(eeg_dilation_ep),1);
    for j = 1:height(eeg_dilation_ep)
        eeg_dilation_ep.spectrogram{j} = wt(:,eeg_dilation_ep.st(j):eeg_dilation_ep.en(j));
    end
    
    % Calculate slow delta amplitude time series.
    trace = bandpass(ephys.ecog, [0.2,4], ephys.Properties.SampleRate);
    trace = hilbert(trace);
    trace = abs(trace);
    % Smooth with 4 seconds.
    trace = smooth(trace,round(ephys.Properties.SampleRate * 4));
    % Init array.
    n = round((sec_before_episode + sec_after_episode) * ephys.Properties.SampleRate) + 1;
    eeg_dilation_ep.slow_delta = nan(height(eeg_dilation_ep),n);
    % Slice per episode.
    for j = 1:height(eeg_dilation_ep)
        eeg_dilation_ep.slow_delta(j,:) = trace(eeg_dilation_ep.st(j):eeg_dilation_ep.en(j));
    end
    
    % Remove the indices used to align the traces.
    eeg_dilation_ep.st = [];
    eeg_dilation_ep.en = [];
    
    t = (0:size(eeg_dilation_ep.spectrogram{1},2)-1) / ephys.Properties.SampleRate;
    t = t - sec_before_episode;
    eeg_dilation.t = t;
    
    ts(i).save_var(eeg_dilation)
    ts(i).save_var(eeg_dilation_ep)
end

