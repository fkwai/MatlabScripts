
global kPath
rootOut=kPath.OutUncer_L3;
rootDB=kPath.DBSMAP_L3;
dataName='CONUSv4f1';
outName='CONUSv4f1_LSOIL';

%% read option
opt = readRnnOpt( outName,rootOut );
varLst=readVarLst([rootDB,'Variable',filesep,opt.var,'.csv']);
epoch=opt.nEpoch;

%% read predictions
[dataPred,dataSig]=readRnnPred_Uncer(outName,dataName,epoch,2,...
    'rootOut',rootOut,'rootDB',rootDB);
[dataPredB,dataSigB]=readRnnPred_Uncer(outName,dataName,epoch,2,...
    'rootOut',rootOut,'rootDB',rootDB,'drBatch',1000);
 [xData,xStat,xDataNorm] = readDB_SMAP(dataName,'SMAP',rootDB);
 dataSMAP=xData(367:732,:);
crdFile=[rootDB,filesep,dataName,filesep,'crd.csv'];
crd=csvread(crdFile);

%%
sig=sqrt(exp(mean(dataSigB,3)))*xStat(4)^2;
[gridSig,xx,yy] = data2grid3d(sig',crd(:,2),crd(:,1));
 [f,cmap]=showMap(mean(gridSig,3),yy,xx,'colorRange',[0,0.01],'strTitle','sigma');
 
statB = statBatch(dataPredB);
stdMC=statB.std;
[gridStd,xx,yy] = data2grid3d(stdMC',crd(:,2),crd(:,1));
 [f,cmap]=showMap(mean(gridStd,3),yy,xx,'colorRange',[0,0.08],'strTitle','MC std');


stat=statCal(dataPred,dataSMAP);
statStr='rsq';
figure('Position',[1,1,1200,400])
subplot(1,3,1)
plot(mean(stdMC,1),stat.(statStr),'b*');
lsline
rho=corr(mean(stdMC,1)',stat.(statStr));
title(['corr=',num2str(rho,'%.2f')])
xlabel('MC std')
ylabel(['SMAP ',statStr])

subplot(1,3,2)
plot(mean(sig,1),stat.(statStr),'r*');
lsline
rho=corr(mean(sig,1)',stat.(statStr));
title(['corr=',num2str(rho,'%.2f')])
xlabel('sigma')
ylabel(['SMAP ',statStr])

subplot(1,3,3)
unc=sqrt(sig.^2+stdMC.^2);
plot(mean(unc,1),stat.(statStr),'k*');
lsline
rho=corr(mean(unc,1)',stat.(statStr));
title(['corr=',num2str(rho,'%.2f')])
xlabel('Uncertainty')
ylabel(['SMAP ',statStr])



plot(mean(unc1,1),mean(unc2,1),'k*')
lsline
rho=corr(mean(unc1,1)',mean(unc2,1)');
title(['corr=',num2str(rho,'%.2f')])
xlabel('MC std')
ylabel('log sigma square')



plot(mean(unc1,1),mean(unc2,1),'b*')
corr(mean(unc1,1)',mean(unc2,1)')



file1='/mnt/sdb1/rnnSMAP/output_uncertainty/CONUSv4f1_LSOIL/test_CONUSv4f1_t2_epoch500.csv';
file2='/mnt/sdb1/rnnSMAP/output_uncertainty/CONUSv4f1_LSOIL/testSigma_CONUSv4f1_t2_epoch500.csv';
d1=csvread(file1);
d2=csvread(file2);


