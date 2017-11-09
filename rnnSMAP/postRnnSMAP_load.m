function out = postRnnSMAP_load(outName,dataName,timeOpt,epoch,varargin)
%POSTRNNSMAP_LOAD 
% load data for LSTM simulations

pnames={'rootOut','rootDB','model','readModel','readSMAP','drBatch'};
dflts={[],[],'Noah',1,1,0};
[rootOut,rootDB,model,readModel,readSMAP,drBatch]=...
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

%% read SMAP
if readSMAP
    disp(['read SMAP in ',outName])
    [ySMAP,ySMAPStat] = readDatabaseSMAP(dataName,'SMAP',rootDB);
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
    [xSoilm,xSoilmStat] = readDatabaseSMAP(dataName,modelField,rootDB);
    yGLDAS=xSoilm(tData,:)/100;
    out.yGLDAS=yGLDAS;
end

%% read LSTM
disp(['read LSTM of ',outName])
yLSTM=readRnnPred(outName,dataName,epoch,timeOpt,'rootOut',rootOut,'drBatch',drBatch);
out.yLSTM=yLSTM;





