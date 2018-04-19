function [xData,xStat,crd,time] = readDB_Global(dataName,varName,varargin)
%read new SMAP database of given varName. Read time series variables only.
% varargin{1} - root Database Folder,,default to be kPath.DBSMAP_L3

global kPath
pnames={'rootDB','yrLst','const'};
dflts={kPath.DBSMAP_L3_Global,[],0};
[rootDB,yrLst,isConst]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

dirDB=[rootDB,filesep,dataName,filesep];

%% get year lst
dirLst=dir(dirDB);
if isempty(yrLst) && ~isConst
    for k=1:length(dirLst)
        if dirLst(k).isdir && ...
                ~strcmp(dirLst(k),'.') && ...
                ~strcmp(dirLst(k),'..') && ...
                ~strcmp(dirLst(k),'const')
            yrLst=[yrLst;str2num(dirLst(k).name)];
        end
    end
end

%% read subset index
subsetFile=[rootDB,filesep,'Subset',filesep,dataName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
C = textscan(fid,'%f');
indSub=C{1};
fclose(fid);

%% read var
time=[];
xData=[];
if indSub==-1
    if ~isConst        
        for iY=1:length(yrLst)
            tic
            yr=yrLst(iY);
            xFile=[dirDB,num2str(yr),filesep,varName,'.csv'];
            xDataYr=csvread(xFile);
            xDataYr=xDataYr';
            xDataYr(xDataYr==-9999)=nan;
            disp(['read ',varName,' year ',num2str(yr),' ',num2str(toc)])
            timeFile=[dirDB,num2str(yr),filesep,'time.csv'];
            tTemp=csvread(timeFile);
            time=[time;tTemp];
            xData=[xData;xDataYr];
        end
        xStatFile=[rootDB,filesep,'Statistics',filesep,varName,'_stat.csv'];
    else
        xFile=[dirDB,'const',filesep,varName,'.csv'];
        xData=csvread(xFile);
        xData(xData==-9999)=nan;
        xStatFile=[rootDB,filesep,'Statistics',filesep,'const_',varName,'_stat.csv'];
    end
    xStat=csvread(xStatFile);
else
    error('Kuai: go code for index subset')
end

%% read crd
crdFile=[dirDB,'crd.csv'];
crd=csvread(crdFile);

end

