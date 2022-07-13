begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_table'));

for i = 1:length(ts)
    roi_table = ts(i).load_var('roi_table');
    if isempty(roi_table)
        ts(i).clear_var('roi_table');
    end
end
