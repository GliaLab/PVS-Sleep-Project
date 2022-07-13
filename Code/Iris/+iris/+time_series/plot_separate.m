function line = plot_separate(ts, ax, plot_legend)
if nargin < 2
    ax = gca;
end
if nargin < 3
    plot_legend = true;
end

hold on

% Plot the average value.
for i = 1:height(ts)
    line(i) = plot(ax, ts.x{i}, ts.y{i});

    % Get color from the table if existing.
    if ismember("color", ts.Properties.VariableNames)
        line(i).Color = ts.color(i,:);
    end
end
ax.XLabel.String = "Time (s)";

% If the table has a column with ylabel, use it.
if ismember("ylabel", ts.Properties.VariableNames)
    ax.YLabel.String = ts.ylabel(1);
end

N = height(ts);

% If the table has a column with name, use it.
if ismember("name", ts.Properties.VariableNames)
    % If the name variables are different use them as legend, or else use
    % the name as the title.
    if all(ts.name(1) == ts.name)
        % Include the number of traces if more than one.
        if N > 1
            ax.Title.String = sprintf("%s (N = %d)", ts.name(1), N);
        else
            ax.Title.String = ts.name(1);
        end
    else
        if plot_legend
            % Make a legend
            for i = 1:height(ts)
                line(i).DisplayName = ts.name(i);
            end
            legend
        end
    end
end

% Set the xlimits as the plot sometimes adds too much padding.
ax.XLim = [min(ts.x{i}),max(ts.x{i})];

end

