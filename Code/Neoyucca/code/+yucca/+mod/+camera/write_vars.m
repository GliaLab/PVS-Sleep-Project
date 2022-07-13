function write_vars(trials)

fprintf('Attempting to load camera:\n');
for trial = trials
    try
        camera = yucca.mod.camera.read(trial);
        trial.save_var(camera);
    catch e
        fprintf('Trial: %s\n',trial.path);
        fprintf('Error: %s\n',e.identifier);
    end
end


end

