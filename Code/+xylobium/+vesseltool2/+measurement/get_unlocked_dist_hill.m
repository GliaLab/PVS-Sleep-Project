function [diameter_m, diameter_lrd, means, left_point, right_point] = get_unlocked_dist_hill(lscan)
    % calculate left and right half means separately as the fluoresence in
    % dynamic measurements might be quite different on either side:
    lscan_s = smooth(lscan);
    mid = floor(length(lscan)/2);
    
    left_min = min(lscan_s(1:mid));
    right_min = min(lscan_s(mid:end));
    
    left_amp = max(lscan_s(1:mid)) - left_min;
    right_amp = max(lscan_s(mid:end)) - right_min;
    
    left_mean = left_min + (left_amp / 2);
    right_mean = right_min + (right_amp / 2);
    
    means = [left_mean right_mean];
    
    % pick the smallest of the means to do the dynamic measurement:
    %means_min = [min(means) min(means)];
    [diameter_m] = get_dist(lscan, means);
    
    % get diameter using individual means from left and right side:
    [diameter_lrd, left_point, right_point] = get_dist(lscan, means);
end

function [diameter, left_point, right_point] = get_dist(lscan, means)
    mid = floor(length(lscan)/2);
    left_mean = means(1);
    right_mean = means(2);
    
    % find intersection of mean with graph: last on left side, and first on
    % the right side. Distance is the length of the line between the
    % interception:
    left_point = find(lscan(1:mid) > left_mean, 1, 'first');
    right_point = find(lscan(mid+1:end) > right_mean, 1, 'last') + mid;
    diameter = right_point - left_point;
end