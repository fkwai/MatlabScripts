

global kPath
rootOut=kPath.OutSigma_L3_NA;
rootDB=kPath.DBSMAP_L3_NA;
dataName='CONUSv16f1';
epoch=500;
saveFolder='/mnt/sdc/Kuai/rnnSMAP_result/sigma/';

trainNameLst={'CONUS','CONUSv2f1','CONUSv4f1','CONUSv8f1','CONUSv16f1'};
outNameLst=trainNameLst;
for k=1:length(outNameLst)
    outNameLst{k}=[trainNameLst{k},'_y15_soilM'];
end
[ySMAP1,ySMAP_stat,crd,t1]=readDB_Global(dataName,'SMAP_AM','yrLst',2015,'rootDB',rootDB);
[ySMAP2,~,~,t2]=readDB_Global(dataName,'SMAP_AM','yrLst',2016:2017,'rootDB',rootDB);


%% load data
nCase=length(outNameLst);
sigMat=cell(nCase,2);
statMat=cell(nCase,1);
for k=1:nCase
    outName=outNameLst{k};
    %% read sigmaX
    [yLSTM1,ySigma1]=readRnnPred_sigma(outName,dataName,epoch,[2015,2015],...
        'rootOut',kPath.OutSigma_L3_NA,'rootDB',rootDB);
    [yLSTM2,ySigma2]=readRnnPred_sigma(outName,dataName,epoch,[2016,2017],...
        'rootOut',kPath.OutSigma_L3_NA,'rootDB',rootDB);
    statLSTM1=statCal(yLSTM1,ySMAP1);
    statLSTM2=statCal(yLSTM2,ySMAP2);
    sigX1=sqrt(exp(ySigma1))*ySMAP_stat(4);
    sigX2=sqrt(exp(ySigma2))*ySMAP_stat(4);
    sigMat{k,1}=mean(sigX2);
    statMat{k}=statLSTM2;
    
    %% read sigmaMC
    [yLSTM1_batch,sigma1_batch]=readRnnPred_sigma(outName,dataName,epoch,[2015,2015],...
        'rootOut',kPath.OutSigma_L3_NA,'rootDB',rootDB,'drBatch',100);
    [yLSTM2_batch,sigma2_batch]=readRnnPred_sigma(outName,dataName,epoch,[2016,2017],...
        'rootOut',kPath.OutSigma_L3_NA,'rootDB',rootDB,'drBatch',100);
    stat1_batch=statBatch(yLSTM1_batch);
    stat2_batch=statBatch(yLSTM2_batch);
    sigMC1=stat1_batch.std;
    sigMC2=stat1_batch.std;
    sigMat{k,2}=mean(sigMC2);
end

%% 121 plot
figure('Position',[1,1,1200,400]);
xLabelLst={'sigmaX','sigmaMC'};
statStr='ubrmse';
for k=1:nCase
    xx=[sigMat{k,1}',sigMat{k,2}'];
    yy=statMat{k}.(statStr);
    for kk=1:2
        subplot(2,nCase,nCase*(kk-1)+k)
        plot(xx(:,kk),yy,'*');hold on
        lsline
        rho=corr(xx(:,kk),yy);
        title(['corr=',num2str(rho,'%.2f')])
        xlabel(xLabelLst{kk})
        ylabel(statStr)
    end
end

%% box plot
plotBoxSMAP(sigMat,{'sigX','sigMC'},trainNameLst,'title',dataName);

statStr='ubrmse';
statPlotMat=cell(nCase,1);
for k=1:nCase
    statPlotMat{k}=statMat{k}.(statStr);
end
plotBoxSMAP(statPlotMat,{'test'},trainNameLst,'title',dataName,'yRange',[0,0.1]);

