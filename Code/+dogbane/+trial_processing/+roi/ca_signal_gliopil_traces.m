function ca_signal_gliopil_traces(ts)

ts.clear_var('ca_signal_gliopil_traces')

if ts.channels < 2
    return;
end
%% Load
roi_array = ts.load_var('roi_array');

I = strcmp({roi_array.group},'Gp');
I = find(I);

if isempty(I)
    return;
end

mat_ast = ts.get_mat(1,1);
mat_neu = ts.get_mat(1,2);

dim_ast = size(mat_ast);
dim_neu = size(mat_neu);
assert(isequal(dim_ast,dim_neu));

frames = size(mat_ast,3);

o = struct;
%% Extract ast
mat = mat_ast(:,:,:);

cnt = 1;
begonia.util.logging.backwrite();
for i = I
    str = sprintf('Gp ast (%d/%d)',cnt,length(I));
    begonia.util.logging.backwrite(1,str);
    
    roi = roi_array(i);
    
    % Crop a square around the roi.
    min_x = min(roi.x);
    min_y = min(roi.y);
    max_x = max(roi.x);
    max_y = max(roi.y);

    min_x = max(min_x,1);
    min_y = max(min_y,1);
    max_x = min(max_x,size(mat,2));
    max_y = min(max_y,size(mat,1));

    roi_mask = roi.mask(min_y:max_y, min_x:max_x);
    roi_mask = repmat(roi_mask, 1, 1, frames);

    % Crop a 3d matrix of the same size out of the recording. 
    chunk = mat(min_y:max_y, min_x:max_x, :);

    % Areas not in the mask are zero. 
    chunk(~roi_mask) = 0;

    vec = sum(sum(chunk, 1), 2) / length(roi.x);
    vec = reshape(vec,1,[]);
    
    o(cnt).ast = vec;
    
    cnt = cnt + 1;
end
%% Extract neu
clear mat;
mat = mat_neu(:,:,:);

cnt = 1;
begonia.util.logging.backwrite();
for i = I
    str = sprintf('Gp neu (%d/%d)',cnt,length(I));
    begonia.util.logging.backwrite(1,str);
    
    roi = roi_array(i);
    
    % Crop a square around the roi.
    min_x = min(roi.x);
    min_y = min(roi.y);
    max_x = max(roi.x);
    max_y = max(roi.y);

    min_x = max(min_x,1);
    min_y = max(min_y,1);
    max_x = min(max_x,size(mat,2));
    max_y = min(max_y,size(mat,1));

    roi_mask = roi.mask(min_y:max_y, min_x:max_x);
    roi_mask = repmat(roi_mask, 1, 1, frames);

    % Crop a 3d matrix of the same size out of the recording. 
    chunk = mat(min_y:max_y, min_x:max_x, :);

    % Areas not in the mask are zero. 
    chunk(~roi_mask) = 0;

    vec = sum(sum(chunk, 1), 2) / length(roi.x);
    vec = reshape(vec,1,[]);
    
    o(cnt).neu = vec;
    
    cnt = cnt + 1;
end
%%
ca_signal_gliopil_traces = o;
ts.save_var(ca_signal_gliopil_traces);

end

