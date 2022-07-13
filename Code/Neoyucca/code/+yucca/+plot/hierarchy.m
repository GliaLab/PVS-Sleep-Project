% Based on an original plot by Celine Marie Løken Cunen
% Re-implemented for Matlab
function [fig, ax] = hierarchy(tab, var, levels, method, colors, use_labels, ax)
    if nargin < 7
        fig = figure(); ax = gca();
    end
    if nargin < 6
        use_labels = false;
    end
    
    initial_weight = (length(levels) / 2) + 1.5;
    
    subplot(tab, levels(1), levels(2:end), var, 1, method, [], colors, initial_weight, use_labels);
    
    ylim([0, length(levels) + 2])
    ax.YDir = "reverse";
    ax.YTick = 1:length(levels) + 1;
    ax.YTickLabel = yucca.util.escape_plot_string([levels, "observations"]);
    grid on;
    
end

function subplot(tab, grpvar, grpvars, var, lv, method, prev_coord, colors, weight, use_labels) 

    grps = unique(tab.(grpvar))';
    for grp = grps 
        color = colors(1);
        if length(colors) > 1
            colors = colors(2:end);
        end
        
        subtab = tab(tab.(grpvar) == string(grp),:);
        val = method(subtab.(var));
        plot(val, lv, "o", "Color", color, "MarkerSize", 10 - weight, "MarkerFaceColor", color); 
        hold on;
        if ~isempty(prev_coord)
            coords = [prev_coord ; [val, lv]];
            line(coords(:,1), coords(:,2), "Color", color, "linewidth", weight)
        end
        
        if use_labels
            text(val, lv - .2, string(grp))
        end
        
        if isempty(grpvars)
            for i = 1:height(subtab)
                plot(subtab.(var)(i), lv + 1, "x", "Color", color);
                coords = [[val, lv] ; [subtab.(var)(i), lv + 1]];
                line(coords(:,1), coords(:,2), "Color", color, "linewidth", weight - 1);
            end
        else
            subplot(subtab, grpvars(1), grpvars(2:end), var, lv + 1, method, [val, lv], color, weight - 1, use_labels)
        end
    end

end