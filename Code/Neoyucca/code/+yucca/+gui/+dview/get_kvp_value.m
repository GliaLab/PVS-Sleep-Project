function value = get_kvp_value( txt, key, kvp_sep, kv_sep )
%get_kvp_value Decomposes a key-vale-pair string and returns the value of
%the provided key.
    
    kvps = strsplit(txt, kvp_sep);
    value = [];
    
    for i = 1:length(kvps)
        kvp = strtrim(kvps{i});
        kv = strsplit(kvp, kv_sep);
        
        if strcmp(kv{1}, key)
            value = kv{2}
        end
    end
    
end

