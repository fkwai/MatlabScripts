function out = postRnnSMAP_load(outName,dataName,timeOpt,epoch,varargin)
%POSTRNNSMAP_LOAD 
% load data for LSTM simulations

pnames={'rootOut','rootDB','model'};
dflts={[],[],'Noah'};
[rootOut,rootDB,model]=...
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
disp('read SMAP')
[ySMAP,ySMAPStat] = readDatabaseSMAP(dataName,'SMAP',rootDB);
ySMAP=ySMAP(tData,:);
out.ySMAP=ySMAP;
lbSMAP=ySMAPStat(1);
ubSMAP=ySMAPStat(2);
meanSMAP=ySMAPStat(3);
stdSMAP=ySMAPStat(4);

%% read model soilM
[xSoilm,xSoilmStat] = readDatabaseSMAP(dataName,modelField,rootDB);
yGLDAS=xSoilm(tData,:)/100;
out.yGLDAS=yGLDAS;

%% read LSTM
disp('read LSTM')
dataOut=readRnnPred(outName,dataName,epoch,timeOpt,rootOut);
yLSTM=(dataOut).*stdSMAP+meanSMAP;
out.yLSTM=yLSTM;





