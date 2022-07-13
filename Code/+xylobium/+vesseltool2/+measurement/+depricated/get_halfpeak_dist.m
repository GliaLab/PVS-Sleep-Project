function [diam_hp, peaks, intercepts] = get_halfpeak_dist(lscan)

    % find peaks to the left and right of the center of scan:
    lscan_smooth = smooth(lscan);
    mid = floor(length(lscan)/2);
    min_prom = (max(lscan_smooth) - min(lscan_smooth))/2;
    [~,locs] = findpeaks(lscan);
    %[~,locs] = findpeaks(lscan, 'MinPeakProminence',50);
    
    peaks_left = locs(locs < mid);
    peaks_right = locs(locs > mid);
    if isempty(peaks_left) || isempty(peaks_right) 
        diam_hp = nan;
        peaks = [nan nan];
        intercepts = [nan nan];
        return;
    end
    
    % if we have peaks on both sides, we can get the closest ones to mid:
    pl = peaks_left(end);
    pr = peaks_right(1);
    peaks = [pl pr];
    
    % get values of peaks, minimum values, and tresholds to intercept:
    peak_vals = [lscan(pl), lscan(pr)];
    min_val = min(lscan(pl:pr));
    tresholds = [...
        min_val + (peak_vals(1) - min_val)/2 ...
        , min_val + (peak_vals(2) - min_val)/2];
    
    % find intercepts treshold-linescan:
    left_intercept = find(lscan(1:mid) > tresholds(1), 1, 'last');
    right_intercept = find(lscan(mid+1:end) > tresholds(2), 1, 'first') + mid;
    
    intercepts = [left_intercept right_intercept];
    diam_hp = right_intercept - left_intercept;
end
