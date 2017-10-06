
%% arguments
global kPath
%{ 
%CP commented this out
outName='CONUSv4f1';
trainName='CONUSv4f1';
testNameT='CONUSv4f1';
%}
outName='fullCONUS02hS512';
trainName='CONUS';
testName='CONUS';

figFolder='H:\Kuai\rnnSMAP\paper\mapLSTM\';
mkdir(figFolder)
opt=2;
unitStr='[-]';
suffix = '.jpg';
global fsize
fsize=20

%% read Data
dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);
shapefile='H:\Kuai\map\USA.shp';
[outTrain,outTest,covMethod]=testRnnSMAP_readData(outName,trainName,testName,epoch,...
    'readCov',0,'readData',0);

statLSTM{1}=statCal(outTrain.yLSTM,outTrain.ySMAP);
statLSTM{2}=statCal(outTest.yLSTM,outTest.ySMAP);

statNLDAS{1}=statCal(outTrain.yGLDAS,outTrain.ySMAP);
statNLDAS{2}=statCal(outTest.yGLDAS,outTest.ySMAP);

statNN{1}=statCal(outTrain.yNN,outTrain.ySMAP);
statNN{2}=statCal(outTest.yNN,outTest.ySMAP);

%% Bias LSTM -> 1a
plotData=statLSTM{opt}.bias;
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='Bias(LSTM)';
colorRange=[-0.02,0.02];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'nLevel',8,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_biasMap_LSTM'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);


%% Bias LSTM - NLDAS -> 1b
plotData=abs(statLSTM{opt}.bias)-abs(statNLDAS{opt}.bias);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='|Bias(LSTM)| minus |Bias(Noah)|';
colorRange=[-0.2,0];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'nLevel',8,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_biasMap_LSTM_NLDAS'];
set(gcf, 'Renderer', 'zbuffer')
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% Rsq LSTM -> 1c
plotData=statLSTM{opt}.rsq;
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='R(LSTM)';
colorRange=[0.4,1]; openEnds = [1 0];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'nLevel',12,'openEnds',openEnds,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_RsqMap_LSTM'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);


%% Rsq LSTM - NLDAS -> 1d
plotData=abs(statLSTM{opt}.rsq)-abs(statNLDAS{opt}.rsq);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='R(LSTM) minus R(Noah)';
colorRange=[-0.6,0.6]; openEnds = [0 0];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'nLevel',12,'openEnds',openEnds,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_RsqMap_LSTM_NLDAS'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);


%% rmse LSTM -> 1e
plotData=statLSTM{opt}.rmse;
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='RMSE(LSTM)';
colorRange=[0,0.05];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'nLevel',10,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_rmseMap_LSTMh'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);


%% rmse LSTM - NN -> 1f
%plotData=abs(statLSTM{opt}.rmse)-abs(statNN{opt}.rmse);
plotData=abs(statLSTM{opt}.rmse)-abs(statNN{opt}.rmse);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='RMSE(LSTM) minus RMSE(NN)';
colorRange=[-0.03,0.01];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'nLevel',8,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_rmseMap_LSTM_NN'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% rmse LSTM - NLDAS -> 1g
%plotData=abs(statLSTM{opt}.rmse)-abs(statNN{opt}.rmse);
plotData=abs(statLSTM{opt}.rmse)-abs(statNLDAS{opt}.rmse);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='RMSE(LSTM) minus RMSE(Noah)';
colorRange=[-0.2,0];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'nLevel',8,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_rmseMap_LSTM_NLDAS'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
5;



