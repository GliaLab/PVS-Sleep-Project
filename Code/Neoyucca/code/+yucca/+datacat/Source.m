classdef Source < yucca.datacat.EntryCollection
    %SOURCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        path
        uuid
        name
        catalog
        data = [];
        meta_file_path
        available
        
        % some metadata
        date_created = datetime();
        date_indexed = [];
        date_opened = datetime();
        indexed_on_arch = [];
        scan_duration;
        path_when_scanned;
    end
    
    events
        on_reindexed 
    end
    
    properties (Constant)   
        METAFILE_NAME = '.datacat_source.mat';
       	UUIDFILE_NAME = '.datacat_uuid';
    end
    
    methods
        function obj = Source(path, name, catalog)
            import begonia.logging.log;
            
            obj.path = path;
            obj.uuid = begonia.util.make_uuid();
            obj.name = name;
            obj.catalog = catalog;
            obj.path_when_scanned = [];
            
            % try to load:
            if ~obj.load()
                log(1, 'Metadata not found');
                obj.update();
            end
        end
        
        
        % returns the path to the meta file of the current source
        function path = get.meta_file_path(obj)
            path = fullfile(obj.path, obj.METAFILE_NAME);
        end
        
        
        % loads a data root if it already exists
        function loaded_ok = load(obj)
            import begonia.logging.log;
            
            loaded_ok = false;
            if exist(obj.meta_file_path, 'file')
                log(1, 'Source data found - loading');
                load(obj.meta_file_path);
                
                % set metadata props
                obj.name = meta.name;
                obj.uuid = meta.uuid;
                obj.date_created = meta.date_created;
                obj.date_indexed = meta.date_indexed;
                obj.scan_duration = meta.scan_duration;
                obj.data = meta.data;
                obj.indexed_on_arch = meta.indexed_on_arch;
                try
                    obj.path_when_scanned = meta.path_when_scanned;
                catch 
                    obj.path_when_scanned = '';
                end
                
                % get architecture of current machine:
                arch = upper(computer());
                arch_state = obj.indexed_on_arch + "->" + arch;
                
                
                % ensure data points to us as it's source
                for d = obj.data
                    d.cat_source = obj;
                    d.catalog = obj.catalog;
                    
                    % if current path is not the path the object was
                    % scanned with, we want to translate the path to it's
                    % current location
                    % FIXME: make this work cross-platform!
                    if obj.path ~= string(obj.path_when_scanned)
                        d.path = replace(d.path, obj.path_when_scanned, obj.path);
                    end
                    
                    % if current architecture is different, we also need to
                    % flip the slashes:
                    if arch_state == "PCWIN64->MACI64" || arch_state == "PCWIN64->GLNXA64"
                        d.path = replace(d.path, "\", "/");
                    elseif arch_state == "MACI64->PCWIN64" || arch_state == "GLNXA64->PCWIN64"
                        d.path = replace(d.path, "/", "\");
                    end
                    
                    % valdiate new path exists:
                    if ~exist(d.path, 'dir')
                        warning(d.path + " -> could not load object path. Needs rescan after files moved?");
                    end
                end
                
                % notify if path has changed:
                if obj.path ~= string(obj.path_when_scanned)
                    disp('Note: root folder has moved - changed entry paths (migth cause trouble)');
                end
                
                if arch_state == "MACI64->PCWIN64" | arch_state == "PCWIN64->MACI64"
                    disp('Note: architecture has changed - changed entry paths (migth cause trouble)');
                end
 
                
                loaded_ok = true;
            end
        end
        
        % re-creates the root data:
        function update(obj)
            import begonia.logging.log;
            
            log(1, 'Updating source metadata');
            
            % main mat file:
            meta.uuid = obj.uuid;
            meta.name = obj.name;
            meta.date_created = obj.date_created;
            meta.date_indexed = obj.date_indexed;
            meta.scan_duration = obj.scan_duration;
            meta.indexed_on_arch = obj.indexed_on_arch;
            meta.path_when_scanned = obj.path_when_scanned; % remembers this for path-translation
            
            meta.data = obj.data; %#ok<STRNU>
            
            save(obj.meta_file_path, 'meta');
            
            % uuid copy for fast availability check:
            uuid_path = fullfile(obj.path, obj.UUIDFILE_NAME);
            fid = fopen(uuid_path,'w');
            fprintf(fid, obj.uuid);
            fclose(fid);
            
            notify(obj, 'on_reindexed');
            obj.catalog.handle_source_reindexed(obj);
        end
        
        
        function rename(obj, name)
            obj.name = name;
            obj.update();
        end
        
        % rescans the root:
        function rescan(obj)
            import yucca.datacat.*;
            import begonia.logging.log;
            
            log(1, 'Indexing source (this could take along time - please be patient)');
            if ~isempty(obj.scan_duration) && obj.scan_duration > seconds(10)
                disp(['Note: last scan of this source took ' char(obj.scan_duration)]);
            end
            
            t = tic;
            
            % stacks using begonia scan search:
            scan_infos = [];
            scans = begonia.scantype.find_scans(obj.path);
            %scans = begonia.scantype.find_scans('C:\Users\knuta\Documents\Local data\E400b2 - day 12 mic\TSeries-06012018-0919-052_aligned');
            scan_infos = arrayfun(@(s) Entry(s, obj), scans);
            
            % find trials:
            trials = yucca.trial_search.find_trials(obj.path);
            trial_infos = arrayfun(@(s) Entry(s, obj), trials);
            
            % merge into data property:
            obj.data = [scan_infos trial_infos];
            
            log(1, 'Indexing complete - saving changes to source');
            obj.date_indexed = datetime();
            obj.indexed_on_arch = computer();
            obj.scan_duration = seconds(toc(t));
            obj.path_when_scanned = obj.path;
            
            obj.update();
            disp('Done');
        end
        
        % rescans part of the source
        function rescan_partial(obj, path)
            error("Function not implemented");
        end
        
%         % list of the types of data that exists in the system
%         function types = get.data_types(obj)
%             types = containers.Map;
%             typenames = unique({obj.data.type});
%             for type = typenames
%                 type_str = string(type);
%                 entries = obj.data({obj.data.type} == type_str);
%                 types(char(type_str)) = entries;
%                 
%             end
%         end
%         
        
        % gets infor 
        function itis = get.available(obj)
            
            itis = false;
            % first - does it exist?
            if exist(obj.path, 'file') ~= 0
                
                % check target has same UUID as us:
                uuid_path = fullfile(obj.path, obj.UUIDFILE_NAME);
                src_uuid = fileread(uuid_path);
                itis = string(obj.uuid) == string(src_uuid); 
            end
            
            
        end
        
    end
end

