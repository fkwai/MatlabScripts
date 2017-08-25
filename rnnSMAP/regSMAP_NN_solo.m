function [yNNpbp,netLst] = regSMAP_NN_solo(xData,yData,varargin)
% regress using neural network to predict SMAP

% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);

%% pre steps
[nt,ngrid,nField]=size(xData);
netLst=cell(ngrid,1);
doTrain=1;
if ~isempty(varargin)
    netLst=varargin{1};
    doTrain=0;
end

yNNpbp=zeros(size(yData))*nan;
for k=1:ngrid
    %% flatten dataset
    xMat=permute(xData(:,k,:),[1,3,2]);
    yMat=yData(:,k);
    
    %% regress and forward
    if doTrain
        hiddensize = 30;
        net = fitnet(hiddensize);
        net.performParam.regularization = 0.002;
        [net,tr] = train(net,xMat',yMat');
        netLst{k}=net;
    end
    net=netLst{k};
    yfit = net(xMat');
    yNNpbp(:,k)=yfit';
end


end

