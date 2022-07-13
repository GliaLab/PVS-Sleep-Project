function [outputArg1,outputArg2] = merge_experiments(exp1, exp2, merge_path)
    import begonia.util.logging.*;

    assert(exist(fullfile(exp1, 'Log.csv'), 'file') == 2);
    assert(exist(fullfile(exp2, 'Log.csv'), 'file') == 2);
    
    vlog(0, '[merge_experiments] : valid experients found, merging')
    
    % create a new dir:
    if ~exist(merge_path, 'dir')
        mkdir(merge_path);
        vlog(0, '[merge_experiments] : created merge dir')
    else
       vlog(0, '[merge_experiments] : merge dir already exists') 
    end
    
    % copy all non-log files from first and last:
    cont1 = dir(exp1);
    cont2 = dir(exp2);
    
    vlog(0, '[merge_experiments] : copying files from first') 
    for i = 1:length(cont1)
        copy_suffixed_non_log(cont1(i), merge_path, '');
    end
    
    vlog(0, '[merge_experiments] : copying files from second') 
    for i = 1:length(cont2)
        copy_suffixed_non_log(cont2(i), merge_path, '_adjoined');
    end
    
    vlog(0, '[merge_experiments] : copying files')

    % merge logs:
    vlog(0, '[merge_experiments] : merging log files')
    log_a_path = fullfile(exp1, 'Log.csv');
    log_b_path = fullfile(exp2, 'Log.csv');
    log_a = readtable(log_a_path);
    log_b = readtable(log_b_path);
    
    % merge logs, and remove first lines of second log:
    log_m = [log_a(:,:) ; log_b(4:end,:)];
    writetable(log_m, fullfile(merge_path, 'Log.csv'));
end


function copy_suffixed_non_log(src_info, merge_dir, suffix)
    if src_info.name == "." || src_info.name == ".." || src_info.name == "Log.csv"
        return;
    end
    src = fullfile(src_info.folder, src_info.name);
    trg =  fullfile(merge_dir, [src_info.name suffix]);
    copyfile(src, trg);
end