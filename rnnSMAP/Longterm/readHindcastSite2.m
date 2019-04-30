function [SMAP,LSTM,dataPred] = readHindcastSite2( siteName,productName,varargin)

% trained on 3 years 2015 - 2017

varinTab={'pred',[];'drBatch',0};
[pred,drBatch]=internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});

global kPath

%% set up
if strcmp(productName,'surface')
    rootOut=kPath.OutSMAP_L3_NA;
    rootDB=kPath.DBSMAP_L3_NA;
    %outName='CONUSv4f1wSite_soilM';
    outName='CONUS_3yr_Forcing';
    targetName='SMAP_AM';
    yrLst=[2000:2017];
    if strcmp(siteName,'CoreSite')
        dataName='CoreSite';
    elseif strcmp(siteName,'CRN')
        dataName='CRN';
    end
elseif strcmp(productName,'rootzone')
    rootOut=kPath.OutSMAP_L4_NA;
    rootDB=kPath.DBSMAP_L4_NA;
    outName='CONUSv4f1wSite_3yr_Forcing';
    targetName='SMGP_rootzone';
    yrLst=[2000:2017];
    if strcmp(siteName,'CoreSite')
        dataName='CoreSite';
    elseif strcmp(siteName,'CRN')
        dataName='CRN';
    end
end

 [xData,~,crd,time] = readDB_Global(dataName,targetName,'yrLst',[2015:2017],'rootDB',rootDB);
 SMAP.v=xData;
 SMAP.t=time;
 SMAP.crd=crd;
 
dataOut=readRnnPred(outName,dataName,500,[yrLst(1),yrLst(end)],...
    'rootOut',rootOut,'rootDB',rootDB,'targetName',targetName);
LSTM.v=dataOut;
LSTM.t=[datenumMulti(yrLst(1)*10000+401):datenumMulti((yrLst(end)+1)*10000+331)]';
LSTM.crd=SMAP.crd;

dataPred=struct('v',[],'t',[],'crd',[]);
for k=1:length(pred)
    field=pred{k};
     [xData,~,crd,time] = readDB_Global(dataName,field,'yrLst',yrLst,'rootDB',rootDB);
    dataPred(k).v=xData;
    dataPred(k).t=time;
    dataPred(k).crd=crd;
    LSTM.t=time;
end

%% remove when LSTM failed
indErr=find(std(LSTM.v,[],1)<0.002);
LSTM.v(:,indErr)=[];
LSTM.crd(indErr,:)=[];
SMAP.v(:,indErr)=[];
SMAP.crd(indErr,:)=[];
for k=1:length(pred)
    dataPred(k).v(:,indErr)=[];
    dataPred(k).crd(indErr,:)=[];
end
if ~isempty(indErr)
    disp(indErr)
end


end

