classdef EntryCollection < handle
    %ENTRYCOLLECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties(Constant)
        API_VERSION = 2;
    end
    
    properties(Transient)
        data_types
        duplicate_names
        duplicate_uuids
    end
    
    properties(Abstract)
        data
    end
    
    methods
        
         % list of the types of data that exists in the system
        function types = get.data_types(obj)
            types = containers.Map;
            typenames = unique({obj.data.type});
            for type = typenames
                type_str = string(type);
                entries = obj.data({obj.data.type} == type_str);
                types(char(type_str)) = entries;
                
            end
        end
        
        % table of duplicate names objects, and their paths:
        function tab = get.duplicate_names(obj)
            warning('off','MATLAB:table:RowsAddedExistingVars')
            cat_e = obj.data;
            names = {obj.data.name};
            unique_names = unique(names);

            tab = table();

            for i = 1:length(unique_names)
                uname = unique_names(i);
                tab.name(i) = uname;
                dup_entries = cat_e({cat_e.name} == string(uname));

                tab.repetitions(i) = length(dup_entries);
                paths = {dup_entries.path};
                tab.paths(i) = join(paths, ' ; ');
            end
            
            tab = tab(tab.repetitions > 1,:);
        end
        
        % table of duplicate uuids, and their paths
        function tab = get.duplicate_uuids(obj)
            warning('off','MATLAB:table:RowsAddedExistingVars')
            cat_e = obj.data;
            uuids = {obj.data.name};
            unique_uuids = unique(uuids);

            tab = table();

            for i = 1:length(unique_uuids)
                uuid = unique_uuids(i);
                tab.uuid(i) = uuid;
                dup_entries = cat_e({cat_e.uuid} == string(uuid));

                tab.repetitions(i) = length(dup_entries);
                paths = {dup_entries.path};
                tab.paths(i) = join(paths, ' ; ');
            end
            
            tab = tab(tab.repetitions > 1,:);
        end
        
        % exports a set of variables to structs from all entries, or a
        % selection
        function [metadata, exported, errors] = export_vars(obj, vars, entries)
            import begonia.logging.log;
            log(1, '[DataCat] : exporting variables. This can take a long time');
            
            exported_all = false;
            if nargin < 3
                entries = obj.data;
                exported_all = true;
            end
            
            if ~isa(vars, "string")
                error('vars list must be an array of strings');
            end
            
            % collect errors:
            errors = string.empty;
            
            % root variable with some basic info that might be useful
            metadata = struct();
            metadata.what_is_this = 'DataCat exported vars using DataCat.export_vars(varlist)';
            metadata.api_version = yucca.datacat.EntryCollection.API_VERSION;
            metadata.vars = vars;
            metadata.exported = datetime();
            metadata.arch = computer();
            metadata.exported_all = exported_all;
%             root.entries = struct('name',{},'uuid',{},'type',{}, ...
%                 'recreation_class',{}, 'missing_vars', {},'vars_changed', {} , ...
%                 'vars',{});
            
            % loop through entries, exporting the variables:
            i = 1;
            for entry = entries
                disp(entry.name);
                vlog(1, ['[DataCat] : exporting ' entry.name]);
                
%                 try
                    %entry_exp = struct();
                    name(i) = string(entry.name); %#ok<*AGROW>
                    uuid(i) = string(entry.uuid);
                    type(i) = string(entry.type);
                    recreation_class(i) = string(entry.recreation_class);
                    %missing_vars(i) = string.empty;
                    
%                     value_change_map = containers.Map;
%                     value_map = containers.Map;
%                     missing_list = string.empty;

                    % export vars from original data:
                    original_data = entry.get_data();

                    for var = vars
                        cvar = char(var);
                        if original_data.has_var(cvar)
%                             value_map(cvar) = original_data.load_var(cvar);
%                             value_change_map(cvar) = original_data.dl_changelog(cvar);
                            entry_name(i) = string(entry.name); %#ok<*AGROW>
                            entry_uuid(i) = string(entry.uuid);
                            entry_type(i) = string(entry.type);
                            entry_recreation_class(i) = string(entry.recreation_class);
                            varname(i) = var;
                            vardata(i) = {original_data.load_var(cvar)};
                            i = i + 1;
                        end
                    end
                    
%                     values(i) = {value_map};
%                     vars_changed(i) = {value_change_map};
%                     missing(i) = {missing_list};
                    
                    
%                 catch err
%                     errors(end + 1) = "UUDI" + string(entry.uuid) + "; Err " + string(err.message);
%                 end
            end
            
            % create table:
            exported = table(...
                entry_name'...
                , entry_uuid'...
                , entry_type'...
                , entry_recreation_class'...
                , varname'...
                , vardata');
            
            exported.Properties.VariableNames = {'entry_name', 'entry_uuid', 'entry_type', 'entry_recreation_class', 'varname', 'vardata'}
        end
        
    end
end






