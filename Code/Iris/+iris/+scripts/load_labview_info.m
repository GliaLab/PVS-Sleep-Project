clear all

%% Load trials
tr = get_labview_trials(true);

%%
tic
for i = 1:length(tr)
    if i == 1 || i == length(tr) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(tr))
    end
    
    % Find the path relative to the prjoect labview directtory.
    path = tr(i).path;
    % Remove the first part of the path.
    labview_path = fullfile(get_project_path(),"Data","Labview");
    path = strrep(path, labview_path, "");
    % Replace file seperator with whitespace.
    path = strrep(path, filesep, " ");
    path = strip(path);
    
    labview_metadata = struct;
    labview_metadata.start_time_abs = tr(i).start_time_abs;
    labview_metadata.duration = tr(i).duration;
    labview_metadata.path = path;
    tr(i).save_var(labview_metadata);
    
end
