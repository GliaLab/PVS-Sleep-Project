function img = get_multichannel_reference_img(ts)
    if ts.channels ~= 2
        img = ts.get_std_img(1,1);
    else
        ch2 = ts.get_std_img(1,1);
        ch3 = ts.get_std_img(1,2);
        
        img = imfuse(...
            ch2...
            , ch3...
            , 'falsecolor' ...
            ,'Scaling','independent' ...
            , 'ColorChannels',[2 1 0]);
    end
end

