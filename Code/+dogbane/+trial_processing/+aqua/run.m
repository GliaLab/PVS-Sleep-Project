function run(trial)

ts = trial.tseries;

start_time = datetime(clock);

%%
begonia.util.logging.vlog(2,'Loading recording');
mat_orig = ts.get_mat(1,1);
mat_orig = mat_orig(:,:,:);
%%
begonia.util.logging.vlog(2,'Resampling');
merge_frames = 10;
new_frames = floor(size(mat_orig,3) / merge_frames);
datOrg = zeros(size(mat_orig,1),size(mat_orig,2),new_frames,'single');
begonia.util.logging.backwrite();
for i = 1:new_frames
    begonia.util.logging.backwrite(2,'Frame %d/%d',i,new_frames);

    datOrg(:,:,i) = single(mean(mat_orig(:,:,(i-1)*merge_frames+1:i*merge_frames),3));
end
clear mat;

% datOrg = datOrg(:,:,200:200+50);
%% 
opts.fileName = 'no_file.tif';
opts.minSize = 8;
opts.smoXY = 0.5000;
opts.thrARScl = 3;
opts.thrTWScl = 2;
opts.thrExtZ = 1;
opts.cDelay = 2;
opts.cRise = 2;
opts.gtwSmo = 1;
opts.maxStp = 11;
opts.zThr = 2;
opts.ignoreMerge = 1;
opts.mergeEventDiscon = 0;
opts.mergeEventCorr = 0;
opts.mergeEventMaxTimeDif = 2;
opts.regMaskGap = 5;
opts.usePG = 1;
opts.cut = 200;
opts.movAvgWin = 25;
opts.extendSV = 1;
opts.legacyModeActRun = 1;
opts.getTimeWindowExt = 50;
opts.seedNeib = 1;
opts.seedRemoveNeib = 2;
opts.thrSvSig = 4;
opts.gapExt = 5;
opts.superEventdensityFirst = 1;
opts.gtwGapSeedRatio = 4;
opts.gtwGapSeedMin = 5;
opts.cOver = 0.2000;
opts.minShow1 = 0.2000;
opts.minShowEvtGUI = 0;
opts.ignoreTau = 1;
opts.correctTrend = 1;
opts.extendEvtRe = 0;
opts.propthrmin = 0.2000;
opts.propthrstep = 0.1000;
opts.propthrmax = 0.8000;
opts.frameRate = 1 / ts.dt / merge_frames;
opts.spatialRes = ts.dx;
opts.varEst = 0.0053;
opts.fgFluo = 0;
opts.bgFluo = 0;
opts.northx = 0;
opts.northy = 1;
opts.skipSteps = 1;

opts.total_frames = new_frames;
%% prep1
begonia.util.logging.vlog(2,'Aqua thing');
bdCrop = opts.regMaskGap;

% Our data is stored in 16 bit, but is recorded in 12 bit. 
maxImg = 2^12 - 1; 

maxDat = max(datOrg(:));
datOrg = datOrg/maxDat;
datOrg = datOrg(bdCrop+1:end-bdCrop,bdCrop+1:end-bdCrop,:);
datOrg(datOrg<0) = 0;

datOrg = datOrg + randn(size(datOrg))*1e-4;
opts.sz = size(datOrg);
opts.maxValueDepth = maxImg;
opts.maxValueDat = maxDat;
%%
begonia.util.logging.vlog(2,'Aqua start of processing');
[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);  % foreground and seed detection
[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection

[riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events
[ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);

% fitler by significance level
mskx = ftsLst.curve.dffMaxZ>opts.zThr;
dffMatFilterZ = dffMat(mskx,:);
evtLstFilterZ = evtLst(mskx);
tBeginFilterZ = ftsLst.curve.tBegin(mskx);
riseLstFilterZ = riseLst(mskx);

% % merging (glutamate)
% evtLstMerge = burst.mergeEvt(evtLstFilterZ,dffMatFilterZ,tBeginFilterZ,opts,[]);
% 
% % reconstruction (glutamate)
% if opts.extendSV==0 || opts.ignoreMerge==0 || opts.extendEvtRe>0
%     [riseLstE,datRE,evtLstE] = burst.evtTopEx(dat,dF,evtLstMerge,opts);
% else
%     riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;
% end
riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;

% feature extraction
[ftsLstE,dffMatE,dMatE] = fea.getFeaturesTop(datOrg,evtLstE,opts);
ftsLstE = fea.getFeaturesPropTop(dat,datRE,evtLstE,ftsLstE,opts);
%%
ts.save_var('aqua_events_struct',ftsLstE);
ts.save_var('aqua_opts',opts);
%%
aqua_res = fea.gatherRes(datOrg,opts,evtLstE,ftsLstE,dffMatE,dMatE,riseLstE,datRE);

ts.save_var(aqua_res);

end_time =  datetime(clock);

aqua_processing_time = seconds(end_time - start_time);
ts.save_var(aqua_processing_time);
end

