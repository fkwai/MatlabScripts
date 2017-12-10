
% post process for training on different combination of different number of
% HUCs. Want to show CONUS model vs HUC models of n HUCs and bias-picked /
% unbias-picked.


%% read data and save matfile

global kPath
nHucLst=[1:6];
rmStd=0;

for i=1:length(nHucLst)
    nHUC=nHucLst(i);
    rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHUC),filesep];
    %rootDB=['E:\Kuai\rnnSMAP_inputs\hucv2n',num2str(nHUC),filesep];
    rootDB=kPath.DBSMAP_L3;
    if nHUC~=4
        jobHead=['hucv2n',num2str(nHUC)];
        postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,...
            'rmStd',rmStd,'testName','CONUSv2f1','saveTS',0);
    else
        jobHead=['huc2_'];
        postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,...
            'saveName','hucv2n4','rmStd',rmStd,'testName','CONUSv2f1','saveTS',0);
    end
end

%% plot cases - temporal
global kPath

statLst={'rmse','nash','rsq','bias'};
yRangeLst=[0,0.2;-2,1;0.2,1;-0.1,0.1];
nHucLst=[1,2,3,4,5];
rmStdLst=[0];
timeOpt=2;

testName='CONUSv2f1';
crdCONUSFile=[kPath.DBSMAP_L3,filesep,testName,filesep,'crd.csv'];
crdCONUS=csvread(crdCONUSFile);
for iR=1:length(rmStdLst)
    rmStd=rmStdLst(iR);
    for iS=1:length(statLst)
        %for iS=1:1
        stat=statLst{iS};
        yRange=yRangeLst(iS,:);
        f=figure('Position', get(0, 'Screensize'));
        
        % init boxMat, boxMat{1} for continous hucs, boxMat{2} for
        % non-continous
        boxMat={cell(length(nHucLst),2);cell(length(nHucLst),2)};
        
        for i=1:length(nHucLst)
            nHUC=nHucLst(i);
            disp(['working on ',num2str(nHUC)])
            tic
            jobHead=['hucv2n',num2str(nHUC)];
            rootOut=['E:\Kuai\rnnSMAP_outputs\hucv2n',num2str(nHUC),filesep];
            if rmStd==0
                saveMatFile=[rootOut,filesep,jobHead,'_',testName,'.mat'];
            else
                saveMatFile=[rootOut,filesep,jobHead,'_',testName,...
                    '_rmStd',num2str(rmStd),'.mat'];
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
            
            %read local matfile to get crd - hypothese: both of local and
            %CONUS contains all cases!!
            matHUCFile_local=[rootOut,filesep,jobHead,'.mat'];
            matHUC_local=load(matHUCFile_local);
            
            %% put data into boxMat
            for kPick=1:2
                if nHUC~=1 || kPick~=2
                    if kPick==1 %continous hucs
                        indNoah=find(bCont & bModel);
                        indNoModel=find(bCont & ~bModel);
                    elseif kPick==2 %non-continous hucs
                        indNoah=find(~bCont & bModel);
                        indNoModel=find(~bCont & ~bModel);
                    end
                    
                    statTemp=[];
                    for kk=1:2
                        if kk==1
                            indLst=indNoah;
                        elseif kk==2
                            indLst=indNoModel;
                        end
                        for k=1:length(indLst)
                            ind=indLst(k);
                            temp=matHUC.statMat.(stat){ind,timeOpt};
                            trainName=matHUC.optLst(ind).train;
                            if strcmp(trainName,matHUC_local.optLst(ind).train)
                                crdHUC=matHUC_local.crdMat{ind};
                                crdCONUS=matHUC.crdMat{ind};
                            else
                                error('mismatch between local matfile and spatial matfile')
                            end
                            [indHUC,indCONUS]=intersectCrd(crdHUC,crdCONUS);
                            temp(indCONUS)=[];
                            statTemp=vertcat(statTemp,temp);
                        end
                        
                        boxMat{kPick}{i,kk}=statTemp;
                    end
                end
            end
            toc
        end
        
        for kPick=1:2
            subplot(2,1,kPick)
            labelX={'Noah','NoModel'};
            labelY=arrayfun(@num2str,nHucLst,'UniformOutput',false);
            plotBoxSMAP(boxMat{kPick},labelX,labelY,'newFig',0,'yRange',yRange);
            if kPick==1
                title(['continuous']);
            else
                title(['non-continuous']);
            end
        end
        
        
        figFolder=['E:\Kuai\rnnSMAP_result\model\'];
        if ~exist(figFolder,'dir')
            mkdir(figFolder);
        end
        figName=[figFolder,'huc_',stat,'_','rmStd',num2str(rmStd),'_t',num2str(timeOpt)];
        savefig(f,figName)
        close(f)
    end
end



