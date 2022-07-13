function trial = fix_comma_corrupted_trial(path)
    % file file path part that contains the comma:
    [~, comma_part] = fileparts(path);
    if ~contains(comma_part, ',')
       error("path must be the directory containing the comma"); 
    end
    
    correction = replace(comma_part, ',', '.');
    
    % fing all log CVS files:
    filelist = dir(fullfile(path, "**" + filesep + "*.*")); 
    
    log_idxs = startsWith(string({filelist.name}), "Log");
    csv_idxs = endsWith(string({filelist.name}), ".csv");
    
    loglist = filelist(log_idxs & csv_idxs);
    paths = arrayfun(@(f) fullfile(f.folder, f.name), loglist, 'UniformOutput', false);
    paths = string(paths);
    
    % replace in all log files:
    for p = begonia.util.to_loopable(paths)
        faulty_csv = fileread(p);
        corrected_csv = replace(faulty_csv, comma_part, correction);
        
        F = fopen(p,'w');
        fwrite(F, corrected_csv);
        fclose(F);
    end
    
    % finally, rename the directory itself:
    corrected_path = replace(path, ',', '.');
    movefile(path, corrected_path);
    
    disp(path + " -> " + corrected_path);
end

