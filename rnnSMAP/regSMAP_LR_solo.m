function [yLRnorm] = regSMAP_LR_solo( xDataNorm,yDataNorm,nTrain)
% regress using LR to predict SMAP. Solo on each grid. 
% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName,2209);

%% pre steps
[nt,nGrid,nField]=size(xDataNorm);
indTrain=1:nTrain;

%% regress and forward
yLRnorm=zeros(size(yDataNorm))*nan;
for k=1:nGrid
    xTrainVec=permute(xDataNorm(indTrain,k,:),[1,3,2]);
    yTrainVec=yDataNorm(indTrain,k);
    tempMat=[xTrainVec,yTrainVec];
    ind=find(isnan(sum(tempMat,2)));
    xTrain=xTrainVec;xTrain(ind,:)=[];
    yTrain=yTrainVec;yTrain(ind)=[];
    %xTrain=[ones(size(xTrain,1),1),xTrain];
    if ~isempty(xTrain)
        [yfitTemp,R2Temp,bTemp]=regress_kuai(yTrain,xTrain);     
        R2Temp
        xTest=permute(xDataNorm(:,k,:),[1,3,2]);
        yTest=yDataNorm(:,k);
        %xTest=[ones(size(xTest,1),1),xTest];
        [yfit,Rsq,bb]=regress_kuai(yTest,xTest,bTemp);
        yLRnorm(:,k)=yfit;
    end    
end
%yLR=(yLRnorm+1).*(yStat(2)-yStat(1))./2+yStat(1);

end

