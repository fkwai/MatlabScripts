function out = postRnnGlobal_load(outName,dataName,yrOpt,varargin)
%POSTRNNSMAP_LOAD 
% load data for LSTM simulations
% yrOpt = [start year , end year];

global kPath

varinTab={'rootOut',kPath.OutSMAP_L3_Global;...
    'rootDB',kPath.DBSMAP_L3_Global;...
    'epoch',0;...
    'modelField','SoilMoi0-10';...
    'readModel',1;...
    'readSMAP',1;...
    'drBatch',0;...
    };
[rootOut,rootDB,epoch,modelField,readModel,readSMAP,drBatch]=...
    internal.stats.parseArgs(varinTab(:,1),varinTab(:,2),varargin{:});

opt=readRnnOpt(outName,rootOut);
if epoch==0
    epoch=opt.nEpoch;
end
yrLst=yrOpt(1):yrOpt(end);

%% read SMAP
if readSMAP
    %disp(['read SMAP in ',outName])
    [ySMAP,~,crd,tnum] = readDB_Global(dataName,'SMAP_AM','rootDB',rootDB,'yrLst',yrLst);    
    out.ySMAP=ySMAP;
end

%% read model soilM
if readModel    
    [xSoilm,~] = readDB_Global(dataName,modelField,'rootDB',rootDB,'yrLst',yrLst);    
    out.yGLDAS=xSoilm./100; % hard code
end

%% read LSTM
%disp(['read LSTM of ',outName])
yLSTM=readRnnPred(outName,dataName,epoch,[yrLst(1),yrLst(end)],'rootOut',rootOut);
out.yLSTM=yLSTM;
if drBatch~=0
    yLSTM_batch=readRnnPred(outName,dataName,epoch,[yrLst(1),yrLst(end)],'rootOut',rootOut,'drBatch',drBatch);
    out.yLSTM_batch=yLSTM_batch;
end

%% read time and crd
out.crd=crd;
out.tnum=tnum;





