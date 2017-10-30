
% post process for training on different combination of different number of
% HUCs. Want to show CONUS model vs HUC models of n HUCs and bias-picked /
% unbias-picked.


%% read data and save matfile

global kPath
nHucLst=[1,2,3,4,5,6];
rmStd=0;

postRnnSMAP_jobHead('CONUSv2f1','rmStd',rmStd);

for i=1:length(nHucLst)
    nHUC=nHucLst(i);
    rootOut=['E:\Kuai\rnnSMAP_outputs\hucv2n',num2str(nHUC),filesep];
    rootDB=['E:\Kuai\rnnSMAP_inputs\hucv2n',num2str(nHUC),filesep];
    
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


%% plot cases - temporal
global kPath

statLst={'rmse','nash','rsq','bias'};
yRangeLst=[0,0.05;0,1;0.6,1;-0.05,0.05];
nHucLst=[1,2,3,4,5,6];
rmStdLst=[0,1,2,4];
for iR=1:length(rmStdLst)
    rmStd=rmStdLst(iR);
    for iS=1:length(statLst)
    %for iS=1:1
        stat=statLst{iS};
        yRange=yRangeLst(iS,:);
        f=figure('Position', get(0, 'Screensize'));
        
        CONUSMatFile=[kPath.OutSMAP_L3,filesep,'CONUSv2f1.mat'];
        matCONUS=load(CONUSMatFile);
        crdCONUS=matCONUS.crdMat{1};
        for i=1:length(nHucLst)
            nHUC=nHucLst(i);
            jobHead=['hucv2n',num2str(nHUC)];
            rootOut=['E:\Kuai\rnnSMAP_outputs\hucv2n',num2str(nHUC),filesep];
            if rmStd==0
                saveMatFile=[rootOut,filesep,jobHead,'.mat'];
            else
                saveMatFile=[rootOut,filesep,jobHead,'_rmStd',num2str(rmStd),'.mat'];
            end
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
            for kPick=1:2
                if nHUC~=1 || kPick~=2
                    if kPick==1 %unbiased hucs
                        indNoah=find(bCont & bModel);
                        indNoModel=find(bCont & ~bModel);
                    elseif kPick==2 %biased hucs
                        indNoah=find(~bCont & bModel);
                        indNoModel=find(~bCont & ~bModel);
                    end
                    
                    crdHUC=vertcat(matHUC.crdMat{indNoah});
                    [indHUC,indCONUS]=intersectCrd(crdHUC,crdCONUS);
                    
                    boxMat=cell(3,2);
                    for iT=1:2
                        boxMat{1,iT}=matCONUS.statMat.(stat){2,iT}(indCONUS);
                        boxMat{2,iT}=matCONUS.statMat.(stat){1,iT}(indCONUS);
                        boxMat{3,iT}=vertcat(matHUC.statMat.(stat){indNoah,iT});
                        boxMat{4,iT}=vertcat(matHUC.statMat.(stat){indNoModel,iT});
                    end
                    
                    subplot(2,length(nHucLst),i+(kPick-1)*length(nHucLst))
                    labelX={'train','test'};
                    labelY={'C-W','C-W\O','H-W','H-W\O'};
                    plotBoxSMAP( boxMat,labelX,labelY,'newFig',0,'yRange',yRange);
                    if kPick==1
                        title(['nHUC = ',num2str(nHUC), ' continuous']);
                    else
                        title(['nHUC = ',num2str(nHUC), ' non-continuous']);
                    end
                end
            end
        end
        
        
        figFolder=['E:\Kuai\rnnSMAP_result\regional\'];
        if ~exist(figFolder,'dir')
            mkdir(figFolder);
        end
        figName=[figFolder,'huc_',stat,'_','rmStd',num2str(rmStd)];
        savefig(f,figName)
        close(f)
    end
end



