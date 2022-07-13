function plot_time_points(tp, ax)
if nargin < 2
    ax = gca;
end

hold on

% Plot the average value.
for i = 1:height(tp)
    x = [tp.t0(i),tp.t0(i)];
    y = ax.YLim;
    line(i) = plot(ax, x, y, '--', "LineWidth", 2);

    % Get color from the table if existing.
    if ismember("color", tp.Properties.VariableNames)
        line(i).Color = tp.color(i,:);
    else
        line(i).Color = [0,0,0];
    end
end

end

