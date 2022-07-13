function [moving,whisking] = state_from_camera_trace(camera_whisker,camera_wheel,camera_dt)
%%
fs = 1/camera_dt;
%% Define movement and whiskering
moving = camera_wheel >= 4;
whisking = camera_whisker >= 1.5;
%% Bridge gaps
moving = begonia.util.dilate_logical(moving, round(2.5/camera_dt));
moving = begonia.util.erode_logical(moving, round(2.5/camera_dt));

whisking = begonia.util.dilate_logical(whisking, round(2.5/camera_dt));
whisking = begonia.util.erode_logical(whisking, round(2.5/camera_dt));
end