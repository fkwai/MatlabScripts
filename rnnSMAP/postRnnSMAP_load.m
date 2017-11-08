function out = postRnnSMAP_load(outName,dataName,timeOpt,epoch,varargin)
%POSTRNNSMAP_LOAD 
% load data for LSTM simulations

pnames={'rootOut','rootDB','model','readModel','readSMAP'};
dflts={[],[],'Noah',1,1};
[rootOut,rootDB,model,readModel,readTarget]=...
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

if isempty(model)
    modelField='LSOIL_0-10';
else
    switch model
        case 'Noah'
            modelField='LSOIL_0-10';
        case 'MOS'
            modelField='SOILM_0-10_MOS';
    end
end


%% read SMAP
if readSMAP
    disp(['read SMAP in ',outName])
    [ySMAP,ySMAPStat] = readDatabaseSMAP(dataName,'SMAP',rootDB);
    ySMAP=ySMAP(tData,:);
    out.ySMAP=ySMAP;
    lbSMAP=ySMAPStat(1);
    ubSMAP=ySMAPStat(2);
    meanSMAP=ySMAPStat(3);
    stdSMAP=ySMAPStat(4);
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
dataOut=readRnnPred(outName,dataName,epoch,timeOpt,rootOut);
statFile=[kPath.DBSMAP_L3_CONUS,filesep,'SMAP_stat.csv'];
statSMAP=csvread(statFile);
meanSMAP=statSMAP(3);
stdSMAP=statSMAP(4);    
yLSTM=(dataOut).*stdSMAP+meanSMAP;
out.yLSTM=yLSTM;





