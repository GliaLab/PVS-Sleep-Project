clear all

%% Load labview trials
tr = get_labview_trials(true);
tr = tr(tr.has_var("pupil_crop"));
tr = tr(tr.has_var("pupil_threshold"));
%%
tic
for i = 1:length(tr)
    if i == 1 || i == length(tr) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(tr))
    end
    
    iris.processing_functions.calc_pupil_mask(tr(i));

end