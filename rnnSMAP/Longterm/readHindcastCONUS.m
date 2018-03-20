function [SMAP,LSTM,Noah] = readHindcastCONUS( productName,varargin)

varinTab={...
    'readSMAP',1;...
    'readLSTM',1;...
    'readModel',0;...
    };

[readSMAP,readLSTM,readModel]=...
    internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});

global kPath
if strcmp(productName,'surface')
    rootOut=kPath.OutSMAP_L3;
    rootDB=kPath.DBSMAP_L3;
    outName='fullCONUS_Noah2yr';
    target='SMAP';
    dataName='CONUS';
    testLst={'LongTerm8595','LongTerm9505','LongTerm0515','CONUS'};
    modelName='SOILM_0-10';
elseif strcmp(productName,'rootzone')
    rootOut=kPath.OutSMAP_L4;
    rootDB=kPath.DBSMAP_L4;
    outName='CONUSv4f1_rootzone';
    target='SMGP_rootzone';
    dataName='CONUSv4f1';
    testLst={'LongTerm8595v4f1','LongTerm9505v4f1','LongTerm0515v4f1','CONUSv4f1'};
    modelName='SOILM_0-100';
end

%% read SMAP
if readSMAP
    SMAP.v=readDB_SMAP(dataName,target,rootDB);
    SMAP.t=csvread([rootDB,dataName,filesep,'time.csv']);
    SMAP.crd=csvread([rootDB,dataName,filesep,'crd.csv']);
else
    SMAP=[];
end

%% read LSTM
if readLSTM
    LSTM.v=[];
    LSTM.t=[];
    LSTM.crd=csvread([rootDB,testLst{1},filesep,'crd.csv']);
    for k=1:length(testLst)
        tic
        vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',target);
        tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
        if k>1
            LSTM.v=[LSTM.v;vTemp(2:end,:)];
            LSTM.t=[LSTM.t;tTemp(2:end)];
        else
            LSTM.v=vTemp;
            LSTM.t=tTemp;
        end
        toc
    end
else
    LSTM=[];
end
%% Model
if readModel
    Noah.v=[];
    Noah.t=[];
    Noah.crd=csvread([rootDB,testLst{end},filesep,'crd.csv']);
    for k=1:length(testLst)
        tic
        vTemp=readDB_SMAP(testLst{k},modelName,rootDB);
        if strcmp(productName,'L3')
            vTemp=vTemp./100;
        elseif strcmp(productName,'rootzone')
            vTemp=vTemp./1000;
        end
        tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
        if k>1
            Noah.v=[Noah.v;vTemp(2:end,1:size(Noah.crd,1))];
            Noah.t=[Noah.t;tTemp(2:end)];
        else
            Noah.v=vTemp;
            Noah.t=tTemp;
        end
        toc
    end
else
    Noah=[];
end


%% remove some points
indErr=std(LSTM.v,[],1)<0.002;
if readSMAP
    SMAP.v(:,indErr)=[];
    SMAP.crd(indErr,:)=[];
end
if readLSTM
    LSTM.v(:,indErr)=[];
    LSTM.crd(indErr,:)=[];
end
if readModel
    Noah.v(:,indErr)=[];
    Noah.crd(indErr,:)=[];
end

end

