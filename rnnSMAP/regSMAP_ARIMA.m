function [yARIMA,errInd1,errInd2] = regSMAP_ARIMA(xDataNorm,yDataNorm)
% regress using ARIMA to predict SMAP
% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';

%% predefine
nTrain=2209;
nt=4160;
saveiter=1000;

% %% read data
% disp('read Input Data')
% tic
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
% toc

%% pre steps
trainFile=[outFolder,trainName,'.csv'];
trainInd=csvread(trainFile);
niter=length(trainInd)*100; % 100 epoch
yTrainMat=yDataNorm(1:nTrain,:);
indValid=find(sum(~isnan(yTrainMat),1));
nValid=length(indValid);


%% regression
disp('regress using ARIMA')

yARIMANorm=zeros(size(yDataNorm))*nan;
p=3;
d=0;
q=3;
nInt=max(p,d+1);
options = optimoptions(@fmincon,'MaxIter',1);

errInd1=[];
errInd2=[];
tic
for iter=1:niter    
    iter
    kk=indValid(randi([1,nValid]));
    Y=yDataNorm(:,kk);
    X=permute(xDataNorm(:,kk,:),[1,3,2]);
    yTrain=Y(1:nTrain);
    xTrain=X(1:nTrain,:);
    
    % estimate
    if iter==1        
        model = arima(p,d,q);
        model = estimate(model,yTrain(nInt+1:end),'X',xTrain,'Constant',0,'Options',options,'Display','off');
%         try
%             model = estimate(model,yTrain(nInt+1:end),'X',xTrain,'Constant',0,'Options',options,'Display','off');
%         catch
%             disp(['All nan ',num2str(kk)])
%         end
    else
        AR0=model.AR;
        Beta0=model.Beta;
        Constant0=model.Constant;
        MA0=model.MA;
        V0=model.Variance;
        SAR0=model.SAR;
        SMA0=model.SMA;
%         model = estimate(model,yTrain(nInt+1:end),'X',xTrain,'Options',options,'Display','off',...
%                 'AR0',AR0,'MA0',MA0,'SAR0',SAR0,'SMA0',SMA0,'Beta0',Beta0,'Constant0',Constant0,'V0',V0);
        try
            modelNew = arima(p,d,q);
            modelNew = estimate(modelNew,yTrain(nInt+1:end),'X',xTrain,'Options',options,'Display','off',...
                'AR0',AR0,'MA0',MA0,'SAR0',SAR0,'SMA0',SMA0,'Beta0',Beta0,'Constant0',Constant0,'V0',V0);
            model=modelNew;
        catch
            disp(['Something wrong ',num2str(kk)])
            errInd1=[errInd1,kk];
        end
    end
    
    % simulate
    if rem(iter,saveiter)==0
        for ind=1:length(trainInd)
            Xp=permute(xDataNorm(:,ind,:),[1,3,2]);
            try
                yp = forecast(model,nt-nInt,'X0',Xp(1:nInt,:),'XF',Xp(nInt+1:end,:));
                yARIMANorm(nInt+1:end,ind)=yp;
            catch
                errInd2=[errInd2,ind];
            end
        end
        yARIMA=(yARIMANorm+1).*(yStat(2)-yStat(1))./2+yStat(1);
        saveName=[outFolder,'\outARIMA_',trainName,'_',num2str(iter),'.mat'];
        save(saveName,'yARIMA','trainInd');
        toc
    end
end
errInd1=unique(errInd1);
errInd2=unique(errInd2);


end

