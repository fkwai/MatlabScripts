
suffix = '.jpg';
figFolder='H:\Kuai\rnnSMAP\paper\';


%% 1 Prcp map
trainName='CONUSs4f1';
dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);

[yRain_All,yRain_stat] = readDatabaseSMAP(trainName,'ARAIN');
[ySnow_All,ySnow_stat] = readDatabaseSMAP(trainName,'ASNOW');

plotData=mean(yRain_All'+ySnow_All',2)*365*24;
[gridData,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='Precipitation [mm]';
shapefile='H:\Kuai\map\USA.shp';
colorRange=[0,2000];
[h,cmap]=showMap(gridData,yy,xx,'colorRange',colorRange,'shapefile',shapefile,...
    'title',titleStr,'Position',[1,1,1600,1000]);
colormap(cmap)

fname=[figFolder,'fig_sup_Prcp'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

%% 2 raw values of R2(Noah) and Bias(Noah)
trainName='CONUSv4f1';
tTest=367:732;
dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);
shapefile='H:\Kuai\map\USA.shp';

[yNOAH_All,yNOAH_stat] = readDatabaseSMAP(trainName,'LSOIL_0-10');
[ySMAP_All,yNOAH_stat] = readDatabaseSMAP(trainName,'SMAP');

ySMAP=ySMAP_All(tTest,:);
yNOAH=yNOAH_All(tTest,:)./100;

statNOAH=statCal(yNOAH,ySMAP);

stat='rsq';
plotData=statNOAH.(stat);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='R(Noah)';
colorRange=[0,1];
openEnds = [0 0];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'openEnds',openEnds,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'\fig_rsqMap_NOAH'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

stat='bias';
plotData=statNOAH.(stat);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='Bias(Noah)';
colorRange=[-0.2,0.2]; 
nLevel=8;
[h,cmap]=showMap(gridStat,yy,xx,'nLevel',nLevel,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'\fig_biasMap_NOAH'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%% 3 SMAP quality flag
trainName='CONUS';
dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
fileSMAP=[dirData,'SMAP.csv'];
crd=csvread(fileCrd);

[yData_All,yData_stat] = readDatabaseSMAP(trainName,'flag_qualRec');
[ySMAP_All,ySMAP_stat] = readDatabaseSMAP(trainName,'SMAP');
yData_All(isnan(ySMAP_All))=nan;
plotData=nanmean(yData_All',2);
[gridData,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='Fraction of time with SMAP "Recommended Quality"';
shapefile='H:\Kuai\map\USA.shp';

temp=parula(22);
cmap=temp(11:end-1,:);
cmap(1,:)=[1,1,1];
openEnds = [0 0];
[h,cmap]=showMap(1-gridData,yy,xx,'colorRange',[0,1],'nLevel',10,'openEnds',openEnds,'shapefile',shapefile,...
    'title',titleStr,'Position',[1,1,1600,1000],'cmap',cmap);

fname=[figFolder,'fig_sup_qualFlag'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
