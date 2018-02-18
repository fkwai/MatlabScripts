function out = postRnnSMAP_load(outName,dataName,timeOpt,varargin)
%POSTRNNSMAP_LOAD 
% load data for LSTM simulations

pnames={'rootOut','rootDB','epoch','model','readModel','readSMAP','drBatch'};
dflts={[],[],0,'Noah',1,1,0};
[rootOut,rootDB,epoch,model,readModel,readSMAP,drBatch]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

global kPath
if isempty(rootOut)
    rootOut=kPath.OutSMAP_L3;
end
if isempty(rootDB)
    rootDB=kPath.DBSMAP_L3;
end

switch timeOpt
    case 1
        tData=1:366;
    case 2
        tData=367:732;
    case 3
        tData=1:732;
end

opt=readRnnOpt(outName,rootOut);
if epoch==0
    epoch=opt.nEpoch;
end

%% read SMAP
if readSMAP
    %disp(['read SMAP in ',outName])
    [ySMAP,~] = readDatabaseSMAP(dataName,'SMAP',rootDB);
    ySMAP=ySMAP(tData,:);
    out.ySMAP=ySMAP;
end

%% read model soilM
if readModel
    switch model
        case 'Noah'
            modelField='LSOIL_0-10';
        case 'MOS'
            modelField='SOILM_0-10_MOS';
        otherwise
            error('unseen model')
    end
    [xSoilm,~] = readDatabaseSMAP(dataName,modelField,rootDB);
    yGLDAS=xSoilm(tData,:)/100;
    out.yGLDAS=yGLDAS;
end

%% read LSTM
%disp(['read LSTM of ',outName])
yLSTM=readRnnPred(outName,dataName,epoch,timeOpt,'rootOut',rootOut);
out.yLSTM=yLSTM;
if drBatch~=0
    yLSTM_batch=readRnnPred(outName,dataName,epoch,timeOpt,'rootOut',rootOut,'drBatch',drBatch);
    out.yLSTM_batch=yLSTM_batch;
end

%% read time and crd
crd=csvread([rootDB,filesep,dataName,filesep,'crd.csv']);
timeAll=csvread([rootDB,filesep,dataName,filesep,'time.csv']);
tnum=timeAll(tData);
out.crd=crd;
out.tnum=tnum;





