function roi_traces(trial)

ts = trial.tseries;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

ts.clear_var('roi_traces');

%% Load roi_array
roi_array = ts.load_var('roi_array',[]);
roi_array = xylobium.moving_rois.ROI(roi_array);
if isempty(roi_array)
    begonia.util.logging.vlog(1,'Missing roi_array.');
    return;
end

% Only include some ROIs. 
valid_rois = {'AS','Gp','Ca','Ve','Ar'};
I = ismember({roi_array.group},valid_rois);
roi_array = roi_array(I);
if isempty(roi_array)
    begonia.util.logging.vlog(1,'roi_array only contains invalid ROIs.');
    return;
end

%% Load calcium recording
mat = ts.get_mat(1,1);
mat = mat(:,:,:);

%% Extract traces.
o = struct;

begonia.util.logging.backwrite();
for i = 1:length(roi_array)
    begonia.util.logging.backwrite(1,'roi %d/%d',i,length(roi_array));
    roi = roi_array(i);
    
    roi.frames = size(mat,3);
    
    vec = roi.calculate_signal_from_mat(mat)';
    
    o(i).roi_id = roi.id;
    o(i).roi_group = roi.group;
    o(i).roi_area_pix = roi.area;
    o(i).roi_area = roi.area * ts.dx * ts.dx;
    o(i).roi_center = roi.center;
    o(i).roi_center_pix = roi.center * ts.dx * ts.dx;
    o(i).df_f0 = vec;
end

roi_traces = struct2table(o,'AsArray',true);
roi_traces.roi_id       = categorical(roi_traces.roi_id);
roi_traces.roi_group    = categorical(roi_traces.roi_group);

mat = roi_traces.df_f0;

window_dt = 0.25; %seconds
sigma = ceil(window_dt/dt);
filter_vec = begonia.util.gausswin(sigma)';

mat = convn(mat,filter_vec,'same');
mat = round(mat);
f0 = mode(mat,2);

roi_traces.df_f0 = roi_traces.df_f0 ./ f0 - 1;

ts.save_var(roi_traces);
end

