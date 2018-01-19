
% post processing for Hucn1 cases. See if the difference of spatial test between withModel and
% noModel has anything to do with:
% 1.  rmse/bias of spatial test
% 2.  rmse/bias of model

global kPath
hucLst=1:6;
statLst={'rmse','ubrmse','bias'};

%% init
boxMat=cell(6,6);

for iHuc=1:length(hucLst)
    %% load data
    nHuc=hucLst(iHuc)
    testName='CONUSv2f1';
    rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHuc),filesep];
    rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHuc),filesep];
    jobHead=['hucv2n',num2str(nHuc)];
    saveName=jobHead;
    if nHuc==4
        jobHead=['huc2_'];
        saveName='hucv2n4';
    end
    saveMatFile=[rootOut,filesep,saveName,'_',testName,'_stat.mat'];
    matCONUS=load(saveMatFile);
    saveMatFile=[rootOut,filesep,saveName,'_stat.mat'];
    matHuc=load(saveMatFile);
    
    bModel=strcmp({matCONUS.optLst.var},'varLst_Noah')';
    
    %% sum up box plot mat
    indCase=find(bModel==1);
    for iStat=1:length(statLst)
        stat=statLst{iStat};
        statExt1.(stat)=[]; % with model
        statExt2.(stat)=[]; % without model
        for k=1:length(indCase)
            kCase=indCase(k);
            crdHuc=matHuc.crdMat{kCase};
            crdCONUS=matCONUS.crdMat{kCase};
            [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);
            indExt=[1:length(crdCONUS)]';indExt(indCONUS)=[];

            iT=1;
            statExt1.(stat)=[statExt1.(stat);matCONUS.statMat.(stat){kCase,iT}(indExt)];
            statExt2.(stat)=[statExt2.(stat);matCONUS.statMat.(stat){kCase-1,iT}(indExt)];
        end        
        boxMat{nHuc,iStat}=statExt1.(stat);
        boxMat{nHuc,iStat+length(statLst)}=statExt2.(stat);
    end
end

%% plot
f=figure('Position', [1,1,1200,800]);
labelX=[];
for k=1:length(statLst)
    labelX{k}=['with Model ',statLst{k}];
    labelX{k+length(statLst)}=['without Model ',statLst{k}];
end
labelY=arrayfun(@num2str,[1:6],'UniformOutput',false);
plotBoxSMAP(boxMat,labelX,labelY,'newFig',0,'yRange',[-0.05,0.2],'xColor','rbgrbg');

