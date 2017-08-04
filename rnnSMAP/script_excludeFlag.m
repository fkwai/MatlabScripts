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
imagesc(gridData)

% 
% shapefile='H:\Kuai\map\USA.shp';
% colorRange=[0,1];
% [h,cmap]=showMap(gridData,yy,xx,'colorRange',colorRange,'shapefile',shapefile);
% colormap(cmap)
