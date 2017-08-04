
%% read SMAP
maskFile=[kPath.SMAP,'maskSMAP_CONUS.mat'];
maskMat=load(maskFile);
[gridSMAPtemp,xx,yy,tSMAP]=csv2grid_SMAP('H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\CONUS\','SMAP');

nD=3;
[C,indX,indX0]=intersect(nDigit(xx,nD),nDigit(maskMat.lon,nD),'stable');
[C,indY,indY0]=intersect(nDigit(yy,nD),nDigit(maskMat.lat,nD),'stable');
gridSMAP=zeros(length(maskMat.lat),length(maskMat.lon),length(tSMAP))*nan;
gridSMAP(indY0,indX0,:)=gridSMAPtemp(indY,indX,:);

%% read NLDAS
file1='H:\Kuai\rnnSMAP\NLDAS_SOILM\LSOIL_NOAH_surf2.mat';
matNLDAS1=load(file1);
file2='H:\Kuai\rnnSMAP\NLDAS_SOILM\LSOIL_NOAH_surf.mat';
matNLDAS2=load(file2);

[C,indT,indT0]=intersect(matNLDAS1.tnum,tSMAP,'stable');
gridNLDAS1=matNLDAS1.data(:,:,indT);
gridNLDAS2=matNLDAS2.data(:,:,indT);

%% comp
gridDiff=gridNLDAS1-gridNLDAS2;
gridDiff1=gridNLDAS1-gridSMAP;
gridDiff2=gridNLDAS2-gridSMAP;
gridRMSE1=nanmean(gridDiff1.^2,3).^0.5;
gridRMSE2=nanmean(gridDiff2.^2,3).^0.5;

%% stat
[ny,nx,nt]=size(gridSMAP);
indMask=find(maskMat.mask==1);

dataSMAP_All=reshape(gridSMAP,[ny*nx,nt]);
dataSMAP=dataSMAP_All(indMask,:);
dataNLDAS1_All=reshape(gridNLDAS1,[ny*nx,nt]);
dataNLDAS1=dataNLDAS1_All(indMask,:);
dataNLDAS2_All=reshape(gridNLDAS2,[ny*nx,nt]);
dataNLDAS2=dataNLDAS2_All(indMask,:);

tTest=367:732;
stat1=statCal(dataNLDAS1(:,tTest)',dataSMAP(:,tTest)');
stat2=statCal(dataNLDAS2(:,tTest)',dataSMAP(:,tTest)');
var='bias';
plotData=[stat1.(var),stat2.(var)];
boxplot(plotData,'Labels',{'interp','top'});
ylim([-0.1,0.1])
hline=refline([0,0]);

%% Bias map LSTM - NLDAS -> 1b
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
[yNLDAS1_All,yNLDAS1_stat] = readDatabaseSMAP(trainName,'LSOIL_surf');
[yNLDAS2_All,yNLDAS2_stat] = readDatabaseSMAP(trainName,'LSOIL');

ySMAP=ySMAP_All(tTest,:);
meanSMAP=ySMAP_stat(3);
stdSMAP=ySMAP_stat(4);
yLSTM=(yLSTM_test).*stdSMAP+meanSMAP;
yNLDAS1=yNLDAS1_All(tTest,:);
yNLDAS2=yNLDAS2_All(tTest,:)./100;
statLSTM=statCal(yLSTM,ySMAP);
statNLDAS1=statCal(yNLDAS1,ySMAP);
statNLDAS2=statCal(yNLDAS2,ySMAP);

plotData=abs(statLSTM.bias)-abs(statNLDAS2.bias);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='| Bias(LSTM) minus Bias(Noah) |';
colorRange=[-0.3,0.1];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)

%% TS Map