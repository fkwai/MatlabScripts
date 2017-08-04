function [yLR,b,inte]=regSMAP_LR(xData,yData,varargin)
% regress using LR to predict SMAP
% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';
% varargin{1}=b; -> if b is given, directly do forward. 
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);

%% predefine
[nt,nGrid,nField]=size(xData);
b=[];
doTrain=1;
if ~isempty(varargin)
    doTrain=0;
    b=varargin{1};
    inte=varargin{2};
end

%% flatten dataset
xMat=reshape(xData,[nt*nGrid,nField]);
yMat=reshape(yData,[nt*nGrid,1]);

%% train and regression
if doTrain==1
    tempMat=[xMat,yMat];
    ind=find(~isnan(sum(tempMat,2)));
    xMatFit=xMat(ind,:);
    yMatFit=yMat(ind,:);    
    [b,FitInfo] = lasso(xMatFit,yMatFit,'Lambda',0.002);
    inte=FitInfo.Intercept;
    %[yfit,R2Temp,b]=regress_kuai(yMatFit,xMatFit);
end

%[yfit,R2Temp,b2]=regress_kuai(yMat,xMat,b);
yfit=xMat*b+inte;

yLR=reshape(yfit,[nt,nGrid]);

end

