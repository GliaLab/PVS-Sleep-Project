function [preview, bbox, frame, diameter_px] = analyse_frame(...
    img, roiarea, minv, maxv, do_imadjust, do_adapt, ignore_mask, reliable_axis)
    diameter_px = nan;
    frame = imcrop(img, roiarea);

    frame_region = false(size(frame));
    %frame = imgaussfilt(frame);
    bbox = [];
    
    if do_imadjust
        frame = imadjust(frame);
    end
    
    if do_adapt
        tresh = adaptthresh(frame,  0.05);
        frame = double(frame) + (tresh*255);
    end
    
    frame = imerode(frame, strel('cube', 3));
    
    frame_bin = frame > minv & frame < maxv;
    
    if nargin > 6 && ~isempty(ignore_mask) 
        if isequal(size(frame_bin), size(ignore_mask))
            frame_bin = frame_bin & ~ignore_mask;
        else
            warning("Size of ignore mask does not match selected area - ignoring");
        end
    end
    
    
    %frame_bin = imerode(frame_bin, strel('sphere',1));
    
    concomp = bwconncomp(frame_bin);
    
    regions = regionprops(concomp, 'BoundingBox');
    centers = regionprops(concomp, 'Centroid');
    pixlists = concomp.PixelIdxList;
    
    % ensure the areas have at least 10 by 10 pixels:
    valid_size = arrayfun(@(p) length(p{:}) > 50 * 50 , pixlists);

    % ensure that interior has at least 25% pixels:
    valid_density = false(1, length(regions));
    for i = 1:length(regions)
        pixcount = length(pixlists{i});
        box_area = regions(i).BoundingBox(3) * regions(i).BoundingBox(4);
        valid_density(i) = (pixcount / box_area) > 0.25;
    end
    
    regions = regions(valid_size & valid_density);
    centers = centers(valid_size & valid_density);
    pixlists = pixlists(valid_size & valid_density);
    
    % find the region 
    if length(regions) > 0
        
        % find centermost:
        x_mid = size(frame, 1)/2;
        y_mid = size(frame, 2)/2;

        dists = arrayfun(@(c)...
            abs(c.Centroid(1) - x_mid) ...
            + abs(c.Centroid(2) - y_mid), centers);

        [d_min, idx] = min(dists);

        frame_region(pixlists{idx}) = true;
        bbox = regions(idx).BoundingBox;
        if reliable_axis == "vertical"
            diameter_px = bbox(4);
        else
            diameter_px = bbox(3);
        end
    end
    
    preview = frame_bin + frame_region;
end




