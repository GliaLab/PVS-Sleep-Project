function eeg_emg_transitions_strict(tbl_eeg_emg_transitions_strict)

% this is the time vector used when extracting the traces. 
fs = 512;
t = -30*fs:30*fs;
t = t / fs;
t = t';
%%
% Only include some spesific transitions
states = {};
states(1,1:2) = {'quiet','locomotion'};
states(2,1:2) = {'quiet','whisking'};

I = false(height(tbl_eeg_emg_transitions_strict),1);
for i = 1:size(states,1)
    I_1 = tbl_eeg_emg_transitions_strict.state_previous == states{i,1};
    I_2 = tbl_eeg_emg_transitions_strict.state == states{i,2};
    
    I_include = I_1 & I_2;
    
    I = I | I_include;
end
tbl_eeg_emg_transitions_strict = tbl_eeg_emg_transitions_strict(I,:);

%%
[G,genotype,trial,state] = findgroups( ...
    tbl_eeg_emg_transitions_strict.genotype, ...
    tbl_eeg_emg_transitions_strict.trial, ...
    tbl_eeg_emg_transitions_strict.state);

eeg = splitapply(@(x)nanmean(x,1),tbl_eeg_emg_transitions_strict.eeg_transitions,G);
emg = splitapply(@(x)nanmean(x,1),tbl_eeg_emg_transitions_strict.emg_transitions,G);

%% Filter
tau = 0.25;
filter_t = (-tau*10:1/fs:tau*10);
filter = filter_t.*exp(-filter_t/tau);
filter(1:floor(length(filter)/2)) = 0;
filter = filter ./ sum(filter);

I = isnan(eeg);
eeg(I) = 0;
eeg = convn(eeg,filter,'same');
eeg(I) = nan;

I = isnan(emg);
emg(I) = 0;
emg = convn(emg,filter,'same');
emg(I) = nan;
%%
tbl = table(genotype,trial,state,eeg,emg);

[G,genotype,state] = findgroups(tbl.genotype,tbl.state);

eeg_mean = splitapply(@(x)nanmean(x,1),tbl.eeg,G);
eeg_sem = splitapply(@(x)nanstd(x,1)/sqrt(size(x,1)),tbl.eeg,G);

emg_mean = splitapply(@(x)nanmean(x,1),tbl.emg,G);
emg_sem = splitapply(@(x)nanstd(x,1)/sqrt(size(x,1)),tbl.emg,G);
%% Plot

output_folder = '~/Desktop/transitions/';
output_folder = fullfile(output_folder,'eeg_emg_transitions_strict');
begonia.path.make_dirs(output_folder);

for i = 1:length(genotype)
    %%
    tbl = table(t,eeg_mean(i,:)',eeg_sem(i,:)',emg_mean(i,:)',emg_sem(i,:)');
    tbl.Properties.VariableNames = {'t','eeg_mean','eeg_sem','emg_mean','emg_sem'};
    file_name = sprintf('data_%s_%s.csv',genotype(i),state(i));
    file_name = fullfile(output_folder,file_name);
    if exist(file_name, 'file')==2
      delete(file_name);
    end
    writetable(tbl,file_name)
    %%
    f = figure;
    f.Position(3:4) = [1000,600];
    
    p = plot(t,eeg_mean(i,:));
    begonia.util.plot_continuous_sem(p,eeg_sem(i,:));
    
    title(sprintf('eeg power (1-15 Hz) in %s %s',genotype(i),state(i)),'Interpreter','none');
    ylabel('A.U.')

    % Save
    file_name = sprintf('eeg_%s_%s.png',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('eeg_%s_%s.fig',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    
    set(gca,'FontSize',20);
    
    close(f)
    %%
    f = figure;
    f.Position(3:4) = [1000,600];
    
    p = plot(t,emg_mean(i,:));
    begonia.util.plot_continuous_sem(p,emg_sem(i,:));
    
    title(sprintf('emg absolute value in %s %s',genotype(i),state(i)),'Interpreter','none');
    ylabel('A.U.')

    % Save
    file_name = sprintf('emg_%s_%s.png',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('emg_%s_%s.fig',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    
    set(gca,'FontSize',20);
    
    close(f)
end

end

