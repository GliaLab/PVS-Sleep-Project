function metadata = read_scanimage_metadata(path)
% Load metadata from the tif file and return a struct. 

metadata = struct;
metadata.frame_count        = [];
metadata.slices             = [];
metadata.channel_names      = [];
metadata.channels           = [];
metadata.img_dim            = [];
metadata.dt                 = [];
metadata.dx                 = [];
metadata.dy                 = [];
metadata.cycles             = [];
metadata.zoom               = [];
metadata.start_time         = [];
metadata.duration           = [];

warning off
tif = Tiff(path);
warning on

evalc(tif.getTag('ImageDescription'));
evalc(tif.getTag('Software'));

metadata.channel_names = ...
    SI.hChannels.channelName(SI.hChannels.channelSave);
metadata.channels = length(metadata.channel_names);
metadata.img_dim(1) = SI.hRoiManager.linesPerFrame;
metadata.img_dim(2) = SI.hRoiManager.pixelsPerLine;
metadata.dt = SI.hRoiManager.scanFramePeriod;
metadata.zoom = SI.hRoiManager.scanZoomFactor;
metadata.cycles = SI.hCycleManager.totalCycles;
metadata.frame_count = SI.hStackManager.framesPerSlice;
metadata.start_time = datetime(epoch);
metadata.start_time.Format = 'uuuu/MM/dd HH:mm:ss';
metadata.duration = seconds(metadata.frame_count * metadata.dt);
metadata.slices = SI.hStackManager.actualNumSlices;
metadata.frames_per_slice = SI.hStackManager.framesPerSlice;

width_um = SI.hRoiManager.imagingFovUm(3,1) - SI.hRoiManager.imagingFovUm(1,1);
height_um = SI.hRoiManager.imagingFovUm(3,2) - SI.hRoiManager.imagingFovUm(1,2);

metadata.dx = width_um / metadata.img_dim(2);
metadata.dy = height_um / metadata.img_dim(1);

metadata.img_dim = reshape(metadata.img_dim,1,[]);
end

