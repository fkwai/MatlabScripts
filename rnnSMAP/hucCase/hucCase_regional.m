
% compare between local and CONUS LSTM results.

%% read data
global kPath
hucLst=1:6;
statLst={'rmse','ubrmse','rsq','bias'};
yRangeLst=[0,0.1;0,0.1;0,1;-0.05,0.05];
rmStdLst=[3];

%% init
boxMat=struct();
for iStat=1:length(statLst)
    stat=statLst{iStat};
    boxMat.(stat)=cell(length(hucLst),4);
end

%% load CONUS model
rootOut=kPath.OutSMAP_L3;
rootDB=kPath.DBSMAP_L3;
outName1='CONUSv2f1_Noah';
outName2='CONUSv2f1_NoModel';
testName='CONUSv2f1';
timeOpt=2;
outCONUS1=postRnnSMAP_load(outName1,testName,timeOpt,'rootOut',rootOut,'rootDB',rootDB);
outCONUS2=postRnnSMAP_load(outName2,testName,timeOpt,'rootOut',rootOut,'rootDB',rootDB);

for iRm=1:length(rmStdLst)
    rmStd=rmStdLst(iRm);
    for iHuc=1:length(hucLst)
        %% load local model
        nHuc=hucLst(iHuc)
        tic
        rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHuc),filesep];
        rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHuc),filesep];
        jobHead=['hucv2n',num2str(nHuc)];
        saveName=jobHead;
        if nHuc==4
            jobHead=['huc2_'];
            saveName='hucv2n4';
        end
        saveMatFile=[rootOut,filesep,saveName,'.mat'];
        matHuc=load(saveMatFile);
        bModel=strcmp({matHuc.optLst.var},'varLst_Noah')';
        
        
        %% sum up box plot mat
        indCase=find(bModel==1);
        for iStat=1:length(statLst)
            stat=statLst{iStat};
            statHuc1.(stat)=[]; % local with model
            statHuc2.(stat)=[]; % local without model
            statHuc3.(stat)=[]; % CONUS with model
            statHuc4.(stat)=[]; % CONUS without model
        end
        boxMat.nData{nHuc}=[];
        for k=1:length(indCase)
            kCase=indCase(k);
            crdHuc=matHuc.crdMat{kCase};
            crdCONUS=outCONUS1.crd;
            [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);
            iT=2;
            statTemp1=statCal(matHuc.outMat.yLSTM{kCase,iT},matHuc.outMat.ySMAP{kCase,iT},'rmStd',rmStd);
            statTemp2=statCal(matHuc.outMat.yLSTM{kCase-1,iT},matHuc.outMat.ySMAP{kCase-1,iT},'rmStd',rmStd);
            statTemp3=statCal(outCONUS1.yLSTM(:,indCONUS),matHuc.outMat.ySMAP{kCase,iT},'rmStd',rmStd);
            statTemp4=statCal(outCONUS2.yLSTM(:,indCONUS),matHuc.outMat.ySMAP{kCase-1,iT},'rmStd',rmStd);
            for iStat=1:length(statLst)
                stat=statLst{iStat};
                statHuc1.(stat)=[statHuc1.(stat);statTemp1.(stat)];
                statHuc2.(stat)=[statHuc2.(stat);statTemp2.(stat)];
                statHuc3.(stat)=[statHuc3.(stat);statTemp3.(stat)];
                statHuc4.(stat)=[statHuc4.(stat);statTemp4.(stat)];
            end
            boxMat.nData{nHuc}=[boxMat.nData{nHuc};...
                length(statTemp1.rmse),length(statTemp2.rmse),...
                length(statTemp4.rmse),length(statTemp3.rmse)];
        end
        for iStat=1:length(statLst)
            stat=statLst{iStat};
            boxMat.(stat){nHuc,1}=statHuc1.(stat);
            boxMat.(stat){nHuc,2}=statHuc2.(stat);
            boxMat.(stat){nHuc,3}=statHuc3.(stat);
            boxMat.(stat){nHuc,4}=statHuc4.(stat);
        end
        toc
    end
    
    %% plot
    save([figFolder,'boxMat_rmStd',num2str(rmStd)],'boxMat')
    
    for iStat=1:length(statLst)
        stat=statLst{iStat};
        yRange=yRangeLst(iStat,:);
        f=figure('Position', [1,1,1200,800]);
        labelX={'H-W','H-W\O','C-W','C-W\O'};
        labelY=arrayfun(@num2str,hucLst,'UniformOutput',false);
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

for i=1:4
    for j=1:6
        temp(j,i)=length(find(isnan(boxMat.rmse{j,i})));
        length(find(isnan(boxMat.rmse{j,i})));
    end
end


