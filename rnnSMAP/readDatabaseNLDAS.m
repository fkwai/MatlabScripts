function [xData,xStat,xDataNorm] = readDatabaseNLDAS(dataName,varName)

dirDB='H:\Kuai\rnnSMAP\Database_NLDASgrid\';

xFile=[dirDB,dataName,'\',varName,'.csv'];
xStatFile=[dirDB,dataName,'\',varName,'_stat.csv'];
xData=csvread(xFile);
xStat=csvread(xStatFile);
xData(xData==-9999)=nan;
xData=xData';
xDataNorm=(xData-xStat(3))./xStat(4);

end

