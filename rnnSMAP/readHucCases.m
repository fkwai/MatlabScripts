function [ statLstMat,crdMat,bNear,bModel ] = readHucCases( nHUC )
%read cases of HUC combinations

statLst={'rmse','bias','rsq'};
global kPath


%% find all jobs (hard code)
rootOut=['E:\Kuai\rnnSMAP_outputs\hucv2nc',num2str(nHUC),'\'];
%rootDB=['E:\Kuai\rnnSMAP_inputs\hucv2nc',num2str(nHUC),'\'];
rootDB=kPath.DBSMAP_L3;

jobHead=['hucv2n',num2str(nHUC)];
[outNameLst,dataNameLst,optLst]=findJobHead(jobHead,rootOut);

%% decide if the dataset is mixed hucs or not
nCase=length(dataNameLst);
HUCid=zeros(nCase,nHUC)*nan;
for k=1:nCase
    idStr=dataNameLst{k}(end-nHUC*2+1:end);
    idCell=cellstr(reshape(idStr,[2,nHUC])');
    HUCid(k,:)=cellfun(@str2num,idCell);
end
if nHUC~=1
    bNear=mean(HUCid(:,2:end)-HUCid(:,1:end-1),2)==1;
else
    bNear=ones(nCase,1);
end

%% decide if the dataset is trained using Noah or not
bModel=strcmp({optLst.var},'varLst_Noah')';

%% read HUC results and calculate stat
statLstMat=cell(length(statLst),1);
for k=1:length(statLst)
    statLstMat{k}=cell(nCase,2);
end
crdMat=cell(nCase,1);

tic
for k=1:nCase
    k
    outTrain=postRnnSMAP_load(outNameLst{k},dataNameLst{k},1,300,'rootOut',rootOut);
    outTest=postRnnSMAP_load(outNameLst{k},dataNameLst{k},2,300,'rootOut',rootOut);
    
    crdFile=[rootDB,filesep,dataNameLst{k},filesep,'crd.csv'];
    crdTemp=csvread(crdFile);
    
    statTrain=statCal(outTrain.yLSTM,outTrain.ySMAP);
    statTest=statCal(outTest.yLSTM,outTest.ySMAP);
    
    for kk=1:length(statLst)
        statLstMat{kk}{k,1}=statTrain.(statLst{kk});
        statLstMat{kk}{k,2}=statTest.(statLst{kk});
    end
    crdMat{k}=crdTemp;
end
toc

%% save a matfile
saveMatFile=[rootOut,'caseMat.mat'];
save(saveMatFile,'statLstMat','crdMat','bNear','bModel')


end

