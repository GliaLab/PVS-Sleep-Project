function out = join_by_center_distance(tbl1, tbl2, distance)
% Join two tables based on the distance between the "center" columns.
% Output table only contains the center coordinates from tbl1.

% Rename center column for table 2 so tables can be joined.
tbl2.tmp_center = tbl2.center;
tbl2.center = [];

% Make all combinations between elements in table 1 and 2.
out = iris.util.crossjoin(tbl1, tbl2);

% Find the distance between all elements.
out.distance = vecnorm(out.center - out.tmp_center, 2, 2);

% Remove rows outside distance threshold.
out(out.distance > distance, :) = [];

% Clean up center coordinates from tbl2.
out.tmp_center = [];

end