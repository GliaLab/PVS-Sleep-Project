classdef DataCat < handle & yucca.datacat.EntryCollection & begonia.data_management.UUIDResolver
    %DATACAT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % the data sources that .data derives from:
        sources = yucca.datacat.Source.empty;
        
        % collections of related data, such as protocol runs
        related_sets = yucca.datacat.RelatedSet.empty;
        
        cache_mode = 'transient';
        dloc_engine_override = [];
    end
    
    properties(Transient)
        data
        data_available
        data_unavailable
        related_set_types
        cache
    end
    
    methods (Access = private)
        
        function data = get_data_by_entries_(obj, entries)
            data = arrayfun(@(e) obj.get_data_by_uuid_(e.uuid), entries, 'UniformOutput', false);
        end
        
        function data = get_data_by_uuid_(obj, uuid)
            % is cached? if so, just return that:
            if obj.cache.isKey(uuid) && obj.cache_mode ~= "off"
               data = obj.cache(uuid);
               return;
            end
            
            info = obj.get_info(uuid);
            if length(info) > 1
                info = info(1); % workaround for duplicate uuids (should be same object)
                warning("Duplicate UUID for object " + info.name  + ", using first");
            end
            
            if isempty(info) 
                data = []; 
                return;
            end
                
            data = eval([info.recreation_class '(info.path)']);
            
            % cache?
            if obj.cache_mode ~= "off"
                obj.cache(uuid) = data;
            end
            
            % if we provide a data location storage engine override, set it
            % to all the object's we retrieve from the catalogue:
            if ~isempty(obj.dloc_engine_override)
                data.dl_storage_engine = obj.dloc_engine_override;
            end
        end
        
    end

    methods
        function obj = DataCat()
            import begonia.logging.log;
            log(2, '(DataCat) Meow')
            %obj.datalocation_engine = begonia.data_management.OnPathEngine();
            obj.cache = containers.Map;
        end
        
        % connects a path as a source:
        function src = connect(obj, path, name)
            import begonia.logging.log;
            
            if nargin < 3
                name = ['Untitled datasource (' char(datetime()) ')'];
            end
            
            % if not path is given, ask for it
            if nargin < 2
                path = uigetdir(userpath, 'Connect a data source directory');
                if isa(path, 'double')
                    disp('Cancled');
                    return;
                end
                
                % suffix the path if needed:
                if ~endsWith(path, ["/", "\"])
                    if ismac || isunix
                        path = [path '/'];
                    elseif ispc
                        path = [path '\'];
                    else
                        error("Unknown OS - neither linux, mac or win?");
                    end
                end
            end
            
            if isempty(path)
                error('Path cannot be empty');
            end
            
            % check if this path exists:
            if ~exist(path, 'file')
                error('Path does not exist')
            end
            
            % check we dont already have this path:
            if ~isempty(obj.get_source(path))
                error(['Source already connected for: ' path])
            end
            
            % invaldiate cached:
            log(1, '(DataCat) Connecting source');
            src = yucca.datacat.Source(path, name, obj);
            
            % is this source already connected? If so, replace it:
            existing = find({obj.sources.uuid} == string(src.uuid));
            if ~isempty(existing)
                log(1, '(DataCat) Source already exists, but on different path - replacing');
                obj.sources(existing) = src;
            else
                obj.sources(end + 1) = src;
            end
            
            % updating overlaps:
            obj.update_overlaps();
            
            % listen for events from the source:
%             addlistener(src ...
%                 , 'on_reindexed' ...
%                 , @(~,~) obj.handle_source_reindexed(src));
            
            log(1, '(DataCat) Done');
        end
        
        % removes a source from the catalog
        function disconnect(obj, src)
            obj.sources(obj.sources == src) = [];
        end
        
        
        function handle_source_reindexed(obj, ~)
            import begonia.logging.log;
            log(1, '(DataCat) Updaing cataloge after source reindex');
            obj.update_overlaps();
        end
        
        % returns the source based on path:
        function src = get_source(obj, path)
            for src = obj.sources
                if src.path == string(path)
                    return;
                end 
            end
            
            src = yucca.datacat.Source.empty;
        end
        
        
        % returns the original data:
        function data = get_data(obj, input)
            if isa(input, 'yucca.datacat.Entry') || isa(input, 'begonia.data_management.DataInfo') 
                data = obj.get_data_by_entries_(input);
            else
                data = obj.get_data_by_uuid_(input);
            end

            if iscell(data)
                data = [data{:}];
            end
        end
        
        
        % returns information about the object with given uuid:
        function info = get_info(obj, uuid)
            info = obj.data({obj.data.uuid} == string(uuid));
        end
        
        
        
        % clears cache:
        function clear_cache(obj)
            obj.cache = containers.Map;
        end
        
        
        % adds a related set:
        function add_related_set(obj, set_)
            obj.related_sets(end + 1) =  set_;
        end
        
        
        % returns data from all connected sources
        function data = get.data(obj)
            data = [obj.sources.data];
        end

            
        % between dates:
        function result = get_between_dates(obj, from, to)
            all_data = obj.data;
            
            matches = [all_data.start_time] > from & [all_data.end_time] < to;
            
            result = all_data(matches);
        end
        
        
        % lookup using fuzzy name:
        function matches = get_by_fuzzyname(obj, varargin)
            if isempty(obj.data)
                warning('NOTE: Doing lookup, but data catalogue is empy. Needs rescan of source?')
                matches = yucca.datacat.Entry.empty;
                return;
            end
            
            args = varargin;
            if isa(args{:}, 'cell')
                args = args{:};
            end
            
            matches = obj.data;
            for arg = args
                matches = matches(contains({matches.search_conglomerate}, arg));
            end
        end

        
        function map = get.related_set_types(obj)
            map = containers.Map();
            keys = unique({obj.related_sets.type});
            
            for key = keys
                map(char(key)) = obj.related_sets( ...
                    {obj.related_sets.type} == string(key));
            end
            
        end
        
        % list of available data:
        function data = get.data_available(obj)
            available_sources = obj.sources([obj.sources.available]);
            data = [available_sources.data];
        end
        
        
        % list of catalogued, but unavailable data:
        function data = get.data_unavailable(obj)
            data = setdiff(obj.data, obj.data_available);
        end
        
        
        % gets all overlaping data entries
        function update_overlaps(obj)
            import begonia.logging.log;
            log(1, '(DataCat) Updating overlap information');
            
            if isempty(obj.data)
                log(1, '(DataCat) No data');
                return;
            end
            
            % collect all time spans:
            has_times = arrayfun( ...
                @(d) ~isempty(d.start_time) & ~isempty(d.end_time) ...
                , obj.data);
            timed_data = obj.data(has_times);
            
            times = [timed_data.start_time ; timed_data.end_time]';
            
            % for each item, see if start and end time overlap:
            for e = timed_data
                
                % find one-way overlap:
                if ~isempty(e.start_time)
                    found = ...
                        timed_data(isbetween(e.start_time, times(:,1), times(:,2)) ...
                        | isbetween(e.end_time, times(:,1), times(:,2)));
                    e.overlaping_in_time = found({found.uuid} ~= string(e.uuid));
                end
            end
            
            % for each item, we now go and ensure the reverse overlap
            % exists:
            for e = obj.data
                for rev = e.overlaping_in_time
                    if ~any(rev.overlaping_in_time == e)
                        rev.overlaping_in_time = [rev.overlaping_in_time e];
                    end
                end
            end
        end

    end
end

