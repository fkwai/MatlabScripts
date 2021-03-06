function [yNN,net] = regSMAP_NN(xData,yData,varargin)
% regress using neural network to predict SMAP
% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';
% varargin{1}=b; -> if b is given, directly do forward. 
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);

%% predefine
[nt,ngrid,nField]=size(xData);

net=[];
doTrain=1;
if ~isempty(varargin)
    net=varargin{1};
    doTrain=0;
end

%% flatten dataset
xMat=reshape(xData,[nt*ngrid,nField]);
yMat=reshape(yData,[nt*ngrid,1]);

%% train and regression
if doTrain==1
    hiddensize=100;
    net = fitnet(hiddensize);
%     net.divideParam.trainRatio=1;    
%     net.divideParam.valRatio=0;
%     net.divideParam.testRatio=0;
    disp('NN training')
	net.trainParam.epochs=500;
	net.trainParam.showWindow = true;
	net.trainParam.showCommandLine = true; 
    net.performParam.regularization = 0.002;
    [net,tr] = train(net,xMat',yMat','showResources','yes');
end

yfit = net(xMat');

yNN=reshape(yfit,[nt,ngrid]);

end

