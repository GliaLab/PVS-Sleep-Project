function l = plot_linescan_line(linescan)
hold on

for i = 1:height(linescan)
    pos = linescan.linescan_position(i,:);
    pos = reshape(pos,2,2);
    l(i) = images.roi.Line(gca, "Position", pos);
    l(i).Tag = "linescan";
    l(i).Label = linescan.linescan_id(i);
    l(i).LabelVisible = "off";
    if ismember("color", linescan.Properties.VariableNames)
        l(i).Color = linescan.color(i,:);
    end
end

end

