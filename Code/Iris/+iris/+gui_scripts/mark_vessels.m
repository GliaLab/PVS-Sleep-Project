clear all
close all force

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("average_images"));

%%

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark vessels', ...
    @(ts,~,~) open_gui(ts), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'vessel_position';

xylobium.dledit.Editor(ts,actions,initial_vars,[],false);
%%
function open_gui(ts)
% Load image.
average_images = ts.load_var('average_images');
if height(average_images) == 1
    img = average_images.img{1};
    img = img/prctile(img(:),99);
else
    img1 = average_images.img{1};
    img2 = average_images.img{2};
    img = zeros([size(img1),3]);
    img(:,:,1) = img2/prctile(img2(:),99);
    img(:,:,2) = img1/prctile(img2(:),99);
end

% Plot.
f = figure;
ax = gca;
imshow(img,'Parent',ax);
f.Position(3:4) = [600,600];

% Load previously marked vessels.
vessel_position = ts.load_var("vessel_position", []);
if ~isempty(vessel_position)
    id = vessel_position.linescan_id;
    linescan_position = vessel_position.linescan_position;
    
    for i = 1:size(linescan_position,1)
        pos = linescan_position(i,:);
        pos = reshape(pos,2,2);
        l = images.roi.Line(ax, "Position", pos);
        l.Tag = "roi line";
        l.Label = id(i);
        l.LabelVisible = "off";
    end
end

% Assign a funcion to key presses that can add, save and delete vessels.
f.KeyPressFcn = @(~,e)press_key(e, ts,  [size(img,1),size(img,2)]);

end

function press_key(e, ts, img_dim)
switch e.Character
    case 'a'
        pos = round(img_dim / 4);
        pos = [pos * 1; pos * 3];
        l = images.roi.Line(gca, "Position", pos);
        l.Tag = "roi line";
        l.Label = begonia.util.make_uuid();
        l.LabelVisible = "off";
    case 'd'
        o = findobj('Tag','roi line');
        delete(o);
    case 's'
        o = findobj('Tag','roi line'); 
        
        if isempty(o)
            ts.clear_var('vessel_position');
            begonia.logging.log(1,'Deleting vessel lines');
        else
            begonia.logging.log(1,'Saving vessel lines');
            linescan_id = "";
            linescan_position = zeros(length(o),4);
            for i = 1:length(o)
                linescan_position(i,:) = o(i).Position(:);
                linescan_id(i,1) = o(i).Label;
            end
            vessel_position = table(linescan_id,linescan_position);
            vessel_position = sortrows(vessel_position);
            vessel_position
            ts.save_var(vessel_position)
        end
end
end