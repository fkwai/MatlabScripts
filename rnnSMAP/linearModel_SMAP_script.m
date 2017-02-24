%% read data
% trainFolder='Y:\Kuai\rnnSMAP\output\NA_division\';
% trainNameLst={'div1';'div2';'div3';'div4';'div5';'div6';'div7';'div8';'div9';'div10'};
% testNameLst={'div1';'div2';'div3';'div4';'div5';'div6';'div7';'div8';'div9';'div10'};

trainFolder='Y:\Kuai\rnnSMAP\output\NA_NDVI\';
trainNameLst={'ndvi1';'ndvi2';'ndvi3';'ndvi4';'ndvi5';'ndvi6';'ndvi7'};
testNameLst={'ndvi1';'ndvi2';'ndvi3';'ndvi4';'ndvi5';'ndvi6';'ndvi7'};

dataFolder='Y:\Kuai\rnnSMAP\Database\';
xField={'soilM','Evap','Rainf','Tair','Wind','PSurf'};
xField_const={'DEM','Slope','Sand','Silt','Clay'};
yField='SMPq';
nt=4160;
nTrain=2209;

%% linear regression
for k=1:length(trainNameLst)
    k
    % train
    trainName=trainNameLst{k};
    [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(trainFolder,trainName);
    nGrid=size(yDataNorm,2);
    
    indTrain=nTrain:nt;
    xTrainMat=xDataNorm(indTrain,:,:);
    yTrainMat=yDataNorm(indTrain,:);
    
    xMat=reshape(xTrainMat,[length(indTrain)*nGrid,length(xField)+length(xField_const)]);
    yMat=reshape(yTrainMat,[length(indTrain)*nGrid,1]);
    tempMat=[xMat,yMat];
    ind=find(isnan(sum(tempMat,2)));
    xMatFit=xMat;xMatFit(ind,:)=[];
    yMatFit=yMat;yMatFit(ind)=[];
    xMatFit=[ones(size(xMatFit,1),1),xMatFit];
    [yfitTemp,R2Temp,bTemp]=regress_kuai(yMatFit,xMatFit);
    
    % test - default trainName==testName
    testName=testNameLst{k};
    if ~strcmp(trainName,testName)
        [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(trainFolder,testName);
        nGrid=size(yDataNorm,2);
    end
    xMatTest=reshape(xDataNorm,[nt*nGrid,length(xField)+length(xField_const)]);
    xMatTest=[ones(size(xMatTest,1),1),xMatTest];
    yMatTest=reshape(yDataNorm,[nt*nGrid,1]);
    [yfit,Rsq,bb]=regress_kuai(yMatTest,xMatTest,bTemp);
    yLRnorm=reshape(yfit,[nt,nGrid]);
    yLR=(yLRnorm+1).*(yStat(2)-yStat(1))./2+yStat(1);
    
    save([trainFolder,'\outLR_',trainName,'_',testName,'.mat'],'yLR')
end

%% linear regression one by one
trainFolder='Y:\Kuai\rnnSMAP\output\';
trainName='indUS';
[xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(trainFolder,trainName);
indTrain=nTrain:nt;
nGrid=size(yDataNorm,2);

yLRnorm=zeros(size(yDataNorm))*nan;
for k=1:nGrid
    xTrainMat=permute(xDataNorm(indTrain,k,:),[1,3,2]);
    yTrainMat=yDataNorm(indTrain,k);
    tempMat=[xTrainMat,yTrainMat];
    ind=find(isnan(sum(tempMat,2)));
    xMatFit=xTrainMat;xMatFit(ind,:)=[];
    yMatFit=yTrainMat;yMatFit(ind)=[];
    xMatFit=[ones(size(xMatFit,1),1),xMatFit];
    if ~isempty(yMatFit)
        [yfitTemp,R2Temp,bTemp]=regress_kuai(yMatFit,xMatFit);        
        xTestMat=permute(xDataNorm(:,k,:),[1,3,2]);
        yTestMat=yDataNorm(:,k);
        xTestMat=[ones(size(xTestMat,1),1),xTestMat];
        [yfit,Rsq,bb]=regress_kuai(yTestMat,xTestMat,bTemp);
    end
    yLRnorm(:,k)=yfit;
end
yLR=(yLRnorm+1).*(yStat(2)-yStat(1))./2+yStat(1);
saveName=[trainFolder,'outLR_',trainName,'.mat'];
trainFile=[trainFolder,trainName,'.csv'];
trainInd=csvread(trainFile);
save(saveName,'yLR','trainInd');

