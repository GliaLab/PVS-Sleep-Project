classdef DataNodeList < handle
    properties (SetAccess = private)
        uuids
        dnodes
    end
    
    methods
        function add(self,dnodes)
            dnodes = reshape(dnodes,1,[]);
            uuids = {dnodes.uuid};
            if isempty(self.dnodes)
                self.dnodes = dnodes;
                self.uuids = uuids;
            else
                assert(~any(ismember(self.uuids,uuids)),'DataNode already exist in DataNodeList');
                self.dnodes = cat(2,self.dnodes,dnodes);
                self.uuids = cat(2,self.uuids,uuids);
            end
            [dnodes.dnode_list] = deal(self);
        end
        
        function reset(self)
            self.uuids = [];
            self.dnodes = [];
        end
        
        function dnode = find_dnode(self,uuid)
            assert(~isempty(uuid),'Input cannot be empty.');
            if ischar(uuid)
                uuid = {uuid};
            end
            for i = 1:length(uuid)
                I = ismember(self.uuids,uuid{i});
                assert(sum(I) > 0,'No data entries found with the given UUID.');
                assert(sum(I) < 2,'Muliple data entries found with the give UUID.');
                dnode(i) = self.dnodes(I);
            end
        end
        
        function val = has_dnode(self, uuid)
            assert(~isempty(uuid),'Input cannot be empty.');
            if ischar(uuid)
                uuid = {uuid};
            end
            val = ismember(uuid, self.uuids);
        end
    end
end

