function [yLRnorm,b]=regSMAP_LR(xDataNorm,yDataNorm,varargin)
% regress using LR to predict SMAP
% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';
% varargin{1}=b; -> if b is given, directly do forward. 
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);

%% predefine
nTrain=2209;
[nt,nGrid,nField]=size(xDataNorm);

b=[];
if ~isempty(varargin)
    b=varargin{1};
end

%% linear regression
if isempty(b)
    indTrain=1:nTrain;
    xTrainMat=xDataNorm(indTrain,:,:);
    yTrainMat=yDataNorm(indTrain,:);
    xMat=reshape(xTrainMat,[nTrain*nGrid,nField]);
    yMat=reshape(yTrainMat,[nTrain*nGrid,1]);
    tempMat=[xMat,yMat];
    ind=find(isnan(sum(tempMat,2)));
    xMatFit=xMat;xMatFit(ind,:)=[];
    yMatFit=yMat;yMatFit(ind)=[];
    xMatFit=[ones(size(xMatFit,1),1),xMatFit];
    [yfitTemp,R2Temp,b]=regress_kuai(yMatFit,xMatFit);
end

%% forward
xMatTest=reshape(xDataNorm,[nt*nGrid,nField]);
xMatTest=[ones(size(xMatTest,1),1),xMatTest];
yMatTest=reshape(yDataNorm,[nt*nGrid,1]);
[yfit,Rsq,bb]=regress_kuai(yMatTest,xMatTest,b);
yLRnorm=reshape(yfit,[nt,nGrid]);
%yLR=(yLRnorm+1).*(yStat(2)-yStat(1))./2+yStat(1);

end

