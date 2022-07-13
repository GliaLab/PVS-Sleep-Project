begonia.logging.set_level(1)
path = fullfile(eustoma.get_data_path,'Sleep Project TSeries','WT');
ts = begonia.scantype.find_scans(path);

%%
vars = cell(1, length(ts));
for i = 1:length(ts)
    vars{i} = ts(i).saved_vars;
end

vars = string([vars{:}]);

unique(vars)'

%%
ts_roa = ts(ts.has_var("roa_in_moving_endfeet"));

%%
datastore = fullfile(eustoma.get_data_path,'Sleep Project TSeries Data');
engine = yucca.datanode.OffPathEngine(datastore);

for i = 1:length(ts)
    begonia.logging.log(1,"%d/%d",i,length(ts))
%     roi_array = ts(i).load_var('roi_array',[]);
%     if ~isempty(roi_array)
%         engine.save_var(ts(i),'roi_array',roi_array);
%     end
%     roa_in_endfeet = ts(i).load_var('roa_in_endfeet',[]);
%     if ~isempty(roa_in_endfeet)
%         engine.save_var(ts(i),'roa_in_endfeet',roa_in_endfeet);
%     end
%     roi_traces = ts(i).load_var('roi_traces',[]);
%     if ~isempty(roi_traces)
%         engine.save_var(ts(i),'roi_traces',roi_traces);
%     end
end

