function save_as_csv(ts,output_dir)


group_tbl = ts;
group_tbl.time_series_file(:) = "";
% Create a new csv file for each row.
for i = 1:height(group_tbl)
    % Create the filename.
    filename = sprintf("%.3d.csv",i);

    % Save the filename in the main table.
    group_tbl.time_series_file(i) = filename;
    
    % Save the time series as a csv file.
    x = group_tbl.x{i};
    y = group_tbl.y{i};
    tbl = table(x,y);
    path = fullfile(output_dir,filename);
    begonia.path.make_dirs(path);
    writetable(tbl,path);
end

% Remove the time series data from the main table.
group_tbl.x = [];
group_tbl.y = [];

% Save the main table.
filename = fullfile(output_dir,"main.csv");
writetable(group_tbl,filename);

end

