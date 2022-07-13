function [ts_corr] = correlate_ts_trial(tseries, trials)
    import begonia.util.to_loopable;
    
    ts_corr = containers.Map();
    
    for ts = to_loopable(tseries) 
        % check if tseries starts within the trials:
        ts_in_trial = arrayfun(@(tr) ...
            overlaps(ts.start_time, tr.start_time, tr.end_time) || ...
            overlaps(ts.end_time, tr.start_time, tr.end_time), trials);
        ts_corr(ts.name) = trials(ts_in_trial);
    end
end

function ol = overlaps(p, s, e) 
    ol = p > s && p < e;
end

