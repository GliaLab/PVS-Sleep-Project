classdef RelatedSet < handle & begonia.data_management.DataLocationAdapter
    %RELATEDSET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        uuid
        
        entries
        roles
        name
        type
        participants
        metadata
        catalogue
    end
    
    methods
        function obj = RelatedSet(name, type, catalogue)
            obj.uuid = begonia.util.make_uuid();
            obj.dl_unique_id = obj.uuid;
            obj.name = name;
            obj.type = type;
            obj.catalogue = catalogue;
            obj.metadata = containers.Map;
              
            id = [];
            role = [];
            
            obj.participants = table('Size',[0 2] ...
                , 'VariableTypes', {'string', 'string'} ...
                , 'VariableNames', {'id', 'role'});
        end
        
        % returns info on the elements of the set with the requested role:
        function infos = get_info_by_role(obj, role)
            infos = [];
            id = obj.participants(obj.participants.role == role,:).id;
            
            if ~isempty(id)
                infos = obj.catalogue.get_info(char(id));
            end
        end
        
        function roles = get.roles(obj)
            all_roles = obj.participants.role;
            roles = unique(all_roles);
        end
        
        % returns data on the elements of the set with the requested role:
        function datas = get_data_by_role(obj, role)
            infos = obj.get_info_by_role(role);
            datas = obj.catalogue.get_data(infos);
        end
        
        
        % true if uuid is a participant in this relation:
        function has = has_participant(obj, uuid)
            if isa(uuid, 'yucca.datacat.Entry')
                uuid = uuid.uuid;
            end
                
            found = obj.participants(obj.participants.id == uuid,1);
            has = ~isempty(found);
        end
        
        
        
        % adds the data info to this set:
        function add(obj, uuid, role)
            if isa(uuid, 'yucca.datacat.Entry')
                uuid = uuid.uuid;
            end
                
            obj.participants(end + 1,:) = {uuid, role};
        end
    end
end

