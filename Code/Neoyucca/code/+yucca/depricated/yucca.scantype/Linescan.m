classdef Linescan < yucca.scantype.PrairieOutput
    %LINESCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        first_point
        last_point
    end
    
    methods
        function obj = Linescan(path)
            obj@yucca.scantype.PrairieOutput(path);
          
            % assert we are a linescan:
            assert(strcmp(obj.type, 'Linescan'), ...
                    'begonia:invalid_stack:not_linescan_sequence_type', ...
                    'Not a linescan according to type');
            
            xml = xmlread(obj.xml_file_path);
            xmldata = yucca.util.xml2struct(xml);
            try
                obj.first_point = xmldata.PVScan.Sequence.PVLinescanDefinition.Freehand{1}.Attributes;
                obj.last_point = xmldata.PVScan.Sequence.PVLinescanDefinition.Freehand{end}.Attributes;
            catch
                warning('Go fuck yourself!')
                obj.first_point = [];
                obj.last_point = [];
            end
            
        end
    end
    
end