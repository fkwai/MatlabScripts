
% post processing for Hucn1 cases. See if the difference of spatial test between withModel and
% noModel has anything to do with:
% 1.  rmse/bias of spatial test
% 2.  rmse/bias of model

%% read data
global kPath
matfileFolder='/mnt/sdb1/Kuai/rnnSMAP_outputs/MatFile/';
%nHucLst=[1:6];
nHucLst=[4];
f=figure('Position',[1,1,1800,1000])
for kHuc=1:length(nHucLst)
    nHuc=nHucLst(kHuc)
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
    stat2='rmse'; % for Model
    distModel=zeros(length(indCase),2);
    
    statLSTMHuc=zeros(length(indCase),2);
    statLSTMHuc2=zeros(length(indCase),2);
    statLSTMExt=zeros(length(indCase),2);
    statLSTMExt2=zeros(length(indCase),2);
    
    stdModelHuc=zeros(length(indCase),2);
    meanModelHuc=zeros(length(indCase),2);
    stdSelfHuc=zeros(length(indCase),2);
    meanSelfHuc=zeros(length(indCase),2);
    
    stdModelExt=zeros(length(indCase),2);
    meanModelExt=zeros(length(indCase),2);
    stdSelfExt=zeros(length(indCase),2);
    meanSelfExt=zeros(length(indCase),2);
    
    xEnds=[-0.1:0.01:0.1];
    %xEnds=[0.4:0.05:1];
    
    for k=1:length(indCase)
        kind=indCase(k);
        crdHuc=matHuc.crdMat{kind};
        crdCONUS=matCONUS.crdMat{kind};
        [indHuc,indCONUS]=intersectCrd(crdHuc,crdCONUS);
        indExt=[1:length(crdCONUS)]';indExt(indCONUS)=[];
        for iT=1:2
            statLSTMExt(k,iT)=nanmean(matCONUS.statMat.(stat1){kind,iT}(indExt));
            statLSTMExt2(k,iT)=nanmean(matCONUS.statMat.(stat1){kind-1,iT}(indExt));
            statLSTMHuc(k,iT)=nanmean(matHuc.statMat.(stat1){kind,iT});
            statLSTMHuc2(k,iT)=nanmean(matHuc.statMat.(stat1){kind-1,iT});
            
            statModelHuc=matHuc.statModelMat.(stat2){kind,iT};
            statModelExt=matCONUS.statModelMat.(stat2){kind,iT}(indExt);
            statSelfHuc=matHuc.statSelfMat.(stat2){kind,iT};
            statSelfExt=matCONUS.statSelfMat.(stat2){kind,iT}(indExt);
            
            stdModelHuc(k,iT)=nanstd(statModelHuc);
            meanModelHuc(k,iT)=nanmean(statModelHuc);
            stdSelfHuc(k,iT)=nanstd(statSelfHuc);
            meanSelfHuc(k,iT)=nanmean(statSelfHuc);
            
            stdModelExt(k,iT)=nanstd(statModelExt);
            meanModelExt(k,iT)=nanmean(statModelExt);
            stdSelfExt(k,iT)=nanstd(statSelfExt);
            meanSelfExt(k,iT)=nanmean(statSelfExt);
            %distModel(k,iT)=KLD_arrays(statModelHuc,statModelExt,xEnds);
            %distModel(k,iT)=KLD_arrays(statSelfHuc,statSelfExt,xEnds);            
        end
    end
    
    %% plot
    subplot(2,3,kHuc)    
    %a=distModel(:,1);    
    %b=statLSTM(:,1)./stdModelHuc(:,1);
    a=statLSTMExt(:,1);    
    b=statLSTMExt2(:,1);        
    
    plot(a,b,'bo');hold on
    h=lsline;
    set(h,'color','k')
%     switch stat1
%         case 'rmse'
%             xlim([0.02,0.05]);ylim([0.02,0.05]);
%         case 'rsq'
%             xlim([0.6,0.9]);ylim([0.6,0.9]);
%         case 'bias'
%             xlim([-0.015,0.015]);ylim([-0.015,0.015]);
%     end
    plot121Line
    hold off
    
    %ylabel('RMSE')
    %xlabel('KL-Dist / std')
    xlabel([stat1, ' LSTM with model'])
    ylabel([stat1,' LSTM without model'])
    
    title(['nHUC=',num2str(kHuc), '; R=',num2str(corr(a,b),'%.2f')]);
end
fixFigure(f)
figFolder=['/mnt/sdb1/Kuai/rnnSMAP_result/predErr/'];

%figName=[figFolder,'improveModel_',stat1,'_spatial.fig'];
saveas(f,figName)

