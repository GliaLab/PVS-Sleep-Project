function ax = overlap_on_background(img_background,img_1,img_2,color_1,color_2,color_overlap)
if nargin < 4
    color_1 = [0,1,0];
    color_2 = [0,0,1];
    color_overlap = [1,0,0];
end

img_overlap = img_1 & img_2;

color_1 = reshape(color_1,1,1,[]);
color_2 = reshape(color_2,1,1,[]);
color_overlap = reshape(color_overlap,1,1,[]);

img_1_color = img_1 .* color_1;
img_2_color = img_2 .* color_2;
img_overlap_color = img_overlap .* color_overlap;

I_1 = img_1 .* true(1,1,3) > 0;
I_2 = img_2 .* true(1,1,3) > 0;
I_overlap = img_overlap .* true(1,1,3) > 0;

I_1 = I_1(:);
I_2 = I_2(:);
I_overlap = I_overlap(:);

imshow(img_background);
ax = gca;
ax.CLim = [0,prctile(img_background(:),99)];

dim = size(img_background);

im_solid = zeros(dim(1),dim(2),3);
im_solid(I_1) = img_1_color(I_1);
im_solid(I_2) = img_2_color(I_2);
im_solid(I_overlap) = img_overlap_color(I_overlap);

hold on
im_handle = imshow(im_solid);
im_handle.AlphaData = double(img_1 | img_2);
end

