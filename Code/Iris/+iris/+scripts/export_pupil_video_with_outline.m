clear all

%% Load labview trials
tr = get_labview_trials(true);
tr = tr(tr.has_var("pupil_mask"));

%%
for i = 1:length(tr)
    iris.util.log_progress(i,tr,0,"Trial");
    iris.processing_functions.export_pupil_video_with_outline(tr(i));
end
