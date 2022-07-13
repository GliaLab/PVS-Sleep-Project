function [xQ,yQ] = interpolate_pupil_threshold(threshold,frametimes)
[~,I] = sort(threshold.frame);
threshold = threshold(I,:);

if threshold.frame(1) ~= 1
    frame = 1;
    theta = threshold.theta(1);
    id = string(begonia.util.make_uuid());
    row = table(frame, theta, id);
    threshold = cat(1, row, threshold);
end
if threshold.frame(end) ~= height(frametimes)
    frame = height(frametimes);
    theta = threshold.theta(end);
    id = string(begonia.util.make_uuid());
    row = table(frame, theta, id);
    threshold = cat(1, threshold, row);
end

% Remove duplicate values.
[~,~,I] = unique(threshold.frame);
threshold = threshold(I,:);

xQ = 1:height(frametimes);
yQ = interp1(threshold.frame,threshold.theta,xQ);
end

