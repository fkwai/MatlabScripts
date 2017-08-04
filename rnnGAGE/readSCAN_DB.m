function [soilM,tnum]=readSCAN_DB(sID,varargin)
% read SCAN data base of given site. varargin{1} -> year list
% example:
% sID=15;
% yrLst=2015:2017;

yrLst=[];
if ~isempty(varargin)
    yrLst=varargin{1};
end

global kPath
dataFolder=[kPath.SCAN,'Daily',kPath.s];
if isempty(yrLst)
    fileLst=dir([dataFolder,num2str(sID),'-y*.csv']);
    fileNameLst={fileLst.name;};
else
    fileNameLst=cell(length(yrLst),1);
    for k=1:length(yrLst)
        fileNameLst{k}=[num2str(sID),'-y',num2str(yrLst(k)),'.csv'];
    end
end

%% read Data
nFile=length(fileNameLst);
soilM=[];
tnum=[];
for k=1:nFile
    fileName=[dataFolder,fileNameLst{k}];
    if exist(fileName, 'file')
        [soilM_tmp,tnum_tmp]=readSCAN(fileName);
        soilM=[soilM;soilM_tmp];
        tnum=[tnum;tnum_tmp];
    end
end

