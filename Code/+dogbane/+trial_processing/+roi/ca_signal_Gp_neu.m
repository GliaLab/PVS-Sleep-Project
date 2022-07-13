function ca_signal_Gp_neu(ts)

ts.clear_var('ca_signal_Gp_neu');

if ts.channels < 2
    return;
end

% Get the neuron mask. 
mat = ts.get_mat(1,2);

dim = size(mat);

roi_array = ts.load_var('roi_array');
roi_mask = begonia.processing.merged_roi_mask(roi_array,'Gp',dim(1:2));

if ~any(roi_mask)
    return;
end

mat = mat(:,:,:);
mat = single(mat);
roi_mask = single(roi_mask);
mat = mat .* roi_mask;
mat = sum(sum(mat,1),2);
mat = reshape(mat,1,[]);
mat = double(mat);

ca_signal_Gp_neu = mat ./ sum(roi_mask(:));
ts.save_var(ca_signal_Gp_neu);
end

