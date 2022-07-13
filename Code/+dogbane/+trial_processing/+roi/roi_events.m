function roi_events(ts)

dt = ts.dt;
fs = 1/dt;

target_fs = 30;

roi_events_param = dogbane.roi_events.default_parameters();

roi_array = ts.load_var('roi_array');
%% Astrocytes
idx_ast = [roi_array.channel] == 1;
if ~any(idx_ast)
    roi_events_ast = [];
else
    ast = roi_array(idx_ast);
    ast_ids = categorical({ast.id})';
    ast_groups = categorical({ast.group})';

    ast_traces = ts.load_var('ca_signal_df_f0');
    ast_traces = ast_traces.Data(:,idx_ast);

    t = (0:size(ast_traces,1)-1) * dt;
    % Remove NaNs during resampling.
    I = any(isnan(ast_traces),1);
    ast_traces(:,I) = 0;
    ast_traces = resample(ast_traces,t,target_fs);
    ast_traces(:,I) = NaN;

    roi_events_ast = dogbane.roi_events.find_events_ast(ast_traces,target_fs,roi_events_param);
    if ~isempty(roi_events_ast)
        roi_events_ast = struct2table(roi_events_ast);

        roi_events_ast.roi_id = ast_ids(roi_events_ast.trace_idx);
        roi_events_ast.roi_group = ast_groups(roi_events_ast.trace_idx);
        roi_events_ast = roi_events_ast(:,{'roi_id','roi_group','x_start','x_end','x','y','width','auc','n_peaks'});
    end
end
%% Neurons
idx_neu = [roi_array.channel] == 2;

if ~any(idx_neu)
    roi_events_neu = [];
else
    neu = roi_array(idx_neu);
    neu_ids = categorical({neu.id})';
    neu_groups = categorical({neu.group})';

    neu_traces = ts.load_var('ca_signal_neurons_subtracted',timeseries);
    neu_traces = neu_traces.Data;

    t = (0:size(neu_traces,1)-1) * dt;
    neu_traces = resample(neu_traces,t,target_fs);

    roi_events_neu = dogbane.roi_events.find_events_neu(neu_traces,target_fs,roi_events_param);
    if ~isempty(roi_events_neu)
        roi_events_neu = struct2table(roi_events_neu);

        roi_events_neu.roi_id = neu_ids(roi_events_neu.trace_idx);
        roi_events_neu.roi_group = neu_groups(roi_events_neu.trace_idx);
        roi_events_neu = roi_events_neu(:,{'roi_id','roi_group','x_start','x_end','x','y','width','auc','n_peaks'});
    end
end
%%
if isempty(roi_events_ast) && isempty(roi_events_neu)
    roi_events = [];
elseif isempty(roi_events_ast)
    roi_events = roi_events_neu;
elseif isempty(roi_events_neu)
    roi_events = roi_events_ast;
else
    roi_events = cat(1,roi_events_ast,roi_events_neu);
end
%%
ts.save_var(roi_events_param);
ts.save_var(roi_events);

end

