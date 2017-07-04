global kPath
outFolder=[kPath.OutSMAP_L3,'CONUSs16f1',kPath.s];
trainName='CONUSs16f1';
testName=trainName;
iter=100;

tTrain=1:366;
tTest=367:732;
[xOut,yOut,xStat,yStat] = readDatabaseSMAP2( testName );
ySMAP_train=yOut(tTrain,:);
ySMAP_test=yOut(tTest,:);
meanSMAP=yStat(3);
stdSMAP=yStat(4);

[dataTrain,dataTest]=readRnnPred(outFolder,trainName,testName,iter);
yLSTM_train=(dataTrain).*stdSMAP+meanSMAP;
yLSTM_test=(dataTest).*stdSMAP+meanSMAP;
k=6
y=ySMAP_train(:,k);
x=yLSTM_train(:,k);

figure
plot(tTrain,ySMAP_train(:,k),'-*b');hold on
plot(tTrain,yLSTM_train(:,k),'-*r');hold on
plot(tTest,ySMAP_test(:,k),'-*b');hold on
plot(tTest,yLSTM_test(:,k),'-*r');hold on