function generate_video(trial, editor)
    import yucca.mod.puptool.*;
    
    img_path = fullfile(trial.path, 'pupil_data');
    config = trial.load_var('puptrack_config');
    
    name = trial.uuid;
    if trial.has_var('puptrack_video_name')
        name = trial.load_var('puptrack_video_name');
    end
    
    video_path = fullfile(editor.video_out_dir, char(name + ".mp4"));
    
    generate_video(img_path, config, video_path);
    trial.save_var('puptrack_video', video_path);
end

