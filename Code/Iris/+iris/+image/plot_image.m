function plot_image(images)

if height(images) == 1
    img = images.img{1};
    
    imagesc(img);
    colormap(gray);
    colorbar;
    
    ax = gca;
    ax.CLim = prctile(img(:),[1,99]);
else
end

end

