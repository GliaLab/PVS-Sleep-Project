function highpass_thresh_roa_mask(ts)
dx = ts.dx;

highpass_thresh_roa_mask = ts.load_var('highpass_roa_mask');
threshold = 0.85; % um^2
highpass_thresh_roa_mask = begonia.processing.remove_roa_events(highpass_thresh_roa_mask,dx,threshold);

ts.save_var(highpass_thresh_roa_mask)
end

