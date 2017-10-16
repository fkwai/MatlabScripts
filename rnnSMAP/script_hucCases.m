
% post process for training on different combination of different number of
% HUCs. Want to show CONUS model vs HUC models of n HUCs and bias-picked /
% unbias-picked.

statLst={'rmse','bias','rsq'};
nHUCLst=1:2;
global kPath

%% read CONUSv2f1
%{
tic
outTrain_Noah=postRnnSMAP_load('CONUSv2f1_Noah','CONUSv2f1',1,500);
outTest_Noah=postRnnSMAP_load('CONUSv2f1_Noah','CONUSv2f1',2,500);
outTrain_NoModel=postRnnSMAP_load('CONUSv2f1_NoModel','CONUSv2f1',1,500);
outTest_NoModel=postRnnSMAP_load('CONUSv2f1_NoModel','CONUSv2f1',2,500);
statCONUS_Noah{1}=statCal(outTrain_Noah.yLSTM,outTrain_Noah.ySMAP);
statCONUS_Noah{2}=statCal(outTest_Noah.yLSTM,outTest_Noah.ySMAP);
statCONUS_NoModel{1}=statCal(outTrain_NoModel.yLSTM,outTrain_NoModel.ySMAP);
statCONUS_NoModel{2}=statCal(outTest_NoModel.yLSTM,outTest_NoModel.ySMAP);
crdCONUSFile=[kPath.DBSMAP_L3,filesep,'CONUSv2f1',filesep,'crd.csv'];
crdCONUS=csvread(crdCONUSFile);
toc
%}

%% start HUCs
kFig=1;
for kHUC=1:2
    nHUC=nHUCLst(kHUC);
    rootOut=['E:\Kuai\rnnSMAP_outputs\hucv2nc',num2str(nHUC),'\'];
    saveMatFile=[rootOut,'caseMat.mat'];
    if ~exist(saveMatFile,'file')        
        readHucCases( nHUC );
    end
    load(saveMatFile);
    
    %% plot cases
    % unbiased
    kStat=1;
    stat=statLst{kStat};
    for kPick=1:2
        if nHUC~=1 || kPick~=2
            if kPick==1
                indPick=find(bNear & bModel);
                indPick_NM=find(bNear & ~bModel);
            elseif kPick==2
                indPick=find(~bNear & bModel);
                indPick_NM=find(~bNear & ~bModel);
            end
            
            crdHUC=vertcat(crdMat{indPick});
            [indHUC,indCONUS]=intersectCrd(crdHUC,crdCONUS);
            
            boxMat=cell(3,2);
            for kTrain=1:2
                temp=statCONUS_Noah{kTrain}.(stat);
                boxMat{1,kTrain}=temp(indCONUS);
                boxMat{2,kTrain}=vertcat(statLstMat{kStat}{indPick,kTrain});
                boxMat{3,kTrain}=vertcat(statLstMat{kStat}{indPick_NM,kTrain});
            end
            
            subplot(2,length(nHUCLst),1+nHUC-1+(kPick-1)*2)
            labelX={'train','test'};
            labelY={'CONUS','Noah','NoModel'};
            plotBoxSMAP( boxMat,labelX,labelY,'newFig',0,'yRange',[0,0.05])
            if kPick==1
                title(['nHUC = ',num2str(nHUC), ' Unbiased']);
            else
                title(['nHUC = ',num2str(nHUC), ' biased']);
            end
            kFig=kFig+1;
        
        else
            kFig=kFig+1;
        end
    end
end



