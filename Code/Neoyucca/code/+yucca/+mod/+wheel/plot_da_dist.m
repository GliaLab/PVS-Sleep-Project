function plot_da_dist( wdata )
%PLOT_DA_WHEEL Summary of this function goes here
%   Detailed explanation goes here
    plot(wdata.Distance, 'LineWidth',1.2);
    ylabel('Distance (accumulated)');
    yyaxis right
    plot(wdata.DeltaAngle * -1, 'LineWidth',1.2);
    xlabel('Time (s)');
    ylabel('Delta angle')
    title('Wheel data / delta angle');
    grid on
end

