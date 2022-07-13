
output_dir = '~/Desktop/sleep_project/tiff_movies';
cycle = 1;
channel = 1;
window = 10;

trials = tm.get_trials();
% Select the trials
trials = trials([22,33,44]);
tseries = [trials.tseries];
for i = 1:length(tseries)
    begonia.tseries_operations.create_movie_tiff(tseries(i),cycle,channel,window,output_dir);
end