function [mask,img] = threshold_pupil(img, threshold)
img = mean(img,3,"native");
mask = img < threshold;
% Ignore border.
mask(1:10,:) = false;
mask(end-10:end,:) = false;
mask(:,1:10) = false;
mask(:,end-10:end) = false;
mask = bwpropfilt(mask,"Area",1);
mask = bwconvhull(mask);
end

