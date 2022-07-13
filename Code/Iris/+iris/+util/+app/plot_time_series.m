function line = plot_time_series(ts, ax)

assert(height(ts) == 1,"This functions only plots time series with one row.")

x = ts.x{1};
y = ts.y{1};

line = plot(ax,x,y);

ax.Title.String = ts.name;
ax.YLabel.String = ts.ylabel;
ax.XLabel.String = "Time (s)";

% Set the xlimits as the plot sometimes adds too much padding.
ax.XLim = [x(1),x(end)];

end

