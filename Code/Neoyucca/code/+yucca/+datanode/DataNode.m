classdef DataNode < handle
    properties
        uuid
        saved_vars
        storage_engine
        dnode_list
    end
    
    methods
        function self = DataNode(uuid, storage_engine)
            self.uuid = uuid;
            self.storage_engine = storage_engine;
        end
        
        
        function dnode = find_dnode(self,varname)
            for i = 1:length(self)
                assert(~isempty(self(i).dnode_list),'DataNodeList missing.');
                uuid = self(i).load_var(varname); %#ok<*PROPLC>
                assert(ischar(uuid),'UUID saved under the variable name must be of type char');
                dnode(i) = self(i).dnode_list.find_dnode(uuid); %#ok<*AGROW>
            end
        end
        
        
        function val = has_dnode(self, varname)
            for i = 1:length(self)
                assert(~isempty(self(i).dnode_list),'DataNodeList missing.');
                uuid = self(i).load_var(varname); %#ok<*PROPLC>
                assert(ischar(uuid),'UUID saved under the variable name must be of type char');
                val(i) = self(i).dnode_list.has_dnode(uuid); %#ok<*AGROW>
            end
        end
        
        
        function vars = get.saved_vars(obj)
            vars = obj.storage_engine.get_saved_vars(obj.uuid);
        end
        
        
        function save_var(objs, variable, data)
            for obj = objs
                if nargin < 3
                    % Only one input supplied. 
                    if ~isempty(inputname(2))
                        % The input was one named variable, save the data
                        % of that variable with the same variable name. 
                        data = variable;
                        variable = inputname(2);
                    elseif ischar(variable)
                        % The input was a char, but without a variable
                        % name. Eg. save_var('asd')
                        % Find the value of a variable with that name in
                        % the calling function workspace.
                        try
                            data = evalin('caller', variable);
                        catch
                            % The evalin error information is a bit obscure as most
                            % users have no idea what it does. Usually it gets an 
                            % error because the variable does not exist. 
                            error(sprintf('Undefined variable ''%s''', variable));
                        end
                    else
                        error('Illegal input.');
                    end
                end
                
                obj.storage_engine.save_var(obj.uuid,variable,data);
            end
        end
        
        function data = load_var(objs, key, default)
            if isstring(key)
                key = char(key);
            end
            if ~isa(key, 'char')
                error(['Data location key needs to be a char vector, ' ...
                    'but got a ' class(key)]);
            end
            
            % Return the data in a cell array if multiple objects.
            data = cell(1,length(objs));
            for i = 1:length(objs)
                obj = objs(i);
                
                try
                    val = obj.storage_engine.load_var(obj.uuid, key);
                catch e
                    % If cannot load and we have default argument
                    if nargin == 3
                        val = default;
                    else
                        rethrow(e);
                    end
                end
                data{i} = val;
            end
            
            % If just one dloc variable is loaded, do not return a cell
            % array.
            if length(objs) <= 1
                data = data{1};
            end
            
            % If no left side assignment, return the variable directly
            % to the callers workspace. 
            if nargout == 0
                assignin('caller', key, data);
            end
        end
        
        
        function val = has_var(objs, variable_name)
            if isa(variable_name, 'char')
                variable_name = char(variable_name);
            end
                
            val = false(size(objs));
            for i = 1:length(objs)
                obj = objs(i);
                val(i) = obj.storage_engine.has_var(obj.uuid, variable_name);
            end
        end
        
        
        function clear_var(objs, variable)
            for obj = objs
                obj.storage_engine.clear_var(obj.uuid, variable);
            end
        end
        
        
        function clear_all_vars(objs)
            for obj = objs
                vars = obj.saved_vars;
                for i = 1:length(vars)
                    obj.clear_var(vars{i});
                end
            end
        end
        
    end
    
end

