function highpass_roa_stats(ts)

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

% ROA ignore mask.
if ts.has_var('roa_ignore_mask')
    roa_ignore_mask = ts.load_var('roa_ignore_mask');
else
    mat = ts.get_mat(1,1);
    dim = size(mat);
    roa_ignore_mask = false(dim(1:2));
end
edge_ignore_width = 15;
roa_ignore_mask(1:edge_ignore_width,:) = true;
roa_ignore_mask(end-edge_ignore_width:end,:) = true;
roa_ignore_mask(:,1:edge_ignore_width) = true;
roa_ignore_mask(:,end-edge_ignore_width:end) = true;
% Flips it. Result is true where ROAs are allowed.
roa_ignore_mask = ~roa_ignore_mask;

highpass_roa_mask = ts.load_var('highpass_roa_mask');
highpass_roa_mask = highpass_roa_mask & roa_ignore_mask;

highpass_roa_density_trace = sum(sum(highpass_roa_mask,1),2)/sum(roa_ignore_mask(:));
highpass_roa_density_trace = squeeze(highpass_roa_density_trace);

highpass_roa_table = begonia.processing.extract_roa_events(highpass_roa_mask,dx,dt);

fov = sum(roa_ignore_mask(:)) * dx * dx;

dur = seconds(ts.duration);

t = 0:dur*fs;
highpass_roa_frequency_trace = histcounts(highpass_roa_table.roa_t_start_idx,t) / dt / fov;

ts.save_var(highpass_roa_table);
ts.save_var(highpass_roa_density_trace);
ts.save_var(highpass_roa_frequency_trace);

end

