% find best and worst cases in spatial extropolation and plot some
% timeseries.

%% read data

global kPath
nHuc=4;
testName='CONUSv2f1';
rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHuc),filesep];
rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHuc),filesep];
jobHead=['hucv2n',num2str(nHuc)];
saveName=jobHead;
if nHuc==4
    jobHead=['huc2_'];
    saveName='hucv2n4';
end
%postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'testName',testName,'timeOpt',[1,2],'saveName',saveName);
%postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,'timeOpt',[1,2],'saveName',saveName);
saveMatFile=[rootOut,filesep,saveName,'_',testName,'.mat'];
matCONUS=load(saveMatFile);
saveMatFile=[rootOut,filesep,saveName,'.mat'];
matHuc=load(saveMatFile);
bModel=strcmp({matHuc.optLst.var},'varLst_Noah')';
%}

%% Calcaulate stat
indModelLst=find(bModel==1);
nCase=length(indModelLst);
statHuc=cell(nCase,2);
statExt=cell(nCase,2);
statHuc2=cell(nCase,2);
statExt2=cell(nCase,2);
statStr='rmse';

tic
for k=1:nCase
    ind=indModelLst(k);
    crdHuc=matHuc.crdMat{ind};
    crdCONUS=matCONUS.crdMat{ind};
    [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);
    indExt=[1:length(crdCONUS)]';indExt(indCONUS)=[];
    for iT=1:2
        stat=statCal(matCONUS.outMat.yLSTM{ind,iT}(:,indExt),matCONUS.outMat.ySMAP{ind,iT}(:,indExt));
        statExt{k,iT}=stat.(statStr);
        stat=statCal(matHuc.outMat.yLSTM{ind,iT},matHuc.outMat.ySMAP{ind,iT});
        statHuc{k,iT}=stat.(statStr);
        % nomodel
        stat=statCal(matCONUS.outMat.yLSTM{ind-1,iT}(:,indExt),matCONUS.outMat.ySMAP{ind-1,iT}(:,indExt));
        statExt2{k,iT}=stat.(statStr);
        stat=statCal(matHuc.outMat.yLSTM{ind-1,iT},matHuc.outMat.ySMAP{ind-1,iT});
        statHuc2{k,iT}=stat.(statStr);
    end
end
toc

%% pick out best and worst cases in spatial test
rmseLst=zeros(nCase,1);
rmseLst2=zeros(nCase,1);
for k=1:nCase
    rmseLst(k)=nanmean(statExt{k,1});
    rmseLst2(k)=nanmean(statExt2{k,1});
end

bCont=zeros(nCase,1);
HUCid=zeros(nCase,nHuc)*nan;
for k=1:nCase
    ind=indModelLst(k);
    idStr=matHuc.optLst(ind).train(end-nHuc*2+1:end);
    idCell=cellstr(reshape(idStr,[2,nHuc])');
    HUCid(k,:)=cellfun(@str2num,idCell);
    bCont(k)=findAdjHUC(HUCid(k,:));
end
[B,ordS]=sort(rmseLst);
[B2,ordS2]=sort(rmseLst2);
[B3,ordS3]=sort(rmseLst-rmseLst2);
aS1=HUCid(ordT,:);
aS2=HUCid(ordT2,:);
aS3=HUCid(ordT3,:);
bCont(ordS);
rankS(ordS)=[1:length(ordS)];rankS=rankS';

% plot ts map
ind=indModelLst(ord(end));
outName=matHuc.optLst(ind).out;
%dataName=matHuc.optLst(ind).train;
dataName='CONUSv2f1';
%rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHuc),filesep];
rootDB=kPath.DBSMAP_L3;
rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHuc),filesep];
postRnnSMAP_map(outName,dataName,'rootDB',rootDB,'rootOut',rootOut)

%% pick out best and worst cases in temporal test
rmseLst=zeros(nCase,1);
rmseLst2=zeros(nCase,1);
for k=1:nCase
    rmseLst(k)=nanmean(statHuc{k,2});
    rmseLst2(k)=nanmean(statHuc2{k,2});
end

bCont=zeros(nCase,1);
HUCid=zeros(nCase,nHuc)*nan;
for k=1:nCase
    ind=indModelLst(k);
    idStr=matHuc.optLst(ind).train(end-nHuc*2+1:end);
    idCell=cellstr(reshape(idStr,[2,nHuc])');
    HUCid(k,:)=cellfun(@str2num,idCell);
    bCont(k)=findAdjHUC(HUCid(k,:));
end
[B,ordT]=sort(rmseLst);
[B2,ordT2]=sort(rmseLst2);
[B3,ordT3]=sort(rmseLst-rmseLst2);
aT1=HUCid(ordT,:);
aT2=HUCid(ordT2,:);
aT3=HUCid(ordT3,:);
bCont(ordT);
rankT(ordT)=[1:length(ordT)];rankT=rankT';

plot(rmseLst,rmseLst2,'*')
[p,S]=polyfit(rmseLst,rmseLst2,1);
corr(rmseLst,rmseLst2)
plot121Line

% plot ts map
ind=indModelLst(ord(end));
outName=matHuc.optLst(ind).out;
dataName=matHuc.optLst(ind).train;
%dataName='CONUSv2f1';
rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHuc),filesep];
%rootDB=kPath.DBSMAP_L3;
rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHuc),filesep];
postRnnSMAP_map(outName,dataName,'rootDB',rootDB,'rootOut',rootOut)

%% pick out several cases to look at
rankArray=1:length(ordT);
rankT
for k=1:length(ordT)
    
end

