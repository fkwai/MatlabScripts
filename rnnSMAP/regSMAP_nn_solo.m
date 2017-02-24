function [yNNnorm] = regSMAP_nn_solo(xDataNorm,yDataNorm)
% regress using neural network to predict SMAP

% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);

%% predefine
nTrain=2209;
[nt,nGrid,nField]=size(xDataNorm);
indTrain=1:nTrain;

%% regress and forward
yNNnorm=zeros(size(yDataNorm))*nan;
for k=1:nGrid
    xTrainVec=permute(xDataNorm(indTrain,k,:),[1,3,2]);
    yTrainVec=yDataNorm(indTrain,k);
    tempMat=[xTrainVec,yTrainVec];
    ind=find(isnan(sum(tempMat,2)));
    xTrain=xTrainVec;xTrain(ind,:)=[];
    yTrain=yTrainVec;yTrain(ind)=[];
    xTestVec=permute(xDataNorm(:,k,:),[1,3,2]);

    if ~isempty(yTrain)
        % train NN
        hiddensize = 10;
        net = fitnet(hiddensize);
        net.divideParam.trainRatio=1;
        [net,tr] = train(net,xTrain',yTrain');        
        % test
        yTestVec = net(xTestVec');
        yNNnorm(:,k)=yTestVec';
    end
end

end

