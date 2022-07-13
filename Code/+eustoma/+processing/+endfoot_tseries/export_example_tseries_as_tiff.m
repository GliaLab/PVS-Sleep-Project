clear all 
begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries(true);
ts = ts(ts.has_var("rem"));
ts = ts(ts.has_var("vessel_position"));
%%
example_ts = ["TSeries-01302019-0918-021", ...
    "TSeries-01302019-0918-028", ...
    "TSeries-04302019-1000-022", ...
    "TSeries-05062019-1018-016", ...
    "TSeries-06242019-1050-008"];

for i = 1:length(ts)
    if any(string(ts(i).name) == example_ts)
        
        filename = fullfile(eustoma.get_plot_path,"Endfeet TSeries examples tiff", ...
            ts(i).name + ".tiff");
        begonia.scantype.tiff.tseries_to_tiff(ts(i),filename,10);
    end
end