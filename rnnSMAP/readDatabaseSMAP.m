function [xData,xStat,xDataNorm] = readDatabaseSMAP(dataName,varName)
%read new SMAP database of given varName. Read time series variables only. 

global kPath
dataFolder=kPath.DBSMAP_L3;

%% read var
xFile=[dataFolder,dataName,kPath.s,varName,'.csv'];
xStatFile=[dataFolder,dataName,kPath.s,varName,'_stat.csv'];
xData=csvread(xFile);
xStat=csvread(xStatFile);
xData(xData==-9999)=nan;
xData=xData';
xDataNorm=(xData-xStat(3))./xStat(4);


end

