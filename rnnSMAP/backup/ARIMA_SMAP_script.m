%% pre-setting
%trainFolder='Y:\Kuai\rnnSMAP\output\NA_division\';
%trainFolder='Y:\Kuai\rnnSMAP\output\NA_NDVI\';
trainFolder='Y:\Kuai\rnnSMAP\output\NA_landcover\';

trainNameLst={'indUS'};

dataFolder='Y:\Kuai\rnnSMAP\Database\';
xField={'soilM','Evap','Rainf','Tair','Wind','PSurf'};
xField_const={'DEM','Slope','Sand','Silt','Clay'};
yField='SMPq';
nt=4160;
nTrain=2209; 

%% read data and do ARIMA grid by grid
for k=1:length(trainNameLst)
    k
    tic
    trainName=trainNameLst{k};
    [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(trainFolder,trainName);
    yARIMANorm=zeros(size(yDataNorm))*nan;
    %kk=randi(size(yDataNorm,2))
    for kk=1:size(yDataNorm,2)        
        kk        
        Y=yDataNorm(:,kk);
        X=permute(xDataNorm(:,kk,:),[1,3,2]);
        p=3;
        d=0;
        q=3;
        model = arima(p,d,q);
        nInt=max(p,d+1);
        
        yTrain=Y(nTrain:nt);
        xTrain=X(nTrain:nt,:);
        try
            model = estimate(model,yTrain(nInt+1:end),'X',xTrain,'Constant',0);
            yp = forecast(model,nt-nInt,'X0',X(1:nInt,:),'XF',X(nInt+1:end,:));
        catch
            disp(['All nan ',num2str(kk)])
            yp=zeros(nt-nInt,1)*nan;
        end
        % plot(1:nt-nInt,y1,'or');hold on
        % plot(1:nt-nInt,yp,'b--');hold off
        yARIMANorm(nInt+1:end,kk)=yp;        
    end
    yARIMA=(yARIMANorm+1).*(yStat(2)-yStat(1))./2+yStat(1);

    saveName=[trainFolder,'outARIMA_',trainName,'.mat'];
    trainFile=[trainFolder,trainName,'.csv'];
    trainInd=csvread(trainFile);
    save(saveName,'yARIMA','trainInd');
    toc
end