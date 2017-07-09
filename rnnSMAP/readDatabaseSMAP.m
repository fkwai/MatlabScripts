function [xOut,xStat] = readDatabaseSMAP( dataName, varName )
%read new SMAP database of given varName. Read time series variables only. 

global kPath
dataFolder=kPath.DBSMAP_L3;

%% read var
xFile=[dataFolder,dataName,kPath.s,varName,'.csv'];
xStatFile=[dataFolder,dataName,kPath.s,varName,'_stat.csv'];
xData=csvread(xFile);
xStatData=csvread(xStatFile);
xData(xData==-9999)=nan;
%[grid,xx,yy] = data2grid3d( yData,lon,lat);    % testify
xOut=xData';
xStat=xStatData;


end

