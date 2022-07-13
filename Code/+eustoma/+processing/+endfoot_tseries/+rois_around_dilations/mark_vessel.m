
ts = eustoma.get_endfoot_tseries();
% ts = ts(ts.has_var("nrem"));
ts = ts(ts.has_var("rem"));
ts = ts(ts.has_var("avg_glt_img"));
ts = ts(ts.has_var("avg_texas_red_img"));

%%

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark vessels', ...
    @(ts,~,~) open_gui(ts), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'path';
initial_vars{end+1} = '!vessel_position_note';
initial_vars{end+1} = 'vessel_position';

xylobium.dledit.Editor(ts,actions,initial_vars,[],false);
%%
function open_gui(ts)
img1 = ts.load_var('avg_glt_img');
img2 = ts.load_var('avg_texas_red_img');
img = zeros([size(img1),3]);
img(:,:,1) = img2/max(img2(:));
img(:,:,2) = img1/max(img2(:));

f = figure;
ax = gca;

imshow(img,'Parent',ax);
f.Position(3:4) = [600,600];

vessel_position = ts.load_var("vessel_position", []);

if ~isempty(vessel_position)
    vessel_id = vessel_position.vessel_id;
    vessel_position = vessel_position.vessel_position;
    
    for i = 1:size(vessel_position,1)
        pos = vessel_position(i,:);
        pos = reshape(pos,2,2);
        l = images.roi.Line(ax, "Position", pos);
        l.Tag = "roi line";
        l.Label = vessel_id(i);
    end
end

f.KeyPressFcn = @(~,e)press_key(e, ts, size(img1));

end

function press_key(e, ts, img_dim)
switch e.Character
    case 'a'
        pos = round(img_dim / 4);
        pos = [pos * 1; pos * 3];
        l = images.roi.Line(gca, "Position", pos);
        l.Position
        l.Tag = "roi line";
        l.Label = begonia.util.make_uuid();
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
            vessel_id = "";
            vessel_position = zeros(length(o),4);
            for i = 1:length(o)
                vessel_position(i,:) = o(i).Position(:);
                vessel_id(i,1) = o(i).Label;
            end
            vessel_position = table(vessel_id,vessel_position);
            vessel_position = sortrows(vessel_position);
            vessel_position
            ts.save_var(vessel_position)
        end
end
end