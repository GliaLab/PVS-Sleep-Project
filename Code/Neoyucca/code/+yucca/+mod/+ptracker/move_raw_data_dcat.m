% function to archive all pupil data in a datacat:
function move_raw_data_dcat(dcat, archive_dir)
    import begonia.util.logging.*;
    vlog(1,'[move_raw_data_dcat]: processing all trials in datacat')

    if ~exist(archive_dir, 'dir')
        error('Archive dir does not exist!');
    end

    % get trials:
    trial_infos = dcat.data_types('Recording rig output');
    vlog(1, ['[move_raw_data_dcat]: found ' num2str(length(trial_infos)) ' trials']);
    
    % process each one:
    for info = trial_infos
        if ~info.cat_source.available
            warning(['Could not process due to source unavailable: ' info.name]);
        end
        
        trial = dcat.get_data(info.uuid);
        
        yucca.mod.ptracker.move_raw_data(trial, archive_dir);
    end
end

