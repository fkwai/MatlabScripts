outName='CONUSs4f1_new';
trainName='CONUSs4f1';
testName='CONUSs4f1';
epoch=500;

dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);
tTest=367:732;
shapefile='H:\Kuai\map\USA.shp';

outFolder=[kPath.OutSMAP_L3,outName,kPath.s];
[yLSTM_train,yLSTM_test]=readRnnPred(outFolder,trainName,testName,epoch);
[ySMAP_All,ySMAP_stat] = readDatabaseSMAP(trainName,'SMAP');
[yNOAH_All,yNOAH_stat] = readDatabaseSMAP(trainName,'LSOIL');

ySMAP=ySMAP_All(tTest,:);
meanSMAP=ySMAP_stat(3);
stdSMAP=ySMAP_stat(4);
yLSTM=(yLSTM_test).*stdSMAP+meanSMAP;
yNOAH=yNOAH_All(tTest,:)./100;
statLSTM=statCal(yLSTM,ySMAP);
statNOAH=statCal(yNOAH,ySMAP);


[gridSMAP,xx,yy] = data2grid3d( ySMAP',crd(:,2),crd(:,1));
[gridLSTM,xx,yy] = data2grid3d( yLSTM',crd(:,2),crd(:,1));
[gridNOAH,xx,yy] = data2grid3d( yNOAH',crd(:,2),crd(:,1));


tsStr(1).grid=gridSMAP;
tsStr(1).t=1:size(gridSMAP,3);
tsStr(1).symb='xk';
tsStr(1).legendStr='SMAP';

tsStr(2).grid=gridLSTM;
tsStr(2).t=1:size(gridLSTM,3);
tsStr(2).symb='-r';
tsStr(2).legendStr='LSTM';

tsStr(3).grid=gridNOAH;
tsStr(3).t=1:size(gridNOAH,3);
tsStr(3).symb='-b';
tsStr(3).legendStr='NOAH';

showGrid(nanmean(gridLSTM,3),[length(yy):-1:1]',[1:length(xx)],1,'tsStr',tsStr,'yRange',[0,0.35])
