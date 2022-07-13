function results = export_as_table(tss)
    
    results = table;
    for ts = tss
        result_ts = ts.load_var('vestool2_results');
        results = vertcat(results, result_ts);
    end
    
end

