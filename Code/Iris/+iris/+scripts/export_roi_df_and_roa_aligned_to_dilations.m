clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("roi_df_aligned_to_dilations"));
ts = ts(ts.has_var("roi_roa_aligned_to_dilations"));
ts = ts(ts.has_var("diameter_aligned_to_dilations"));
ts = ts(ts.has_var("trial_group"));

%%
trial_group = ts.load_var("trial_group");
trial_group = cat(1, trial_group{:});

roi_df_tbl = ts.load_var("roi_df_aligned_to_dilations");
roi_df_tbl = cat(1, roi_df_tbl{:});
roi_df_tbl = roi_df_tbl(:,["trial_id","linescan_id","t0_id","roi_id","fs","x","y"]);
roi_df_tbl.roi_filename = string(1:height(roi_df_tbl))';

roi_roa_tbl = ts.load_var("roi_roa_aligned_to_dilations");
roi_roa_tbl = cat(1, roi_roa_tbl{:});
roi_roa_tbl = roi_roa_tbl(:,["trial_id","linescan_id","t0_id","roi_id","fs","x","y"]);
roi_roa_tbl.roi_filename = string(1:height(roi_df_tbl))';

assert(height(roi_df_tbl) == height(roi_roa_tbl))

diam_tbl = ts.load_var("diameter_aligned_to_dilations");
diam_tbl = cat(1, diam_tbl{:});
diam_tbl = diam_tbl(:,["trial_id","linescan_id","t0_id","fs","x","y"]);
diam_tbl.diam_filename = string(1:height(diam_tbl))';

for i = 1:height(roi_df_tbl)
    tbl = table;
    tbl.time = roi_df_tbl.x{i}';
    tbl.roi_df = roi_df_tbl.y{i}';
    
    filename = fullfile(get_project_path, "Plot", "ROI df and roa aligned to dilations csv", ...
        "roi_df", roi_df_tbl.roi_filename(i) + ".csv");
    begonia.path.make_dirs(filename);
    writetable(tbl, filename);
end

for i = 1:height(roi_roa_tbl)
    tbl = table;
    tbl.time = roi_roa_tbl.x{i}';
    tbl.roi_roa = roi_roa_tbl.y{i}';
    
    filename = fullfile(get_project_path, "Plot", "ROI df and roa aligned to dilations csv", ...
        "roi_roa", roi_roa_tbl.roi_filename(i) + ".csv");
    begonia.path.make_dirs(filename);
    writetable(tbl, filename);
end

for i = 1:height(diam_tbl)
    tbl = table;
    tbl.time = diam_tbl.x{i}';
    tbl.diameter = diam_tbl.y{i}';
    
    filename = fullfile(get_project_path, "Plot", "ROI df and roa aligned to dilations csv", ...
        "diameter", diam_tbl.diam_filename(i) + ".csv");
    begonia.path.make_dirs(filename);
    writetable(tbl, filename);
end

diam_tbl.diameter_fs = diam_tbl.fs;
diam_tbl.fs = [];
diam_tbl.x = [];
diam_tbl.y = [];

roi_df_tbl.roi_fs = roi_df_tbl.fs;
roi_df_tbl.fs = [];
roi_df_tbl.x = [];
roi_df_tbl.y = [];

roi_roa_tbl.roi_fs = roi_roa_tbl.fs;
roi_roa_tbl.fs = [];
roi_roa_tbl.x = [];
roi_roa_tbl.y = [];

group_tbl = innerjoin(trial_group,diam_tbl);
group_tbl = innerjoin(group_tbl,roi_df_tbl);
group_tbl = innerjoin(group_tbl,roi_roa_tbl);

filename = fullfile(get_project_path, "Plot", "ROI df and roa aligned to dilations csv", "groups_and_filenames.csv");
begonia.path.make_dirs(filename);
writetable(group_tbl, filename);


