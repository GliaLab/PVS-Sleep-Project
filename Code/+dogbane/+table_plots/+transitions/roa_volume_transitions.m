function roa_volume_transitions(tbl_roa_transitions)

% this is the time vector used when extracting the traces. 
fs = 30;
t = -30*fs:30*fs;
t = t / fs;
t = t';
%%
[G,genotype,state] = findgroups(tbl_roa_transitions.genotype, ...
    tbl_roa_transitions.state);

mu = splitapply(@(x)nanmean(x,1), ...
    tbl_roa_transitions.roa_volume_transition,G);
sigma = splitapply(@(x)nanstd(x,1)/sqrt(size(x,1)), ...
    tbl_roa_transitions.roa_volume_transition,G);

mu_strict = splitapply(@(x)nanmean(x,1), ...
    tbl_roa_transitions.roa_volume_transition_strict,G);
sigma_strict = splitapply(@(x)nanstd(x,1)/sqrt(size(x,1)), ...
    tbl_roa_transitions.roa_volume_transition_strict,G);
%% Plot
output_folder = '~/Desktop/sleep_project/transitions/roa_volume_transitions';
begonia.path.make_dirs(output_folder);

for i = 1:size(mu,1)
    %% Save data
    tbl = table(t,mu(i,:)',sigma(i,:)',mu_strict(i,:)',sigma_strict(i,:)');
    tbl.Properties.VariableNames = {'t','mu','sigma','mu_strict','sigma_strict'};
    file_name = sprintf('data_%s_%s.csv',genotype(i),state(i));
    file_name = fullfile(output_folder,file_name);
    if exist(file_name, 'file')==2
      delete(file_name);
    end
    writetable(tbl,file_name)
    %%
    f = figure;
    f.Position(3:4) = [1000,600];

    p = plot(t,mu(i,:));
    begonia.util.plot_continuous_sem(p,sigma(i,:));

    title(sprintf('ROA volume : %s : Start of %s',genotype(i),state(i)),'Interpreter','none');
    ylabel('Mean ROA volume (um^2*s)')

    % Save
    file_name = sprintf('roa_volume_%s_%s.png',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('roa_volume_%s_%s.fig',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));

    set(gca,'FontSize',20);

    close(f)
    %%
    f = figure;
    f.Position(3:4) = [1000,600];

    p = plot(t,mu_strict(i,:));
    begonia.util.plot_continuous_sem(p,sigma_strict(i,:));

    title(sprintf('ROA volume : %s : Start of %s',genotype(i),state(i)),'Interpreter','none');
    ylabel('Mean ROA volume (um^2*s)')

    % Save
    file_name = sprintf('roa_volume_%s_%s_strict.png',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));
    file_name = sprintf('roa_volume_%s_%s_strict.fig',genotype(i),state(i));
    export_fig(f,fullfile(output_folder,file_name));

    set(gca,'FontSize',20);

    close(f)
end

end

