
global kPath
matMask=load([kPath.SMAP,'maskSMAP_L3.mat']);

field='TRMM';
[xData,xStat,crd,time] = readDB_Global('Globalv8f1',field,'yrLst',[2015]);
dataTRMM=nansum(xData,2);
[gridTRMM,xx,yy] = data2grid(dataTRMM,crd(:,2),crd(:,1));
[f,cmap]=showMap(gridTRMM,yy,xx,'colorRange',[0,1500]);

field='Prcp';
[xData,xStat,crd,time] = readDB_Global('Globalv8f1',field,'yrLst',[2015]);
dataGLDAS=nansum(xData,2);
[gridGLDAS,xx,yy] = data2grid(dataGLDAS,crd(:,2),crd(:,1));
[f,cmap]=showMap(gridGLDAS,yy,xx,'colorRange',[0,1500]);


field='flag_extraOrd';
[xData,xStat,crd,time] = readDB_Global('Globalv8f1',field,'const',1);
[grid,xx,yy] = data2grid(xData,crd(:,2),crd(:,1));
[f,cmap]=showMap(grid,yy,xx);
