classdef LineScan < yucca.datanode.DataNode
    
    properties
        path
    end
    
    methods
        function obj = LineScan(path,engine)
            uuid_file = strsplit(path,'.');
            uuid_file = uuid_file{1};
            uuid_file = [uuid_file,'.uuid'];
            
            if exist(uuid_file,'file')
                uuid = fileread(uuid_file);
            else
                fid = fopen(uuid_file,'w');
                uuid = begonia.util.make_uuid;
                fprintf(fid,uuid);
                fclose(fid);
            end
            
            obj@yucca.datanode.DataNode(uuid,engine);
            
            obj.path = path;
        end
        
        function metadata = read_metadata(obj)
            path = strsplit(obj.path,'.');
            path = path{1};
            text = fileread([path,'.meta.txt']);
            text = strsplit(text,'\n');
            text = join(text(1:end-80),'');
            text = text{1};
            evalc(text);
            
            tmp = dir([path,'.meta.txt']);
            metadata.start_time = datetime(tmp.date);
            
            metadata.fs = SI.hRoiManager.scanFrameRate;
            metadata.dt = 1/metadata.fs;
            metadata.samples_per_frame = SI.hScan2D.lineScanSamplesPerFrame;
            metadata.channels = length(SI.hChannels.channelSave);

            % Calculate linescan "vector" from the coordinates. The
            % coordinates are the same as can be seen in the ScanImage
            % software. There are 2 metrics: micrometer (imagingFovUm) and
            % degrees (imagingFovUm).
            dist_vec = SI.hRoiManager.imagingFovUm(1,:) - SI.hRoiManager.imagingFovUm(3,:);
            dist_vec_deg = SI.hRoiManager.imagingFovDeg(1,:) - SI.hRoiManager.imagingFovDeg(3,:);

            % Calculate the number of micrometer per degree. This is a
            % setting in the microscope.
            metadata.um_per_deg = norm(dist_vec, 2) / norm(dist_vec_deg, 2);
            
            % Calculate a correction factor. The um_per_deg should be 71.77
            % we think.
            correction_factor = 71.77 / metadata.um_per_deg;
            
            % Calculate the length of the linescan and multiply by the
            % correction factor.
            metadata.linescan_length = norm(dist_vec, 2) * correction_factor;

            % Calculate the number of micrometer per sample/pixel.
            metadata.dx = metadata.linescan_length / metadata.samples_per_frame;
            
            tmp = dir([path,'.pmt.dat']);
            metadata.frames = tmp.bytes / 2 / metadata.channels / metadata.samples_per_frame;
            metadata.duration = metadata.frames * metadata.dt;
        end
        
        function signal = read(obj,fraction_of_frames,frame_limit)
            if nargin < 2
                fraction_of_frames = 1;
            end
            if nargin < 3
                frame_limit = inf;
            end
            
            path = strsplit(obj.path,'.');
            path = path{1};
            metadata = obj.read_metadata();
            
            if frame_limit > metadata.frames
                frame_limit = inf;
            end
            
            % Number of bytes to skip to the next frame. 
            skip = metadata.samples_per_frame*metadata.channels*2*(fraction_of_frames-1);
            
            % Number of values to read in a consecutive read.
            nval = metadata.samples_per_frame*metadata.channels;
            
            % Numbers of values to read if the number of frames should be
            % limited. 
            N = nval * frame_limit;
            
            fid = fopen([path,'.pmt.dat']);
            signal = fread(fid,N,nval+"*int16=>int16",skip);
            signal = reshape(signal,metadata.channels,metadata.samples_per_frame,[]);
            fclose(fid);
        end
    end
end

