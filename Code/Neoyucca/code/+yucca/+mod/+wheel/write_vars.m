function write_vars(trials)
%begonia.util.logging.vlog(1,'Attempting to load wheel...');
%begonia.util.logging.backwrite(1,sprintf('Attempting to load wheel...'));
%fprintf('Attempting to load wheel:\n');
for trial = trials
    try
        wheel = yucca.mod.wheel.read(trial);
        trial.save_var(wheel);
    catch e
        fprintf('Trial: %s\n',trial.path);
        fprintf('Error: %s\n',e.identifier);
    end
end


end

