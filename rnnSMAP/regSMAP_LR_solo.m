function [yLRpbp,bLst,cLst] = regSMAP_LR_solo( xData,yData,varargin)
% regress using LR to predict SMAP. Solo on each grid. 
% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName,2209);

%% pre steps
[nt,ngrid,nField]=size(xData);
bLst=zeros(nField,ngrid);
doTrain=1;
if ~isempty(varargin)
    bLst=varargin{1};
    cLst=varargin{2};
    doTrain=0;
end

yLRpbp=zeros(size(yData))*nan;
for k=1:ngrid
    %% flatten dataset
    xMat=permute(xData(:,k,:),[1,3,2]);
    yMat=yData(:,k);
 
    %% regress and forward
    if doTrain
        tempMat=[xMat,yMat];
        ind=find(~isnan(sum(tempMat,2)));
        xMatFit=xMat(ind,:);
        yMatFit=yMat(ind);   
        [b,FitInfo] = lasso(xMatFit,yMatFit,'Lambda',0.02);
        c=FitInfo.Intercept;

        %[yfit,R2Temp,b]=regress_kuai(yMatFit,xMatFit);
        bLst(:,k)=b;
        cLst(:,k)=c;
    end
    b=bLst(:,k);
    c=cLst(:,k);
    yfit=xMat*b+c;
    %[yfit,R2Temp,b]=regress_kuai(yMat,xMat,b);
    yLRpbp(:,k)=yfit;    
end

end

