function vessel(tm)

trials = tm.get_trials();

dir_out = '~/Desktop/vesseltool';
begonia.path.make_dirs(dir_out);

xylobium.vesseltool2.VesselTool([trials.tseries],dir_out)

end

