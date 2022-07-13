begonia.logging.set_level(1);

scans = eustoma.get_linescans(true);
scans = scans(scans.has_var('linescan_info'));
%%
path = scans.load_var('path');
[~,I] = sort(string(path),'descend');
scans = scans(I);
%%
actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Crop linescan', ...
    @(trial,~,~) crop_linescan(trial), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'linescan_crop';
initial_vars{end+1} = '!linescan_crop_status';

mod = xylobium.dledit.mods.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(scans,actions,initial_vars,mod,false);

%%
function crop_linescan(scan)

mat = scan.read(500);
dim = size(mat);

if size(mat,1) == 2
    mat1 = mat(1,:,:);
    mat2 = mat(2,:,:);
    
    b = prctile(mat1(:),[1,99]);
    mat1 = (mat1 - b(1)) / (b(2) - b(1));
    
    b = prctile(mat2(:),[1,99]);
    mat2 = (mat2 - b(1)) / (b(2) - b(1));

    img = zeros(dim(2),dim(3),3);
    img(:,:,2) = mat1;
    img(:,:,1) = mat2;
else
    mat1 = mat(1,:,:);
    
    b = prctile(mat1(:),[1,99]);
    mat1 = (mat1 - b(1)) / (b(2) - b(1));

    img = zeros(dim(2),dim(3),3);
    img(:,:,1) = mat1;
end

img(img < 0) = 0;
img(img > 1) = 1;

f = figure;
imagesc(img * 0.5);

linescan_crop = scan.load_var('linescan_crop',[]);
if ~isempty(linescan_crop)
    for i = 1:size(linescan_crop,1)
        eustoma.util.MoveRectangleVert(f,gca,linescan_crop(i,:),'Marker');
    end
end

f.KeyPressFcn = @(~,e)press_key(scan,e,size(img,1));
end

function press_key(scan,e,pixels)
switch e.Character
    case 'a'
        eustoma.util.MoveRectangleVert();
    case 'd'
        o = findobj('Tag','Marker');
        delete(o);
    case 's'
        o = findobj('Tag','Marker'); 
        
        if isempty(o)
            scan.clear_var('linescan_crop');
            begonia.logging.log(1,'Deleting cropping');
        else
            linescan_crop = zeros(length(o),2);
            for i = 1:length(o)
                linescan_crop(i,1) = o(i).Position(2);
                linescan_crop(i,2) = o(i).Position(2) + o(i).Position(4);
            end
            linescan_crop = round(linescan_crop);
            linescan_crop(linescan_crop < 1) = 1;
            linescan_crop(linescan_crop > pixels) = pixels;
            begonia.logging.log(1,'Saving cropping');
            linescan_crop
            scan.save_var(linescan_crop);
        end
end
end