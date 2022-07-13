function plot_roi_traces(trial)
%%
ts = trial.tseries;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;
%%

roi_traces = ts.load_var('roi_traces');

mat = roi_traces.df_f0;

window_dt = 0.25; %seconds
sigma = ceil(window_dt/dt);
filter_vec = begonia.util.gausswin(sigma)';

mat = convn(mat,filter_vec,'same');

figure;
hold on
for i = 1:size(mat,1)
    y = mat(i,:);
    y = y + i;
    plot(y);
end


end

