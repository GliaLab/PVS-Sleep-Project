begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_table'));
ts = ts(ts.has_var('roi_signals_raw'));
ts = ts(ts.has_var('dt'));

%%

new_fs = 30;

for i = 1:length(ts)
    begonia.logging.log(1,"TSeries (%d/%d)",i,length(ts));
    
    roi_signals = ts(i).load_var('roi_signals_raw');
    
    roi_signals.signal = cell(height(roi_signals),1);
    for j = 1:height(roi_signals)
        y = roi_signals.signal_raw{j};
        t = (0:length(y)-1) * roi_signals.dt(j);
        roi_signals.signal{j} = resample(y,t,new_fs);
    end
    roi_signals.signal_raw = [];
    
    roi_signals.fs(:) = new_fs;
    roi_signals.dt = [];
    
    % Separate the Cap ROIs (which is in the middle of the vessel) from the
    % rest of the ROIs. 
    roi_signals_cap = roi_signals(roi_signals.type == "Cap",:);
    roi_signals(roi_signals.type == "Cap",:) = [];
    
    if ~isempty(roi_signals_cap)
        ts(i).save_var(roi_signals_cap);
    end
    ts(i).save_var(roi_signals);
end

