% try to find the best cases and worst cases in spatial test

% matCONUS=load('E:\Kuai\rnnSMAP_outputs\hucv2n4\hucv2n4_CONUSv2f1.mat');
% matHUC=load('E:\Kuai\rnnSMAP_outputs\hucv2n4\hucv2n4.mat');

nCase=length(matHUC.optLst);
prctLst=[25,50,75];
tabStat=zeros(length(matHUC.optLst),length(prctLst));
tabRank1=zeros(length(matHUC.optLst),length(prctLst));
tabRank2=zeros(length(matHUC.optLst),length(prctLst));
for k=1:nCase
    stat='rmse';
    tOpt=1;
    crdHUC=matHUC.crdMat{k};
    crdCONUS=matCONUS.crdMat{k};
    [indHUC,indCONUS]=intersectCrd(crdHUC,crdCONUS);
    indTrain=indCONUS;
    indTest=[1:size(crdCONUS,1)]';
    indTest(indTrain)=[];
    statTest=matCONUS.statMat.(stat){k,tOpt}(indTest,tOpt);
    for kk=1:length(prctLst)
        tabStat(k,kk)=prctile(statTest,prctLst(kk));
    end
end

for kk=1:length(prctLst)
    [~,~,rr] = unique(tabStat(1:2:end,kk));
    tabRank1(:,kk)=rr;
    [~,~,rr] = unique(tabStat(2:2:end,kk));
    tabRank2(:,kk)=rr;
end

trainLst={matCONUS.optLst(1:2:end).train}';