
%% arguments
global kPath
outName='CONUSs4f1';
trainName='CONUSs4f1';
testName='CONUSs4f1';
epoch=500;

figFolder='H:\Kuai\rnnSMAP\paper\';
opt=2;
unitStr='[-]';
suffix = '.jpg';

%% read Data
dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);
shapefile='H:\Kuai\map\USA.shp';
[outTrain,outTest,covMethod]=testRnnSMAP_readData(outName,trainName,testName,epoch);

statLSTM{1}=statCal(outTrain.yLSTM,outTrain.ySMAP);
statLSTM{2}=statCal(outTest.yLSTM,outTest.ySMAP);

statNLDAS{1}=statCal(outTrain.yGLDAS,outTrain.ySMAP);
statNLDAS{2}=statCal(outTest.yGLDAS,outTest.ySMAP);

%% Bias LSTM -> 1a
plotData=statLSTM{opt}.bias;
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='Bias Between SMAP and LSTM Predictions';
colorRange=[-0.1,0.1];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_biasMap_LSTM'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

%% Bias LSTM - NLDAS -> 1b
plotData=abs(statLSTM{opt}.bias)-abs(statNLDAS{opt}.bias);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='Bias of LSTM - Bias of NOAH';
colorRange=[-0.3,0.1];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_biasMap_LSTM_NLDAS'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

%% Rsq LSTM -> 1c
plotData=statLSTM{opt}.rsq;
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='R^2 Between SMAP and LSTM Predictions';
colorRange=[0,1];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_RsqMap_LSTM'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

%% Rsq LSTM - NLDAS -> 1d
plotData=abs(statLSTM{opt}.rsq)-abs(statNLDAS{opt}.rsq);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='R^2 of LSTM - R^2 of NOAH';
colorRange=[-0.5,0.5];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_RsqMap_LSTM_NLDAS'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

%% rmse LSTM -> 1e
plotData=statLSTM{opt}.rmse;
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='RMSE Between SMAP and LSTM Predictions';
colorRange=[0,0.1];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_rmseMap_LSTM'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

%% rmse LSTM - NLDAS -> 1f
plotData=abs(statLSTM{opt}.rmse)-abs(statNLDAS{opt}.rmse);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='RMSE of LSTM - RMSE of NOAH';
colorRange=[-0.3,0.1];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_rmseMap_LSTM_NLDAS'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);


