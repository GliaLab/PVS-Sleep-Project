function plot_markers(ts)
    fig = figure;
    fig.Position(3) = fig.Position(3) * 1.5;

    data = ts.load_var('vestool2_results');

    markers = string(unique(data.marker_name))';

    for marker = markers
        data_ch2 = data(data.channel == "Ch2" & data.marker_name == marker,:);
        data_ch3 = data(data.channel == "Ch3" & data.marker_name == marker,:);

        subplot(3,1,1);
        plot(data_ch2.time_s, data_ch2.distance_um, 'linewidth', 1.3, 'color', [.7 .7 .7]);
        hold on
        plot(data_ch2.time_s, smooth(data_ch2.distance_um), 'linewidth', 1.3, 'color', 'green');
        grid on;
        title("Ch2");
        xlim([0 data_ch2.time_s(end)])
        ylabel("μm")

        subplot(3,1,2);
        plot(data_ch3.time_s, data_ch3.distance_um, 'linewidth', 1.3, 'color', [.7 .7 .7]);
        hold on
        plot(data_ch3.time_s, smooth(data_ch3.distance_um), 'linewidth', 1.3, 'color', 'red');
        grid on;
        title("Ch3");
        xlim([0 data_ch3.time_s(end)])
        ylabel("μm")


        subplot(3,1,3);
        diff = data_ch2.distance_um - data_ch3.distance_um;
        plot(data_ch2.time_s, diff, 'linewidth', 1.3, 'color', [.7 .7 .7]);
        hold on;   
        plot(data_ch3.time_s, smooth(diff), 'linewidth', 1.3, 'color', 'blue');

        xlim([0 data_ch2.time_s(end)])
        grid on;
        title("Ch2 - Ch3");
        xlabel("Time (s)");
        ylabel("μm")

        suptitle(ts.name + " / " + marker);
        fig.name = marker;
    end
end


