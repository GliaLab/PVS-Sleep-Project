function [I, X, Y] = calc_linescan_diameter(mat, dt, timepoints, thresholds, direction, side)

% Decide a threshold at every frame by interpolating the points.
X = (0:size(mat,2)-1) * dt;
Y = interp1(timepoints, thresholds, X, 'linear', 'extrap');
dim = size(mat);

% Apply the threshold depending on how the diameter should be found. If the
% algorithm should start on the outer edge of the linescan and go in, or if
% it should start inside and go out. 
% The max function is used to quickly find the first index crossing the
% threshold.
switch direction
    case "outer"
        if side == "upper"
            [~, I] = max(mat > Y, [], 1);
            I(I == 1) = nan;
        elseif side == "lower"
            [~, I] = max(flipud(mat) > Y, [], 1);
            I(I == 1) = nan;
            I = size(mat, 1) - I + 1;
        end
    case "inner"
        half_idx = round(size(mat,1)/2);
        if side == "upper"
            mat = mat(1:half_idx,:);
            mat = flipud(mat);
            [~, I] = max(mat > Y, [], 1);
            I(I == 1) = nan;
            I = size(mat, 1) - I + 1;
        elseif side == "lower"
            mat = mat(half_idx:end,:);
            [~, I] = max(mat > Y, [], 1);
            I(I == 1) = nan;
            I = I + half_idx;
        end
    otherwise
        error();
end
I = fillmissing(I,'linear');
I = round(I);
I(I<1) = 1;
I(I>dim(1)) = dim(1);
end

