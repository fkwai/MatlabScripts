function [dataTrain,dataTest]= readRnnPred( outFolder,trainName,testName,iter)
% read prediction from testRnnSMAP.lua into a data.mat

% % example
% outFolder='Y:\Kuai\rnnSMAP\output\PA';
% trainName='PA';
% testName='PA';
% iter=2000;

testFolder=[outFolder,'\out_',trainName,'_',testName,'_',num2str(iter),'\'];

trainFile=dir([testFolder,'*_train.csv']);
testFile=dir([testFolder,'*_test.csv']);

dataTrain=[];
dataTest=[];
ind=0;
for i=1:length(trainFile)
    % verify file order
    indtemp=str2num(trainFile(i).name(1:6));
    if indtemp<ind
        error('file not in order');
    end
    ind=indtemp;
    M=csvread([testFolder,trainFile(i).name]);
    dataTrain=[dataTrain,M];
end

ind=0
for i=1:length(testFile)
    % verify file order
    indtemp=str2num(testFile(i).name(1:6));
    if indtemp<ind
        error('file not in order');
    end
    ind=indtemp;
    M=csvread([testFolder,testFile(i).name]);
    dataTest=[dataTest,M];
end



end

