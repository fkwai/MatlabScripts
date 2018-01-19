
% post processing for Hucn1 cases. See if the difference of spatial test between withModel and
% noModel has anything to do with:
% 1.  rmse/bias of spatial test
% 2.  rmse/bias of model

%% read data
global kPath
hucLst=1:6;
statLst={'rmse','ubrmse','rsq','bias'};
yRangeLst=[0,0.05;0,0.05;0.6,1;-0.05,0.05];
rmStdLst=[0,1,2];

%% init
boxMat=struct();
for iStat=1:length(statLst)
    stat=statLst{iStat};
    boxMat.(stat)=cell(length(hucLst),4);
end

for iR=1:length(rmStdLst)
    rmStd=rmStdLst(iR);
    for iHuc=1:length(hucLst)
        %% load data
        nHuc=hucLst(iHuc);
        testName='CONUSv2f1';
        rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHuc),filesep];
        rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHuc),filesep];
        jobHead=['hucv2n',num2str(nHuc)];
        saveName=jobHead;
        if nHuc==4
            jobHead=['huc2_'];
            saveName='hucv2n4';
        end
        if rmStd==0
            saveMatFileCONUS=[rootOut,filesep,saveName,'_',testName,'_stat.mat'];
            saveMatFile=[rootOut,filesep,saveName,'_stat.mat'];
        else
            saveMatFileCONUS=[rootOut,filesep,saveName,'_',testName,'_rmStd',num2str(rmStd),'_stat.mat'];
            saveMatFile=[rootOut,filesep,saveName,'_rmStd',num2str(rmStd),'_stat.mat'];
        end
        matCONUS=load(saveMatFileCONUS);
        matHuc=load(saveMatFile);
        bModel=strcmp({matCONUS.optLst.var},'varLst_Noah')';
        
        %% sum up box plot mat
        indCase=find(bModel==1);
        for iStat=1:length(statLst)
            stat=statLst{iStat};            
            statHuc1.(stat)=[]; % local with model
            statHuc2.(stat)=[]; % local without model
            statHuc3.(stat)=[]; % CONUS with model
            statHuc4.(stat)=[]; % CONUS without model            
            for k=1:length(indCase)
                kCase=indCase(k);
                crdHuc=matHuc.crdMat{kCase};
                crdCONUS=matCONUS.crdMat{kCase};
                [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);                
                iT=2;
                statHuc1.(stat)=[statHuc1.(stat);matHuc.statMat.(stat){kCase,iT}];
                statHuc2.(stat)=[statHuc2.(stat);matHuc.statMat.(stat){kCase-1,iT}];
                statHuc3.(stat)=[statHuc3.(stat);matCONUS.statMat.(stat){kCase,iT}(indCONUS)];
                statHuc4.(stat)=[statHuc4.(stat);matCONUS.statMat.(stat){kCase-1,iT}(indCONUS)];
            end
            boxMat.(stat){nHuc,1}=statHuc1.(stat);
            boxMat.(stat){nHuc,2}=statHuc2.(stat);
            boxMat.(stat){nHuc,3}=statHuc3.(stat);
            boxMat.(stat){nHuc,4}=statHuc4.(stat);
        end
    end
    
    %% plot
    for iStat=1:length(statLst)
        stat=statLst{iStat};
        yRange=yRangeLst(iStat,:);
        f=figure('Position', [1,1,1200,800]);
        labelX={'H-W','H-W\O','C-W','C-W\O'};
        labelY=arrayfun(@num2str,[1:6],'UniformOutput',false);
        plotBoxSMAP(boxMat.(stat),labelX,labelY,'newFig',0,'yRange',yRange);
        
        figFolder=['/mnt/sdb1/Kuai/rnnSMAP_result/temporal/'];
        if ~exist(figFolder,'dir')
            mkdir(figFolder);
        end
        figName=[figFolder,'hucTemp_',stat,'_','rmStd',num2str(rmStd)];
        savefig(f,figName)
        close(f)
    end
end
