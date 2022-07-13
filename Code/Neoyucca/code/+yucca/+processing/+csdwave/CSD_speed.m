%% Script to estimate CSD wave propagation speed and lag between two channels

clear all;
close all force;
% loads tseries - change folder if needed
tss = begonia.scantype.find_scans('/Users/runeenger/Desktop/CSD/');
ts = tss(1); %velg den relevante tseries


%% Rotate tseries so wave goes from bottom to top and then save value

begonia.processing.csdwave.rotation(ts);
ts.save_var("genotype","Control")
ts.save_var("mouseID","Per")
ts.save_var("mouseID","Per")
%% Rotate the actual matrix and display the two channels
close all force
clearvars -except ts

strt = ts.load_var("Startframe");
stp = ts.load_var("Stopframe");
rot = ts.load_var("rotation");
ch1 = ts.get_mat(1);
ch1 = ch1(:,:,strt:stp);
ch1 = ch1+1;
ch1 = imrotate(ch1, rot, 'nearest', 'crop');
ch1(ch1 == 0) = nan;
ch1 = ch1-1;

ch1 = nanmean(ch1(:, round(size(ch1,1)/2)-30:round(size(ch1,1)/2)+30, :),2);
ch1 = squeeze(ch1);
figure('Units', 'centimeters', 'Position', [5,5,50,30]); imagesc(ch1)

ch2 = ts.get_mat(2);
ch2 = ch2(:,:,strt:stp);
ch2 = ch2+1;
ch2 = imrotate(ch2, rot, 'nearest', 'crop'); %rotate
ch2(ch2 == 0) = nan; % trick to not count zeros in mean
ch2 = ch2-1;

ch2 = nanmean(ch2(:, round(size(ch2,1)/2)-30:round(size(ch2,1)/2)+30, :),2);
ch2 = squeeze(ch2);
figure('Units', 'centimeters', 'Position', [5,5,50,30]); imagesc(ch2)
colormap('hot')

%% Draw wavefront


h = imline;

%% When happy proceed and calculate speed and lag

coord = h.getPosition(); % get coords from line
speed = ((coord(2,2)-coord(1,2))*ts.dx)/((coord(2,1)-coord(1,1))*ts.dt) % calculate velocity

mergimg = imfuse(ch1, ch2, 'ColorChannels',[2 1 0]); % lag komposittbilde av to kanaler

imshow(mergimg) % Show this image

%using threshold of median+0.1*max: 
for i = 1:size(mergimg, 1)
    ch1_start(i) = find(ch1(i,:) > (0.1*(max(ch1(i,:))-median(ch1(i,:)))+median(ch1(i,:))), 1, 'first');
    ch2_start(i) = find(ch2(i,:) > (0.1*(max(ch2(i,:))-median(ch2(i,:)))+median(ch2(i,:))), 1, 'first');
end

hold on; 
scatter(ch1_start, 1:i,'*') %scatter startpoint

hold on; 
scatter(ch2_start, 1:i, '+')
df = (ch2_start-ch1_start)*ts.dt;
df(df < -1.5) = [];
timelag = (sum(df)/length(df))


%% lagre timelag og speed
ts.save_var("timelag", timelag);
ts.save_var("wavespeed", speed);


