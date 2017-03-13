%%
outFolder='E:\Kuai\rnnSMAP\output\case3\';
trainName='CONUS_sub4';
testName='CONUS_sub4';
epoch=1000;
optSMAP=1;
optGLDAS=1;

[ySMAP,yLSTM,yGLDAS,yCov,covMethod]=testRnnSMAP_readData(...
    outFolder,trainName,testName,epoch,...
    'optSMAP',optSMAP,'optGLDAS',optGLDAS,'readCov',0);
testFile=[outFolder,'\',testName,'.csv'];
testInd=csvread(testFile);
ntrain=276;
nt=520;
t1=1:ntrain-1;
t2=ntrain:nt;
dirSMAP='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
crdFile=[dirSMAP,'crdIndex.csv'];
crdAll=csvread(crdFile);
crdTest=crdAll(testInd,:);
xSort=sort(unique(crdTest(:,1)));
cellsize=xSort(2)-xSort(1); %!!!may modify later

% stat='nash';
% statStr='Nash';
% colorRange=[-1,0.75];
stat='rmse';
statStr='Rmse';
colorRange=[0,0.1];

%% plot figure
figFolder='E:\Kuai\rnnSMAP\paper\';
shapefile='Y:\Maps\USA.shp';
statLSTM=statCal(yLSTM(t2,:,:),ySMAP(t2,:));
[gridStat,xx,yy] = data2grid(statLSTM.(stat),crdTest(:,2),crdTest(:,1),cellsize);
figure('Position',[0,0,1600,600])
titleStr=[statStr,' between SMAP and LSTM prediction'];
showGrid( gridStat,xx,yy,cellsize,'colorRange',colorRange,'shapefile',shapefile,...
    'titleStr',titleStr,'newFig',0)
addDegreeAxis()
suffix = '.eps';
fname=[figFolder,stat,'MapLSTM'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

statGLDAS=statCal(yGLDAS(t2,:,:),ySMAP(t2,:));
[gridStat,xx,yy] = data2grid(statGLDAS.(stat),crdTest(:,2),crdTest(:,1),cellsize);
figure('Position',[0,0,1600,600])
titleStr=[statStr,' between SMAP and GLDAS simulation'];
showGrid( gridStat,xx,yy,cellsize,'colorRange',colorRange,'shapefile',shapefile,...
    'titleStr',titleStr,'newFig',0)
addDegreeAxis()
suffix = '.eps';
fname=[figFolder,stat,'MapGLDAS'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);