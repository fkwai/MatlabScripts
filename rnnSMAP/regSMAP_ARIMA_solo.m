function yARIMANorm = regSMAP_ARIMA_solo(xDataNorm,yDataNorm)
% regress using ARIMA to predict SMAP (regress grid one by one)
% outFolder='Y:\Kuai\rnnSMAP\output\USsub_anorm\';
% trainName='indUSsub4';

%% predefine
nTrain=2209;
nt=4160;

% %% read data
% disp('read Input Data')
% tic
% [xDataNorm,yDataNorm,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
% toc

%% regression
disp('regress using ARIMA')
tic
yARIMANorm=zeros(size(yDataNorm))*nan;
for kk=1:size(yDataNorm,2)
    kk
    Y=yDataNorm(:,kk);
    Xraw=permute(xDataNorm(:,kk,:),[1,3,2]);
    [nt,nx]=size(Xraw);
    p=3;
    d=0;
    q=0;
    model = arima(p,d,q);
    %nInt=max(p,d+1);
    nInt = 2;
    X=zeros(nt,nx*nInt+1);
    X(:,1:nx)=Xraw;
    for i=1:nInt
        X(i+1:end,nx*i+1:nx*(i+1))=Xraw(1:end-i,:);
    end
    
    yTrain=Y(1:nTrain);
    xTrain=X(1:nTrain,:);
    try
        %model = estimate(model,yTrain(nInt+1:end),'X',xTrain,'Constant',0);
        model = estimate(model,yTrain(nInt+1:end),'X',xTrain(nInt+1:end,:),'Constant',0);
        yp = forecast(model,nt-nInt,'X0',X(1:nInt,:),'XF',X(nInt+1:end,:));
    catch
        disp(['All nan ',num2str(kk)])
        yp=zeros(nt-nInt,1)*nan;
    end
    % plot(1:nt-nInt,y1,'or');hold on
    % plot(1:nt-nInt,yp,'b--');hold off
    yARIMANorm(nInt+1:end,kk)=yp;
end
%yARIMA=(yARIMANorm+1).*(yStat(2)-yStat(1))./2+yStat(1);
toc

end

