function [dataOut]= readRnnPred(outName,dataName,epoch,timeOpt,varargin)
% read prediction from testRnnSMAP.lua into a data.mat
% varargin{1} - root outFolder,default to be kPath.outSMAP_L3

% % example
% outFolder='Y:\Kuai\rnnSMAP\output\PA';
% trainName='PA';
% testName='PA';
% iter=2000;

global kPath
if isempty(varargin)
    rootOut=kPath.OutSMAP_L3;
else
    rootOut=varargin{1};
end

dataFile=['test_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'.csv'];
dataOut=csvread([rootOut,outName,kPath.s,dataFile]);


end

