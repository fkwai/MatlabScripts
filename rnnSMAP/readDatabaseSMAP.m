function [xData,xStat,xDataNorm] = readDatabaseSMAP(dataName,varName,varargin)
%read new SMAP database of given varName. Read time series variables only.
% varargin{1} - root Database Folder,,default to be kPath.DBSMAP_L3


global kPath
if isempty(varargin)
    rootDB=kPath.DBSMAP_L3;
else
    rootDB=varargin{1};
end

%% read subset index
subsetFile=[rootDB,'Subset',kPath.s,dataName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
C = textscan(fid,'%f');
indSub=C{1};
fclose(fid);

%% read var
if indSub==-1
    xFile=[rootDB,dataName,kPath.s,varName,'.csv'];
    xStatFile=[rootDB,dataName,kPath.s,varName,'_stat.csv'];
    xData=csvread(xFile);
    xStat=csvread(xStatFile);
    xData(xData==-9999)=nan;
    xData=xData';
    xDataNorm=(xData-xStat(3))./xStat(4);
else
    error('Kuai: go code for index subset')
end


end

