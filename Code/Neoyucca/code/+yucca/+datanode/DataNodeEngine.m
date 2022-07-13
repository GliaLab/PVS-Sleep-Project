classdef DataNodeEngine < handle
    
    properties
        datastore_path
    end
    
    methods
        function obj = DataNodeEngine(datastore_path)
            obj.datastore_path = datastore_path;
        end
        
        function dnodes = get_dnodes(obj)
            tbl = obj.get_register();
            if isempty(tbl)
                dnodes = [];
            end
            
            uuids = unique(tbl.uuid);
            uuids = cellstr(uuids);
            
            for i = 1:length(uuids)
                dnodes(i) = yucca.datanode.DataNode(uuids{i},obj);
            end
        end
        
        function tbl = get_register(obj)
            % Create a table with all the data.
            
            %% Find all mat files.
            str = fullfile(obj.datastore_path,'**','*.mat');
            files = dir(str);
            
            uuid = cell(length(files),1);
            varname = cell(length(files),1);
            ext = cell(length(files),1);
            ext(:) = {'mat'};
            for i = 1:length(files)
                uuid{i} = files(i).name(1:end-4);
                folders = textscan(files(i).folder,'%s','Delimiter',filesep);
                varname{i} = folders{1}{end};
            end
            
            tbl_mat = table(uuid,varname,ext);
            
            tbl_mat.uuid = categorical(tbl_mat.uuid);
            tbl_mat.varname = categorical(tbl_mat.varname);
            tbl_mat.ext = categorical(tbl_mat.ext);
            
            %% Find all h5 files.
            str = fullfile(obj.datastore_path,'**','*.h5');
            files = dir(str);
            
            uuid = cell(length(files),1);
            varname = cell(length(files),1);
            ext = cell(length(files),1);
            ext(:) = {'mat'};
            for i = 1:length(files)
                uuid{i} = files(i).name(1:end-3);
                folders = textscan(files(i).folder,'%s','Delimiter',filesep);
                varname{i} = folders{1}{end};
            end
            
            tbl_h5 = table(uuid,varname,ext);
            
            tbl_h5.uuid = categorical(tbl_h5.uuid);
            tbl_h5.varname = categorical(tbl_h5.varname);
            tbl_h5.ext = categorical(tbl_h5.ext);
            
            %%
            tbl = cat(1,tbl_mat,tbl_h5);
        end
        
        function save_var(obj, uuid, varname, data)
            if isstring(varname)
                varname = char(varname);
            end
            
            info = whos('data');
            if info.bytes < 2e9
                % Delete previous data.
                obj.clear_var(uuid,varname);
            
                filepath = fullfile(obj.datastore_path,varname,[uuid,'.mat']);
                
                begonia.path.make_dirs(filepath);
                
                % Save the matfile in a older format so the files can be
                % editied to have the same output every time. 
                save(filepath, 'data','-v7','-nocompression');
                % The beginning of the file has a timestamp and operating
                % system ID. That information is overwrittern with zeros. 
                fileID = fopen(filepath,'r+');
                fseek(fileID,21,'bof');
                fwrite(fileID,zeros(1,54));
                fclose(fileID);
            elseif ismember(class(data),{'double', 'single','uint64', ...
                    'int64', 'uint32', 'int32', 'uint16','int16', ...
                    'uint8', 'int8', 'logical'})
                % Save as HDF5 for deterministic output.
                
                % Delete previous data.
                obj.clear_var(uuid,varname);
            
                filepath = fullfile(obj.datastore_path,varname,[uuid,'.h5']);
                
                begonia.path.make_dirs(filepath);
                
                if isequal(class(data),'logical')
                    read_as_logical = 1; % True
                    data = uint8(data);
                else
                    read_as_logical = 0; % False
                end
                
                arr = begonia.util.H5Array(filepath,size(data),class(data), ...
                    'dataset_name','/md_array');
                arr(:) = data;
                h5writeatt(filepath,'/md_array','read_as_logical',read_as_logical);
            else
                error('Data could not be saved because the file size is larger than 2GB and is not a numeric type.')
            end
        end
        
        
        function data = load_var(obj, uuid, varname)
            if isstring(varname)
                varname = char(varname);
            end
            
            file = fullfile(obj.datastore_path,varname,uuid);
            file = char(file);
            if exist([file,'.mat'],'file')
                tmp = load([file,'.mat']);
                data = tmp.data;
            elseif exist([file,'.h5'],'file')
                arr = begonia.util.H5Array([file,'.h5'],'dataset_name','/md_array');
                data = arr(:);
                data = reshape(data,size(arr));
                read_as_logical = h5readatt([file,'.h5'],'/md_array','read_as_logical');

                if read_as_logical
                    data = logical(data);
                end
            else
                error(['yucca:data_node:missing_variable:',varname], ...
                    ['Variable "', varname ,'" not found.']);
            end
        end
        
        
        function vars = get_saved_vars(obj,uuid)
            register = obj.get_register();
            I = register.uuid == uuid;
            vars = cellstr(register.varname(I));
        end
        
        
        function val = has_var(obj, uuid, varname)
            if isstring(varname)
                varname = char(varname);
            end
            
            val = false;
            
            file = fullfile(obj.datastore_path,varname,uuid);
            file = char(file);
            if exist([file,'.mat'],'file')
                val = true;
                return
            end
            if exist([file,'.h5'],'file')
                val = true;
                return;
            end
        end
        
        
        function clear_var(obj, uuid, varname)
            if isstring(varname)
                varname = char(varname);
            end
            
            file = fullfile(obj.datastore_path,varname,uuid);
            file = char(file);
            if exist([file,'.mat'],'file')
                delete([file,'.mat']);
            end
            if exist([file,'.h5'],'file')
                delete([file,'.h5']);
            end
        end
    end
    
end

