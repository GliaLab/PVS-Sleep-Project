function plot_vessel_linescan(vessel_linescan, vessel_diameter)
if nargin < 2
    vessel_diameter = [];
end

ax = gca;

imagesc(vessel_linescan.linescan{1});

yticklabel = string(round(ax.YTick * vessel_linescan.dx(1)));
ax.YTickLabel = yticklabel;

xticklabel = string(round(ax.XTick / vessel_linescan.fs(1)));
ax.XTickLabel = xticklabel;

ylabel("Diameter (um)");
xlabel("Time (s)");

ax.CLim = prctile(vessel_linescan.linescan{1}(:),[0,98]);

if ~isempty(vessel_diameter)
    hold on
    p = plot(vessel_diameter.vessel_upper{1});
    plot(vessel_diameter.vessel_lower{1}, "Color", p.Color);
end

end

