
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
saveMatFile=[rootOut,filesep,saveName,'_',testName,'.mat'];
matCONUS=load(saveMatFile);
saveMatFile=[rootOut,filesep,saveName,'.mat'];
matHuc=load(saveMatFile);
bModel=strcmp({matHuc.optLst.var},'varLst_Noah')';


%% model bias
indCase=find(bModel==1);
biasModelHuc=cell(length(indCase),2);
biasModelExt=cell(length(indCase),2);

for k=1:length(indCase)
    crdHuc=matHuc.crdMat{k};
    crdCONUS=matCONUS.crdMat{k};
    [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);
    indExt=[1:length(crdCONUS)]';indExt(indCONUS)=[];
    for iT=1:2        
        stat=statCal(matCONUS.outMat.yGLDAS{k,iT}(:,indExt),matCONUS.outMat.ySMAP{k,iT}(:,indExt));
        biasModelExt{k,iT}=stat.bias;
        stat=statCal(matHuc.outMat.yGLDAS{k,iT},matHuc.outMat.ySMAP{k,iT});
        biasModelHuc{k,iT}=stat.bias;
    end
end

%% performance at spatial test - y
% difference between model and noModel on extrapolation test
indCase=find(bModel==1);
rmseDiff=zeros(length(indCase),2);
rmse1=zeros(length(indCase),2);
rmse2=zeros(length(indCase),2);
for k=1:length(indCase)    
    crdHuc=matHuc.crdMat{k};
    crdCONUS=matCONUS.crdMat{k};
    [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);
    indExt=[1:length(crdCONUS)]';indExt(indCONUS)=[];
    for iT=1:2
        rmseTemp1=matCONUS.statMat.rmse{k,iT}(indExt);
        rmse1(k,iT)=nanmean(rmseTemp1);
        rmseTemp2=nanmean(matCONUS.statMat.rmse{k+1,iT}(indExt));
        rmse2(k,iT)=nanmean(rmseTemp2);
        rmseDiff(k,iT)=nanmean(rmseTemp1-rmseTemp2);
    end
end

%% distance between train and test / std(train model bias)
biasModelExtStd=zeros(length(indCase),2);
biasModelHucStd=zeros(length(indCase),2);
klDist=zeros(length(indCase),2);
xEnds=[-0.1:0.01:0.1];
for k=1:length(indCase)
    for iT=1:2                        
        biasModelExtStd(k,iT)=nanstd(biasModelExt{k,iT});
        biasModelHucStd(k,iT)=nanstd(biasModelHuc{k,iT});
        [KL,xx]=KLD_arrays(biasModelHuc{k,iT},biasModelExt{k,iT},xEnds);
        klDist(k,iT)=KL;
    end
end

a=klDist(:,1)./biasModelHucStd(:,1);
b=rmse1(:,1);
c=rmse2(:,1);
subplot(1,2,1)
plot(a,c,'bo');hold on
lsline
title([ 'R with Noah=',num2str(corr(a,b),'%.2f')]);
plot(a,b,'ro');hold on
lsline
title([ 'R without Noah=',num2str(corr(a,c),'%.2f')]);
