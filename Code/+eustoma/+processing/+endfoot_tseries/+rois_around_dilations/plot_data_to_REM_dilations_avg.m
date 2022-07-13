begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_to_REM_dilation'));
ts = ts(ts.has_var('diam_to_REM_dilation'));

%%
roi_to_REM_dilation = ts.load_var('roi_to_REM_dilation');
roi_to_REM_dilation = cat(1, roi_to_REM_dilation{:});

roi_to_REM_dilation_struct = ts(1).load_var('roi_to_REM_dilation_struct');

roi_to_rem_t = roi_to_REM_dilation_struct.t;

% Pick out the roi signals
start_sig = roi_to_REM_dilation.roi_to_start;
end_sig = roi_to_REM_dilation.roi_to_end;
% Remove all rows that contain NaN values.
start_sig(isnan(start_sig(:,1)),:) = [];
end_sig(isnan(end_sig(:,1)),:) = [];

roi_to_rem_start_avg = mean(start_sig,1);
roi_to_rem_end_avg = mean(end_sig,1);

N_episodes_start = size(start_sig,1);
N_episodes_end = size(end_sig,1);

roi_to_rem_start_std = std(start_sig,[],1);
roi_to_rem_start_confidence = 1.96 * roi_to_rem_start_std / sqrt(N_episodes_start);

roi_to_rem_end_std = std(end_sig,[],1);
roi_to_rem_end_confidence = 1.96 * roi_to_rem_end_std / sqrt(N_episodes_end);

%% Calculate diameter transitions
diam_to_REM_dilation = ts.load_var('diam_to_REM_dilation');
diam_to_REM_dilation = cat(1, diam_to_REM_dilation{:});

diam_to_REM_dilation_struct = ts(1).load_var('diam_to_REM_dilation_struct');

diam_to_REM_t = diam_to_REM_dilation_struct.t;

% Pick out the traces.
start_sig = diam_to_REM_dilation.diam_to_start;
end_sig = diam_to_REM_dilation.diam_to_end;
% Remove all rows that contain NaN values.
start_sig(isnan(start_sig(:,1)),:) = [];
end_sig(isnan(end_sig(:,1)),:) = [];

N_diam_to_REM_start = size(start_sig,1);
N_diam_to_REM_end = size(end_sig,1);

diam_to_REM_start_avg = mean(start_sig,1);
diam_to_REM_start_std = std(start_sig,[],1);
diam_to_REM_start_confidence = 1.96 * diam_to_REM_start_std / sqrt(N_diam_to_REM_start);

diam_to_REM_end_avg = mean(end_sig,1);
diam_to_REM_end_std = std(end_sig,[],1);
diam_to_REM_end_confidence = 1.96 * diam_to_REM_end_std / sqrt(N_diam_to_REM_end);

%%

f = figure;
f.Position(3:4) = [1200,1200];
tiledlayout(4,1,"Padding","tight","TileSpacing","tight")

nexttile
p = plot(roi_to_rem_t,roi_to_rem_start_avg,'r');
yucca.plot.plot_around_line(p,roi_to_rem_start_confidence)
title(sprintf('ROI to start of REM dilation (average +/- 1.96 sem), N episodes = %.f',N_episodes_start))
hold on
y = ylim;
plot([0,0],[y(1),y(2)],'--k');
ylabel('Ratio difference from transition');
xlim([roi_to_rem_t(1),roi_to_rem_t(end)]);

nexttile
p = plot(diam_to_REM_t,diam_to_REM_start_avg,'r');
yucca.plot.plot_around_line(p,diam_to_REM_start_confidence)
title(sprintf('Diameter to start of REM dilation (average +/- 1.96 sem), N episodes + vessels = %.f',N_diam_to_REM_start))
hold on
y = ylim;
plot([0,0],[y(1),y(2)],'--k');
ylabel('Diameter (um)');
xlim([diam_to_REM_t(1),diam_to_REM_t(end)]);

nexttile
p = plot(roi_to_rem_t,roi_to_rem_end_avg,'g');
yucca.plot.plot_around_line(p,roi_to_rem_end_confidence)
title(sprintf('ROI to end of REM dilation (average +/- 1.96 sem), N episodes = %.f',N_episodes_end))
hold on
y = ylim;
plot([0,0],[y(1),y(2)],'--k');
ylabel('Ratio difference from transition');
xlim([roi_to_rem_t(1),roi_to_rem_t(end)]);

nexttile
p = plot(diam_to_REM_t,diam_to_REM_end_avg,'g');
yucca.plot.plot_around_line(p,diam_to_REM_end_confidence)
title(sprintf('Diameter to end of REM dilation (average +/- 1.96 sem), N episodes + vessels = %.f',N_diam_to_REM_end))
hold on
y = ylim;
plot([0,0],[y(1),y(2)],'--k');
ylabel('Diameter (um)');
xlim([diam_to_REM_t(1),diam_to_REM_t(end)]);
xlabel('Seconds from REM dilation (s)');

filename = fullfile(eustoma.get_plot_path,"Endfeet REM associated dilation avg", ...
    "REM transition");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)

%% Write ROIs to table
roi_to_rem_t = roi_to_rem_t';

roi_to_rem_start_avg = roi_to_rem_start_avg';
roi_to_rem_start_std = roi_to_rem_start_std';
roi_to_rem_start_confidence = roi_to_rem_start_confidence';

roi_to_rem_end_avg = roi_to_rem_end_avg';
roi_to_rem_end_std = roi_to_rem_end_std';
roi_to_rem_end_confidence = roi_to_rem_end_confidence';

filename = fullfile(eustoma.get_plot_path,"Endfeet REM associated dilation avg", ...
    "ROI to REM transition.csv");

roi_to_rem_table = table(roi_to_rem_t, ...
    roi_to_rem_start_avg,roi_to_rem_start_std,roi_to_rem_start_confidence, ...
    roi_to_rem_end_avg,roi_to_rem_end_std,roi_to_rem_end_confidence);
writetable(roi_to_rem_table,filename);

%% Write diameter to table
diam_to_REM_t = diam_to_REM_t';

diam_to_REM_start_avg = diam_to_REM_start_avg';
diam_to_REM_start_std = diam_to_REM_start_std';
diam_to_REM_start_confidence = diam_to_REM_start_confidence';

diam_to_REM_end_avg = diam_to_REM_end_avg';
diam_to_REM_end_std = diam_to_REM_end_std';
diam_to_REM_end_confidence = diam_to_REM_end_confidence';

filename = fullfile(eustoma.get_plot_path,"Endfeet REM associated dilation avg", ...
    "diameter to REM transition.csv");
diam_to_REM_table = table(diam_to_REM_t, ...
    diam_to_REM_start_avg,diam_to_REM_start_std,diam_to_REM_start_confidence, ...
    diam_to_REM_end_avg,diam_to_REM_end_std,diam_to_REM_end_confidence);
writetable(diam_to_REM_table,filename);

%% Calculate onset of diameter

binwidth = round(diam_to_REM_dilation_struct.fs);
kernel = ones(binwidth,1) / binwidth;

rows = height(diam_to_REM_dilation);
tbls = cell(rows,1);
for i = 1:rows
    t = diam_to_REM_dilation_struct.t(1:binwidth:end)';
    
    x = diam_to_REM_dilation.diam_to_start(i,:)';
    x = conv(x,kernel,'same');
    x = x(1:binwidth:end);
    diam_to_start = x;
    
    tbls{i} = table(t,diam_to_start);
end
tbl = cat(1,tbls{:});
tbl.t = round(tbl.t);
tbl(tbl.t < -20,:) = [];
tbl(tbl.t >  20,:) = [];
tbl.t = categorical(tbl.t);

model = fitlm(tbl,"diam_to_start ~ t");

model.plot()
title("Diameter aligned to start of REM associated dilation")
hold on
legend("AutoUpdate","Off")
for i = 1:height(model.Coefficients)
    if model.Coefficients.pValue(i) < 0.05
        plot(i,0,"*k","MarkerSize",10)
    end
end
f = gcf;
f.Position(3:4) = [1100,600];

filename = fullfile(eustoma.get_plot_path,"Endfeet REM associated dilation avg", ...
    "Stats - Diameter to start");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% Calculate onset of roi

binwidth = round(roi_to_REM_dilation_struct.fs);
kernel = ones(binwidth,1) / binwidth;

rows = height(roi_to_REM_dilation);
tbls = cell(rows,1);
for i = 1:rows
    t = roi_to_REM_dilation_struct.t(1:binwidth:end)';
    
    x = roi_to_REM_dilation.roi_to_start(i,:)';
    x = conv(x,kernel,'same');
    x = x(1:binwidth:end);
    roi_to_start = x;
    
    tbls{i} = table(t,roi_to_start);
end
tbl = cat(1,tbls{:});
tbl.t = round(tbl.t);
tbl(tbl.t < -20,:) = [];
tbl(tbl.t >  20,:) = [];
tbl.t = categorical(tbl.t);

model = fitlm(tbl,"roi_to_start ~ t");

figure
model.plot()
title("ROI aligned to start of REM associated dilation")
hold on
legend("AutoUpdate","Off")
for i = 1:height(model.Coefficients)
    if model.Coefficients.pValue(i) < 0.05
        plot(i,0,"*k","MarkerSize",10)
    end
end

f = gcf;
f.Position(3:4) = [1100,600];

filename = fullfile(eustoma.get_plot_path,"Endfeet REM associated dilation avg", ...
    "Stats - ROI to start");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)

%% Calculate onset of diameter

binwidth = round(diam_to_REM_dilation_struct.fs);
kernel = ones(binwidth,1) / binwidth;

rows = height(diam_to_REM_dilation);
tbls = cell(rows,1);
for i = 1:rows
    t = diam_to_REM_dilation_struct.t(1:binwidth:end)';
    
    x = diam_to_REM_dilation.diam_to_end(i,:)';
    x = conv(x,kernel,'same');
    x = x(1:binwidth:end);
    diam_to_end = x;
    
    tbls{i} = table(t,diam_to_end);
end
tbl = cat(1,tbls{:});
tbl.t = round(tbl.t);
tbl(tbl.t < -20,:) = [];
tbl(tbl.t >  20,:) = [];
tbl.t = categorical(tbl.t);

model = fitlm(tbl,"diam_to_end ~ t");

model.plot()
title("Diameter aligned to end of REM associated dilation")
hold on
legend("AutoUpdate","Off")
for i = 1:height(model.Coefficients)
    if model.Coefficients.pValue(i) < 0.05
        plot(i,0,"*k","MarkerSize",10)
    end
end
f = gcf;
f.Position(3:4) = [1100,600];

filename = fullfile(eustoma.get_plot_path,"Endfeet REM associated dilation avg", ...
    "Stats - Diameter to end");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)

%% Calculate onset of roi

binwidth = round(roi_to_REM_dilation_struct.fs);
kernel = ones(binwidth,1) / binwidth;

rows = height(roi_to_REM_dilation);
tbls = cell(rows,1);
for i = 1:rows
    t = roi_to_REM_dilation_struct.t(1:binwidth:end)';
    
    x = roi_to_REM_dilation.roi_to_end(i,:)';
    x = conv(x,kernel,'same');
    x = x(1:binwidth:end);
    roi_to_end = x;
    
    tbls{i} = table(t,roi_to_end);
end
tbl = cat(1,tbls{:});
tbl.t = round(tbl.t);
tbl(tbl.t < -20,:) = [];
tbl(tbl.t >  20,:) = [];
tbl.t = categorical(tbl.t);

model = fitlm(tbl,"roi_to_end ~ t");

figure
model.plot()
title("ROI aligned to start of REM associated dilation")
hold on
legend("AutoUpdate","Off")
for i = 1:height(model.Coefficients)
    if model.Coefficients.pValue(i) < 0.05
        plot(i,0,"*k","MarkerSize",10)
    end
end

f = gcf;
f.Position(3:4) = [1100,600];

filename = fullfile(eustoma.get_plot_path,"Endfeet REM associated dilation avg", ...
    "Stats - ROI to end");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
