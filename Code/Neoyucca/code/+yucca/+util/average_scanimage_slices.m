function average_scanimage_slices(folder,folder_out,max_prcntile)
if nargin < 3
    max_prcntile = 97.5;
end
files = begonia.path.find_files(char(folder),'.tif',true);

for i = 1:length(files)
    fname = files{i};

    metadata = yucca.util.read_scanimage_metadata(fname);
    if metadata.slices == 1
        continue;
    end

    info = imfinfo(fname);
    num_images = numel(info);

    mat = zeros([metadata.img_dim,num_images],'int16');
    for k = 1:num_images
        mat(:,:,k) = imread(fname, k, 'Info', info);
    end
    
    mat = reshape(mat, ...
        info(1).Width, ...
        info(1).Height, ...
        metadata.channels, ...
        metadata.frames_per_slice, ...
        metadata.slices);

    mat = mean(mat,4);
    dim = size(mat);

    red = squeeze(mat(:,:,1,:,:));
    green = squeeze(mat(:,:,2,:,:));

    red = red - min(red(:));
    red = red / prctile(red(:),max_prcntile);

    green = green - min(green(:));
    green = green / prctile(green(:),max_prcntile);

    % Red
    [d,f,e] = fileparts(fname);
    fname_out = sprintf("%s channel 1.tif",f);
    fname_out = fullfile(d,fname_out);
    fname_out = strrep(fname_out,folder,folder_out);
    if exist(fname_out,'file')
        delete(fname_out)
    end
    begonia.path.make_dirs(fname_out);
    for k = 1:size(mat,5)
        rgb = zeros(dim(1),dim(2),3);
        rgb(:,:,1) = red(:,:,k);
        imwrite(rgb,fname_out,'WriteMode','append')
    end

    % Green
    [d,f,e] = fileparts(fname);
    fname_out = sprintf("%s channel 2.tif",f);
    fname_out = fullfile(d,fname_out);
    fname_out = strrep(fname_out,folder,folder_out);
    if exist(fname_out,'file')
        delete(fname_out)
    end
    begonia.path.make_dirs(fname_out);
    for k = 1:size(mat,5)
        rgb = zeros(dim(1),dim(2),3);
        rgb(:,:,2) = green(:,:,k);
        rgb(:,:,2) = histeq(rgb(:,:,2));
        imwrite(rgb,fname_out,'WriteMode','append')
    end

    % Merged
    [d,f,e] = fileparts(fname);
    fname_out = sprintf("%s merged.tif",f);
    fname_out = fullfile(d,fname_out);
    fname_out = strrep(fname_out,folder,folder_out);
    if exist(fname_out,'file')
        delete(fname_out)
    end
    begonia.path.make_dirs(fname_out);
    for k = 1:size(mat,5)
        rgb = zeros(dim(1),dim(2),3);
        rgb(:,:,1) = red(:,:,k);
        rgb(:,:,2) = green(:,:,k);
        imwrite(rgb,fname_out,'WriteMode','append')
    end
end

end

