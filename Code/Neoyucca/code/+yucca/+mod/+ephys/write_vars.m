function write_vars(trials)

begonia.util.logging.vlog(1,'Loading trial ephys');
begonia.util.logging.backwrite();
for i = 1:length(trials)
    trial = trials(i);
    str = sprintf('Trial (%d/%d)',i,length(trials));
    begonia.util.logging.backwrite(1,str);
    try
        [ephys,ephys_down] = yucca.mod.ephys.read(trial);
        trial.save_var(ephys);
        trial.save_var(ephys_down);
    catch e
        begonia.util.logging.backwrite();
        
        fprintf('Error: %s\n',e.identifier);
        fprintf('Trial: %s\n',trial.path);
    end
end


end

