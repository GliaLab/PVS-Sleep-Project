function microarousal_transitions(tbl)

% this is the time vector used when extracting the traces. 
fs = 30;
t = -30*fs:30*fs;
t = t' / fs;
%%
[G,genotype,state] = findgroups(tbl.genotype, ...
    tbl.state);

roa_mu = splitapply(@(x)nanmean(x,1), ...
    tbl.roa,G);
roa_sigma = splitapply(@(x)begonia.util.nansem(x,1), ...
    tbl.roa,G);

eeg_mu = splitapply(@(x)nanmean(x,1), ...
    tbl.eeg,G);
eeg_sigma = splitapply(@(x)begonia.util.nansem(x,1), ...
    tbl.eeg,G);

emg_mu = splitapply(@(x)nanmean(x,1), ...
    tbl.emg,G);
emg_sigma = splitapply(@(x)begonia.util.nansem(x,1), ...
    tbl.emg,G);

whisker_mu = splitapply(@(x)nanmean(x,1), ...
    tbl.whisker,G);
whisker_sigma = splitapply(@(x)begonia.util.nansem(x,1), ...
    tbl.whisker,G);

neuron_mu = splitapply(@(x)nanmean(x,1), ...
    tbl.neuron,G);
neuron_sigma = splitapply(@(x)begonia.util.nansem(x,1), ...
    tbl.neuron,G);

roa_mu      = roa_mu * 60 * 100;
roa_sigma   = roa_sigma * 60 * 100;
%% Plot
output_folder = '~/Desktop/sleep_project/microarousal_transitions';
begonia.path.make_dirs(output_folder);

for i = 1:size(roa_mu,1)
    %% Save data
    tbl = table(t, ...
        roa_mu(i,:)',roa_sigma(i,:)', ...
        eeg_mu(i,:)',eeg_sigma(i,:)', ...
        emg_mu(i,:)',emg_sigma(i,:)', ...
        neuron_mu(i,:)',neuron_sigma(i,:)', ...
        whisker_mu(i,:)',whisker_sigma(i,:)');
    tbl.Properties.VariableNames = {'t', ...
        'roa_mu','roa_sigma', ...
        'eeg_mu','eeg_sigma', ...
        'emg_mu','emg_sigma', ...
        'neuron_mu','neuron_sigma', ...
        'whisker_mu','whisker_sigma'};
    file_name = sprintf('data_%s_%s.csv',genotype(i),state(i));
    file_name = fullfile(output_folder,file_name);
    if exist(file_name, 'file')==2
      delete(file_name);
    end
    writetable(tbl,file_name)
    %%
    f = figure;
    f.Position(3:4) = [2000,1200];
    
    ax(1) = subplot(5,1,1);
    p = plot(t,roa_mu(i,:));
    begonia.util.plot_continuous_sem(p,roa_sigma(i,:));
    title(sprintf('ROA frequency : %s : Start of %s',genotype(i),state(i)),'Interpreter','none');
    ylabel('ROA / min / 100um^2')
    
    ax(2) = subplot(5,1,2);
    p = plot(t,eeg_mu(i,:));
    begonia.util.plot_continuous_sem(p,eeg_sigma(i,:));
    ylabel('ECoG power (1-15 Hz)')
    
    ax(3) = subplot(5,1,3);
    p = plot(t,emg_mu(i,:));
    begonia.util.plot_continuous_sem(p,emg_sigma(i,:));
    ylabel('EMG absolute value')
    
    ax(4) = subplot(5,1,4);
    p = plot(t,whisker_mu(i,:));
    begonia.util.plot_continuous_sem(p,whisker_sigma(i,:));
    ylabel('Whisking trace')
    
    ax(5) = subplot(5,1,5);
    p = plot(t,neuron_mu(i,:));
    begonia.util.plot_continuous_sem(p,neuron_sigma(i,:));
    ylabel('Neuron soma Ca trace')


    set(ax,'FontSize',20);
    
    linkaxes(ax,'x');
    
    % Save
    file_name = sprintf('roa_freq_%s_%s.png',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('roa_freq_%s_%s.fig',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));

    close(f)
end

end
