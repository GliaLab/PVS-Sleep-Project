function result = analyse_frame(ts, cy, ch, method, frame, marker)
    import xylobium.vesseltool2.measurement.*;

    xs = [marker.start_point(1) marker.end_point(1)];
    ys = [marker.start_point(2) marker.end_point(2)];
    ang = marker.angle;

    % grab the matricies:
    mat_ch = ts.get_mat(cy,ch);
    mat_frame = mean(mat_ch(:,:,frame-15:frame+15),3);
    [lscan, mat_rot] = get_lscan(mat_frame, xs, ys, ang);

    if method == "valley-intercept"
        [diameter_m, diameter_lrd, means, left_point, right_point]  ...
            = get_unlocked_dist_valley(lscan);
    elseif method == "hill-intercept"
        [diameter_m, diameter_lrd, means, left_point, right_point]  ...
            = get_unlocked_dist_hill(lscan);
    else
        error("Unknown detection method")
    end
        
    % collect results:
    result = xylobium.vesseltool2.measurement.AnalysedFrame();
    result.linescan = lscan;
    result.mat_rotated = mat_rot;
    result.method = method;
    result.distance_pix = diameter_m;
    result.intercept_y_left = left_point;
    result.intercept_y_right = right_point;
end


function [lscan, mat_rot] = get_lscan(mat, xs, ys, ang)
    span = 5;
    
    dist = sqrt(((xs(2) - xs(1))^2) + ((ys(2) - ys(1))^2));
    h = ys(2) - ys(1);

    % crop to area around the line, then rotatE:
    cx = xs(1) +  (xs(2) - xs(1)) / 2;
    cy = ys(1) + (ys(2) - ys(1)) / 2;

    croprect = [cx - dist/2 ...
        , cy - dist/2 ...
        , dist ...
        , dist];

    mat_crop = imcrop(mat, croprect);   % select area
    mat_gaus = imgaussfilt(mat_crop, 2); % smooth a little in space
    %mat_gaus = mat_crop;
    mat_rot = imrotate(mat_gaus, ang);  % rotate
    %mat_rot(mat_rot == 0) = mean(mat_rot(:));
    mat_rot(mat_rot == 0) = nan;
    
    % get the imddle part, and use that as a linescan to get profile of
    % vessel:
    mat_rot_mid = floor(size(mat_rot,2)/2);
    lscan_mat = mat_rot(:,mat_rot_mid-span:mat_rot_mid+span)';
    lscan = mean(lscan_mat,1);
end
