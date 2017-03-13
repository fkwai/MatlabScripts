%% spatial
outFolder='E:\Kuai\rnnSMAP\output\CONUS_test\';
trainName='CONUS_sub16';
testName='CONUS_sub4';
epoch=1000;

[ySMAP,yLSTM,yGLDAS,yCov,covMethod]=testRnnSMAP_readData(outFolder,trainName,testName,epoch);

statLSTM=statCal(yLSTM,ySMAP);
statGLDAS=statCal(yGLDAS,ySMAP);
clear statCov
for k=1:length(covMethod)
    mStr=covMethod{k};
    yTemp=yCov{k};
    statCov(k)=statCal(yTemp,ySMAP);
end
figfolder=['E:\Kuai\rnnSMAP\paper\'];
if ~exist(figfolder,'dir')
    mkdir(figfolder)
end
statBoxPlot( statLSTM,statGLDAS,statCov,covMethod,figfolder,'_extro' )

%% time
outFolder='E:\Kuai\rnnSMAP\output\CONUS_test\';
trainName='CONUS_sub16';
testName='CONUS_sub16';
epoch=1000;

[ySMAP,yLSTM,yGLDAS,yCov,covMethod]=testRnnSMAP_readData(outFolder,trainName,testName,epoch);

ntrain=276;
nt=520;
t2=ntrain:nt;
statLSTM=statCal(yLSTM(t2,:),ySMAP(t2,:));
statGLDAS=statCal(yGLDAS(t2,:),ySMAP(t2,:));
clear statCov
for k=1:length(covMethod)
    mStr=covMethod{k};
    yTemp=yCov{k};
    statCov(k)=statCal(yTemp(t2,:),ySMAP(t2,:));
end
figfolder=['E:\Kuai\rnnSMAP\paper\'];
if ~exist(figfolder,'dir')
    mkdir(figfolder)
end
statBoxPlot( statLSTM,statGLDAS,statCov,covMethod,figfolder,'_time' )
