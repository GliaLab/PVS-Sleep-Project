function imagesc_toiyt(img,path)
dim = size(img);

imagesc(img);
colormap(begonia.colormaps.turbo);

axis equal

ax = gca;
set(ax,'XTickLabel',[])
set(ax,'YTickLabel',[])
set(ax,'XLim',[0,dim(1)])
set(ax,'YLim',[0,dim(2)])
set(ax,'FontSize',20)
set(ax,'XTick',[])
set(ax,'YTick',[])

if nargin == 2
    export_fig(f,path,'-native');
end

end

