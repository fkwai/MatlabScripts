
global kPath
rootOut=kPath.OutSigma_L3_NA;
rootDB=kPath.DBSMAP_L3_NA;
dataName='CONUSv4f1';
epoch=500;
saveFolder='/mnt/sdc/Kuai/rnnSMAP_result/sigma/';

outName='cudnn_local3';
outSigmaName='cudnn_sigma';
outSigmaName='CONUSv4f1_y15_soilM2';

[ySMAP1,ySMAP_stat,crd,t1]=readDB_Global(dataName,'SMAP_AM','yrLst',2015,'rootDB',rootDB);
[ySMAP2,~,~,t2]=readDB_Global(dataName,'SMAP_AM','yrLst',2016:2017,'rootDB',rootDB);

%% original
yLSTM1=readRnnPred(outName,dataName,epoch,[2015,2015],...
    'rootOut',kPath.OutSMAP_L3_NA,'rootDB',rootDB);
yLSTM2=readRnnPred(outName,dataName,epoch,[2016,2017],...
    'rootOut',kPath.OutSMAP_L3_NA,'rootDB',rootDB);
stat1=statCal(yLSTM1,ySMAP1);
stat2=statCal(yLSTM2,ySMAP2);

%% MC dropout
% [yLSTM1_batch,sigma1_batch]=readRnnPred_sigma(outSigmaName,dataName,epoch,[2015,2015],...
%     'rootOut',kPath.OutSMAP_L3_NA,'rootDB',rootDB,'drBatch',100);
% yLSTM2_batch,sigma2_batch=readRnnPred(outSigmaName,dataName,epoch,[2016,2017],...
%     'rootOut',kPath.OutSMAP_L3_NA,'rootDB',rootDB,'drBatch',100);
% stat1_batch=statBatch(yLSTM1_batch);
% stat2_batch=statBatch(yLSTM2_batch);
% stdMC1=stat1_batch.std;
% stdMC2=stat1_batch.std;
% yLSTM1_MC=stat1_batch.mean;
% yLSTM2_MC=stat2_batch.mean;
% stat1_MC=statCal(yLSTM1_MC,ySMAP1);
% stat2_MC=statCal(yLSTM2_MC,ySMAP2);

%% sigma
[yLSTM1_Sigma,ySigma1]=readRnnPred_sigma(outSigmaName,dataName,epoch,[2015,2015],...
    'rootOut',kPath.OutSigma_L3_NA,'rootDB',rootDB);
[yLSTM2_Sigma,ySigma2]=readRnnPred_sigma(outSigmaName,dataName,epoch,[2016,2017],...
    'rootOut',kPath.OutSigma_L3_NA,'rootDB',rootDB);
stat1_sigma=statCal(yLSTM1_Sigma,ySMAP1);
stat2_sigma=statCal(yLSTM2_Sigma,ySMAP2);
sig1=sqrt(exp(ySigma1))*ySMAP_stat(4);
sig2=sqrt(exp(ySigma2))*ySMAP_stat(4);

%% MC + sigma
[yLSTM1_batch,sigma1_batch]=readRnnPred_sigma(outSigmaName,dataName,epoch,[2015,2015],...
    'rootOut',kPath.OutSigma_L3_NA,'rootDB',rootDB,'drBatch',100);
[yLSTM2_batch,sigma2_batch]=readRnnPred_sigma(outSigmaName,dataName,epoch,[2016,2017],...
    'rootOut',kPath.OutSigma_L3_NA,'rootDB',rootDB,'drBatch',100);
stat1_batch=statBatch(yLSTM1_batch);
stat2_batch=statBatch(yLSTM2_batch);
stdMC1=stat1_batch.std;
stdMC2=stat1_batch.std;
yLSTM1_MC=stat1_batch.mean;
yLSTM2_MC=stat2_batch.mean;
stat1_MC=statCal(yLSTM1_MC,ySMAP1);
stat2_MC=statCal(yLSTM2_MC,ySMAP2);

% ySigma1=mean(sigma1_batch(end,:,:),3);
% ySigma2=mean(sigma2_batch(end,:,:),3);
% sig1=sqrt(exp(ySigma1))*ySMAP_stat(4);
% sig2=sqrt(exp(ySigma2))*ySMAP_stat(4);



%% box plot of non-sigma vs sigma
statStr='rmse';
statMat={stat1.(statStr),stat2.(statStr);...
    stat1_sigma.(statStr),stat2_sigma.(statStr);};
labelY={'no-sigma','sigma'};
plotBoxSMAP(statMat,{'train','test'},labelY,'yRange',[0,0.08],'newFig',0);

%% map of sigma and stdMC1
[gridSig,xx,yy] = data2grid3d(sig2',crd(:,2),crd(:,1));
[gridStdMC,~,~] = data2grid3d(stdMC2',crd(:,2),crd(:,1));
showMap(mean(gridSig,3),yy,xx,'strTitle',['test sigma'],...
    'Position',[1,1,600,400],'lonTick',[],'latTick',[]);
showMap(mean(gridStdMC,3),yy,xx,'strTitle',['test stdMC'],...
    'Position',[1,1,600,400],'lonTick',[],'latTick',[]);


%% 121 plot between error and uncertainty
%xx=[sig2(end,:)',nanmean(stdMC2)'];
xx=[nanmean(sig2)',nanmean(stdMC2)'];
xLabelLst={'sigma','stdMC'};
% xx=[nanmean(sig2.^2)',nanmean(stdMC2.^2)'];
% xLabelLst={'sigma^2','stdMC^2'};

statStr='ubrmse';
yy=stat2_MC.(statStr);
figure('Position',[1,1,1200,400])
for k=1:2
    subplot(1,3,k)
    plot(xx(:,k),yy,'*');hold on
    lsline
    rho=corr(xx(:,k),yy);
    title(['corr=',num2str(rho,'%.2f')])
    xlabel(xLabelLst{k})
    ylabel(statStr)
end

mdl=fitlm(xx,yy,'linear');
sigComb=predict(mdl,xx);

subplot(1,3,3)
plot(sigComb,yy,'*');hold on
lsline
rho=corr(sigComb,yy);
title(['corr=',num2str(rho,'%.2f')])
xlabel('combined')
ylabel(statStr)

figure
plot(xx(:,1),xx(:,2),'*');hold on
lsline
plot121Line
rho=corr(xx(:,1),xx(:,2));
title(['corr=',num2str(rho,'%.2f')])
xlabel('sigma-x')
ylabel('sigma-MC')
