classdef PrairieOutput < begonia.stack.Stack
    %The idea is that begonia.stack.StackPrarie uses this class to
    %initialize and that this class is a general "PrarieOutput" reader that
    %can handle zseries, tseries, single images and linescans.
    
    properties (Access = private)
        files
    end
    
    properties
        xml_file_path
        line_x
        line_y
    end
    
    methods
        function obj = PrairieOutput(path)
            obj@begonia.stack.Stack(path);
            if path(end) == filesep
                path(end) = [];
            end
            
            xml_files = begonia.path.find_files(path,'.xml',false);
            assert(~isempty(xml_files),'begonia:invalid_stack:missing_xml','Missing xml file.');
            
            obj.xml_file_path = xml_files{1};
            meta = begonia.stack.StackPrarie.parse_xml_file_fast(obj.xml_file_path);

            obj.type = meta.type;
            
            obj.dx = meta.dx;
        
            obj.dy = meta.dx;
            obj.dt = meta.dt;
            obj.optical_zoom = meta.optical_zoom;
            obj.cycles = meta.cycles;
            obj.frames_in_cycle = meta.frames_in_cycle;
            ix = meta.line_x < 1;
            meta.line_x(ix) = [];
            meta.line_y(ix) = [];
            obj.line_x = meta.line_x;
            obj.line_y = meta.line_y;
            
            obj.channels = meta.channels;
            obj.record_date = meta.date;
            obj.channel_names = meta.channel_names;
            obj.path = path;
            obj.original_img_dim = meta.original_img_dim;
            
            obj.files = cellfun(@(filename) [obj.path,filesep,filename], ...
                meta.files, 'UniformOutput',false);
            
            % Set the name of the stack from the directory.
            name = strsplit(path,filesep);
            name = name{end};
            % This is a hotfix, not needed in most cases, but probably wont
            % hurt. 
            name = strrep(name,'-raw','');
            obj.name = name;
        end
        
        function mat = get_stack(self,cycle,channel)
            files = self.files(cycle,channel,:);  %#ok<*PROPLC>
            mat = begonia.frame_providers.PrarieFrameProvider(files);
        end
    end
    
    methods (Static)
        
%         function metadata = parse_xml_file_fast(xml_path)
%             if ~contains(xml_path,'.xml')
%                 % Assume it is a directory.
%                 xml_path = begonia.path.find_files(xml_path, '.xml');
%                 xml_path = xml_path{1};
%             end
% %             metadata.date = '';
% %             metadata.dt = '';
% %             metadata.dx = [];
% %             metadata.dy = [];
% %             metadata.cycles = [];
% %             metadata.type = [];
% %             metadata.frames_in_cycle = [];
% %             metadata.files = {};
% %             metadata.channels = [];
% %             metadata.channel_names = {};
%             
%             text = fileread(xml_path);
%             
%             out = regexp(text(1:10000),'(?<=date=").*?(?=")','match');
%             metadata.date = out{1};
%             
%             out = regexp(text(1:10000),'(?<="framePeriod" value=").*?(?=")','match');
%             metadata.dt = str2double(out{1});
%             
%             out = regexp(text(1:10000),'(?<="XAxis" value=").*?(?=")','match');
%             metadata.dx = str2double(out{4});
%             
%             out = regexp(text(1:10000),'(?<="YAxis" value=").*?(?=")','match');
%             metadata.dy = str2double(out{4});
%             
%             out = regexp(text(1:10000),'(?<=type=").*?(?=")','match');
%             metadata.type = out{1};
%             
%             % Matches any characters that are not whitespace (\S) which is
%             % also between 'filename="' and '"' .
%             out = regexp(text,'(?<=filename=")\S*?\.ome\.tif(?=")','match');
%             metadata.files = out;
%             tmp_cy = cell(length(out),1);
%             tmp_ch = cell(length(out),1);
%             for i = 1:length(out)
%                 tmp_cy{i} = out{i}(end-23:end-19);
%                 tmp_ch{i} = out{i}(end-17:end-15);
%             end
%             metadata.cycles = length(unique(tmp_cy));
%             tmp_ch = unique(tmp_ch);
%             metadata.channels = length(tmp_ch);
%             metadata.channel_names = tmp_ch;
%             metadata.files = reshape(metadata.files,metadata.cycles,metadata.channels,[]);
%             % The previous code of sorting the files brakes if the cycles
%             % dont have equally many frames, so we juse use that data to
%             % create frames_in_cycle.
%             metadata.frames_in_cycle = repmat(size(metadata.files,3),1,metadata.cycles);
%             
%         end
        
        function metadata = parse_xml_file(xml_path)
            if ~contains(xml_path,'.xml')
                % Assume it is a directory.
                xml_path = begonia.path.find_files(xml_path, '.xml');
                xml_path = xml_path{1};
            end

            metadata = struct();

            doc = xmlread(xml_path);

            metadata.date = char(doc.getElementsByTagName('PVScan').item(0).getAttribute('date'));

            seq_list = doc.getElementsByTagName('PVStateValue');
            for i = 0:seq_list.getLength()-1
                item = seq_list.item(i);
                key = item.getAttribute('key');
                value = item.getAttribute('value');

                if strcmp(key, 'framePeriod')
                    metadata.dt = str2num(char(value));
                elseif strcmp(key, 'micronsPerPixel')
                    var = item.getElementsByTagName('IndexedValue');
                    metadata.dx = str2num(char(var.item(0).getAttribute('value')));
                    metadata.dy = str2num(char(var.item(1).getAttribute('value')));
                end
            end

            seq_list = doc.getElementsByTagName('Sequence');
            metadata.cycles = seq_list.getLength;
            metadata.type = char(seq_list.item(0).getAttribute('type'));

            for cycle = 0:seq_list.getLength - 1
                frame_list = seq_list.item(cycle).getElementsByTagName('Frame');
                metadata.frames_in_cycle(cycle+1) = frame_list.getLength;

                for frame = 0:frame_list.getLength - 1
                    channel_list = frame_list.item(frame).getElementsByTagName('File');
                    for channel = 0:channel_list.getLength - 1
                        metadata.files{cycle+1,channel+1,frame+1} = char(channel_list.item(channel).getAttribute('filename')); 
                    end
                end
            end

            file_list = frame_list.item(0).getElementsByTagName('File');
            metadata.channels = file_list.getLength;
            for i = 0:file_list.getLength - 1
                metadata.channel_names{i+1} = lower(char(file_list.item(i).getAttribute('channelName')));
            end
        end
        
    end
    
end


