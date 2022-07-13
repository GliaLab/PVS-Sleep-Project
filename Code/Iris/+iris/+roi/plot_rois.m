function plot_rois(roi_table, plot_legend, plot_roi_name)
if nargin < 2
    plot_legend = true;
end
if nargin < 3
    plot_roi_name = false;
end

hold on

% Get color from the table if existing.
if ~ismember("color", roi_table.Properties.VariableNames)
    roi_color_table = iris.roi.get_default_roi_color_table();
    assert(all(ismember(roi_table.roi_group,roi_color_table.roi_group)), "Not all ROIs have a default color.");
    roi_table = innerjoin(roi_table, roi_color_table);
end

for i = 1:height(roi_table)
    % Make an outline of the mask.
    mask = false(roi_table.img_dim(i,:));
    I = roi_table.roi_indices{i};
    mask(I) = true;
    B = bwboundaries(mask);
    
    line = plot(B{1}(:,2), B{1}(:,1), 'w', 'LineWidth', 2);
    line.Color = roi_table.color(i,:);
    
    % If a short name is present and plot, then plot.
    if ismember("roi_short_name", roi_table.Properties.VariableNames) && plot_roi_name
        text(roi_table.center(i,1),roi_table.center(i,2), ...
            roi_table.roi_short_name(i), ...
            "Color",roi_table.color(i,:), ...
            "HorizontalAlignment","Center");
    end
    
end

% Plot legend
if plot_legend
    ax = gca;
    % Make a table with 2 columns, roi_group and color. This could usually
    % be done like this: color_table = findgroups(roi_table(:,["roi_group","color"])); 
    % but this does not work because findgroups demands the columns are 1D
    % and the 'color' column is Nx3 matrix as it has has 3 numbers in each row. 
    [~, roi_group, r, g, b] = findgroups(roi_table.roi_group, ...
        roi_table.color(:,1), roi_table.color(:,2), roi_table.color(:,3));
    color = [r,g,b];
    color_table = table(roi_group, color);
    
    for i = 1:height(color_table)
        h(i) = plot(ax, NaN,'square', ...
            'MarkerSize', 10, ...
            'MarkerEdgeColor',color_table.color(i,:), ...
            'MarkerFaceColor',color_table.color(i,:), ...
            'DisplayName', char(color_table.roi_group(i)));
    end
    legend(h);
end

end

