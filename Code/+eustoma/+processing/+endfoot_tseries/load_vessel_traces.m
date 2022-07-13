
% Load vessel traces from the on path engine to the off path engine. 

begonia.logging.set_level(1);

ts_path = fullfile(eustoma.get_data_path(),'Endfeet TSeries');
ts = begonia.scantype.find_scans(ts_path);
ts = ts(ts.has_var('vestool2_results'));
%%
tseries_datastore_path = fullfile(eustoma.get_data_path(),'Endfeet TSeries Data');
engine = yucca.datanode.OffPathEngine(tseries_datastore_path);

%%

for ts_idx = 1:length(ts)
    begonia.logging.log(1,'%d/%d',ts_idx,length(ts));
    vessel_traces = ts(ts_idx).load_var('vestool2_results');

    vessel_center = cellfun(@(x)mean([x.start_point;x.end_point],1),vessel_traces.marker_obj,'UniformOutput',false);
    vessel_traces.vessel_center = cat(1,vessel_center{:});

    % Edit columns so we can add info about the perivascular space which is the
    % difference between endfoot and lumen diameter. 
    vessel_traces.ts_name = [];
    vessel_traces.distance_pix = [];
    vessel_traces.marker_obj = [];
    vessel_traces.vessel_structure = vessel_traces.channel;
    vessel_traces.channel = [];
    % Ch2 marks the endfeet and Ch3 marks the blood. 
    vessel_traces.vessel_structure = renamecats( ...
        vessel_traces.vessel_structure,{'Ch2','Ch3'},{'Endfoot','Lumen'});

    % Define if the vessel is artery or vein. 
    vessel_traces.vessel_type = cell(height(vessel_traces),1);
    for i = 1:height(vessel_traces)
        if contains(char(vessel_traces.marker_name(i)),'artery')
            vessel_traces.vessel_type{i} = 'Artery';
        elseif contains(char(vessel_traces.marker_name(i)),'vein')
            vessel_traces.vessel_type{i} = 'Vein';
        else
            error();
        end 
    end
    vessel_traces.vessel_type = categorical(vessel_traces.vessel_type);

    % Separate endfoot and lumen into separate tables. 
    tmp_end = vessel_traces(vessel_traces.vessel_structure == 'Endfoot',:);
    tmp_lum = vessel_traces(vessel_traces.vessel_structure == 'Lumen',:);

    % Safety check to see that there is one trace from each endfoot/lumen. 
    assert(isequal(tmp_end.marker_name,tmp_lum.marker_name));
    
    % Change format of table.
    tbl = table;
    tbl.vessel_type = tmp_end.vessel_type;
    
    for i = 1:height(tmp_end)
        tbl.vessel_center(i,:) = tmp_end.vessel_center(i,:);
        
        tbl.distance_endfoot{i} = tmp_end.distance_um(i,:);
        tbl.distance_lumen{i} = tmp_lum.distance_um(i,:);
        tbl.distance_peri{i} = tmp_end.distance_um(i,:) - tmp_lum.distance_um(i,:);
        
        tbl.t{i} = tmp_end.time_s(i,:);
    end
    
    vessel_traces = tbl;

    engine.save_var(ts(ts_idx),'vessel_traces',vessel_traces);
end