%%
outFolder='Y:\Kuai\rnnSMAP\output\test_CONUS\';
trainName='indUSsub4';
testName='indUSsub4';
epoch=800;

[ySMAP,yLSTM,yGLDAS,yCov,covMethod]=testRnnSMAP_readData(outFolder,trainName,testName,epoch,'doAnorm',1);
testFile=[outFolder,'\',testName,'.csv'];
testInd=csvread(testFile);
ntrain=2209;
nt=4160;
t1=1:ntrain-1;
t2=ntrain:nt;
statLSTM=statCal(yLSTM(t2,:,:),ySMAP(t2,:));
dirSMAP='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
crdFile=[dirSMAP,'crdIndex.csv'];
crdAll=csvread(crdFile);
crdTest=crdAll(testInd,:);
xSort=sort(unique(crdTest(:,1)));
cellsize=xSort(2)-xSort(1); %!!!may modify later

% plot figure
figFolder='E:\Kuai\rnnSMAP\paper\';
shapefile='Y:\Maps\USA.shp';
statLSTM=statCal(yLSTM(t2,:,:),ySMAP(t2,:));
[gridStat,xx,yy] = data2grid(statLSTM.nash,crdTest(:,2),crdTest(:,1),cellsize);
figure('Position',[0,0,1600,600])
titleStr='RMSE between SMAP and LSTM prediction';
showGrid( gridStat,xx,yy,cellsize,'colorRange',[-0.2,0.8],'shapefile',shapefile,...
    'titleStr',titleStr,'newFig',0)
addDegreeAxis()
suffix = '.eps';
fname=[figFolder,'rmseMapLSTM'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

statGLDAS=statCal(yGLDAS(t2,:,:),ySMAP(t2,:));
[gridStat,xx,yy] = data2grid(statGLDAS.nash,crdTest(:,2),crdTest(:,1),cellsize);
figure('Position',[0,0,1600,600])
titleStr='RMSE between SMAP and GLDAS simulation';
showGrid( gridStat,xx,yy,cellsize,'colorRange',[-0.2,0.8],'shapefile',shapefile,...
    'titleStr',titleStr,'newFig',0)
addDegreeAxis()
suffix = '.eps';
fname=[figFolder,'rmseMapGLDAS'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);