
% post process for training on different combination of different number of
% HUCs. Want to show CONUS model vs HUC models of n HUCs and bias-picked /
% unbias-picked.


%% read data and save matfile
%{
global kPath
nHucLst=[6];
rmStd=0;

postRnnSMAP_jobHead('CONUSv2f1','rmStd',rmStd);

for i=1:length(nHucLst)
    nHUC=nHucLst(i);
    rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHUC),filesep];
    rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHUC),filesep];
    
    if nHUC~=4
        jobHead=['hucv2n',num2str(nHUC)];
        postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,...
            'rmStd',rmStd);
    else
        jobHead=['huc2_'];
        postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,...
            'saveName','hucv2n4','rmStd',rmStd);
    end
end
%}


%% plot cases - temporal
global kPath

statLst={'rmse','nash','rsq','bias'};
%statLst={'rmse'};
yRangeLst=[0,0.08;0,1;0.6,1;-0.05,0.05];
nHucLst=[1,2,4,6];
%rmStdLst=[0,1,2,4];


rmStd=0
for iS=1:length(statLst)
    stat=statLst{iS}
    yRange=yRangeLst(iS,:);
    f=figure('Position', [1,1,1000,800]);
    
    CONUSMatFile=[kPath.OutSMAP_L3,filesep,'CONUSv2f1.mat'];
    matCONUS=load(CONUSMatFile);
    crdCONUS=matCONUS.crdMat{1};
    for kPick=1:2
        boxMat=cell(length(nHucLst)+1,2);
        
        for i=1:length(nHucLst)+1
            if i<=length(nHucLst)
                nHUC=nHucLst(i);
                jobHead=['hucv2n',num2str(nHUC)];
                %rootOut=['E:\Kuai\rnnSMAP_outputs\hucv2n',num2str(nHUC),filesep];
                rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHUC),filesep];
                saveMatFile=[rootOut,filesep,jobHead,'.mat'];
                matHUC=load(saveMatFile);
                
                %% figure out if bias/unbias, with/without model
                % get HUC id
                nCase=length(matHUC.optLst);
                HUCid=zeros(nCase,nHUC)*nan;
                for k=1:nCase
                    idStr=matHUC.optLst(k).train(end-nHUC*2+1:end);
                    idCell=cellstr(reshape(idStr,[2,nHUC])');
                    HUCid(k,:)=cellfun(@str2num,idCell);
                end
                % biased/unbiased
                bCont=ones(nCase,1);
                for k=1:nCase
                    bCont(k)=findAdjHUC(HUCid(k,:));
                end
                % with/without model
                bModel=strcmp({matHUC.optLst.var},'varLst_Noah')';
                
                %% plot
                if nHUC~=1 || kPick~=2
                    if kPick==1 %unbiased hucs
                        indNoah=find(bCont & bModel);
                        indNoModel=find(bCont & ~bModel);
                    elseif kPick==2 %biased hucs
                        indNoah=find(~bCont & bModel);
                        indNoModel=find(~bCont & ~bModel);
                    end
                    boxMat{i,1}=vertcat(matHUC.statMat.(stat){indNoah,2});
                    boxMat{i,2}=vertcat(matHUC.statMat.(stat){indNoModel,2});
                else
                    boxMat{i,1}=nan;
                    boxMat{i,2}=nan;
                end
            else
                boxMat{i,1}=matCONUS.statMat.(stat){2,2};
                boxMat{i,2}=matCONUS.statMat.(stat){1,2};
            end
        end
        subplot(2,1,kPick)
        labelX={'W/ Noah','W/O Noah'};
        labelY=cell(length(nHucLst)+1,1);
        for k=1:length(nHucLst)
            labelY{k}=['nHUC=',num2str(nHucLst(k))];
        end
        labelY{length(nHucLst)+1}='CONUS';
        plotBoxSMAP( boxMat,labelX,labelY,'newFig',0,'yRange',yRange);
        if kPick==1
            title(['Continuous']);
        else
            title(['Non-continuous']);
        end
    end
    fixFigure(f)
    
    figFolder=['/mnt/sdb1/Kuai/rnnSMAP_result/temporal/'];
    if ~exist(figFolder,'dir')
        mkdir(figFolder);
    end
    figName=[figFolder,'allhuc_',stat];
    savefig(f,figName)
    close(f)
    
    
end
