function [line, shape] = plot_time_series(ts, ax)
if nargin < 2
    ax = gca;
end

% Use a dummy name if the name-column is missing. Used to make findgroups work.
if ismember("name", ts.Properties.VariableNames)
    name_column = ts.name;
else
    name_column = repmat("temp",height(ts),1);
end

% Assume the time series are equal length, OK for now.
ts.y = cat(1, ts.y{:});
x = ts.x{1};

% Plot one time series for each unique name.
[G,names] = findgroups(name_column);
y_mean = splitapply(@(trace) mean(trace,1,'omitnan'),ts.y,G);
y_std = splitapply(@(trace) std(trace,[],1,'omitnan'),ts.y,G);
y_N = splitapply(@(trace) size(trace,1),ts.y,G);
y_N_trace = splitapply(@(trace) sum(~isnan(trace),1),ts.y,G);

hold on
for i = 1:length(names)
    % Plot the average value.
    line(i) = plot(ax, x, y_mean(i,:));
    
    % Plot the std if there are multiple traces in the group.
    if y_N(i) > 1
        % Calc aprox conf intervall.
        tmp = 1.96 * y_std(i,:) ./ sqrt(y_N_trace(i,:));

        % Plot the confidence interval with a polygon thing.
        x_long = [x,fliplr(x)];
        y_long = [y_mean(i,:)+tmp,fliplr(y_mean(i,:)-tmp)];
        
        % Replace nan values as they mess up the plot.
        y_long(isnan(y_long)) = 0;
        
        shape(i) = fill(x_long,y_long,line(i).Color);
        shape(i).FaceAlpha = 0.3;
        shape(i).EdgeAlpha = 0.0;
        uistack(shape,'bottom');
        
        % Include the number of traces in the legend name
        if ismember("name", ts.Properties.VariableNames)
            line(i).DisplayName = sprintf("%s +/- sem. (N = %d)", names(i), y_N(i));
        end
    else
        if ismember("name", ts.Properties.VariableNames)
            line(i).DisplayName = names(i);
        end
        shape = [];
    end
end

% Use legend if more than one group.
if length(names) > 1
    legend(line)
elseif ismember("name", ts.Properties.VariableNames)
    % If there is only one group use the title to name the plot. 
    ax.Title.String = sprintf("%s +/- sem. (N = %d)", ts.name(1), height(ts));
end

ax.XLabel.String = "Time (s)";

% If the table has a column with ylabel, use it.
if ismember("ylabel", ts.Properties.VariableNames)
    ax.YLabel.String = ts.ylabel(1);
end

% Set the xlimits as the plot sometimes adds too much padding.
ax.XLim = [x(1),x(end)];

end

