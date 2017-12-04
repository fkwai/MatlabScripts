
% post processing for Hucn1 cases. See if the difference of spatial test between withModel and
% noModel has anything to do with:
% 1.  rmse/bias of spatial test
% 2.  rmse/bias of model

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

%% model bias
indCase=find(bModel==1);
biasModelHuc=cell(length(indCase),2);
biasModelExt=cell(length(indCase),2);
biasModelHucMean=zeros(length(indCase),2);
biasModelExtMean=zeros(length(indCase),2);

for k=1:length(indCase)
    crdHuc=matHuc.crdMat{k};
    crdCONUS=matCONUS.crdMat{k};
    [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);
    indExt=[1:length(crdCONUS)]';indExt(indCONUS)=[];
    for iT=1:2        
        stat=statCal(matCONUS.outMat.yGLDAS{k,iT}(:,indExt),matCONUS.outMat.ySMAP{k,iT}(:,indExt));
        biasModelExt{k,iT}=stat.bias;
        biasModelExtMean(k,iT)=nanmean(stat.bias);
        stat=statCal(matHuc.outMat.yGLDAS{k,iT},matHuc.outMat.ySMAP{k,iT});
        biasModelHuc{k,iT}=stat.bias;
        biasModelHucMean(k,iT)=nanmean(stat.bias);
    end
end

%% performance at spatial test
indCase=find(bModel==1);
rmseDiff=zeros(length(indCase),2);
for k=1:length(indCase)    
    crdHuc=matHuc.crdMat{k};
    crdCONUS=matCONUS.crdMat{k};
    [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);
    indExt=[1:length(crdCONUS)]';indExt(indCONUS)=[];
    for iT=1:2
        rmse1=matCONUS.statMat.rmse{k,iT}(indExt);
        rmse2=matCONUS.statMat.rmse{k+1,iT}(indExt);
        rmseDiff(k,iT)=nanmean(rmse1-rmse2);
    end
end
plot(rmseDiff,biasModelExtMean,'*')    

plot(rmseDiff,biasModelHucMean,'*')    

plot(rmseDiff,biasModelModelMean,'*')    
