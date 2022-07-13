classdef Entry < handle & begonia.data_management.DataInfo
    %ENTRY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        uuid
        source_uuid
        name
        path
        path_relative
        type
        source
        recreation_class
        overlaping_in_time = [];
        
        % DataInfo props:
        start_time_abs
        duration
        time_correction
    end
    
    properties (Transient)
        cat_source 
        catalog
        search_conglomerate
    end
    
    methods
        
        function obj = Entry(datainfo, cat_source)
            if ~isa(datainfo, 'begonia.data_management.DataInfo')
                error('Catalog entries must implement begonia.data_management.DataInfo')
            end
            
            % clone source object:
            obj.uuid = datainfo.uuid;
            obj.name = datainfo.name;
            obj.path = datainfo.path;
            obj.type = datainfo.type;
            obj.source = datainfo.source;
            obj.load_timeinfo(datainfo);
            
            obj.cat_source = cat_source;
            obj.source_uuid = cat_source.uuid;
            obj.catalog = cat_source.catalog;
            
            obj.recreation_class = class(datainfo);
            
            obj.path_relative = replace(obj.path, cat_source.path, '');
        end

        
        % concat a string used in fuzzy searches:
        function congl = get.search_conglomerate(obj)
            congl = [obj.name ' ' obj.path ' ' obj.uuid ' ' obj.type ' ' obj.source];
        end
        
        
        % function to load and support the DataInfo superclass:
        function load_timeinfo(obj, source)
            obj.start_time_abs = source.start_time_abs;
            obj.duration = source.duration;
            obj.time_correction = source.time_correction;
        end
        
        
        % gets other datacat entries associated with this one in time:
        function assoc = get_associated_by_time(obj, leeway_before, leeway_after)
            if nargin < 2
                leeway_before = seconds(60);
                leeway_after = seconds(60);
            end
            
            start_ = obj.start_time - leeway_before;
            end_ = obj.end_time + leeway_after;
            
            assoc = obj.catalog.between_dates(start_, end_);
            assoc = assoc({assoc.uuid} ~= string(obj.uuid));
        end
        
        
        % get related sets this entry is part of:
        function sets = get_related_sets(obj)
            sets = yucca.datacat.RelatedSet.empty;
            for set_ = obj.catalog.related_sets
            	if set_.has_participant(obj.uuid)
                    sets(end+1) = set_;
                end
            end
        end
        
        
        % convenience function to get data:
        function data = get_data(obj)
            data = obj.catalog.get_data(obj);
        end

        % copies five entries to a destination
        function copy_to(objs, dest_path)
            import begonia.logging.log;
            log(1, ['Copying ' num2str(length(objs))]);
            
            for obj = objs
                [~,fname, ext] = fileparts(obj.path);
                log(2, ['Copying ' fname ' -> ' dest_path]);
                
                from = obj.path;
                to = fullfile(dest_path, [fname ext]);
%                 if ispc
%                     cmd = ['copy "' from '" "' to '"'];
%                     system(cmd);
%                 else
%                     % terribly slow:
                    copyfile(obj.path, fullfile(dest_path, [fname ext]));
%                 end
            end
        end
        
        % opens the path in an external program:
        function open(obj)
            begonia.util.open_path_externally(obj.path)
        end
    end
end
















