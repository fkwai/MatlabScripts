
outName='CONUSs4f1';
trainName='CONUSs4f1';
testName='CONUSs4f1';

outNameSF='CONUSs4f1_SFy1';
trainNameSF='CONUSs4f1_SFy1';
testNameSF='CONUSs4f1_SFy1';

epoch=500

[outTrain,outTest,covMethod]=testRnnSMAP_readData(outName,trainName,testName,epoch);
[outTrainSF,outTestSF,covMethodSF]=testRnnSMAP_readData(outNameSF,trainNameSF,testNameSF,epoch);

y=outTest.ySMAP;
ySF=outTestSF.ySMAP;
x=outTest.yLSTM;
xSF=outTestSF.yLSTM;
stat=statCal(x,y);
statSF=statCal(xSF,y);

statName='nash';
plot(stat.(statName),statSF.(statName),'*');hold on
xlim([0,1])
ylim([0,1])
plot121Line;hold off


for i=1:4
    subplot(2,2,i)
    k=randi([1,412])
    plot(y(:,k),x(:,k),'b*');hold on
    plot(y(:,k),xSF(:,k),'ro');hold on
    axis square
    plot121Line;hold off
end


%%
[p,pStat] = readDatabaseSMAP(trainName,'ARAIN');
[pSF,pStatSF] = readDatabaseSMAP(trainNameSF,'ARAIN');
t=1:732;
k=20;
plot(t,p(:,k),'b-*');hold on
plot(t,pSF(:,k),'r-o');hold on

