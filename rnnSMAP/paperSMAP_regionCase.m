
global kPath
outName1='regionCase1';
outName2='regionCase1_noModel';
trainName='regionACDs2';
testName='regionBs2';
epoch=500;
[outTrain1,outTest1,covMethod1]=testRnnSMAP_readData(outName1,trainName,testName,epoch);
[outTrain2,outTest2,covMethod2]=testRnnSMAP_readData(outName2,trainName,testName,epoch);


stat1=statCal(outTest1.yLSTM,outTest1.ySMAP);
stat2=statCal(outTest2.yLSTM,outTest2.ySMAP);

statName='bias';
plotData=[stat1.(statName),stat2.(statName)];
boxplot(plotData,'Labels',{'With Model','No Model'});

