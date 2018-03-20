function [SMAP,LSTM,dataPred] = readHindcastSite( siteName,productName,varargin)

varinTab={'pred',[];'drBatch',0};
[pred,drBatch]=internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});

global kPath
%% CRN
if strcmp(siteName,'CRN')
    if strcmp(productName,'surface')
        rootOut=kPath.OutSMAP_L3;
        rootDB=kPath.DBSMAP_L3;
        outName='fullCONUS_Noah2yr';
        smapName='CONUS_CRN';
        dataName='LongTerm_CRN';
        target='SMAP';
    elseif strcmp(productName,'rootzone')
        rootOut=kPath.OutSMAP_L4;
        rootDB=kPath.DBSMAP_L4;
        outName='CONUSv4f1_rootzone';
        smapName='CONUS_CRN';
        dataName='LongTerm_CRN';
        target='SMGP_rootzone';
    elseif strcmp(productName,'rootzonev4f1')
        rootOut=kPath.OutSMAP_L4;
        rootDB=kPath.DBSMAP_L4;
        outName='CONUSv4f1_rootzone';
        smapName='CONUSv4f1_CRN';
        dataName='LongTermv4f1_CRN';
        target='SMGP_rootzone';
    end    
end

%% Core Validation Site
if strcmp(siteName,'CoreSite')
    if strcmp(productName,'surface')
        rootOut=kPath.OutSMAP_L3;
        rootDB=kPath.DBSMAP_L3;
        outName='fullCONUS_Noah2yr';
        smapName='CONUS_Core';
        dataName='LongTermCore';
        target='SMAP';
        modelName='SOILM_0-10';
    elseif strcmp(productName,'rootzone')
        rootOut=kPath.OutSMAP_L4;
        rootDB=kPath.DBSMAP_L4;
        outName='CONUSv4f1_rootzone';
        smapName='CONUS_Core';
        dataName='LongTermCore';
        target='SMGP_rootzone';
        modelName='SOILM_0-100';
    elseif strcmp(productName,'rootzonev4f1')
        rootOut=kPath.OutSMAP_L4;
        rootDB=kPath.DBSMAP_L4;
        outName='CONUSv4f1_rootzone';
        smapName='CONUSv4f1_Core';
        dataName='LongTermCorev4f1';
        target='SMGP_rootzone';
        modelName='SOILM_0-100';
    end
end

LSTM.v=readRnnPred(outName,dataName,500,0,...
    'rootOut',rootOut,'rootDB',rootDB,'target',target,'drBatch',drBatch);
LSTM.t=csvread([rootDB,dataName,filesep,'time.csv']);
LSTM.crd=csvread([rootDB,dataName,filesep,'crd.csv']);
SMAP.v=readDB_SMAP(smapName,target,rootDB);
SMAP.t=csvread([rootDB,smapName,filesep,'time.csv']);
SMAP.crd=csvread([rootDB,smapName,filesep,'crd.csv']);

dataPred=struct('v',[],'t',[],'crd',[]);
for k=1:length(pred)
    field=pred{k};
    dataPred(k).v=readDB_SMAP(dataName,field,rootDB);
    dataPred(k).t=LSTM.t;
    dataPred(k).crd=LSTM.crd;
end

indErr=std(LSTM.v,[],1)<0.002;
LSTM.v(:,indErr)=[];
LSTM.crd(indErr,:)=[];

end

