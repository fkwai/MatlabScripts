
% post process for training on different combination of different number of
% HUCs. Want to show CONUS model vs HUC models of n HUCs and bias-picked /
% unbias-picked.

nHucLst=1:2;
global kPath

% %% read CONUSv2f1
% [outCONUSMat,statCONUSMat,crdCONUSMat,optCONUSLst] = postRnnSMAP_jobHead('CONUSv2f1');
% % 
% 
% %% read all HUC-cases and save matfile
% for i=1:length(nHucLst)
%     nHUC=nHucLst(i);
%     jobHead=['hucv2n',num2str(nHUC)];
%     rootOut=['E:\Kuai\rnnSMAP_outputs\hucv2n',num2str(nHUC),filesep];
%     rootDB=['E:\Kuai\rnnSMAP_inputs\hucv2n',num2str(nHUC),filesep];
%     postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB);    
% end


%% plot cases
CONUSMatFile=[kPath.OutSMAP_L3,filesep,'CONUSv2f1.mat'];
matCONUS=load(CONUSMatFile);
crdCONUS=matCONUS.crdMat{1};
for i=1:length(nHucLst)
    nHUC=nHucLst(i);
    jobHead=['hucv2n',num2str(nHUC)];
    rootOut=['E:\Kuai\rnnSMAP_outputs\hucv2n',num2str(nHUC),filesep];
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
    bNear=ones(nCase,1);
    if nHUC~=1
        bNear=mean(HUCid(:,2:end)-HUCid(:,1:end-1),2)==1;    
    end
    % with/without model
    bModel=strcmp({matHUC.optLst.var},'varLst_Noah')';
    
    %% plot
    stat='rmse';
    for kPick=1:2
        if nHUC~=1 || kPick~=2
            if kPick==1 %biased hucs
                indNoah=find(bNear & bModel);
                indNoModel=find(bNear & ~bModel);
            elseif kPick==2 %unbiased hucs
                indNoah=find(~bNear & bModel);
                indNoModel=find(~bNear & ~bModel);
            end
            
            crdHUC=vertcat(matHUC.crdMat{indNoah});
            [indHUC,indCONUS]=intersectCrd(crdHUC,crdCONUS);
            
            boxMat=cell(3,2);
            for iT=1:2                
                boxMat{1,iT}=matCONUS.statMat.(stat){2,iT};
                boxMat{2,iT}=matCONUS.statMat.(stat){1,iT};
                boxMat{3,iT}=vertcat(matHUC.statMat.(stat){indNoah,iT});
                boxMat{4,iT}=vertcat(matHUC.statMat.(stat){indNoModel,iT});                
            end
            
            subplot(2,length(nHucLst),1+nHUC-1+(kPick-1)*2)
            labelX={'train','test'};
            labelY={'CONUS Noah','CONUS NoModel','HUC Noah','HUC NoModel'};
            plotBoxSMAP( boxMat,labelX,labelY,'newFig',0,'yRange',[0,0.05]);
            if kPick==1
                title(['nHUC = ',num2str(nHUC), ' Unbiased']);
            else
                title(['nHUC = ',num2str(nHUC), ' biased']);
            end
        end
    end
end



