function neuron_doughnuts_merged(ts)

ts.clear_var('neuron_doughnuts_merged');

ca_signal_doughnuts = ts.load_var('ca_signal_doughnuts');
ca_signal_doughnuts = ca_signal_doughnuts.Data';

% assert(~isempty(ca_signal_doughnuts),'No doughnut traces.');
if isempty(ca_signal_doughnuts)
    return;
end

neuron_doughnuts_merged = nanmean(ca_signal_doughnuts,1);

ts.save_var(neuron_doughnuts_merged)

end

