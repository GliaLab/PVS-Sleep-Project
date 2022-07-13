function correlates = by_offset( lag_ms, leeway_ms, trial, stack )
%CORRFUNC_BY_OFFSET Summary of this function goes here
%   Detailed explanation goes here

    % compare stack recorded time with trial time:
    
    % add lag milliseconds to stack
    infmt = 'MM/dd/uuuu hh:mm:ss aa';
    stime_adjusted = datetime(stack.record_date, 'InputFormat',infmt) ...
        + milliseconds(lag_ms);

    % see if they are correalted within leeway:
    ttime_min = trial.DateRecorded - milliseconds(leeway_ms);
    ttime_max = trial.DateRecorded + milliseconds(leeway_ms);
    
    correlates = ttime_min < stime_adjusted && ttime_max > stime_adjusted;
end

