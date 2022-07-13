clear all

%% Load labview trials
tr = get_labview_trials(true);

%%
for i = 1:length(tr)
    iris.util.log_progress(i,tr,5,"Trial");
    iris.processing_functions.load_wheel(tr(i));
end