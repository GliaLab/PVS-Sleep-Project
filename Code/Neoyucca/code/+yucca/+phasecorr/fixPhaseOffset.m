function dest_path = fixPhaseOffset( src_path, dest_path, offset )
%FIX_PHASE_OFFSET Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 2
        dest_path = [src_path '_phasecorr'];
    end
    
    if nargin < 3
       error('No offset given') 
    end
    
    if offset == 0
       error('Asked to correct zero offset. Would not do anyting.') 
    end

    % get/check offset:
    disp(['Fixing phase offset in: ' src_path]);
    h = waitbar(0.0, 'Preparing folder');
    
    % create new dir:
    if endsWith(src_path, ["/", "\"])
        src_path = src_path(1:end-1);
    end

    mkdir(dest_path);
    
    % find tiffs and non-tiffs:
    files = dir(src_path);
    non_tiffs = arrayfun(@(p) ~contains(p, 'ome.tif') & ~startsWith(p, '.'), {files.name});
    non_tiffs = files(non_tiffs);
    tiffs = arrayfun(@(p) contains(p, 'ome.tif'), {files.name});
    tiffs = files(tiffs);
    
    % copy non-tiffs:
    waitbar(0.0, h, 'Copying non-tiff files');
    for i = 1:length(non_tiffs)
        src_file = fullfile(src_path, non_tiffs(i).name);
        dest_file = fullfile(dest_path, non_tiffs(i).name);
        copyfile(src_file, dest_file);
    end
    
    % perform adjustment:
    counter = 1;
    for i = 1:length(tiffs)
        counter = counter + 1 ;
        if counter == 100
            progress = i / length(tiffs);
            waitbar(progress, h, ['Adjusting tiff file ' num2str(i) ' of ' num2str(length(tiffs)) ' at offset ' num2str(offset)]);
            counter = 1;
        end
        
        src_file = fullfile(src_path, tiffs(i).name);
        dest_file = fullfile(dest_path, tiffs(i).name);
        
        img = imread(src_file);
        for j = 1:2:size(img, 2)
            row = img(j,:);
            row_shifted = circshift(row, offset);
            img(j,:) = row_shifted;
        end
        imwrite(img, dest_file);
    end
    close(h)
    
    % align if asked
%     if align
%         h = waitbar(0.0, 'Aligning (takes a long time, does not update bar');
%         begonia.stack_operations.align(dest_path, [dest_path '_rigal'], true);
%         close(h)
%         rmdir(dest_path, 's');
%         dest_path = [dest_path '_aligned']
%     end
end

