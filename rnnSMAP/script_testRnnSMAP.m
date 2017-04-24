%% plot bar 
outFolder='E:\Kuai\rnnSMAP\output\test\';
trainName='CONUS_sub16';
testName=trainName;
epoch=500;
testRnnSMAP_plot(outFolder,trainName,testName,epoch)

 %% plot map 
outFolder='E:\Kuai\rnnSMAP\output\test\';
trainName='CONUS_sub16';
testName=trainName;
epoch=500;
shapefile='Y:\Maps\USA.shp';
stat='nash';% or rmse, rsq, bias
colorRange=[-0.8,0.8];
opt=2; %0->all; 1->train; 2->test
testRnnSMAP_map(outFolder,trainName,testName,epoch,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);

%% one cell
outFolder='E:\Kuai\rnnSMAP\output\cell_IL\';
trainName='cell_IL';
epoch=200;
testName=trainName;
[outTrain,outTest,covMethod]=testRnnSMAP_readData(outFolder,trainName,testName,epoch);

out=outTest;
statLSTM=statCal(out.yLSTM,out.ySMAP);
statGLDAS=statCal(out.yGLDAS,out.ySMAP);
for k=1:length(covMethod)
    mStr=covMethod{k};
    yTemp=out.(['y',mStr]);
    statCov(k)=statCal(yTemp,out.ySMAP);
end
%statBoxPlot(statLSTM,statGLDAS,statCov,covMethod,[])

k=1;
subplot(2,1,1)
t=1:length(outTrain.ySMAP(:,k));
plot(t,outTrain.ySMAP(:,k),'ro');hold on
plot(t,outTrain.yLSTM(:,k),'-b');hold on
plot(t,outTrain.yGLDAS(:,k),'-k');hold on
plot(t,outTrain.yNN(:,k),'-g');hold off
subplot(2,1,2)
t=1:length(outTest.ySMAP(:,k));
plot(t,outTest.ySMAP(:,k),'ro');hold on
plot(t,outTest.yLSTM(:,k),'-b');hold on
plot(t,outTest.yGLDAS(:,k),'-k');hold on
plot(t,outTest.yNN(:,k),'-g');hold off

[xOut,yOut,xStat,yStat] = readDatabaseSMAP2( testName );
tTrain=1:154;
tTest=367:520;
xTrain=permute(xOut(tTrain,k,:),[1,3,2]);
xTest=permute(xOut(tTest,k,:),[1,3,2]);
yTrain=yOut(tTrain,k);
yTest=yOut(tTest,k);
dlmwrite([outFolder,'\xTrain.csv'],xTrain,'precision',8);
dlmwrite([outFolder,'\xTest.csv'],xTest,'precision',8);
dlmwrite([outFolder,'\yTrain.csv'],yTrain,'precision',8);
dlmwrite([outFolder,'\yTest.csv'],yTest,'precision',8);

dataFolder='E:\Kuai\rnnSMAP\Database\Daily\';
fileCrd=[dataFolder,testName,'\crd.csv'];
crd=csvread(fileCrd);



%%
runfile=[outFolder,'\runFile.csv'];
err=csvread(runfile);
plot(err(1:end),'b-');

%%
smap=csvread('E:\Kuai\rnnSMAP\Database\Daily\CONUS_sub4\SMAP.csv');
smapStat=csvread('E:\Kuai\rnnSMAP\Database\Daily\CONUS_sub4\SMAP_stat.csv');
lb=smapStat(1);
ub=smapStat(2);
(smap(2,369)-lb)/(ub-lb)*2-1
