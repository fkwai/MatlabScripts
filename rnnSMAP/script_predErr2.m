% post processing for Hucn1 cases. See if the difference of spatial test between withModel and
% noModel has anything to do with:
% 1.  rmse/bias of spatial test
% 2.  rmse/bias of model

%% read data
global kPath
matfileFolder='/mnt/sdb1/Kuai/rnnSMAP_outputs/MatFile/';
nHucLst=[1];
for kHuc=1:length(nHucLst)
    nHuc=nHucLst(kHuc);
    nHuc
    testName='CONUSv2f1';
    saveName=['hucv2n',num2str(nHuc)];
    saveMatFile=[matfileFolder,filesep,saveName,'_',testName,'_stat.mat'];
    matCONUS=load(saveMatFile);
    saveMatFile=[matfileFolder,filesep,saveName,'_stat.mat'];
    matHuc=load(saveMatFile);
    bModel=strcmp({matHuc.optLst.var},'varLst_Noah')';
    
    %% calculate
    indCase=find(bModel==1);
    stat1='rmse'; % for LSTM
    stat2='bias'; % for Model
    statLSTM=zeros(length(indCase),length(indCase));
    stdModelHuc=zeros(length(indCase),length(indCase));
    meanModelHuc=zeros(length(indCase),length(indCase));
    distModel=zeros(length(indCase),length(indCase));
    
    xEnds=[-0.1:0.005:0.1];
    for k1=1:length(indCase)
        for k2=1:length(indCase)
            if k2~=k1
                k1ind=indCase(k1);
                k2ind=indCase(k2);
                crdHuc=matHuc.crdMat{k1ind};
                crdHuc2=matHuc.crdMat{k2ind};
                crdCONUS=matCONUS.crdMat{k1ind};
                [indHuc,indTest]=intersectCrd(crdHuc2,crdCONUS);
                
                iT=1;
                statLSTM(k1,k2)=nanmean(matCONUS.statMat.(stat1){k1ind,iT}(indTest));
                biasModelHuc=matHuc.statModelMat.(stat2){k1ind,iT};
                biasModelExt=matCONUS.statModelMat.(stat2){k1ind,iT}(indTest);
                stdModelHuc(k1,k2)=nanstd(biasModelHuc);
                meanModelHuc(k1,k2)=nanmean(biasModelHuc);
                distModel(k1,k2)=KLD_arrays(biasModelHuc,biasModelExt,xEnds);
            end
        end
    end
    
    %% plot
    subplot(2,3,kHuc)
    a=distModel(:)./stdModelHuc(:);
    b=statLSTM(:);
    plot(a,b,'bo');hold on
    lsline
    ylabel(stat1)
    title(['nHUC=',num2str(kHuc), '; R =',num2str(corr(a,b),'%.2f')]);
end
