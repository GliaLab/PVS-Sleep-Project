function whisker_wheel_transitions_strict(tbl_whisker_wheel_transitions_strict)

% this is the time vector used when extracting the traces. 
assumed_fs = 30;
t = -30*assumed_fs:30*assumed_fs;
t = t / assumed_fs;
t = t';
%%
% Only include some spesific transitions
states = {};
states(1,1:2) = {'quiet','locomotion'};
states(2,1:2) = {'quiet','whisking'};

I = false(height(tbl_whisker_wheel_transitions_strict),1);
for i = 1:size(states,1)
    I_1 = tbl_whisker_wheel_transitions_strict.state_previous == states{i,1};
    I_2 = tbl_whisker_wheel_transitions_strict.state == states{i,2};
    
    I_include = I_1 & I_2;
    
    I = I | I_include;
end
tbl_whisker_wheel_transitions_strict = tbl_whisker_wheel_transitions_strict(I,:);

%%
[G,genotype,trial,state] = findgroups( ...
    tbl_whisker_wheel_transitions_strict.genotype, ...
    tbl_whisker_wheel_transitions_strict.trial, ...
    tbl_whisker_wheel_transitions_strict.state);

whisker = splitapply(@(x)nanmean(x,1),tbl_whisker_wheel_transitions_strict.whisker_transitions,G);
wheel = splitapply(@(x)nanmean(x,1),tbl_whisker_wheel_transitions_strict.wheel_transitions,G);

%% Filter
tau = 0.25;
filter_t = (-tau*10:1/assumed_fs:tau*10);
filter = filter_t.*exp(-filter_t/tau);
filter(1:floor(length(filter)/2)) = 0;
filter = filter ./ sum(filter);

I = isnan(whisker);
whisker(I) = 0;
whisker = convn(whisker,filter,'same');
whisker(I) = nan;

I = isnan(wheel);
wheel(I) = 0;
wheel = convn(wheel,filter,'same');
wheel(I) = nan;
%%
tbl = table(genotype,trial,state,whisker,wheel);

[G,genotype,state] = findgroups(tbl.genotype,tbl.state);

whisker_mean = splitapply(@(x)nanmean(x,1),tbl.whisker,G);
whisker_sem = splitapply(@(x)nanstd(x,1)/sqrt(size(x,1)),tbl.whisker,G);

wheel_mean = splitapply(@(x)nanmean(x,1),tbl.wheel,G);
wheel_sem = splitapply(@(x)nanstd(x,1)/sqrt(size(x,1)),tbl.wheel,G);
%% Plot

output_folder = '~/Desktop/transitions/';
output_folder = fullfile(output_folder,'whisker_wheel_transitions_strict');
begonia.path.make_dirs(output_folder);

for i = 1:length(genotype)
    %%
    tbl = table(t,whisker_mean(i,:)',whisker_sem(i,:)',wheel_mean(i,:)',wheel_sem(i,:)');
    tbl.Properties.VariableNames = {'t','whisker_mean','whisker_sem','wheel_mean','wheel_sem'};
    file_name = sprintf('data_%s_%s.csv',genotype(i),state(i));
    file_name = fullfile(output_folder,file_name);
    if exist(file_name, 'file')==2
      delete(file_name);
    end
    writetable(tbl,file_name)
    %%
    f = figure;
    f.Position(3:4) = [1000,600];
    
    p = plot(t,whisker_mean(i,:));
    begonia.util.plot_continuous_sem(p,whisker_sem(i,:));
    
    title(sprintf('Whisking trace in %s %s',genotype(i),state(i)),'Interpreter','none');
    ylabel('A.U.')

    % Save
    file_name = sprintf('whisking_%s_%s.png',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('whisking_%s_%s.fig',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    
    set(gca,'FontSize',20);
    
    close(f)
    %%
    f = figure;
    f.Position(3:4) = [1000,600];
    
    p = plot(t,wheel_mean(i,:));
    begonia.util.plot_continuous_sem(p,wheel_sem(i,:));
    
    title(sprintf('Wheel trace in %s %s',genotype(i),state(i)),'Interpreter','none');
    ylabel('A.U.')

    % Save
    file_name = sprintf('wheel_%s_%s.png',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('wheel_%s_%s.fig',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    
    set(gca,'FontSize',20);
    
    close(f)
end

end

