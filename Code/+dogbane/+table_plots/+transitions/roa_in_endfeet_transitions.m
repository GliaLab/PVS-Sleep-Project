function roa_in_endfeet_transitions(tbl_roa_in_endfeet_transitions)

% this is the time vector used when extracting the traces. 
assumed_fs = 30;
t = -30*assumed_fs:30*assumed_fs;
t = t / assumed_fs;
t = t';
%%
I = tbl_roa_in_endfeet_transitions.state == 'locomotion' & tbl_roa_in_endfeet_transitions.state_previous == 'undefined';
tbl_roa_in_endfeet_transitions(I,:) = [];
I = tbl_roa_in_endfeet_transitions.state == 'whisking' & tbl_roa_in_endfeet_transitions.state_previous == 'undefined';
tbl_roa_in_endfeet_transitions(I,:) = [];

%%
[G,genotype,trial,roi_group,state] = findgroups( ...
    tbl_roa_in_endfeet_transitions.genotype, ...
    tbl_roa_in_endfeet_transitions.trial, ...
    tbl_roa_in_endfeet_transitions.roi_group, ...
    tbl_roa_in_endfeet_transitions.state);

roa_freq = splitapply(@(x)nanmean(x,1),tbl_roa_in_endfeet_transitions.roa_frequency_transitions,G) * 60 * 100;
roa_dens = splitapply(@(x)nanmean(x,1),tbl_roa_in_endfeet_transitions.roa_density_transitions,G);

%% Filter
% filter = begonia.util.gausswin(round(0.25*assumed_fs))';
tau = 0.25;
filter_t = (-tau*10:1/assumed_fs:tau*10);
filter = filter_t.*exp(-filter_t/tau);
filter(1:floor(length(filter)/2)) = 0;
filter = filter ./ sum(filter);

I = isnan(roa_freq);
roa_freq(I) = 0;
roa_freq = convn(roa_freq,filter,'same');
roa_freq(I) = nan;

I = isnan(roa_dens);
roa_dens(I) = 0;
roa_dens = convn(roa_dens,filter,'same');
roa_dens(I) = nan;
%%
tbl = table(genotype,trial,roi_group,state,roa_freq,roa_dens);

[G,genotype,roi_group,state] = findgroups(tbl.genotype,tbl.roi_group,tbl.state);

freq_mean = splitapply(@(x)nanmean(x,1),tbl.roa_freq,G);
freq_sem = splitapply(@(x)nanstd(x,1)/sqrt(size(x,1)),tbl.roa_freq,G);

density_mean = splitapply(@(x)nanmean(x,1),tbl.roa_dens,G);
density_sem = splitapply(@(x)nanstd(x,1)/sqrt(size(x,1)),tbl.roa_dens,G);
%% Plot

output_folder = '~/Desktop/transitions/';
output_folder = fullfile(output_folder,'roa_in_endfeet_transitions');
begonia.path.make_dirs(output_folder);

for i = 1:length(genotype)
    %%
    tbl = table(t,freq_mean(i,:)',freq_sem(i,:)',density_mean(i,:)',density_sem(i,:)');
    tbl.Properties.VariableNames = {'t','freq_mean','freq_sem','density_mean','density_sem'};
    file_name = sprintf('data_%s_%s_%s.csv',genotype(i),roi_group(i),state(i));
    file_name = fullfile(output_folder,file_name);
    if exist(file_name, 'file')==2
      delete(file_name);
    end
    writetable(tbl,file_name)
    %%
    f = figure;
    f.Position(3:4) = [1000,600];
    
    p = plot(t,freq_mean(i,:));
    begonia.util.plot_continuous_sem(p,freq_sem(i,:));
    
    title(sprintf('ROA Frequency in %s %s %s',genotype(i),roi_group(i),state(i)),'Interpreter','none');
    ylabel('ROA events / min / 100um2')

    % Save
    file_name = sprintf('roa_frequency_%s_%s_%s.png',genotype(i),roi_group(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('roa_frequency_%s_%s_%s.fig',genotype(i),roi_group(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    
    set(gca,'FontSize',20);
    
    close(f)
    %%
    f = figure;
    f.Position(3:4) = [1000,600];
    
    p = plot(t,density_mean(i,:));
    begonia.util.plot_continuous_sem(p,density_sem(i,:));
    
    title(sprintf('ROA Density in %s %s %s',genotype(i),roi_group(i),state(i)),'Interpreter','none');
    ylabel('ROA density')

    % Save
    file_name = sprintf('roa_density_%s_%s_%s.png',genotype(i),roi_group(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('roa_density_%s_%s_%s.fig',genotype(i),roi_group(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    
    set(gca,'FontSize',20);
    
    close(f)
end

end

