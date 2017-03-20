
outFolder='E:\Kuai\rnnSMAP\output\test\';
trainName='CONUS_sub16';
testName='CONUS_sub16';
epoch=500;
testRnnSMAP_plot(outFolder,trainName,testName,epoch)

 %% plot map
shapefile='Y:\Maps\USA.shp';
stat='nash';% or rmse, rsq, bias
colorRange=[-0.8,0.8];
opt=2; %0->all; 1->train; 2->test
testRnnSMAP_map(outFolder,trainName,testName,epoch,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);

%%
[outTrain,outTest,covMethod]=testRnnSMAP_readData(outFolder,trainName,testName,epoch);

out=outTest;
statLSTM=statCal(out.yLSTM,out.ySMAP);
statGLDAS=statCal(out.yGLDAS,out.ySMAP);
for k=1:length(covMethod)
    mStr=covMethod{k};
    yTemp=out.(['y',mStr]);
    statCov(k)=statCal(yTemp,out.ySMAP);
end


k=50;
t=1:244;
plot(t,out.ySMAP(:,k),'ro');hold on
plot(t,out.yLSTM(:,k),'-b');hold on
plot(t,out.yGLDAS(:,k),'-k');hold on
plot(t,out.yNN(:,k),'-g');hold on
hold off

%%
runfile=[outFolder,'\runFile.csv'];
err=csvread(runfile);
plot(err,'b-');