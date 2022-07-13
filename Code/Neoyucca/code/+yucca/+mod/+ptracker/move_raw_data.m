%{ 
Raw pupil tracker data is so large that it makes sense at times to copy 
it to separat locations. move_raw_data moves the data to an archive and
keeps data on the trial that was used so that the data can later be
connected when analysed
%}

function move_raw_data(trial, destination)
    import begonia.util.logging.*;
    vlog(1, ['[move_raw_data]: processing trial ' trial.uuid])
    ARCH_VAR = 'ptrack_archived_to';
    
    raw_path = fullfile(trial.path, 'pupil_data');
    
    
    % check if the trial already has archived it's pupil data, and if this
    % exists:
    if trial.has_var(ARCH_VAR)
        existing_arch = trial.load_var(ARCH_VAR);
        if exist(existing_arch, 'dir')
            vlog(1, ['[move_raw_data]: existing archived data found - skipping']);
            return;
        else
            if ~exist(raw_path, 'dir')
                error('Trial has arvhive variable that does not exist, and no raw data in trial dir!');
            end
        end
    end
    
    % check trial has raw pupil data:
    if ~exist(raw_path, 'dir')
        error('The trial has no pupil_data dir, or trial does not exist');
    end
    
    % create dir name for raw data:
    start_str = datestr(trial.start_time, 'YYYY-MM-DD-HHmmss');
    arch_dir = ['pupil_raw ' start_str ' - ' trial.name];
    arch_path = fullfile(destination, arch_dir);
    
    % metadata:
    mdata = struct();
    mdata.trial_start = trial.start_time;
    mdata.trial_end = trial.end_time;
    mdata.trial_uuid = trial.uuid;
    mdata.trial_name = trial.name;
    mdata.trial_path = trial.path;
    mdata.trial_time_correction = char(trial.time_correction);
    
    % create dir and write metadata
    vlog(2, ['[move_raw_data]: creating: ' arch_path])
    mkdir(arch_path);
    
    vlog(2, ['[move_raw_data]: writing metadata'])
    mdata_json = jsonencode(mdata);
    mdata_path = fullfile(arch_path, 'source_trial.json');
    file = fopen(mdata_path,'w');
    fprintf(file, mdata_json);
    fclose(file);
    
    % create a datalocation for the new dir:
    dloc = begonia.data_management.DataLocation(arch_path);
    dloc.dl_ensure_has_uuid;
    dloc.save_var('source_trial', mdata);
    
    % move data:
    vlog(2, ['[move_raw_data]: moving "pupil_data" to archive']);
    [status,message] = movefile(raw_path, arch_path);
    if status ~= true
       error(['Something went wrong moving the data :' message]); 
    end
    
    trial.save_var(ARCH_VAR, arch_path);
end

