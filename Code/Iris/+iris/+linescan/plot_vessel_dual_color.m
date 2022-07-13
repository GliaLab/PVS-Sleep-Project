function plot_vessel_dual_color(vessel_linescan, vessel_wall)
if nargin < 2
    vessel_wall = [];
end

assert(height(vessel_linescan) == 2);

%% Plot 2 linescans with green and red.
img1 = vessel_linescan.linescan{1};
img1 = imadjust(img1);
img1 = im2uint8(img1);

img2 = vessel_linescan.linescan{2};
img2 = imadjust(img2);
img2 = im2uint8(img2);

img = zeros(size(img1,1), size(img1,2), 3, 'uint8');
img(:,:,1) = img1;
img(:,:,2) = img2;

ax = gca;
X = (0:size(img1,2)-1) / vessel_linescan.fs(1);
Y = (0:size(img1,1)-1) * vessel_linescan.dx(1);
imagesc(X,Y,img);

ylabel("Diameter (um)");
xlabel("Time (s)");

%% Plot vessel wall.
if ~isempty(vessel_wall)
    hold on
    N = min(4,height(vessel_wall));
    for i = 1:N
        p = plot(vessel_wall.x{i}, vessel_wall.y{i});
        p.Color = "blue";
        p.LineWidth = 2;
    end
%     p = plot(vessel_diameter.vessel_upper{1});
%     plot(vessel_diameter.vessel_lower{1}, "Color", p.Color);
end

end

