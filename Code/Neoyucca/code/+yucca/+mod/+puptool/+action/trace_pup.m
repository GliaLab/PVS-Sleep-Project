function trace_pup(trial)
    import yucca.mod.puptool.*;
    
    img_path = fullfile(trial.path, 'pupil_data');
    config = trial.load_var('puptrack_config');
    trace = analyse_recording(img_path, config);
    trial.save_var('puptrack_data', trace);
end

