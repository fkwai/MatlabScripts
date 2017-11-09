function [dataTrain,dataTest]= readRnnPred(outName,trainName,testName,epoch,timeOpt)
% read prediction from testRnnSMAP.lua into a data.mat

% % example
% outFolder='Y:\Kuai\rnnSMAP\output\PA';
% trainName='PA';
% testName='PA';
% iter=2000;

global kPath

if timeOpt==1
    tTrain='t1';
    tTest='t2';
elseif timeOpt==2
    tTrain='t3';
    tTest='t3';
elseif timeOpt==3
    tTrain='t1';
    tTest='t1';
end


trainFile=['test_',trainName,'_',tTrain,'_epoch',num2str(epoch),'.csv'];
testFile=['test_',testName,'_',tTest,'_epoch',num2str(epoch),'.csv'];

dataTrain=csvread([kPath.OutSMAP_L3,outName,kPath.s,trainFile]);
dataTest=csvread([kPath.OutSMAP_L3,outName,kPath.s,testFile]);

end

