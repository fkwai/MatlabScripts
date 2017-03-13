function dataSMAP_hourly2daily( tDBFolder,tDBFolderDaily,varargin )
% transfer hourly SMAP database (tDB) to daily data. 
% varargin{1} -> processed ind list

% example:
% indLst=csvread('E:\Kuai\rnnSMAP\output\indFile\CONUS.csv');
% tDBFolder='Y:\Kuai\rnnSMAP\Database\tDB_SMPq_Anomaly\';

% script:
% indLst=csvread('E:\Kuai\rnnSMAP\output\indFile\CONUS.csv');
% saveFolder='E:\Kuai\rnnSMAP\Database\';
% dataFolder='Y:\Kuai\rnnSMAP\Database\';
% fieldStr={'SMPq_Anomaly','soilM_Anomaly','Evap','Rainf','Tair','Wind','PSurf','Canopint','Snowf'};
% for k=1:length(fieldStr)
%     tDBFolder=[dataFolder,'tDB_',fieldStr{k},'\'];
%     tDBFolderDaily=[saveFolder,'tDB_',fieldStr{k},'_Daily\'];
%     dataSMAP_hourly2daily( tDBFolder,tDBFolderDaily,indLst )
% end

indLst=[1:243003];
if ~isempty(varargin)
    indLst=varargin{1};
end


if ~exist(tDBFolderDaily, 'dir')
    mkdir(tDBFolderDaily);
end
if ~exist([tDBFolderDaily,'\data\'], 'dir')
    mkdir([tDBFolderDaily,'\data\']);
end

%% time
tInd=csvread([tDBFolder,'\tIndex.csv']);
tStr=num2str(tInd,'%8.2f');
tnum=datenum(tStr,'yyyymmdd.HH');
nt=length(tnum);
tnumD=tnum(1:8:end);
tstr=datestr(tnumD,'yyyymmdd');

tfile=[tDBFolderDaily,'\tIndex.csv'];
dlmwrite(tfile, str2num(tstr),'precision','%8.0f');

%% crd
crdAll=csvread([tDBFolder,'\crdIndex.csv']);
crd=crdAll(indLst,:);
crdfile=[tDBFolderDaily,'crdIndex.csv'];
dlmwrite(crdfile, crd,'precision',8);

%% stat
copyfile([tDBFolder,'\stat.csv'],[tDBFolderDaily,'\stat.csv'])

%% data
parfor k=1:length(indLst)
    ind=indLst(k);    
    dataH=csvread([tDBFolder,'\data\',sprintf('%06d',ind),'.csv']);
    dataH=dataH(1:nt);
    dataH(dataH==-9999)=nan;
    dataD=nanmean(reshape(dataH,[8,nt/8]));
    dataD(isnan(dataD))=-9999;
    outFile=[tDBFolderDaily,'\data\',sprintf('%06d',ind),'.csv'];
    dlmwrite(outFile, dataD','precision',8);
end

end

