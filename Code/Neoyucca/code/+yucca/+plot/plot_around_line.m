function plot_around_line(line, y, alpha)
if nargin < 3
    alpha = 0.3;
end

x = line.XData;
y_orig = line.YData;

x = reshape(x,1,[]);
y_orig = reshape(y_orig,1,[]);
y = reshape(y,1,[]);

x = [x,fliplr(x)];
y = [y_orig+y,fliplr(y_orig-y)];
hold on
shape = fill(x,y,line.Color);
shape.FaceAlpha = alpha;
shape.EdgeAlpha = 0.0;
uistack(shape,'bottom');

end