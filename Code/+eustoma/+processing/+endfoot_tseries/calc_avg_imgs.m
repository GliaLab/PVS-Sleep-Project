fprintf("[%s] : Finding tseries\n", datestr(now));
ts = eustoma.get_endfoot_tseries(true);
ts = ts(ts.has_var("nrem"));

%%
tic
for i = 1:length(ts)
    if toc > 30 || i == 1 || i == length(ts)
        fprintf("[%s] : Trial %d/%d\n", datestr(now), i, length(ts));
        tic
    end
    avg_glt_img = ts(i).get_avg_img(1,1,false);
    ts(i).save_var(avg_glt_img);
    
    avg_texas_red_img = ts(i).get_avg_img(2,1,false);
    ts(i).save_var(avg_texas_red_img)
end