global kPath
outFolder=[kPath.OutSMAP_L3,'CONUSs4f1',kPath.s];
trainName='CONUSs4f1';
testName='CONUSs4f1';
epoch=500;

opt=1;
stat='rmse';
unitStr='[-]';
figName='RMSE_train_time';
colorRange=[0,0.1];
titleStr='RMSE Between SMAP and LSTM Predictions';

dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);
shapefile='H:\Kuai\map\USA.shp';
figFolder='H:\Kuai\rnnSMAP\paper\';
% [outTrain,outTest,covMethod]=testRnnSMAP_readData(...
%     outFolder,trainName,testName,epoch);


statLSTM{1}=statCal(outTrain.yLSTM,outTrain.ySMAP);
statLSTM{2}=statCal(outTest.yLSTM,outTest.ySMAP);
[gridStatLSTM,xx,yy] = data2grid( statLSTM{opt}.(stat),crd(:,2),crd(:,1));
[lon,lat]=meshgrid(xx,yy);
data=gridStatLSTM;

h=showMap(data,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr)

suffix = '.eps';
fname=[figFolder,figName];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);



