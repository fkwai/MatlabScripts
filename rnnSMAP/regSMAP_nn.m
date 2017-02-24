function [yNNnorm,net] = regSMAP_nn(xDataNorm,yDataNorm,varargin)
% regress using neural network to predict SMAP
% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';
% varargin{1}=b; -> if b is given, directly do forward. 
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);

%% predefine
nTrain=2209;
[nt,nGrid,nField]=size(xDataNorm);

net=[];
if ~isempty(varargin)
    net=varargin{1};
end

%% prepare data
if isempty(net)
    indTrain=1:nTrain;
    xTrainMat=xDataNorm(indTrain,:,:);
    yTrainMat=yDataNorm(indTrain,:);
    xTrainVec=reshape(xTrainMat,[nTrain*nGrid,nField]);
    yTrainVec=reshape(yTrainMat,[nTrain*nGrid,1]);
    tempVec=[xTrainVec,yTrainVec];
    ivTrain=find(isnan(sum(tempVec,2)));
    xTrain=xTrainVec;xTrain(ivTrain,:)=[];
    yTrain=yTrainVec;yTrain(ivTrain)=[];
    
    hiddensize = 100;
    net = fitnet(hiddensize);
    net.divideParam.trainRatio=1;
    disp('NN training')
    [net,tr] = train(net,xTrain',yTrain');
end


%% test NN
xTestVec=reshape(xDataNorm,[nt*nGrid,nField]);
yTestVec = net(xTestVec');
yNNnorm=reshape(yTestVec',[nt,nGrid]);


end

