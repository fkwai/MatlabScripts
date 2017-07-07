global kPath
outFolder=[kPath.OutSMAP_L3,'CONUSs4f1_CONUSs4f3',kPath.s];
trainName='CONUSs4f1';
testName='CONUSs4f3';
epoch=500;
testRnnSMAP_plot(outFolder,trainName,testName,epoch,'testTime',0)

outFolder=[kPath.OutSMAP_L3,'CONUSs4f1',kPath.s];
trainName='CONUSs4f1';
testName='CONUSs4f1';
shapefile=[];
stat='rmse';% or rmse, rsq, bias
colorRange=[0,0.1];
opt=1; %0->all; 1->train; 2->test
epoch=500;
testRnnSMAP_map(outFolder,trainName,testName,epoch,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);

%
% tTrain=1:366;
% tTest=367:732;
% [xOut,yOut,xStat,yStat] = readDatabaseSMAP2( testName );
% ySMAP_train=yOut(tTrain,:);
% ySMAP_test=yOut(tTest,:);

tTrain=1:732;
tTest=1:732;
[xTrain,yTrain,xStatTrain,yStat]=readDatabaseSMAP2(trainName);
[xTest,yTest,xStatTest,yStat]=readDatabaseSMAP2(testName);
ySMAP_train=yTrain;
ySMAP_test=yTest;
meanSMAP=yStat(3);
stdSMAP=yStat(4);

[dataTrain,dataTest]=readRnnPred(outFolder,trainName,testName,epoch);
yLSTM_train=(dataTrain).*stdSMAP+meanSMAP;
yLSTM_test=(dataTest).*stdSMAP+meanSMAP;

statTrain=statCal(yLSTM_train,ySMAP_train);
statTest=statCal(yLSTM_test,ySMAP_test);


itPath
figure
plot(tTrain,ySMAP_train(:,k),'-*b');hold on
plot(tTrain,yLSTM_train(:,k),'-*r');hold on
figure
plot(tTest,ySMAP_test(:,k),'-*b');hold on
plot(tTest,yLSTM_test(:,k),'-*r');hold on

