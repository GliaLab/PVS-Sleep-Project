function tbl = align_time_series(time_points, time_series, ...
    window_before, window_after)

tbl = innerjoin(time_points, time_series);

% Find the start and end indices of the window.
N = round((window_before + window_after) .* tbl.fs(1));
tbl.st = round((tbl.t0 - window_before) .* tbl.fs(1)) + 1;
tbl.en = tbl.st + N;

% Ignore timepoints where the window is outside the bounds of the
% time series.
tbl(tbl.st < 1,:) = [];
if isempty(tbl); return; end
tbl(tbl.en > length(tbl.y{1}),:) = [];
if isempty(tbl); return; end

% Align the time series.
for j = 1:height(tbl)
    tbl.y{j} = tbl.y{j}(tbl.st(j):tbl.en(j));
end

% Add a time vector.
x = (0:N) / tbl.fs(1) - window_before;
tbl.x = repmat({x}, height(tbl), 1);

% Clean up table
tbl.st = [];
tbl.en = [];

end
